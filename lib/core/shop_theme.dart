import 'package:flutter/material.dart';

/// ============================================================
/// ShopDekho - Dynamic Shop Theme
/// ============================================================
///
/// Theme shop ki category ke according automatically change hota hai.
///
/// Supported categories:
///   vegetables / sabji / सब्जी
///   fruits / fruit / फल
///   dairy / milk / डेयरी / दूध
///   grocery / kirana / किराना
///   default
///
/// IMPORTANT:
/// ShopScreen is class ke ye properties use karta hai:
///
/// primary
/// dark
/// mid
/// light
/// tint
/// cardGlow
/// icon
/// promoBackground
/// promoIcon
/// promoImage
/// promoTitle
/// promoSubtitle
/// browseImage
/// browseTitle
/// browseSubtitle
/// ============================================================

class ShopThemeConfig {
  final Color primary;
  final Color dark;
  final Color mid;
  final Color light;
  final Color tint;
  final Color cardGlow;

  final String icon;

  final Color promoBackground;

  final String? promoIcon;
  final String? promoImage;

  final String promoTitle;
  final String promoSubtitle;

  final String? browseImage;
  final String browseTitle;
  final String browseSubtitle;

  const ShopThemeConfig({
    required this.primary,
    required this.dark,
    required this.mid,
    required this.light,
    required this.tint,
    required this.cardGlow,
    required this.icon,
    required this.promoBackground,
    required this.promoIcon,
    required this.promoImage,
    required this.promoTitle,
    required this.promoSubtitle,
    required this.browseImage,
    required this.browseTitle,
    required this.browseSubtitle,
  });

  // ==========================================================
  // DEFAULT THEME
  // ==========================================================

  static const ShopThemeConfig defaultTheme = ShopThemeConfig(
    primary: Color(0xFF15803D),
    dark: Color(0xFF075E2B),
    mid: Color(0xFF16A34A),
    light: Color(0xFFE8F7ED),
    tint: Color(0xFFF4FAF6),
    cardGlow: Color(0x3315803D),

    icon: '🛍️',

    promoBackground: Color(0xFFEFFAF2),

    promoIcon: null,
    promoImage:
        'https://shopdekho.github.io/localshop-content/img_g/vegetables_basket.webp',

    promoTitle: 'Fresh Vegetables Everyday',
    promoSubtitle: 'Fresh quality products from your local shop',

    browseImage:
        'https://shopdekho.github.io/localshop-content/img_g/vegetables_basket.webp',

    browseTitle: 'Browse Fresh Products',
    browseSubtitle: 'View products and today’s prices',
  );

  // ==========================================================
  // VEGETABLE THEME
  // ==========================================================

  static const ShopThemeConfig vegetables = ShopThemeConfig(
    primary: Color(0xFF159447),
    dark: Color(0xFF075E2B),
    mid: Color(0xFF20B957),

    light: Color(0xFFE2F7E9),
    tint: Color(0xFFF3FBF5),

    cardGlow: Color(0x33159447),

    icon: '🥬',

    promoBackground: Color(0xFFEAF8EE),

    promoIcon: null,

    promoImage:
        'https://shopdekho.github.io/localshop-content/img_g/vegetables_basket.webp',

    promoTitle: 'Fresh Vegetables Everyday',
    promoSubtitle: 'Fresh vegetables • Daily quality • Local shop',

    browseImage:
        'https://shopdekho.github.io/localshop-content/img_g/vegetables_basket.webp',

    browseTitle: 'Fresh Vegetables',
    browseSubtitle: 'See today’s vegetables and prices',
  );
  
  
    // ==========================================================
  // Medical Pharmacy THEME
  // ==========================================================
  
  static const ShopThemeConfig medicalPharmacy =
    ShopThemeConfig(
  primary: Color(0xFF1565C0),
  dark: Color(0xFF0D3E7A),
  mid: Color(0xFF1E7FD6),
  light: Color(0xFFE4EEFC),
  tint: Color(0xFFF2F7FE),

  cardGlow: Color(0x4D1565C0),

  icon: '💊',

  promoBackground: Color(0xFFEAF3FF),

  promoIcon:
      'https://static.vecteezy.com/system/resources/thumbnails/060/423/763/small/high-quality-image-of-a-single-capsule-drug-symbolizing-pharmaceutical-treatment-and-medicine-free-png.png',

  promoImage:
      'https://shopdekho.github.io/localshop-content/img_g/pills-of-different-colour.webp',

  promoTitle:
      'सही दाम में असली दवाइयाँ! / Genuine medicines at fair prices!',

  promoSubtitle:
      'Genuine/असली · Trusted/भरोसेमंद · Medicines/दवाइयाँ',

  browseImage:
      'https://shopdekho.github.io/localshop-content/img_g/medicine.webp',

  browseTitle:
      'दवाइयाँ देखें',

  browseSubtitle:
      'आज के दाम देखें / See today’s prices & availability',
);

  // ==========================================================
  // FRUIT THEME
  // ==========================================================

