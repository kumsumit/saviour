# Saviour

Flutter app connected to the Rust `saviour_server` using protobuf over QUIC through Flutter Rust Bridge. The server does not expose HTTP/REST endpoints.

## Run locally

The server's PostgreSQL database and `.env` must already be configured. From this app directory:

```sh
python3 tool/run_local_server.py --server /Users/amitsharan/rustProject/saviour_server
```

This runs the server on UDP **8081**, creates a valid localhost development certificate in the ignored `.local-server/` directory, and writes ignored Flutter connection settings to `saviour.local.json`. It leaves any existing server on 8080 alone. Development certificates expire after 30 days; delete `.local-server/` and rerun the script to renew them.

In another terminal:

```sh
flutter run -d macos --dart-define-from-file=saviour.local.json
```

For the Android emulator, update the connection address first:

```sh
python3 tool/configure_server.py --ca .local-server/cert.pem --address 10.0.2.2:8081
flutter run --dart-define-from-file=saviour.local.json
```

For a physical device, use the server computer's LAN address with `--address HOST:8081`. Keep `--name localhost` for this development certificate; the TLS identity and destination address are configured separately. Allow UDP traffic through the host firewall.

For an existing deployment, use `tool/configure_server.py --ca PATH_TO_PUBLIC_CA.pem --address HOST:PORT --name CERTIFICATE_DNS_NAME`. Certificate verification is always enabled. Do not supply private keys. The original local server certificate was rejected by rustls as `CaUsedAsEndEntity`; the startup script supplies a server certificate with `CA:FALSE` without modifying the server repository.

## Integration

- OTP request/verification, including refreshed development OTP after resend.
- Dashboard, filtered blood requests, request creation/response, camps/reservations, notifications, and donor profile updates.
- Loading, empty and error states with refresh; mutations display server errors.
- Session tokens are kept in memory and cleared on sign-out. Restarting the app requires login.
- The backend has no endpoints for the older donation-history, inventory, health-insight, or rare-donor prototype screens; those screens are not server-backed.
- Browsers cannot access this raw QUIC protocol. Use a native Flutter target; web deployment requires a separate server gateway.

The canonical schema is copied into `rust/proto/saviour.proto`; its checked-in descriptor avoids requiring `protoc` during mobile builds. After changing the server schema:

```sh
cp /Users/amitsharan/rustProject/saviour_server/proto/saviour.proto rust/proto/
protoc --proto_path=rust/proto --include_imports --descriptor_set_out=rust/proto/saviour.bin rust/proto/saviour.proto
flutter_rust_bridge_codegen generate
```

Each call sends one bounded, length-prefixed protobuf frame on a QUIC bidirectional stream, with a 12-second timeout. The client uses s2n-quic's default `h3` TLS ALPN for compatibility; application traffic is protobuf, not HTTP/3. Responses are checked for protocol version, request ID, operation and status.

## Checks

```sh
flutter analyze
flutter test
cargo clippy --manifest-path rust/Cargo.toml --all-targets -- -D warnings
cargo run --manifest-path rust/Cargo.toml --example health -- 127.0.0.1:8081 localhost .local-server/cert.pem
flutter test integration_test/simple_test.dart -d macos --dart-define-from-file=saviour.local.json --dart-define=SAVIOUR_LIVE_TEST=true
```

The live test only checks health; it does not send OTPs or create donor/request data.
