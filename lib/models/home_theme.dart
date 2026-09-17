import 'package:flutter/material.dart';

/// Maps an icon *name string* (from JSON) to a real Flutter icon — JSON
/// can't carry an IconData directly, only text, so festival configs pick
/// an icon by name from this list. Add more entries here any time you
/// want a new icon available to the JSON.
const Map<String, IconData> kNamedIcons = {
  'storefront': Icons.storefront_rounded,
  'eco': Icons.eco_rounded,
  'moped': Icons.moped_rounded,
  'verified_user': Icons.verified_user_rounded,
  'verified': Icons.verified_rounded,
  'shield': Icons.shield_rounded,
  'location_city': Icons.location_city_rounded,
  'location_on': Icons.location_on_rounded,
  'park': Icons.park_rounded,
  'search': Icons.search_rounded,
  'qr_code': Icons.qr_code_2_rounded,
  'shopping_bag': Icons.shopping_bag_rounded,
  'shopping_basket': Icons.shopping_basket_rounded,
  'local_offer': Icons.local_offer_rounded,
  'discount': Icons.discount_rounded,
  'star': Icons.star_rounded,
  'favorite': Icons.favorite_rounded,
  'thumb_up': Icons.thumb_up_rounded,
  'delivery_dining': Icons.delivery_dining_rounded,
  'local_shipping': Icons.local_shipping_rounded,
  'payments': Icons.payments_rounded,
  'card_giftcard': Icons.card_giftcard_rounded,
  'celebration': Icons.celebration_rounded,
  'spa': Icons.spa_rounded,
};

IconData _iconByName(String? name, IconData fallback) {
  if (name == null) return fallback;
  return kNamedIcons[name] ?? fallback;
}

class HomeTheme {
  final Color primary;
  final Color primaryDark;
  final Color accentPurple;
  final Color accentOrange;
  final Color backgroundColor;
  final String headerImage;

  /// Optional font family name. Only works if that font is already bundled
  /// in the app (added to pubspec.yaml under `fonts:` and shipped in the
  /// build) — a string here can't make Flutter download a new font from
  /// the internet by itself. If you want truly dynamic fonts by name
  /// (e.g. any Google Font, picked at runtime), add the `google_fonts`
  /// package instead — see the commented option in home_screen.dart's
  /// `_themedStyle()` helper.
  final String? fontFamily;

  final ActionTileTheme nearbyTile;
  final ActionTileTheme scanTile;
  final ActionTileTheme searchTile;

  final List<BenefitTheme> benefits;

  final List<HomeBanner> banners;

  const HomeTheme({
    required this.primary,
    required this.primaryDark,
    required this.accentPurple,
    required this.accentOrange,
    required this.backgroundColor,
    required this.headerImage,
    this.fontFamily,
    required this.nearbyTile,
    required this.scanTile,
    required this.searchTile,
    required this.benefits,
    required this.banners,
  });

