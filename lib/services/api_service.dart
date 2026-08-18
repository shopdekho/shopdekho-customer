import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/shop.dart';
import '../models/product.dart';
import 'api_config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  final http.Client _client;
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// GET {discoveryBase}/nearby?lat=&lng= — same endpoint as cardNearby flow.
  Future<List<Shop>> fetchNearbyShops(double lat, double lng) async {
    final res = await _client.get(Uri.parse(ApiConfig.nearbyUrl(lat, lng)));
    if (res.statusCode != 200) throw ApiException('API_ERROR');
    final data = jsonDecode(res.body);
    final list = (data is List) ? data : (data['shops'] as List? ?? []);
    return list
        .whereType<Map>()
        .map((e) => Shop.fromJson(Map<String, dynamic>.from(e)))
        .where((s) => s.latitude != 0 || s.longitude != 0)
        .toList();
  }

  /// GET {discoveryBase}/shop?shopId= — used by "Search Shop by ID".
  /// Returns null on 404, same as searchShopById() in index.js.
  Future<Shop?> searchShopById(String shopId) async {
    final res = await _client.get(Uri.parse(ApiConfig.shopByIdUrl(shopId)));
    if (res.statusCode == 404) return null;
    if (res.statusCode != 200) throw ApiException('API_ERROR');
    final data = jsonDecode(res.body);
    return Shop.fromJson(Map<String, dynamic>.from(data));
  }

  /// Loads shop detail + master catalog + this shop's inventory in parallel
  /// and merges them — same three fetches as loadAllData() in s/index.html.
  Future<ShopPageData> loadShopPage(String shopId) async {
    final city = ApiConfig.cityFromShopId(shopId);
    final results = await Future.wait([
      _client.get(Uri.parse(ApiConfig.shopJsonUrl(city, shopId))),
      _client.get(Uri.parse(ApiConfig.masterProductsUrl())),
      _client.get(Uri.parse(ApiConfig.inventoryJsonUrl(city, shopId))),
    ]);

    final shopRes = results[0];
    final masterRes = results[1];
    final invRes = results[2];

    if (shopRes.statusCode != 200) {
      throw ApiException('Shop JSON failed: HTTP ${shopRes.statusCode}');
    }
    if (masterRes.statusCode != 200) {
      throw ApiException('Master JSON failed: HTTP ${masterRes.statusCode}');
    }
    if (invRes.statusCode != 200) {
      throw ApiException('Inventory JSON failed: HTTP ${invRes.statusCode}');
    }

    final shop = Shop.fromJson(Map<String, dynamic>.from(jsonDecode(shopRes.body)));

    final masterJson = jsonDecode(masterRes.body) as Map<String, dynamic>;
    final masterProductsRaw = Map<String, dynamic>.from(masterJson['products'] ?? {});
    final master = <String, MasterProduct>{
      for (final entry in masterProductsRaw.entries)
        entry.key: MasterProduct.fromJson(entry.key, Map<String, dynamic>.from(entry.value)),
    };

    final invJson = jsonDecode(invRes.body) as Map<String, dynamic>;
    final invList = (invJson['products'] as List? ?? [])
        .whereType<Map>()
        .map((e) => InventoryItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final merged = invList.map((inv) => MergedProduct.merge(inv, master)).toList();

    return ShopPageData(shop: shop, products: merged);
  }
}

class ShopPageData {
  final Shop shop;
  final List<MergedProduct> products;
  ShopPageData({required this.shop, required this.products});
}
