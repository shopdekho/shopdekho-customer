import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../models/shop.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_model.dart';
import '../theme/app_theme.dart';
import 'products_screen.dart';

class ShopScreen extends StatefulWidget {
  final String shopId;
  const ShopScreen({super.key, required this.shopId});

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

  @override
  void initState() {
    super.initState();
    _cart = CartModel();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.loadShopPage(widget.shopId);
      setState(() {
        _shop = data.shop;
        _products = data.products;
        _cart.products = data.products;
        _loading = false;
      });
    } catch (e) {
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
          child: ProductsScreen(shopName: _shop?.shopName ?? ''),
        ),
      ),
    );
  }

  Future<void> _call() async {
    if (_shop?.mobile == null) return;
    final uri = Uri(scheme: 'tel', path: _shop!.mobile);
    if (await canLaunchUrl(uri)) launchUrl(uri);
  }

  Future<void> _directions() async {
    if (_shop == null) return;
    final uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${_shop!.latitude},${_shop!.longitude}');
    if (await canLaunchUrl(uri)) launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _shareShop() {
    Share.share('Hmare shop ke sabjiyo ka price dekhne ke liye click kare\n'
        'https://shopdekho.the-web.top/s/${widget.shopId}');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null || _shop == null) {
      return Scaffold(
        appBar: AppBar(leading: BackButton(onPressed: () => Navigator.pop(context))),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 32, color: AppColors.inkFaint),
              const SizedBox(height: 10),
              Text(_error ?? 'Shop data unavailable'),
              const SizedBox(height: 14),
              ElevatedButton(onPressed: _load, child: const Text('Try Again')),
            ],
          ),
        ),
      );
    }

    final shop = _shop!;
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHero(shop),
                  _buildShopCard(shop),
                  _buildContactRow(),
                  _buildPromoStrip(),
                  _buildInfoGrid(shop),
                  _buildSearchBar(),
                  _buildTodaySection(shop),
                  _buildShopInfoCard(shop),
                  _buildFindShopCard(shop),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _openProducts,
                        icon: const Icon(Icons.shopping_basket),
                        label: const Text('ताज़ी सब्ज़ियाँ देखें'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              left: 8,
              child: _heroIconButton(Icons.arrow_back, () => Navigator.pop(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroIconButton(IconData icon, VoidCallback onTap) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: const Color(0xFF1B1F1D)),
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildHero(Shop shop) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E9160), Color(0xFF0E6B3A), Color(0xFF093F22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: (shop.banner != null && shop.banner!.isNotEmpty)
            ? DecorationImage(image: NetworkImage(shop.banner!), fit: BoxFit.cover, onError: (_, __) {})
            : null,
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 4, right: 8),
          child: _heroIconButton(Icons.share, _shareShop),
        ),
      ),
    );
  }

  Widget _buildShopCard(Shop shop) {
    return Transform.translate(
      offset: const Offset(0, -38),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14),
        padding: const EdgeInsets.fromLTRB(15, 16, 15, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.lg + 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.08), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greenLight,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: ClipOval(
                    child: (shop.logo != null && shop.logo!.isNotEmpty)
                        ? Image.network(shop.logo!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(child: Text('🏪', style: TextStyle(fontSize: 28))))
                        : const Center(child: Text('🏪', style: TextStyle(fontSize: 28))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(shop.shopName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: shop.isCurrentlyOpen ? AppColors.greenLight : AppColors.redTint,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(shop.isCurrentlyOpen ? 'OPEN' : 'CLOSED',
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.w700,
                                    color: shop.isCurrentlyOpen ? AppColors.green : AppColors.red)),
                          ),
                        ],
                      ),
                      if (shop.tagline != null)
                        Text(shop.tagline!, style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
                      if (shop.verified)
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Text('Verified Shop', style: TextStyle(fontSize: 10, color: AppColors.green, fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 11),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: AppColors.gold),
                Text(' ${shop.rating ?? '--'}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                if (shop.reviewCount > 0) Text(' (${shop.reviewCount} ratings)', style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
              ],
            ),
            if (shop.openTime != null && shop.closeTime != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text('🕐 ${shop.openTime} – ${shop.closeTime} (${shop.isCurrentlyOpen ? 'Open' : 'Closed'})',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow() {
    return Transform.translate(
      offset: const Offset(0, -26),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _call,
                icon: const Icon(Icons.call, size: 15),
                label: const Text('कॉल करें / Call'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _directions,
                icon: const Icon(Icons.directions, size: 15, color: AppColors.ink),
                label: const Text('रास्ता / Directions', style: TextStyle(color: AppColors.ink)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoStrip() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: InkWell(
        onTap: _openProducts,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFB5D30B),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              const Text('🌿', style: TextStyle(fontSize: 17)),
              const SizedBox(width: 9),
              const Expanded(
                child: Text('सही दाम में ताज़ी सब्ज़ियाँ! / Best quality vegetables at fair prices!',
                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.greenDark)),
              ),
              const Icon(Icons.chevron_right, color: AppColors.green),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoGrid(Shop shop) {
    final items = [
      ('✅', shop.verified, 'Verified Shop', 'Trusted & Verified', 'Not Verified'),
      ('🛵', shop.homeDelivery, 'Home Delivery', 'Available', 'Not Available'),
      ('🚚', shop.delivery, 'Delivery', 'Available', 'Not Available'),
      ('💳', shop.upi, 'UPI Payment', 'Accepted', 'Not Accepted'),
      ('🅿️', shop.parking, 'Parking', 'Available', 'Not Available'),
      ('🛡️', true, 'Fresh Guarantee', 'Quality Assured', ''),
    ];
    return Transform.translate(
      offset: const Offset(0, -14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 2.7,
          children: items.map((it) {
            final ok = it.$2;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(it.$1, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(it.$3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.8, fontWeight: FontWeight.w700)),
                        Text(ok ? it.$4 : it.$5, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w650, color: ok ? AppColors.green : AppColors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: InkWell(
        onTap: _openProducts,
        child: Container(
          margin: const EdgeInsets.only(top: 2, bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(children: [
            Icon(Icons.search, size: 15, color: AppColors.inkSoft),
            SizedBox(width: 9),
            Text('Search vegetables, fruits...', style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft)),
          ]),
        ),
      ),
    );
  }

  Widget _buildTodaySection(Shop shop) {
    final items = _products.take(4).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Today at ${shop.shopName}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
              const Row(children: [
                Icon(Icons.circle, size: 6, color: AppColors.green),
                SizedBox(width: 5),
                Text('Live Updates', style: TextStyle(fontSize: 10.5, color: AppColors.green, fontWeight: FontWeight.w700)),
              ]),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No products yet.', style: TextStyle(color: AppColors.inkSoft, fontSize: 12.5)),
            )
          else
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: .72,
              children: items.map((p) {
                return InkWell(
                  onTap: _openProducts,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.line),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: p.image.isNotEmpty
                                ? Image.network(p.image, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(color: AppColors.paper))
                                : Container(color: AppColors.paper),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700)),
                        Text('₹${p.price.toStringAsFixed(0)}${p.priceSuffix}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.greenDark)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildShopInfoCard(Shop shop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: const Color(0xFFD7E7CC), borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🗓️ दुकान की जानकारी / Shop Information', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
            const SizedBox(height: 11),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _infoCol('मालिक / Owner', shop.ownerName ?? '—', 'पता / Address', shop.address ?? '—')),
                Expanded(child: _infoCol('Member Since', shop.memberSince ?? '—', 'आखिरी अपडेट / Last Updated', _lastUpdatedText(shop))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _lastUpdatedText(Shop shop) {
    if (shop.lastUpdated == null) return '—';
    try {
      final d = DateTime.parse(shop.lastUpdated!);
      return '${d.day}/${d.month}/${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '—';
    }
  }

  Widget _infoCol(String l1, String v1, String l2, String v2) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l1, style: const TextStyle(fontSize: 9.5, color: AppColors.inkSoft, fontWeight: FontWeight.w650)),
        Text(v1, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w650)),
        const SizedBox(height: 9),
        Text(l2, style: const TextStyle(fontSize: 9.5, color: AppColors.inkSoft, fontWeight: FontWeight.w650)),
        Text(v2, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w650)),
      ],
    );
  }

  Widget _buildFindShopCard(Shop shop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: const Color(0xFFE5E5E5), borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Find this shop', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 7),
                  Text('📍 ${shop.address ?? '—'}', style: const TextStyle(fontSize: 11, color: AppColors.inkSoft, height: 1.5)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _directions,
                    child: const Text('View on Map / नक्शे पर देखें ›', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.green)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 11),
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(color: AppColors.paper, borderRadius: BorderRadius.circular(11)),
              child: const Icon(Icons.map, color: AppColors.inkFaint),
            ),
          ],
        ),
      ),
    );
  }
}
