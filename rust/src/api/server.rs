use anyhow::{ensure, Context, Result};
use prost::Message;
use prost_reflect::{DescriptorPool, DynamicMessage, SerializeOptions};
use rustls::pki_types::{pem::PemObject, CertificateDer};
use std::{
    sync::{Arc, OnceLock},
    time::Duration,
};

/// Send one protobuf request on a TLS-verified QUIC stream.
/// JSON is only used across the Dart/Rust bridge, never on the network.
pub fn server_request(
    address: String,
    server_name: String,
    ca_pem: String,
    request_json: String,
) -> Result<String> {
    static RUNTIME: OnceLock<tokio::runtime::Runtime> = OnceLock::new();
    let runtime = RUNTIME.get_or_init(|| tokio::runtime::Runtime::new().expect("Tokio runtime"));
    runtime.block_on(async {
        tokio::time::timeout(
            Duration::from_secs(12),
            exchange(address, server_name, ca_pem, request_json),
        )
        .await
        .context("Saviour server timed out")?
    })
}

async fn exchange(
    address: String,
    server_name: String,
    ca_pem: String,
    request_json: String,
) -> Result<String> {
    let pool = DescriptorPool::decode(include_bytes!("../../proto/saviour.bin").as_ref())?;
    let request = DynamicMessage::deserialize(
        pool.get_message_by_name("saviour.v1.Request").unwrap(),
        &mut serde_json::Deserializer::from_str(&request_json),
    )?;
    let bytes = request.encode_to_vec();
    ensure!(bytes.len() <= 65536, "Request exceeds 64 KiB");
    let mut roots = rustls::RootCertStore::empty();
    for cert in CertificateDer::pem_slice_iter(ca_pem.as_bytes()) {
        roots.add(cert?)?;
    }
    ensure!(
        !roots.is_empty(),
        "Configure SAVIOUR_CA_BASE64 with the server's trusted CA certificate"
    );
    let mut tls = rustls::ClientConfig::builder_with_provider(Arc::new(
        rustls::crypto::ring::default_provider(),
    ))
    .with_safe_default_protocol_versions()?
    .with_root_certificates(roots)
    .with_no_client_auth();
    // s2n-quic's default ALPN; the application framing is protobuf, not HTTP/3.
    tls.alpn_protocols = vec![b"h3".to_vec()];
    let remote = tokio::net::lookup_host(&address)
        .await?
        .next()
        .context("Server address did not resolve")?;
    let mut endpoint = quinn::Endpoint::client(
        if remote.is_ipv4() {
            "0.0.0.0:0"
        } else {
            "[::]:0"
        }
        .parse()?,
    )?;
    endpoint.set_default_client_config(quinn::ClientConfig::new(Arc::new(
        quinn::crypto::rustls::QuicClientConfig::try_from(tls)?,
    )));
    let connection = endpoint
        .connect(remote, &server_name)?
        .await
        .context("QUIC/TLS connection failed")?;
    let (mut send, mut recv) = connection.open_bi().await?;
    send.write_all(&(bytes.len() as u32).to_be_bytes()).await?;
    send.write_all(&bytes).await?;
    send.finish()?;
    let frame = recv.read_to_end(65540).await?;
    ensure!(frame.len() >= 4, "Missing response frame length");
    let length = u32::from_be_bytes(frame[..4].try_into()?) as usize;
    ensure!(
        length <= 65536 && length == frame.len() - 4,
        "Invalid response frame length"
    );
    let response = DynamicMessage::decode(
        pool.get_message_by_name("saviour.v1.Response").unwrap(),
        &frame[4..],
    )?;
    let mut output = Vec::new();
    response.serialize_with_options(
        &mut serde_json::Serializer::new(&mut output),
        &SerializeOptions::new().skip_default_fields(false),
    )?;
    connection.close(0u32.into(), b"done");
    Ok(String::from_utf8(output)?)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn optional_false_survives_protobuf_round_trip() {
        let pool =
            DescriptorPool::decode(include_bytes!("../../proto/saviour.bin").as_ref()).unwrap();
        let descriptor = pool.get_message_by_name("saviour.v1.Request").unwrap();
        let request = DynamicMessage::deserialize(
            descriptor.clone(),
            &mut serde_json::Deserializer::from_str(r#"{"protocolVersion":1,"operation":"PROFILE_UPDATE","profileUpdate":{"available":false}}"#),
        ).unwrap();
        let decoded =
            DynamicMessage::decode(descriptor, request.encode_to_vec().as_slice()).unwrap();
        let json = serde_json::to_value(decoded).unwrap();
        assert_eq!(json["profileUpdate"]["available"], false);
        assert_eq!(json["operation"], "PROFILE_UPDATE");
    }
}
