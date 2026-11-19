import '../models/product.dart';

class FormattedQty {
  final num value;
  final String label;
  FormattedQty(this.value, this.label);
}

class QtyHelper {
  QtyHelper._();

  static const int minCustomG = 10;
  static const int maxG = 25000;
  static const int maxPieces = 99;

  static const List<int> gramPresets = [50, 100, 150, 200, 250, 500, 750];

  // KG_PRESETS_G: 1.0kg through 25.0kg in 0.5kg steps -> grams
  static List<int> get kgPresetsG {
    final list = <int>[];
    for (int t = 10; t <= 250; t += 5) {
      list.add(((t / 10) * 1000).round());
    }
    return list;
  }

  static List<int> get weightPresets => [...gramPresets, ...kgPresetsG];

  static const List<int> piecePresets = [
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 15, 20, 25, 30
  ];

  static bool isPresetValue(bool isPiece, num qty) {
    return isPiece ? piecePresets.contains(qty.round()) : weightPresets.contains(qty.round());
  }

  /// Mirrors formatQty() in s/index.html.
  static FormattedQty format(num qty, bool isPiece) {
    if (isPiece) {
      return FormattedQty(qty, qty == 1 ? 'pc' : 'pcs');
    }
    if (qty >= 1000) {
      final kg = ((qty / 1000) * 100).round() / 100;
      return FormattedQty(kg, 'kg');
    }
    return FormattedQty(qty.round(), 'g');
  }

  static double subtotalFor(MergedProduct p, num qty) {
    return p.isPieceUnit ? qty * p.price : (qty / 1000) * p.price;
  }

  /// Clean up a custom-entered quantity the same way handleCustomCommit() does.
  static num? clampCustom({required bool isPiece, required double rawValue, String unit = 'g'}) {
    if (rawValue.isNaN || rawValue <= 0) return null;
    if (isPiece) {
      final n = rawValue.round().clamp(1, maxPieces);
      return n;
    }
    double grams = unit == 'kg' ? rawValue * 1000 : rawValue;
    grams = (grams / 10).round() * 10;
    grams = grams.clamp(minCustomG, maxG).toDouble();
    return grams;
  }
}
