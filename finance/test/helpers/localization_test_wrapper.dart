// Provides a minimal AssetLoader for tests that simply returns an empty
// map so that EasyLocalization resolves any key to itself without
// touching the real JSON asset bundles. This eliminates noisy missing
// key warnings in widget tests.
//
// Usage:
//   EasyLocalization(
//     supportedLocales: const [Locale('en')],
//     path: 'assets/translations',
//     fallbackLocale: const Locale('en'),
//     assetLoader: const FakeAssetLoader(),
//     child: YourWidgetUnderTest(),
//   );
//
// Note: Tests should still call `EasyLocalization.ensureInitialized()`
// before pumping widgets. They may also silence logs with
// `EasyLocalization.logger.enableBuildModes = [];` if desired.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';

/// Asset loader that returns an empty map for all locales.
/// EasyLocalization will then fallback to returning the key itself,
/// which is exactly what we want inside tests.
class FakeAssetLoader extends AssetLoader {
  const FakeAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String fullPath, Locale locale) async {
    return <String, dynamic>{};
  }
} 