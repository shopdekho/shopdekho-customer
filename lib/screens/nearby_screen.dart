import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/shop.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import 'shop_screen.dart';
import 'search_screen.dart';

enum _NearbyState { loading, denied, error, empty, loaded }

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});
  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  final _api = ApiService();
  final _loc = LocationService();

  _NearbyState _state = _NearbyState.loading;
  String _title = 'Requesting location…';
  String _text = 'Allow location access to find vegetable shops near you.';
  List<Shop> _shops = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _state = _NearbyState.loading;
      _title = 'Requesting location…';
      _text = 'Allow location access to find vegetable shops near you.';
    });

    late final Position position;
    try {
      position = await _loc.requestLocation();
    } on LocationException catch (e) {
      setState(() {
        if (e.reason == LocationFailure.permissionDenied) {
          _state = _NearbyState.denied;
          _title = 'Location access denied';
          _text = 'Location permission is required to find nearby shops.';
        } else {
          _state = _NearbyState.error;
          _title = 'Could not get your location';
          _text = 'Please check your device settings and try again.';
        }
      });
      return;
    }

    setState(() {
      _title = 'Finding shops near you…';
      _text = '';
    });

    try {
      final raw = await _api.fetchNearbyShops(position.latitude, position.longitude);
      final withDistance = raw
          .map((s) => s.copyWithDistance(
              LocationService.haversineKm(position.latitude, position.longitude, s.latitude, s.longitude)))
          .where((s) => (s.distanceKm ?? 999) <= LocationService.nearbyRadiusKm)
          .toList()
        ..sort((a, b) => (a.distanceKm ?? 0).compareTo(b.distanceKm ?? 0));

      setState(() {
        _shops = withDistance;
        _state = withDistance.isEmpty ? _NearbyState.empty : _NearbyState.loaded;
        _title = 'No nearby vegetable shops found.';
        _text = 'Try searching by Shop ID instead.';
      });
    } catch (_) {
      setState(() {
        _state = _NearbyState.error;
        _title = 'Could not load nearby shops';
        _text = 'Please check your connection and try again.';
      });
    }
  }

  void _openShop(String shopId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ShopScreen(shopId: shopId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Shops')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_state == _NearbyState.loaded) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: AppColors.leafTint,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.leafDark, size: 16),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Text('Location Active\nShops near you',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.leafDark)),
                      ),
                      IconButton(onPressed: _load, icon: const Icon(Icons.refresh, size: 18, color: AppColors.leafDark)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                ..._shops.map((s) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ShopCard(shop: s, onTap: () => _openShop(s.shopId)),
                    )),
                _FindMoreCard(onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const SearchScreen()))),
              ] else
                _StateBlock(
                  state: _state,
                  title: _title,
                  text: _text,
                  onRetry: _load,
                  onSearchInstead: () => Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StateBlock extends StatelessWidget {
  final _NearbyState state;
  final String title;
  final String text;
  final VoidCallback onRetry;
  final VoidCallback onSearchInstead;

  const _StateBlock({
    required this.state,
    required this.title,
    required this.text,
    required this.onRetry,
    required this.onSearchInstead,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.info_outline;
    if (state == _NearbyState.denied) icon = Icons.location_disabled;
    if (state == _NearbyState.error) icon = Icons.warning_amber_rounded;
    if (state == _NearbyState.empty) icon = Icons.shopping_basket_outlined;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 20),
      child: Column(
        children: [
          if (state == _NearbyState.loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3)),
            )
          else
            Icon(icon, size: 26, color: AppColors.inkFaint),
          const SizedBox(height: 6),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
          if (text.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.5, height: 1.6, color: AppColors.inkSoft)),
          ],
          if (state == _NearbyState.error || state == _NearbyState.denied) ...[
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Try Again')),
          ],
          if (state == _NearbyState.error || state == _NearbyState.denied || state == _NearbyState.empty) ...[
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onSearchInstead, child: const Text('Search by Shop ID')),
          ],
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onTap;
  const _ShopCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: shop.logo != null && shop.logo!.isNotEmpty
                        ? Image.network(shop.logo!, width: 64, height: 64, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _thumbFallback())
                        : _thumbFallback(),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(shop.shopName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                            ),
                            if (shop.verified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, size: 12, color: AppColors.leafDark),
                            ],
                          ],
                        ),
                        if (shop.address != null && shop.address!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.location_on, size: 10, color: AppColors.inkFaint),
                            const SizedBox(width: 4),
                            Expanded(child: Text(shop.address!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft))),
                          ]),
                        ],
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.straighten, size: 10, color: AppColors.inkFaint),
                          const SizedBox(width: 4),
                          Text(LocationService.formatDistance(shop.distanceKm ?? 0),
                              style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft)),
                        ]),
                        const SizedBox(height: 6),
                        Wrap(spacing: 10, children: [
                          if (shop.rating != null)
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.star, size: 12, color: AppColors.orangeDark),
                              const SizedBox(width: 3),
                              Text('${shop.rating}${shop.reviewCount > 0 ? ' (${shop.reviewCount})' : ''}',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.orangeDark)),
                            ]),
                          if (shop.homeDelivery)
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              const Icon(Icons.moped, size: 12, color: AppColors.leafDark),
                              const SizedBox(width: 3),
                              const Text('Home Delivery',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.leafDark)),
                            ]),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: shop.isCurrentlyOpen ? AppColors.leafTint : AppColors.redTint,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(shop.isCurrentlyOpen ? 'Open' : 'Closed',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: shop.isCurrentlyOpen ? AppColors.leafDark : AppColors.red)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(onPressed: onTap, child: const Text('View Shop')),
          ),
        ],
      ),
    );
  }

  Widget _thumbFallback() {
    return Container(
      width: 64,
      height: 64,
      color: AppColors.leafTint,
      child: const Icon(Icons.storefront, color: AppColors.leafDark),
    );
  }
}

class _FindMoreCard extends StatelessWidget {
  final VoidCallback onTap;
  const _FindMoreCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCFE0D4), width: 1.5),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.leaf, size: 16),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Can't find any shop near you?",
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                  Text('Try searching by Shop ID', style: TextStyle(fontSize: 11, color: AppColors.inkSoft)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.inkFaint),
          ],
        ),
      ),
    );
  }
}
