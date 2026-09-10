//! Read-only smoke check: cargo run --example health -- ADDRESS NAME CA_FILE
use rust_lib_saviour::api::server::server_request;
fn main() -> anyhow::Result<()> {
    let args: Vec<String> = std::env::args().collect();
    anyhow::ensure!(args.len() == 4, "Usage: health ADDRESS TLS_NAME CA_FILE");
    let response = server_request(
        args[1].clone(),
        args[2].clone(),
        std::fs::read_to_string(&args[3])?,
        r#"{"protocolVersion":1,"requestId":"smoke-health","operation":"HEALTH_LIVE","empty":{}}"#
            .into(),
    )?;
    let value: serde_json::Value = serde_json::from_str(&response)?;
    anyhow::ensure!(
        value["status"] == "OK" && value["health"]["status"] == "ok",
        "Health check failed: {value}"
    );
    println!(
        "QUIC/TLS health check passed: {}",
        value["health"]["service"]
    );
    Ok(())
}
