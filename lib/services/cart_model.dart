import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/qty_helper.dart';

class CartLine {
  final MergedProduct product;
  final num qty;
  final double subtotal;
  CartLine({required this.product, required this.qty, required this.subtotal});
}

class BillSummary {
  final List<CartLine> items;
  final double subtotal;
  final double discount;
  final double delivery;
  final double total;
  final int count;
  BillSummary({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.delivery,
    required this.total,
    required this.count,
  });
}

/// One CartModel is created per shop visit (see ShopDetailScreen) — matches
/// the website's QTY_STATE map which is scoped to whichever shop's page is open.
class CartModel extends ChangeNotifier {
  final Map<String, num> _qtyState = {};
  List<MergedProduct> products = [];

  num qtyOf(String productId) => _qtyState[productId] ?? 0;

  void setQty(String productId, num qty) {
    if (qty <= 0) {
      _qtyState.remove(productId);
    } else {
      _qtyState[productId] = qty;
    }
    notifyListeners();
  }

  void remove(String productId) => setQty(productId, 0);

  void clear() {
    _qtyState.clear();
    notifyListeners();
  }

  /// Same discount rule as the website: flat ₹10 off once subtotal >= ₹100.
  BillSummary calcBill() {
    final items = <CartLine>[];
    double subtotal = 0;
    for (final p in products) {
      final qty = qtyOf(p.id);
      if (qty > 0) {
        final sub = QtyHelper.subtotalFor(p, qty);
        subtotal += sub;
        items.add(CartLine(product: p, qty: qty, subtotal: sub));
      }
    }
    final discount = subtotal >= 100 ? 10.0 : 0.0;
    const delivery = 0.0;
    final total = (subtotal - discount + delivery).clamp(0, double.infinity).toDouble();
    return BillSummary(
      items: items,
      subtotal: subtotal,
      discount: discount,
      delivery: delivery,
      total: total,
      count: items.length,
    );
  }
}
