import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/home_theme.dart';

class RemoteConfigService {
  // Served via the data worker's /website/data/ proxy — same pattern as
  // master/products.json — so it's just a JSON file update on GitHub,
  // no separate deploy needed.
  static const _homeThemeUrl =
      'https://shopdekho.the-web.top/website/data/app-config/home-theme.json';

  static const _shopThemesUrl =
      'https://shopdekho.the-web.top/website/data/app-config/shop-themes.json';

  static HomeTheme? _cachedHomeTheme;
  static DateTime? _cachedHomeThemeAt;

  static Map<String, dynamic>? _cachedShopThemes;
  static DateTime? _cachedShopThemesAt;

  static const _cacheDuration = Duration(minutes: 15);

  /// Fetches the home theme config. Returns [HomeTheme.fallback] on any
  /// failure (no internet, bad JSON, server down, etc.) — the home screen
  /// should never look broken just because this one fetch failed.
  static Future<HomeTheme> fetchHomeTheme() async {
    final now = DateTime.now();
    if (_cachedHomeTheme != null &&
        _cachedHomeThemeAt != null &&
        now.difference(_cachedHomeThemeAt!) < _cacheDuration) {
      return _cachedHomeTheme!;
    }

    try {
      final res = await http
          .get(Uri.parse(_homeThemeUrl))
          .timeout(const Duration(seconds: 6));

      if (res.statusCode != 200) return HomeTheme.fallback;

      // This route returns the raw file content directly (same as
      // master/products.json does) — no {success, config} wrapper.
      final json = jsonDecode(res.body) as Map<String, dynamic>;

      final theme = HomeTheme.fromJson(json);
      _cachedHomeTheme = theme;
      _cachedHomeThemeAt = now;
      return theme;
    } catch (_) {
      return HomeTheme.fallback;
    }
  }

  /// Fetches the shop-category theme config — a map keyed by category
  /// (e.g. "fruit_vegetable", "medical_pharmacy", "default"). Returns null
  /// on any failure; shop_screen.dart falls back to its built-in
  /// per-category defaults in that case, same safety pattern as the home
  /// theme fetch.
  static Future<Map<String, dynamic>?> fetchShopThemes() async {
    final now = DateTime.now();
    if (_cachedShopThemes != null &&
        _cachedShopThemesAt != null &&
        now.difference(_cachedShopThemesAt!) < _cacheDuration) {
      return _cachedShopThemes;
    }

    try {
      final res = await http
          .get(Uri.parse(_shopThemesUrl))
          .timeout(const Duration(seconds: 6));

      if (res.statusCode != 200) return null;

      final json = jsonDecode(res.body) as Map<String, dynamic>;
      _cachedShopThemes = json;
      _cachedShopThemesAt = now;
      return json;
    } catch (_) {
      return null;
    }
  }
}