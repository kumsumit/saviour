import 'package:saviour/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show ProviderScope;
import 'package:saviour/features/auth/login.dart';
import 'package:saviour/platform_widgets/platform_app.dart';
import 'package:saviour/src/rust/frb_generated.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RustLib.init();
  runApp(const ProviderScope(child: VitalReserveApp()));
}

class VitalReserveApp extends StatelessWidget {
  const VitalReserveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlatformApp(
      title: 'Saviour',
      seedColor: SaviourPalette.seed,
      home: LoginScreen(),
    );
  }
}
