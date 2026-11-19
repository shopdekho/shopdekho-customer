/// A raw entry from master/products.json — the shared catalog every
/// merchant picks vegetables from.
class MasterProduct {
  final String id;
  final String name;
  final String nameHi;
  final String image;
  final String unit; // "kg" | "piece" | "bunch"
  final String category;

  MasterProduct({
    required this.id,
    required this.name,
    required this.nameHi,
    required this.image,
    required this.unit,
    required this.category,
  });

  factory MasterProduct.fromJson(String id, Map<String, dynamic> j) {
    return MasterProduct(
      id: id,
      name: j['name']?.toString() ?? id,
      nameHi: j['nameHi']?.toString() ?? '',
      image: j['image']?.toString() ?? '',
      unit: j['unit']?.toString() ?? 'kg',
      category: j['category']?.toString() ?? 'other',
    );
  }
}

/// One line from a shop's products/{city}/{shopId}.json inventory file.
class InventoryItem {
  final String id;
  final double price;
  final double? mrp;
  final bool stock;

  InventoryItem({required this.id, required this.price, this.mrp, this.stock = true});

  factory InventoryItem.fromJson(Map<String, dynamic> j) {
    return InventoryItem(
      id: j['id']?.toString() ?? '',
      price: (j['price'] as num?)?.toDouble() ?? 0.0,
      mrp: (j['mrp'] as num?)?.toDouble(),
      stock: j['stock'] != false,
    );
  }
}

/// Master product + this shop's price/stock, merged — same shape the
/// website builds in mergeProducts(). This is what every screen renders.
class MergedProduct {
  final String id;
  final String name;
  final String nameHi;
  final String image;
  final String unit;
  final String category;
  final double price;
  final double? mrp;
  final bool stock;

  MergedProduct({
    required this.id,
    required this.name,
    required this.nameHi,
    required this.image,
    required this.unit,
    required this.category,
    required this.price,
    this.mrp,
    required this.stock,
  });

  /// unitTypeOf(p) in the website: only "piece" is piece-based, everything
  /// else (kg, bunch, ...) is weight-based (grams internally).
  bool get isPieceUnit => unit == 'piece';

  String get priceSuffix => isPieceUnit ? '/piece' : '/kg';

  int? get discountPercent {
    if (mrp == null || mrp == 0) return null;
    return (100 * (1 - price / mrp!)).round();
  }

  factory MergedProduct.merge(InventoryItem inv, Map<String, MasterProduct> master) {
    final m = master[inv.id];
    return MergedProduct(
      id: inv.id,
      name: m?.name ?? inv.id,
      nameHi: m?.nameHi ?? '',
      image: m?.image ?? '',
      unit: m?.unit ?? 'kg',
      category: m?.category ?? 'other',
      price: inv.price,
      mrp: inv.mrp,
      stock: inv.stock,
    );
  }
}
