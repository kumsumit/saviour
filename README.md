# Saviour

Saviour is a platform-native blood donation and emergency coordination app. It includes OTP sign-in, verified blood requests, nearby camps, donor availability, rare-donor coordination, eligibility tracking, donation history, inventory, notifications, and profile/security settings.

## Run locally

Start the companion API first:

```sh
cd ../saviour_server
dart pub get
dart run bin/server.dart
```

Then run Flutter:

```sh
flutter pub get
flutter run
```

The local OTP is `123456`. Android emulators connect to `10.0.2.2:8080`; other local targets use `127.0.0.1:8080`.

For a hosted API, pass its origin at build or run time:

```sh
flutter run --dart-define=SAVIOUR_API_URL=https://api.example.com
```

## Architecture

- `lib/platform_widgets/` owns native controls and navigation for Android, iOS, macOS, Windows, Linux, and web.
- `lib/features/` contains authentication and the blood-donation product flows.
- `lib/services/saviour_api.dart` is the typed boundary to the companion server.
- Riverpod provides platform selection and test overrides. `part` is used only by generated Riverpod output.
