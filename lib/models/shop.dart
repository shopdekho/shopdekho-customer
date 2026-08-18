class Shop {
  final String shopId;
  final String city;
  final String shopName;
  final String? ownerName;
  final String? mobile;
  final String? address;
  final double latitude;
  final double longitude;
  final String? logo;
  final String? banner;
  final double? rating;
  final int reviewCount;
  final bool verified;
  final bool isOpen;
  final String? openTime; // "07:00"
  final String? closeTime; // "21:00"
  final bool homeDelivery;
  final bool upi;
  final bool parking;
  final bool delivery;
  final String? tagline;
  final String? memberSince;
  final String? lastUpdated;
  final double? distanceKm; // filled in client-side for nearby-shops list

  Shop({
    required this.shopId,
    required this.city,
    required this.shopName,
    this.ownerName,
    this.mobile,
    this.address,
    required this.latitude,
    required this.longitude,
    this.logo,
    this.banner,
    this.rating,
    this.reviewCount = 0,
    this.verified = false,
    this.isOpen = false,
    this.openTime,
    this.closeTime,
    this.homeDelivery = false,
    this.upi = false,
    this.parking = false,
    this.delivery = false,
    this.tagline,
    this.memberSince,
    this.lastUpdated,
    this.distanceKm,
  });

  factory Shop.fromJson(Map<String, dynamic> j) {
    return Shop(
      shopId: j['shopId']?.toString() ?? '',
      city: j['city']?.toString() ?? '',
      shopName: j['shopName']?.toString() ?? j['name']?.toString() ?? 'Unnamed Shop',
      ownerName: j['ownerName']?.toString(),
      mobile: j['mobile']?.toString(),
      address: j['address']?.toString(),
      latitude: _toDouble(j['latitude']),
      longitude: _toDouble(j['longitude']),
      logo: j['logo']?.toString(),
      banner: j['banner']?.toString(),
      rating: j['rating'] == null ? null : _toDouble(j['rating']),
      reviewCount: (j['reviewCount'] as num?)?.toInt() ?? 0,
      verified: j['verified'] == true,
      isOpen: j['isOpen'] == true || j['open'] == true,
      openTime: j['openTime']?.toString(),
      closeTime: j['closeTime']?.toString(),
      homeDelivery: j['homeDelivery'] == true,
      upi: j['upi'] == true,
      parking: j['parking'] == true,
      delivery: j['delivery'] == true,
      tagline: j['tagline']?.toString(),
      memberSince: j['memberSince']?.toString(),
      lastUpdated: j['lastUpdated']?.toString(),
    );
  }

  Shop copyWithDistance(double km) {
    return Shop(
      shopId: shopId,
      city: city,
      shopName: shopName,
      ownerName: ownerName,
      mobile: mobile,
      address: address,
      latitude: latitude,
      longitude: longitude,
      logo: logo,
      banner: banner,
      rating: rating,
      reviewCount: reviewCount,
      verified: verified,
      isOpen: isOpen,
      openTime: openTime,
      closeTime: closeTime,
      homeDelivery: homeDelivery,
      upi: upi,
      parking: parking,
      delivery: delivery,
      tagline: tagline,
      memberSince: memberSince,
      lastUpdated: lastUpdated,
      distanceKm: km,
    );
  }

  /// Same logic as getCurrentShopStatus() in s/index.html — computed live
  /// from openTime/closeTime rather than trusting a possibly-stale isOpen flag.
  bool get isCurrentlyOpen {
    if (openTime == null || closeTime == null) return isOpen;
    try {
      final now = DateTime.now();
      final nowMin = now.hour * 60 + now.minute;
      final op = openTime!.split(':').map(int.parse).toList();
      final cl = closeTime!.split(':').map(int.parse).toList();
      final openMin = op[0] * 60 + op[1];
      final closeMin = cl[0] * 60 + cl[1];
      return nowMin >= openMin && nowMin < closeMin;
    } catch (_) {
      return isOpen;
    }
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
