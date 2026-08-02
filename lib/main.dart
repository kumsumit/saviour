import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart' show ProviderScope;
import 'package:saviour/features/login.dart';
import 'package:saviour/platform_widgets/platform_app.dart';

void main() {
  runApp(const ProviderScope(child: VitalReserveApp()));
}

class VitalReserveApp extends StatelessWidget {
  const VitalReserveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlatformApp(
      title: 'Saviour',
      seedColor: Color(0xFFB0102A),
      home: LoginScreen(),
    );
  }
}