  /// Safe fallback used before the remote config loads, or if the fetch
  /// fails (e.g. no internet) — the app must never look broken/blank.
  static const HomeTheme fallback = HomeTheme(
    primary: Color(0xFF3AAE5C),
    primaryDark: Color(0xFF0D5131),
    accentPurple: Color(0xFF6D3BE5),
    accentOrange: Color(0xFFE58A13),
    backgroundColor: Color(0xFFF7F9F7),
    headerImage:
        'https://images.unsplash.com/photo-1610348725531-843dff563e2c?auto=format&fit=crop&w=600&q=80',
    fontFamily: null,
    nearbyTile: ActionTileTheme(
      title: 'Nearby Shops',
      subtitle: 'Discover shops near you',
      background: Color(0xFFEAF7EA),
      iconBackground: Color(0xFFD5EFD5),
      iconColor: Color(0xFF0E6B3A),
      titleColor: Color(0xFF111111),
      titleFontSize: 12.5,
      subtitleColor: Color(0xFF6B7280),
      subtitleFontSize: 9.5,
    ),
    scanTile: ActionTileTheme(
      title: 'Scan Shop QR',
      subtitle: 'Scan a ShopDekho QR',
      background: Color(0xFFF0EBFF),
      iconBackground: Color(0xFFE3D8FF),
      iconColor: Color(0xFF6D3BE5),
      titleColor: Color(0xFF111111),
      titleFontSize: 12.5,
      subtitleColor: Color(0xFF6B7280),
      subtitleFontSize: 9.5,
    ),
    searchTile: ActionTileTheme(
      title: 'Search Shop',
      subtitle: 'Find using Shop ID',
      background: Color(0xFFFFF2E5),
      iconBackground: Color(0xFFFFE3C7),
      iconColor: Color(0xFFE58A13),
      titleColor: Color(0xFF111111),
      titleFontSize: 12.5,
      subtitleColor: Color(0xFF6B7280),
      subtitleFontSize: 9.5,
    ),
    benefits: [
      BenefitTheme(
        icon: Icons.storefront_rounded,
        decorativeIcon: Icons.location_city_rounded,
        title: 'Local Shops',
        subtitle: 'Support nearby\nbusinesses',
        backgroundStart: Color(0xFFEBF8EE),
        backgroundEnd: Color(0xFFDCF0E1),
        iconBackground: Color(0xFFD6EFDA),
        iconColor: Color(0xFF0E6B3A),
        titleColor: Color(0xFF111111),
        titleFontSize: 12.5,
        subtitleColor: Color(0xFF6B7280),
        subtitleFontSize: 10,
      ),
      BenefitTheme(
        icon: Icons.eco_rounded,
        decorativeIcon: Icons.eco_rounded,
        title: 'Fresh Produce',
        subtitle: 'Fresh & quality\nvegetables',
        backgroundStart: Color(0xFFEFF8E9),
        backgroundEnd: Color(0xFFE3F1D9),
        iconBackground: Color(0xFFDDEFD1),
        iconColor: Color(0xFF0E6B3A),
        titleColor: Color(0xFF111111),
        titleFontSize: 12.5,
        subtitleColor: Color(0xFF6B7280),
        subtitleFontSize: 10,
      ),
      BenefitTheme(
        icon: Icons.moped_rounded,
        decorativeIcon: Icons.park_rounded,
        title: 'Home Delivery',
        subtitle: 'Get it delivered\nto you',
        backgroundStart: Color(0xFFFFF4E9),
        backgroundEnd: Color(0xFFFFE9D3),
        iconBackground: Color(0xFFFFE3C7),
        iconColor: Color(0xFFE58A13),
        titleColor: Color(0xFF111111),
        titleFontSize: 12.5,
        subtitleColor: Color(0xFF6B7280),
        subtitleFontSize: 10,
      ),
      BenefitTheme(
        icon: Icons.verified_user_rounded,
        decorativeIcon: Icons.shield_rounded,
        title: 'Trusted Shops',
        subtitle: 'Verified local\nsellers',
        backgroundStart: Color(0xFFF2ECFE),
        backgroundEnd: Color(0xFFE7DDFB),
        iconBackground: Color(0xFFE3D8FF),
        iconColor: Color(0xFF6D3BE5),
        titleColor: Color(0xFF111111),
        titleFontSize: 12.5,
        subtitleColor: Color(0xFF6B7280),
        subtitleFontSize: 10,
      ),
    ],
    banners: [
      HomeBanner(
        image:
            'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=1200&q=85',
        tag: 'FRESH • LOCAL • TRUSTED',
        titleStart: 'Eat Fresh, ',
        titleHighlight: 'Live Healthy',
        subtitle: 'Find fresh vegetables from trusted local shops around you.',
      ),
    ],
  );

  factory HomeTheme.fromJson(Map<String, dynamic> j) {
    final tiles = j['actionTiles'] as Map<String, dynamic>?;

    return HomeTheme(
      primary: _parseColor(j['primaryColor']) ?? fallback.primary,
      primaryDark: _parseColor(j['primaryDark']) ?? fallback.primaryDark,
      accentPurple: _parseColor(j['accentPurple']) ?? fallback.accentPurple,
      accentOrange: _parseColor(j['accentOrange']) ?? fallback.accentOrange,
      backgroundColor: _parseColor(j['backgroundColor']) ?? fallback.backgroundColor,
      headerImage: (j['headerImage'] as String?)?.isNotEmpty == true
          ? j['headerImage']
          : fallback.headerImage,
      fontFamily: (j['fontFamily'] as String?)?.trim().isNotEmpty == true
          ? j['fontFamily']
          : null,
      nearbyTile: ActionTileTheme.fromJson(
        tiles?['nearby'] as Map<String, dynamic>?,
        fallback.nearbyTile,
      ),
      scanTile: ActionTileTheme.fromJson(
        tiles?['scan'] as Map<String, dynamic>?,
        fallback.scanTile,
      ),
      searchTile: ActionTileTheme.fromJson(
        tiles?['search'] as Map<String, dynamic>?,
        fallback.searchTile,
      ),
      benefits: (j['benefits'] as List?)
              ?.whereType<Map>()
              .map((b) => BenefitTheme.fromJson(Map<String, dynamic>.from(b)))
              .toList() ??
          fallback.benefits,
      banners: (j['banners'] as List?)
              ?.whereType<Map>()
              .map((b) => HomeBanner.fromJson(Map<String, dynamic>.from(b)))
              .toList() ??
          fallback.banners,
    );
  }

