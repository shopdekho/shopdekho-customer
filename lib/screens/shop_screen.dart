import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../models/shop.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_model.dart';
import '../services/notification_service.dart';
import '../services/remote_config_service.dart';
import '../theme/app_theme.dart';
import 'products_screen.dart';

class ShopScreen extends StatefulWidget {
  final String shopId;

  const ShopScreen({
    super.key,
    required this.shopId,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  final _api = ApiService();

  late final CartModel _cart;

  Shop? _shop;
  List<MergedProduct> _products = [];

  bool _loading = true;
  String? _error;

  // null until the fetch finishes (or fails) — resolveTheme() falls back
  // to the built-in per-category defaults in _ShopTheme.forCategory()
  // whenever this is null, so the page never looks broken while waiting.
  Map<String, dynamic>? _remoteShopThemes;

  @override
  void initState() {
    super.initState();

    _cart = CartModel();

    _load();
    _loadRemoteShopThemes();
  }

  Future<void> _loadRemoteShopThemes() async {
    final themes = await RemoteConfigService.fetchShopThemes();
    if (!mounted || themes == null) return;
    setState(() => _remoteShopThemes = themes);
  }

  /// Picks the theme for [category]: remote JSON entry for that category
  /// if present, else the remote "default" entry, else the hardcoded
  /// per-category fallback baked into the app.
  _ShopTheme _resolveTheme(String? category) {
    final hardcoded = _ShopTheme.forCategory(category);

    final remote = _remoteShopThemes;
    if (remote == null) return hardcoded;

    final key = (category != null && remote.containsKey(category)) ? category : 'default';
    final entry = remote[key];
    if (entry is! Map) return hardcoded;

    return _ShopTheme.fromJson(Map<String, dynamic>.from(entry), hardcoded);
  }

  // ==========================================================
  // DATA
  // ==========================================================

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _api.loadShopPage(widget.shopId);

      if (!mounted) return;

      setState(() {
        _shop = data.shop;
        _products = data.products;
        _cart.products = data.products;
        _loading = false;
      });

      // Fire-and-forget — this shop's customers will now get its
      // notifications too. Never blocks the UI or throws if it fails.
      NotificationService.subscribeToShop(widget.shopId);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = 'Shop data unavailable';
        _loading = false;
      });
    }
  }

  void _openProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: _cart,
          child: ProductsScreen(
            shopName: _shop?.shopName ?? '',
            shopId: widget.shopId,
          ),
        ),
      ),
    );
  }

  Future<void> _call() async {
    if (_shop?.mobile == null) return;

    final uri = Uri(
      scheme: 'tel',
      path: _shop!.mobile,
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _directions() async {
    if (_shop == null) return;

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${_shop!.latitude},${_shop!.longitude}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  void _shareShop() {
    Share.share(
      'Hmare shop ke sabjiyo ka price dekhne ke liye click kare\n'
      'https://shopdekho.the-web.top/s/${widget.shopId}',
    );
  }

  // Human-friendly "Updated X ago" text, used under the today's-products
  // strip — mirrors the "Updated 10 days ago" line on the website.
  String _relativeTime(String? iso) {
    if (iso == null || iso.isEmpty) return '';

    try {
      final d = DateTime.parse(iso);
      final diff = DateTime.now().difference(d);

      if (diff.inDays >= 1) {
        return 'Updated ${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
      }
      if (diff.inHours >= 1) {
        return 'Updated ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
      }
      if (diff.inMinutes >= 1) {
        return 'Updated ${diff.inMinutes} min ago';
      }
      return 'Updated just now';
    } catch (_) {
      return '';
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F9F7),
        body: Center(
          child: CircularProgressIndicator(
            color: AppColors.green,
          ),
        ),
      );
    }

    if (_error != null || _shop == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F9F7),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const BackButton(
            color: AppColors.ink,
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.redTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.store_mall_directory_outlined,
                    size: 30,
                    color: AppColors.red,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _error ?? 'Shop data unavailable',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final shop = _shop!;

    // Category-based theme — colors, icons, images and copy all switch
    // based on shop.category, mirroring THEME_CONFIG on the website.
    final theme = _resolveTheme(shop.category);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHero(shop),

                  Transform.translate(
                    offset: const Offset(0, -42),
                    child: Column(
                      children: [
                        _buildShopCard(shop, theme),

                        const SizedBox(height: 2),

                        _buildContactRow(theme),

                        const SizedBox(height: 14),

                        _buildPromoStrip(theme),

                        const SizedBox(height: 16),

                        _buildInfoGrid(shop, theme),

                        const SizedBox(height: 18),

                        _buildSearchBar(),

                        const SizedBox(height: 4),

                        _buildTodaySection(shop, theme),

                        const SizedBox(height: 4),

                        _buildShopInfoCard(shop, theme),

                        const SizedBox(height: 2),

                        _buildFindShopCard(shop, theme),

                        const SizedBox(height: 14),

                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            16,
                            0,
                            16,
                            24,
                          ),
                          child: _buildProductsButton(theme),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Back button
            Positioned(
              top: 12,
              left: 12,
              child: _heroIconButton(
                Icons.arrow_back_rounded,
                () => Navigator.pop(context),
              ),
            ),

            // Share button
            Positioned(
              top: 12,
              right: 12,
              child: _heroIconButton(
                Icons.share_rounded,
                _shareShop,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // HERO
  // ==========================================================

  Widget _buildHero(Shop shop) {
    return SizedBox(
      height: 220,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Banner image
          if (shop.banner != null && shop.banner!.isNotEmpty)
            Image.network(
              shop.banner!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return _heroGradient();
              },
            )
          else
            _heroGradient(),

          // Dark premium overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0x66000000),
                  Color(0x18000000),
                  Color(0xB300321D),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Bottom fade
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 90,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color(0xCC00351F),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Hero label
          Positioned(
            left: 18,
            bottom: 52,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(.28),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.eco_rounded,
                    size: 12,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'LOCAL • FRESH • TRUSTED',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF31A46A),
            Color(0xFF0E713F),
            Color(0xFF063C21),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _heroIconButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(.15),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 18,
            color: AppColors.ink,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SHOP CARD
  // ==========================================================

  Widget _buildShopCard(Shop shop, _ShopTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      padding: const EdgeInsets.fromLTRB(
        16,
        10,
        16,
        17,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.09),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo + verified badge (stacked in one column, matching the
          // website's .avatar-wrap) + name row
          Transform.translate(
            offset: const Offset(0, -20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.12),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFE8F5E9),
                        ),
                        child: ClipOval(
                          child: shop.logo != null &&
                                  shop.logo!.isNotEmpty
                              ? Image.network(
                                  shop.logo!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    return const Center(
                                      child: Text(
                                        '🏪',
                                        style: TextStyle(
                                          fontSize: 30,
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : const Center(
                                  child: Text(
                                    '🏪',
                                    style: TextStyle(
                                      fontSize: 30,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // Verified pill sits directly under the logo, pulled
                    // up slightly so it overlaps the logo's bottom edge —
                    // matches the website's .verified-ribbon (margin-top:-9px).
                    if (shop.verified)
                      Transform.translate(
                        offset: const Offset(0, -9),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.primary,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: theme.primary.withOpacity(.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Verified Shop',
                                style: TextStyle(
                                  fontSize: 7.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 3,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      shop.shopName,
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight:
                                            FontWeight.w900,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ),
                                  if (shop.verified) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified_rounded,
                                      size: 15,
                                      color: Color(0xFF2E9BEE),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            const SizedBox(width: 7),

                            _statusBadge(shop, theme),
                          ],
                        ),

                        const SizedBox(height: 3),
                        Text(
                          (shop.tagline != null &&
                                  shop.tagline!.isNotEmpty)
                              ? shop.tagline!
                              : 'Fresh Vegetables Everyday',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppColors.inkSoft,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          'Store ID: ${widget.shopId}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: theme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Transform.translate(
            offset: const Offset(0, -9),
            child: Column(
              children: [
                // Rating / distance prompt
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 17,
                      color: AppColors.gold,
                    ),

                    const SizedBox(width: 4),

                    Text(
                      '${shop.rating ?? '--'}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    if (shop.reviewCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${shop.reviewCount} ratings)',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.inkSoft,
                        ),
                      ),
                    ],

                    const SizedBox(width: 10),

                    Container(
                      width: 4,
                      height: 4,
                      decoration:
                          const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.inkFaint,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: InkWell(
                        onTap: _directions,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: theme.primary,
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                'Tap to check distance',
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: theme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (shop.openTime != null &&
                    shop.closeTime != null) ...[
                  const SizedBox(height: 7),

                  Row(
                    children: [
                      Container(
                        width: 25,
                        height: 25,
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFF4F6F4,
                          ),
                          borderRadius:
                              BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: AppColors.inkSoft,
                        ),
                      ),

                      const SizedBox(width: 7),

                      Text(
                        '${shop.openTime} – ${shop.closeTime}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w600,
                          color: AppColors.inkSoft,
                        ),
                      ),

                      const SizedBox(width: 6),

                      Text(
                        shop.isCurrentlyOpen
                            ? '• Open now'
                            : '• Closed',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight:
                              FontWeight.w700,
                          color: shop
                                  .isCurrentlyOpen
                              ? theme.primary
                              : AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(Shop shop, _ShopTheme theme) {
    final isOpen = shop.isCurrentlyOpen;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isOpen
            ? theme.light
            : const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isOpen
                  ? theme.primary
                  : AppColors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isOpen ? 'OPEN' : 'CLOSED',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: isOpen
                  ? theme.primary
                  : AppColors.red,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CALL / DIRECTIONS
  // ==========================================================

  Widget _buildContactRow(_ShopTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.mid, theme.dark],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: theme.primary.withOpacity(.30),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _call,
                  icon: const Icon(
                    Icons.call_rounded,
                    size: 17,
                  ),
                  label: const Text(
                    'कॉल करें / Call',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: SizedBox(
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFFE2E7E2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: OutlinedButton.icon(
                  onPressed: _directions,
                  icon: Icon(
                    Icons.directions_rounded,
                    size: 17,
                    color: theme.primary,
                  ),
                  label: const Text(
                    'रास्ता / Directions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: BorderSide.none,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PROMO
  // ==========================================================

  Widget _buildPromoStrip(_ShopTheme theme) {
    return InkWell(
      onTap: _openProducts,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          // A vibrant, universal lime-yellow accent for the promo banner —
          // deliberately not the muted theme tint, so it pops the way it
          // does on the website regardless of category.
          gradient: const LinearGradient(
            colors: [Color(0xFFEEF8C4), Color(0xFFDCEF8E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFCFE07A),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFCFE07A).withOpacity(.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: theme.promoIcon != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        theme.promoIcon!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Text('🌿', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    )
                  : const Center(
                      child: Text(
                        '🌿',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    theme.promoTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF3B4A12),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    theme.promoSubtitle,
                    maxLines: 1,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF5B6B22),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 6),

            // Right-side image (or arrow fallback) — matches the
            // website's promo-chev basket image.
            theme.promoImg != null
                ? Image.network(
                    theme.promoImg!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => _promoArrow(theme),
                  )
                : _promoArrow(theme),
          ],
        ),
      ),
    );
  }

  Widget _promoArrow(_ShopTheme theme) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.arrow_forward_rounded,
        size: 15,
        color: theme.primary,
      ),
    );
  }

  // ==========================================================
  // INFORMATION GRID
  // ==========================================================

  Widget _buildInfoGrid(Shop shop, _ShopTheme theme) {
    final items = [
      (
        Icons.verified_rounded,
        theme.primary,
        shop.verified,
        'Verified Shop',
        'Trusted & Verified',
        'Not Verified',
      ),
      (
        Icons.moped_rounded,
        const Color(0xFFE58A13),
        shop.homeDelivery,
        'Home Delivery',
        'Available',
        'Not Available',
      ),
      (
        Icons.local_shipping_rounded,
        const Color(0xFF3987D6),
        shop.delivery,
        'Delivery',
        'Available',
        'Not Available',
      ),
      (
        Icons.account_balance_wallet_rounded,
        const Color(0xFFE0A500),
        shop.upi,
        'UPI Payment',
        'Accepted',
        'Not Accepted',
      ),
      (
        Icons.local_parking_rounded,
        const Color(0xFF5183C8),
        shop.parking,
        'Parking',
        'Available',
        'Not Available',
      ),
      (
        Icons.shield_rounded,
        const Color(0xFF7A4DDB),
        true,
        'Fresh Guarantee',
        'Quality Assured',
        '',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 9,
          mainAxisSpacing: 9,
          mainAxisExtent: 76,
        ),
        itemBuilder: (_, index) {
          final item = items[index];

          final icon = item.$1;
          final color = item.$2;
          final available = item.$3;
          final title = item.$4;
          final yesText = item.$5;
          final noText = item.$6;

          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFFEDF1ED),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.045),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(.12),
                    borderRadius:
                        BorderRadius.circular(11),
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(.18), blurRadius: 8, offset: const Offset(0, 3)),
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: color,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight:
                              FontWeight.w800,
                          color: AppColors.ink,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        available
                            ? yesText
                            : noText,
                        maxLines: 1,
                        overflow:
                            TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight:
                              FontWeight.w700,
                          color: available
                              ? theme.primary
                              : AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // SEARCH
  // ==========================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: _openProducts,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE1E7E1),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F5F2),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 17,
                    color: AppColors.inkSoft,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Text(
                    'Search vegetables, fruits...',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppColors.inkSoft,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: AppColors.inkFaint,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // TODAY PRODUCTS
  // ==========================================================

  Widget _buildTodaySection(Shop shop, _ShopTheme theme) {
    final items = _products.take(4).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        0,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today at ${shop.shopName}',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w900,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Fresh prices & availability',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: theme.light,
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 6,
                      color: theme.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Live',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight:
                            FontWeight.w800,
                        color: theme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
              ),
              child: const Text(
                'No products yet.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.inkSoft,
                  fontSize: 12,
                ),
              ),
            )
          else
            SizedBox(
              height: 158,
              child: Row(
                children:
                    List.generate(items.length,
                        (index) {
                  final product = items[index];

                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right:
                            index == items.length - 1
                                ? 0
                                : 7,
                      ),
                      child: _buildProductPreview(
                        product,
                        theme,
                      ),
                    ),
                  );
                }),
              ),
            ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 12,
                color: AppColors.inkFaint,
              ),
              const SizedBox(width: 5),
              const Expanded(
                child: Text(
                  'Prices & availability updated by the shop',
                  style: TextStyle(
                    fontSize: 8.5,
                    color: AppColors.inkSoft,
                  ),
                ),
              ),
              Text(
                _relativeTime(shop.lastUpdated),
                style: const TextStyle(
                  fontSize: 8.5,
                  color: AppColors.inkSoft,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductPreview(
    MergedProduct product,
    _ShopTheme theme,
  ) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _openProducts,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE4E9E4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.025),
                blurRadius: 9,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F8F5),
                    borderRadius:
                        BorderRadius.circular(11),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(11),
                    child: product.image.isNotEmpty
                        ? Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) {
                              return const Center(
                                child: Icon(
                                  Icons
                                      .image_not_supported_outlined,
                                  size: 22,
                                  color:
                                      AppColors
                                          .inkFaint,
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons
                                  .image_outlined,
                              size: 22,
                              color:
                                  AppColors
                                      .inkFaint,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                product.name,
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                '₹${product.price.toStringAsFixed(2)}${product.priceSuffix}',
                maxLines: 1,
                overflow:
                    TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: theme.dark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SHOP INFORMATION
  // ==========================================================

  Widget _buildShopInfoCard(Shop shop, _ShopTheme theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.light, theme.tint],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius:
              BorderRadius.circular(22),
          border: Border.all(
            color: theme.light,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primary.withOpacity(.08),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 18,
                    color: theme.primary,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'दुकान की जानकारी',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Shop Information',
                        style: TextStyle(
                          fontSize: 9.5,
                          color:
                              AppColors.inkSoft,
                          fontWeight:
                              FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 17),

            IntrinsicHeight(
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _infoCol(
                      'मालिक / Owner',
                      shop.ownerName ?? '—',
                      'पता / Address',
                      shop.address ?? '—',
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: VerticalDivider(
                      width: 1,
                      thickness: 1,
                      color: theme.primary.withOpacity(.12),
                    ),
                  ),

                  Expanded(
                    child: _infoCol(
                      'Member Since',
                      shop.memberSince ?? '—',
                      'आखिरी अपडेट / Last Updated',
                      _lastUpdatedText(shop),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _lastUpdatedText(Shop shop) {
    if (shop.lastUpdated == null) {
      return '—';
    }

    try {
      final d =
          DateTime.parse(shop.lastUpdated!);

      return '${d.day}/${d.month}/${d.year} '
          '${d.hour.toString().padLeft(2, '0')}:'
          '${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '—';
    }
  }

  Widget _infoCol(
    String label1,
    String value1,
    String label2,
    String value2,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label1,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          value1,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            height: 1.25,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),

        const SizedBox(height: 11),

        Text(
          label2,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          value2,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            height: 1.25,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // FIND SHOP / MAP
  // ==========================================================

  Widget _buildFindShopCard(Shop shop, _ShopTheme theme) {
    final hasCoords =
        shop.latitude != 0 || shop.longitude != 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        0,
      ),
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFFE7ECE7),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: theme.light,
                          borderRadius:
                              BorderRadius.circular(
                            11,
                          ),
                          boxShadow: [
                            BoxShadow(color: theme.primary.withOpacity(.15), blurRadius: 8, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: theme.primary,
                        ),
                      ),

                      const SizedBox(width: 9),

                      const Text(
                        'Find this shop',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Expanded(
                    child: Text(
                      shop.address ?? '—',
                      maxLines: 3,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        height: 1.45,
                        color:
                            AppColors.inkSoft,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),

                  InkWell(
                    onTap: _directions,
                    child: Row(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Text(
                          'View on Map / नक्शे पर देखें',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w800,
                            color: theme.primary,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons
                              .arrow_forward_rounded,
                          size: 13,
                          color: theme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Real static map preview (falls back to the abstract
            // road-pattern painter if there's no location, or if the
            // map tile fails to load).
            Container(
              width: 105,
              height: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F1),
                borderRadius:
                    BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: hasCoords
                        ? InkWell(
                            onTap: _directions,
                            child: Image.network(
                              'https://staticmap.openstreetmap.de/staticmap.php'
                              '?center=${shop.latitude},${shop.longitude}'
                              '&zoom=15&size=220x320&maptype=mapnik'
                              '&markers=${shop.latitude},${shop.longitude},red-pushpin',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return CustomPaint(
                                  painter: _MapPatternPainter(),
                                );
                              },
                            ),
                          )
                        : CustomPaint(
                            painter: _MapPatternPainter(),
                          ),
                  ),

                  if (!hasCoords)
                    Center(
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 38,
                        color: theme.primary,
                      ),
                    ),

                  Positioned(
                    right: 7,
                    bottom: 7,
                    child: Container(
                      padding:
                          const EdgeInsets.all(5),
                      decoration:
                          const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.map_rounded,
                        size: 13,
                        color:
                            AppColors.inkSoft,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // PRODUCTS BUTTON
  // ==========================================================

  Widget _buildProductsButton(_ShopTheme theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openProducts,
        borderRadius:
            BorderRadius.circular(18),
        child: Container(
          height: 55,
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.mid, theme.dark],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius:
                BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: theme.primary
                    .withOpacity(.20),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(.16),
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                child: theme.browseIcon != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          theme.browseIcon!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.shopping_basket_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.shopping_basket_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      theme.browseTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      theme.browseSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Big basket-style image, matching the website's browse
              // button, shown before the trailing arrow circle.
              if (theme.browseImg != null) ...[
                Image.network(
                  theme.browseImg!,
                  width: 32,
                  height: 32,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
                const SizedBox(width: 8),
              ],

              Container(
                width: 34,
                height: 34,
                decoration:
                    const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 17,
                  color: theme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CATEGORY THEME
//
// Mirrors THEME_CONFIG from the website (s/index.html) — colors,
// icon/promo images and copy all switch based on shop.category so
// a medical store, kirana shop, etc. don't look like a veggie shop.
//
// NOTE: this requires `Shop.category` (String?) to exist on your
// Shop model, populated from the shop JSON's "category" field. If
// your model doesn't have it yet, add:
//   final String? category;
// and read it from JSON the same way as your other shop fields.
// ============================================================

class _ShopTheme {
  final Color primary;
  final Color dark;
  final Color mid;
  final Color light;
  final Color tint;
  final String? promoIcon;
  final String? promoImg;
  final String? browseIcon;
  final String? browseImg;
  final String promoTitle;
  final String promoSubtitle;
  final String browseTitle;
  final String browseSubtitle;

  const _ShopTheme({
    required this.primary,
    required this.dark,
    required this.mid,
    required this.light,
    required this.tint,
    this.promoIcon,
    this.promoImg,
    this.browseIcon,
    this.browseImg,
    required this.promoTitle,
    required this.promoSubtitle,
    required this.browseTitle,
    required this.browseSubtitle,
  });

  /// Builds a theme from a remote JSON entry, falling back field-by-field
  /// to [fallback] (the hardcoded category default) for anything missing
  /// or malformed — a partially-filled JSON entry never breaks the page.
  factory _ShopTheme.fromJson(Map<String, dynamic> j, _ShopTheme fallback) {
    return _ShopTheme(
      primary: _parseColor(j['primary']) ?? fallback.primary,
      dark: _parseColor(j['dark']) ?? fallback.dark,
      mid: _parseColor(j['mid']) ?? fallback.mid,
      light: _parseColor(j['light']) ?? fallback.light,
      tint: _parseColor(j['tint']) ?? fallback.tint,
      promoIcon: (j['promoIcon'] as String?)?.isNotEmpty == true ? j['promoIcon'] : fallback.promoIcon,
      promoImg: (j['promoImg'] as String?)?.isNotEmpty == true ? j['promoImg'] : fallback.promoImg,
      browseIcon: (j['browseIcon'] as String?)?.isNotEmpty == true ? j['browseIcon'] : fallback.browseIcon,
      browseImg: (j['browseImg'] as String?)?.isNotEmpty == true ? j['browseImg'] : fallback.browseImg,
      promoTitle: (j['promoTitle'] as String?)?.isNotEmpty == true ? j['promoTitle'] : fallback.promoTitle,
      promoSubtitle:
          (j['promoSubtitle'] as String?)?.isNotEmpty == true ? j['promoSubtitle'] : fallback.promoSubtitle,
      browseTitle: (j['browseTitle'] as String?)?.isNotEmpty == true ? j['browseTitle'] : fallback.browseTitle,
      browseSubtitle:
          (j['browseSubtitle'] as String?)?.isNotEmpty == true ? j['browseSubtitle'] : fallback.browseSubtitle,
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

  static _ShopTheme forCategory(String? category) {
    switch (category) {
      case 'fruit_vegetable':
        return const _ShopTheme(
          primary: Color(0xFF0E6B3A),
          dark: Color(0xFF093F22),
          mid: Color(0xFF159152),
          light: Color(0xFFE6F4EB),
          tint: Color(0xFFF2FAF5),
          promoIcon:
              'https://img.magnific.com/premium-photo/png-coriander-leaf-vegetable-illustration-transparent-background_53876-985358.jpg',
          promoImg:
              'https://shopdekho.github.io/localshop-content/img_g/vegetables_basket.webp',
          browseIcon:
              'https://png.pngtree.com/png-clipart/20250110/original/pngtree-vibrant-vegetables-and-fruits-basket-png-image_19000311.png',
          browseImg:
              'https://png.pngtree.com/png-clipart/20250529/original/pngtree-basket-full-of-vegetables-png-image_21086473.png',
          promoTitle:
              'सही दाम में ताज़ी सब्ज़ियाँ! / Best Quality vegetables at fair prices!',
          promoSubtitle:
              'Fresh/ताज़ा · Hygienic/साफ़-सुथरा · Affordable/किफायती',
          browseTitle: 'ताज़ी सब्ज़ियाँ देखें',
          browseSubtitle:
              "आज के दाम देखें / See today's prices & availability",
        );

      case 'medical_pharmacy':
        return const _ShopTheme(
          primary: Color(0xFF1565C0),
          dark: Color(0xFF0D3E7A),
          mid: Color(0xFF1E7FD6),
          light: Color(0xFFE4EEFC),
          tint: Color(0xFFF2F7FE),
          promoIcon:
              'https://static.vecteezy.com/system/resources/thumbnails/060/423/763/small/high-quality-image-of-a-single-capsule-drug-symbolizing-pharmaceutical-treatment-and-medicine-free-png.png',
          promoImg:
              'https://shopdekho.github.io/localshop-content/img_g/pills-of-different-colour.webp',
          browseIcon:
              'https://png.pngtree.com/png-vector/20210109/ourmid/pngtree-yellow-and-red-pill-capsule-material-png-image_2701948.jpg',
          browseImg:
              'https://shopdekho.github.io/localshop-content/img_g/medicine.webp',
          promoTitle:
              'सही दाम में असली दवाइयाँ! / Genuine medicines at fair prices!',
          promoSubtitle:
              'Genuine/असली · Trusted/भरोसेमंद · Medicines/दवाइयाँ',
          browseTitle: 'दवाइयाँ देखें',
          browseSubtitle:
              "आज के दाम देखें / See today's prices & availability",
        );

      case 'kirana_grocery':
        return const _ShopTheme(
          primary: Color(0xFFB8590A),
          dark: Color(0xFF7A3B06),
          mid: Color(0xFFD6720F),
          light: Color(0xFFFBEADC),
          tint: Color(0xFFFDF5EE),
          promoTitle:
              'सही दाम में रोज़मर्रा का सामान! / Daily essentials at fair prices!',
          promoSubtitle:
              'Fresh/ताज़ा · Quality/अच्छी क्वालिटी · Affordable/किफायती',
          browseTitle: 'किराना सामान देखें',
          browseSubtitle:
              "आज के दाम देखें / See today's prices & availability",
        );

      case 'dairy':
        return const _ShopTheme(
          primary: Color(0xFF2E7DA6),
          dark: Color(0xFF164A63),
          mid: Color(0xFF3E97C4),
          light: Color(0xFFE1F0F8),
          tint: Color(0xFFF1F9FD),
          promoTitle:
              'शुद्ध और ताज़ा डेयरी उत्पाद! / Pure & fresh dairy products!',
          promoSubtitle:
              'Pure/शुद्ध · Fresh/ताज़ा · Affordable/किफायती',
          browseTitle: 'डेयरी उत्पाद देखें',
          browseSubtitle:
              "आज के दाम देखें / See today's prices & availability",
        );

      case 'bakery':
        return const _ShopTheme(
          primary: Color(0xFFB8763E),
          dark: Color(0xFF7A4C24),
          mid: Color(0xFFCC8F55),
          light: Color(0xFFFAEEE1),
          tint: Color(0xFFFDF8F2),
          promoTitle:
              'ताज़ी बेकरी वस्तुएं रोज़! / Fresh bakery items every day!',
          promoSubtitle:
              'Fresh/ताज़ा · Soft/मुलायम · Affordable/किफायती',
          browseTitle: 'बेकरी आइटम देखें',
          browseSubtitle:
              "आज के दाम देखें / See today's prices & availability",
        );

      case 'sweets':
        return const _ShopTheme(
          primary: Color(0xFFC2410C),
          dark: Color(0xFF7C2D0C),
          mid: Color(0xFFE05B1F),
          light: Color(0xFFFCE4D6),
          tint: Color(0xFFFEF3EC),
          promoTitle:
              'शुद्ध घी की मिठाइयाँ! / Pure ghee sweets at fair prices!',
          promoSubtitle:
              'Pure/शुद्ध · Fresh/ताज़ा · Hygienic/साफ़-सुथरा',
          browseTitle: 'मिठाइयाँ देखें',
          browseSubtitle:
              "आज के दाम देखें / See today's prices & availability",
        );

      case 'stationery':
        return const _ShopTheme(
          primary: Color(0xFF6D28D9),
          dark: Color(0xFF3F1671),
          mid: Color(0xFF8B4FE8),
          light: Color(0xFFEDE3FC),
          tint: Color(0xFFF7F2FE),
          promoTitle:
              'हर तरह का स्टेशनरी सामान! / All types of stationery items!',
          promoSubtitle:
              'Quality/अच्छी क्वालिटी · Variety/विविधता · Affordable/किफायती',
          browseTitle: 'स्टेशनरी सामान देखें',
          browseSubtitle:
              "आज के दाम देखें / See today's prices & availability",
        );

      default:
        return const _ShopTheme(
          primary: Color(0xFF6E756F),
          dark: Color(0xFF3A3D3B),
          mid: Color(0xFF8A908C),
          light: Color(0xFFEAECEA),
          tint: Color(0xFFF6F7F6),
          browseImg:
              'https://png.pngtree.com/png-clipart/20250529/original/pngtree-basket-full-of-vegetables-png-image_21086473.png',
          promoImg:
              'https://shopdekho.github.io/localshop-content/img_g/vegetables_basket.webp',
          promoTitle:
              'सही दाम में अच्छा सामान! / Fair prices, quality guaranteed!',
          promoSubtitle:
              'Fresh/ताज़ा · Trusted/भरोसेमंद · Affordable/किफायती',
          browseTitle: 'सामान देखें',
          browseSubtitle:
              "आज के दाम देखें / See today's prices & availability",
        );
    }
  }
}

// ============================================================
// MAP PATTERN
// ============================================================

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = const Color(0xFFDCE4DC)
      ..strokeWidth = 1;

    // Horizontal roads
    for (double y = 15; y < size.height; y += 24) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y + 5),
        paint,
      );
    }

    // Vertical roads
    for (double x = 10; x < size.width; x += 27) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 8, size.height),
        paint,
      );
    }

    final minorPaint = Paint()
      ..color = const Color(0xFFE8EEE8)
      ..strokeWidth = .7;

    for (double y = 6; y < size.height; y += 14) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        minorPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}
