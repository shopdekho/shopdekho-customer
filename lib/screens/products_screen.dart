import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_model.dart';
import '../services/qty_helper.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String shopName;
  const ProductsScreen({super.key, required this.shopName});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  bool _grid = true;
  String _activeCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final categories = ['All', ...{for (final p in cart.products) p.category}];
    final products = _activeCategory == 'All'
        ? cart.products
        : cart.products.where((p) => p.category == _activeCategory).toList();
    final bill = cart.calcBill();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        actions: [
          IconButton(
            icon: Icon(_grid ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _grid = !_grid),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = categories[i];
                final active = c == _activeCategory;
                return ChoiceChip(
                  label: Text(c[0].toUpperCase() + c.substring(1)),
                  selected: active,
                  onSelected: (_) => setState(() => _activeCategory = c),
                  selectedColor: AppColors.leaf,
                  labelStyle: TextStyle(
                    color: active ? Colors.white : AppColors.ink,
                    fontWeight: FontWeight.w650,
                    fontSize: 12.5,
                  ),
                  backgroundColor: AppColors.paper,
                  side: const BorderSide(color: AppColors.line),
                );
              },
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('No products in this category.', style: TextStyle(color: AppColors.inkSoft)))
                : Padding(
                    padding: const EdgeInsets.all(14),
                    child: _grid
                        ? GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 9,
                              mainAxisSpacing: 9,
                              childAspectRatio: .62,
                            ),
                            itemCount: products.length,
                            itemBuilder: (_, i) => _GridProductCard(product: products[i]),
                          )
                        : ListView.separated(
                            itemCount: products.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => _ListProductCard(product: products[i]),
                          ),
                  ),
          ),
          if (bill.count > 0)
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(value: cart, child: const CartScreen()),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.greenMid, AppColors.greenDark]),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: Colors.white,
                      child: Text('${bill.count}', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Items', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          Text('₹${bill.total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 15.5)),
                        ],
                      ),
                    ),
                    const Row(children: [
                      Text('View Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                      SizedBox(width: 4),
                      Icon(Icons.chevron_right, color: Colors.white, size: 16),
                    ]),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shared qty control widget used by both grid & list cards, and reused
/// (in read-only-price mode) on the cart screen.
class QtyControl extends StatelessWidget {
  final MergedProduct product;
  const QtyControl({super.key, required this.product});

  Future<void> _openCustomDialog(BuildContext context, CartModel cart) async {
    final controller = TextEditingController();
    String unit = 'g';
    final result = await showDialog<num>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text('Custom Quantity — ${product.name}'),
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(hintText: product.isPieceUnit ? 'Qty (pcs)' : 'Qty'),
                ),
              ),
              if (!product.isPieceUnit) ...[
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: unit,
                  items: const [DropdownMenuItem(value: 'g', child: Text('g')), DropdownMenuItem(value: 'kg', child: Text('kg'))],
                  onChanged: (v) => setSt(() => unit = v ?? 'g'),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final raw = double.tryParse(controller.text) ?? -1;
                final clamped = QtyHelper.clampCustom(isPiece: product.isPieceUnit, rawValue: raw, unit: unit);
                Navigator.pop(ctx, clamped);
              },
              child: const Text('Set'),
            ),
          ],
        ),
      ),
    );
    if (result != null) cart.setQty(product.id, result);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    if (!product.stock) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(color: AppColors.redTint, borderRadius: BorderRadius.circular(9)),
        alignment: Alignment.center,
        child: const Text('Out of Stock', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700, fontSize: 10.5)),
      );
    }

    final qty = cart.qtyOf(product.id);
    if (qty <= 0) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => cart.setQty(product.id, product.isPieceUnit ? 1 : QtyHelper.gramPresets.first),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
          child: const Text('+ Add', style: TextStyle(fontSize: 11.5)),
        ),
      );
    }

    final presets = product.isPieceUnit ? QtyHelper.piecePresets : QtyHelper.weightPresets;
    final isCustom = !QtyHelper.isPresetValue(product.isPieceUnit, qty);
    final fmt = QtyHelper.format(qty, product.isPieceUnit);
    final subtotal = QtyHelper.subtotalFor(product, qty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: isCustom ? 'custom' : qty.round().toString(),
                isDense: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(fontSize: 10.5, color: AppColors.ink),
                items: [
                  const DropdownMenuItem(value: 'custom', child: Text('Custom Quantity')),
                  ...presets.map((p) {
                    final f = QtyHelper.format(p, product.isPieceUnit);
                    return DropdownMenuItem(value: p.toString(), child: Text('${f.value} ${f.label}'));
                  }),
                ],
                onChanged: (v) {
                  if (v == 'custom') {
                    _openCustomDialog(context, cart);
                  } else if (v != null) {
                    cart.setQty(product.id, num.parse(v));
                  }
                },
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () => cart.remove(product.id),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  border: Border.all(color: AppColors.line),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close, size: 12, color: AppColors.red),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Subtotal: ₹${subtotal.toStringAsFixed(2)}',
            textAlign: TextAlign.right, style: const TextStyle(fontSize: 9.5, color: AppColors.inkSoft)),
        const SizedBox(height: 2),
        Text('${fmt.value} ${fmt.label}', style: const TextStyle(fontSize: 9, color: AppColors.inkFaint)),
      ],
    );
  }
}

class _GridProductCard extends StatelessWidget {
  final MergedProduct product;
  const _GridProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: product.image.isNotEmpty
                      ? Image.network(product.image, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(color: AppColors.paper))
                      : Container(color: AppColors.paper),
                ),
              ),
              if (product.discountPercent != null)
                Positioned(
                  top: 4, left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.leaf, borderRadius: BorderRadius.circular(6)),
                    child: Text('${product.discountPercent}% OFF', style: const TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.w750)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(product.nameHi.isNotEmpty ? product.nameHi : product.name,
              maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
          if (product.nameHi.isNotEmpty)
            Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, color: AppColors.inkSoft)),
          const SizedBox(height: 4),
          Row(children: [
            Text('₹${product.price.toStringAsFixed(0)}${product.priceSuffix}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w750)),
            if (product.mrp != null) ...[
              const SizedBox(width: 4),
              Text('₹${product.mrp!.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 10, color: AppColors.inkFaint, decoration: TextDecoration.lineThrough)),
            ],
          ]),
          const SizedBox(height: 6),
          QtyControl(product: product),
        ],
      ),
    );
  }
}

class _ListProductCard extends StatelessWidget {
  final MergedProduct product;
  const _ListProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(11),
            child: SizedBox(
              width: 66, height: 66,
              child: product.image.isNotEmpty
                  ? Image.network(product.image, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: AppColors.paper))
                  : Container(color: AppColors.paper),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.nameHi.isNotEmpty ? product.nameHi : product.name,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w750)),
                if (product.nameHi.isNotEmpty)
                  Text(product.name, style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                const SizedBox(height: 4),
                Row(children: [
                  Text('₹${product.price.toStringAsFixed(0)}${product.priceSuffix}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w750)),
                  if (product.mrp != null) ...[
                    const SizedBox(width: 6),
                    Text('₹${product.mrp!.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.inkFaint, decoration: TextDecoration.lineThrough)),
                  ],
                ]),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 130, child: QtyControl(product: product)),
        ],
      ),
    );
  }
}
