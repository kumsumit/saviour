import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saviour/features/login.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:saviour/providers/app_platform_provider.dart';

void main() {
  runApp(const ProviderScope(child: VitalReserveApp()));
}

class VitalReserveApp extends ConsumerWidget {
  const VitalReserveApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(appPlatformProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Saviour',
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB0102A)),
      ),
      builder: (context, child) => PlatformTheme(
        data: PlatformThemeData.forPlatform(
          platform: platform,
          brightness: Theme.of(context).brightness,
          seed: const Color(0xFFB0102A),
        ),
        child: child!,
      ),
      home: const LoginScreen(),
    );
  }
}
