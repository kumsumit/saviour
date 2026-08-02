// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_platform_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Current running platform.

@ProviderFor(appPlatform)
final appPlatformProvider = AppPlatformProvider._();

/// Current running platform.

final class AppPlatformProvider
    extends $FunctionalProvider<AppPlatform, AppPlatform, AppPlatform>
    with $Provider<AppPlatform> {
  /// Current running platform.
  AppPlatformProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appPlatformProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appPlatformHash();

  @$internal
  @override
  $ProviderElement<AppPlatform> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppPlatform create(Ref ref) {
    return appPlatform(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppPlatform value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppPlatform>(value),
    );
  }
}

String _$appPlatformHash() => r'0affba2edc008b7b8b460eb57dbc0a3015b03286';
