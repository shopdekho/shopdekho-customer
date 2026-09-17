/// All backend calls go through these two Cloudflare Workers — exactly the
/// same ones the website (index.html / s/index.html) uses. Nothing else in
/// this app talks to Firestore or GitHub directly.
class ApiConfig {
  ApiConfig._();

  /// Handles: /nearby?lat=&lng=  and  /shop?shopId=  (shop discovery/search)
  static const String discoveryBase =
      'https://shopdekho-customer-discovery.quizpulse-com.workers.dev';

  /// Serves the raw JSON files that used to be read straight from the
  /// private GitHub repo — same folder layout: /website/data/...
  static const String dataBase =
      'https://shopdekho-customer-worker.quizpulse-com.workers.dev/website';

  static String nearbyUrl(double lat, double lng) =>
      '$discoveryBase/nearby?lat=$lat&lng=$lng';

  static String shopByIdUrl(String shopId) =>
      '$discoveryBase/shop?shopId=${Uri.encodeComponent(shopId)}';

  static String masterProductsUrl() => '$dataBase/data/master/products.json';

  static String shopJsonUrl(String city, String shopId) =>
      '$dataBase/data/shops/$city/$shopId.json';

  static String inventoryJsonUrl(String city, String shopId) =>
      '$dataBase/data/products/$city/$shopId.json';

  static String shopsIndexUrl(String city) =>
      '$dataBase/data/shops-index/$city.json';

  /// Shop ID's first 3 letters are the city code (e.g. PRY3GF765 -> PRY),
  /// exactly like getCityFromShopId() in s/index.html.
  static String cityFromShopId(String shopId) =>
      shopId.length >= 3 ? shopId.substring(0, 3).toUpperCase() : shopId.toUpperCase();
}