  /// Accepts "#RRGGBB" or "#AARRGGBB" hex strings from the JSON.
  static Color? _parseColor(dynamic value) {
    if (value is! String || value.isEmpty) return null;
    var hex = value.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final intVal = int.tryParse(hex, radix: 16);
    return intVal == null ? null : Color(intVal);
  }
}

/// Colors, copy, and font sizes for one of the three home-screen action
/// tiles (Nearby Shops / Scan Shop QR / Search Shop).
class ActionTileTheme {
  final String title;
  final String subtitle;
  final Color background;
  final Color iconBackground;
  final Color iconColor;
  final Color titleColor;
  final double titleFontSize;
  final Color subtitleColor;
  final double subtitleFontSize;

  const ActionTileTheme({
    required this.title,
    required this.subtitle,
    required this.background,
    required this.iconBackground,
    required this.iconColor,
    required this.titleColor,
    required this.titleFontSize,
    required this.subtitleColor,
    required this.subtitleFontSize,
  });

  factory ActionTileTheme.fromJson(Map<String, dynamic>? j, ActionTileTheme fallback) {
    if (j == null) return fallback;
    return ActionTileTheme(
      title: (j['title'] as String?)?.isNotEmpty == true ? j['title'] : fallback.title,
      subtitle: (j['subtitle'] as String?)?.isNotEmpty == true ? j['subtitle'] : fallback.subtitle,
      background: HomeTheme._parseColor(j['background']) ?? fallback.background,
      iconBackground: HomeTheme._parseColor(j['iconBackground']) ?? fallback.iconBackground,
      iconColor: HomeTheme._parseColor(j['iconColor']) ?? fallback.iconColor,
      titleColor: HomeTheme._parseColor(j['titleColor']) ?? fallback.titleColor,
      titleFontSize: (j['titleFontSize'] as num?)?.toDouble() ?? fallback.titleFontSize,
      subtitleColor: HomeTheme._parseColor(j['subtitleColor']) ?? fallback.subtitleColor,
      subtitleFontSize: (j['subtitleFontSize'] as num?)?.toDouble() ?? fallback.subtitleFontSize,
    );
  }
}

/// Colors, copy, and font sizes for one of the four "Why ShopDekho?"
/// benefit cards.
class BenefitTheme {
  final IconData icon;
  final IconData decorativeIcon;
  final String title;
  final String subtitle;
  final Color backgroundStart;
  final Color backgroundEnd;
  final Color iconBackground;
  final Color iconColor;
  final Color titleColor;
  final double titleFontSize;
  final Color subtitleColor;
  final double subtitleFontSize;

  const BenefitTheme({
    required this.icon,
    required this.decorativeIcon,
    required this.title,
    required this.subtitle,
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.iconBackground,
    required this.iconColor,
    required this.titleColor,
    required this.titleFontSize,
    required this.subtitleColor,
    required this.subtitleFontSize,
  });

  factory BenefitTheme.fromJson(Map<String, dynamic> j) {
    const neutral = Color(0xFF9AA39C);

    return BenefitTheme(
      icon: _iconByName(j['icon'] as String?, Icons.star_rounded),
      decorativeIcon: _iconByName(j['decorativeIcon'] as String?, Icons.star_rounded),
      title: j['title']?.toString() ?? '',
      subtitle: j['subtitle']?.toString() ?? '',
      backgroundStart: HomeTheme._parseColor(j['backgroundStart']) ?? neutral,
      backgroundEnd: HomeTheme._parseColor(j['backgroundEnd']) ?? neutral,
      iconBackground: HomeTheme._parseColor(j['iconBackground']) ?? neutral,
      iconColor: HomeTheme._parseColor(j['iconColor']) ?? neutral,
      titleColor: HomeTheme._parseColor(j['titleColor']) ?? const Color(0xFF111111),
      titleFontSize: (j['titleFontSize'] as num?)?.toDouble() ?? 12.5,
      subtitleColor: HomeTheme._parseColor(j['subtitleColor']) ?? const Color(0xFF6B7280),
      subtitleFontSize: (j['subtitleFontSize'] as num?)?.toDouble() ?? 10,
    );
  }
}

class HomeBanner {
  final String image;
  final String tag;
  final String titleStart;
  final String titleHighlight;
  final String subtitle;

  const HomeBanner({
    required this.image,
    required this.tag,
    required this.titleStart,
    required this.titleHighlight,
    required this.subtitle,
  });

  factory HomeBanner.fromJson(Map<String, dynamic> j) {
    return HomeBanner(
      image: j['image']?.toString() ?? '',
      tag: j['tag']?.toString() ?? '',
      titleStart: j['titleStart']?.toString() ?? '',
      titleHighlight: j['titleHighlight']?.toString() ?? '',
      subtitle: j['subtitle']?.toString() ?? '',
    );
  }
}