  static const ShopThemeConfig fruits = ShopThemeConfig(
    primary: Color(0xFFE4572E),
    dark: Color(0xFFB83216),
    mid: Color(0xFFFF7043),

    light: Color(0xFFFFE8E0),
    tint: Color(0xFFFFF7F3),

    cardGlow: Color(0x33E4572E),

    icon: '🍎',

    promoBackground: Color(0xFFFFF0EA),

    promoIcon: null,

    promoImage:
        'https://shopdekho.github.io/localshop-content/img_g/fruits_basket.webp',

    promoTitle: 'Fresh Fruits Everyday',
    promoSubtitle: 'Fresh seasonal fruits from your local shop',

    browseImage:
        'https://shopdekho.github.io/localshop-content/img_g/fruits_basket.webp',

    browseTitle: 'Fresh Fruits',
    browseSubtitle: 'See today’s fruits and prices',
  );

  // ==========================================================
  // DAIRY THEME
  // ==========================================================

  static const ShopThemeConfig dairy = ShopThemeConfig(
    primary: Color(0xFF2563EB),
    dark: Color(0xFF1746A2),
    mid: Color(0xFF3B82F6),

    light: Color(0xFFE8F0FF),
    tint: Color(0xFFF5F8FF),

    cardGlow: Color(0x332563EB),

    icon: '🥛',

    promoBackground: Color(0xFFEDF4FF),

    promoIcon: null,

    promoImage:
        'https://shopdekho.github.io/localshop-content/img_g/dairy.webp',

    promoTitle: 'Fresh Dairy Everyday',
    promoSubtitle: 'Milk, curd, paneer and fresh dairy products',

    browseImage:
        'https://shopdekho.github.io/localshop-content/img_g/dairy.webp',

    browseTitle: 'Fresh Dairy Products',
    browseSubtitle: 'See dairy products and today’s prices',
  );

  // ==========================================================
  // GROCERY / KIRANA THEME
  // ==========================================================

  static const ShopThemeConfig grocery = ShopThemeConfig(
    primary: Color(0xFFB7791F),
    dark: Color(0xFF7A4E0B),
    mid: Color(0xFFD69E2E),

    light: Color(0xFFFFF3D8),
    tint: Color(0xFFFFFBF2),

    cardGlow: Color(0x33B7791F),

    icon: '🛒',

    promoBackground: Color(0xFFFFF6E5),

    promoIcon: null,

    promoImage:
        'https://shopdekho.github.io/localshop-content/img_g/grocery.webp',

    promoTitle: 'Your Local Kirana Store',
    promoSubtitle: 'Daily essentials at your nearby shop',

    browseImage:
        'https://shopdekho.github.io/localshop-content/img_g/grocery.webp',

    browseTitle: 'Browse Grocery',
    browseSubtitle: 'See products and today’s prices',
  );

  // ==========================================================
  // CATEGORY DETECTION
  // ==========================================================

  static ShopThemeConfig forCategory(String? category) {
    final value = (category ?? '')
        .trim()
        .toLowerCase();

    // ----------------------------------------------------------
    // VEGETABLES
    // ----------------------------------------------------------

    if (_matches(value, [
	'fruit_vegetable',
'fruit vegetable',
'fruit-vegetable',
 'medical_pharmacy',
  'medical pharmacy',
  'medical',
  'pharmacy',
  'medical shop',
  'medical store',

      'vegetable',
      'vegetables',
      'sabji',
      'sabzi',
      'sabzi wala',
      'sabji wala',
      'सब्जी',
      'सब्ज़ी',
      'सब्जी वाला',
      'सब्ज़ी वाला',
    ])) {
      return vegetables;
    }

    // ----------------------------------------------------------
    // FRUITS
    // ----------------------------------------------------------

    if (_matches(value, [
      'fruit',
      'fruits',
      'fruit shop',
      'फल',
      'फल वाला',
      'फ्रूट',
    ])) {
      return fruits;
    }

    // ----------------------------------------------------------
    // DAIRY
    // ----------------------------------------------------------

    if (_matches(value, [
      'dairy',
      'milk',
      'milk shop',
      'dairy shop',
      'डेयरी',
      'दूध',
      'दूध वाला',
      'दूध डेयरी',
    ])) {
      return dairy;
    }

    // ----------------------------------------------------------
    // GROCERY / KIRANA
    // ----------------------------------------------------------

    if (_matches(value, [
      'grocery',
      'groceries',
      'kirana',
      'kirana store',
      'grocery store',
      'किराना',
      'किराना स्टोर',
      'जनरल स्टोर',
    ])) {
      return grocery;
    }

    // ----------------------------------------------------------
    // DEFAULT
    // ----------------------------------------------------------

    return defaultTheme;
  }

  // ==========================================================
  // HELPER
  // ==========================================================

  static bool _matches(
    String value,
    List<String> values,
  ) {
    for (final item in values) {
      if (value == item) {
        return true;
      }

      if (value.contains(item)) {
        return true;
      }
    }

    return false;
  }
}