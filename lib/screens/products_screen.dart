import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../services/cart_model.dart';
import '../services/qty_helper.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';

// Combined "English / Hindi" label used in the bill table and the
// shopkeeper modal — matches "Cabbage / पत्तागोभी" on the website.
String productBillLabel(MergedProduct p) {
  return p.nameHi.isNotEmpty ? '${p.name} / ${p.nameHi}' : p.name;
}

class ProductsScreen extends StatefulWidget {
  final String shopName;
  final String shopId;

  const ProductsScreen({
    super.key,
    required this.shopName,
    required this.shopId,
  });

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
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        title: const Text('Product List'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ViewToggle(isGrid: _grid, onChanged: (v) => setState(() => _grid = v)),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final c = categories[i];
                final active = c == _activeCategory;
                return ChoiceChip(
                  label: Text(c.isEmpty ? 'Other' : c[0].toUpperCase() + c.substring(1)),
                  selected: active,
                  onSelected: (_) => setState(() => _activeCategory = c),
                  selectedColor: AppColors.green,
                  showCheckmark: false,
                  labelStyle: TextStyle(
                    color: active ? Colors.white : AppColors.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: active ? AppColors.green : AppColors.line),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Text('No products in this category.', style: TextStyle(color: AppColors.inkSoft)),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
                    child: _grid
                        ? GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 9,
                              mainAxisSpacing: 9,
                              // Fixed pixel height (not childAspectRatio) — with
                              // enough headroom for the qty controls, and every
                              // button below has its default Material tap-target
                              // padding stripped out (that was the real cause of
                              // the overflow, not just lack of height).
                              mainAxisExtent: 205,
                            ),
                            itemCount: products.length,
                            itemBuilder: (_, i) => ProductGridCard(product: products[i]),
                          )
                        : ListView.separated(
                            itemCount: products.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => ProductListCard(product: products[i]),
                          ),
                  ),
          ),
          if (bill.count > 0) _CartBar(bill: bill, shopName: widget.shopName, shopId: widget.shopId, cart: cart),
        ],
      ),
    );
  }
}

class _CartBar extends StatelessWidget {
  final BillSummary bill;
  final String shopName;
  final String shopId;
  final CartModel cart;

  const _CartBar({
    required this.bill,
    required this.shopName,
    required this.shopId,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: cart,
            child: CartScreen(shopName: shopName, shopId: shopId),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppColors.greenMid, AppColors.greenDark]),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: [
            BoxShadow(color: AppColors.green.withOpacity(.28), blurRadius: 16, offset: const Offset(0, 7)),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
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
              Icon(Icons.chevron_right_rounded, color: Colors.white, size: 18),
            ]),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// GRID / LIST TOGGLE — a proper segmented pill control, reused on
// both the Products screen and the Cart screen.
// ============================================================

class ViewToggle extends StatelessWidget {
  final bool isGrid;
  final ValueChanged<bool> onChanged;

  const ViewToggle({super.key, required this.isGrid, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F3F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _segment(icon: Icons.grid_view_rounded, active: isGrid, onTap: () => onChanged(true)),
          _segment(icon: Icons.view_list_rounded, active: !isGrid, onTap: () => onChanged(false)),
        ],
      ),
    );
  }

  Widget _segment({required IconData icon, required bool active, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 34,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.green : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: active
              ? [BoxShadow(color: AppColors.green.withOpacity(.35), blurRadius: 6, offset: const Offset(0, 2))]
              : null,
        ),
        child: Icon(icon, size: 16, color: active ? Colors.white : AppColors.inkFaint),
      ),
    );
  }
}

/// Opens the full-screen product detail sheet — same behaviour as
/// openProductDetail() on the website (image.onclick). Re-provides the
/// SAME CartModel instance to the sheet's subtree so the shared QtyControl
/// widget inside it reads/writes the exact same cart state as the grid and
/// list cards: adding or changing quantity in the popup instantly reflects
/// everywhere else (and vice versa), because it's one CartModel, not a copy.
void openProductDetail(BuildContext context, MergedProduct product) {
  final cart = context.read<CartModel>();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => ChangeNotifierProvider.value(
      value: cart,
      child: _ProductDetailSheet(product: product),
    ),
  );
}

class _ProductDetailSheet extends StatelessWidget {
  final MergedProduct product;

  const _ProductDetailSheet({required this.product});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.88,
      child: Column(
        children: [
          // Small drag handle, like a proper bottom sheet.
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 4),
            child: SizedBox(
              width: 40,
              height: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.all(Radius.circular(3))),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      // A wide ratio (not a full square) so the image never
                      // eats the whole screen height on a portrait phone —
                      // that was pushing the Add/qty control below the fold.
                      AspectRatio(
                        aspectRatio: 1.5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: product.image.isNotEmpty
                              ? Image.network(
                                  product.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(color: AppColors.paper),
                                )
                              : Container(color: AppColors.paper),
                        ),
                      ),
                      if (product.discountPercent != null)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.leaf, borderRadius: BorderRadius.circular(9)),
                            child: Text(
                              '${product.discountPercent}% OFF',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(color: Colors.black.withOpacity(.5), shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.nameHi.isNotEmpty ? product.nameHi : product.name,
                          style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800),
                        ),
                        if (product.nameHi.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            product.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.inkSoft),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '₹${product.price.toStringAsFixed(2)}${product.priceSuffix}',
                              style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800, color: AppColors.greenDark),
                            ),
                            if (product.mrp != null) ...[
                              const SizedBox(width: 9),
                              Text(
                                '₹${product.mrp!.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  color: AppColors.inkFaint,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Sticky footer — always visible, no scrolling needed to add
          // the item or change its quantity.
          Container(
            padding: EdgeInsets.fromLTRB(22, 13, 22, 14 + MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 14, offset: const Offset(0, -4)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('QUANTITY', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppColors.inkFaint, letterSpacing: .5)),
                const SizedBox(height: 6),
                QtyControl(product: product),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SHARED QTY CONTROL
//
// Used by the grid card, list card, product detail popup, and the cart
// screen — one widget, one CartModel, always in sync.
//
// NOTE on the earlier overflow bug: it wasn't really about missing height.
// ElevatedButton/IconButton/DropdownButton all reserve Material's default
// ~48dp tap target no matter what padding you set, unless you explicitly
// zero it out. That's what was silently adding ~20-30px per card. Fixed
// below with `minimumSize: Size.zero` + `tapTargetSize: shrinkWrap`.
// ============================================================

class QtyControl extends StatelessWidget {
  final MergedProduct product;
  final bool showSubtotal;
  const QtyControl({super.key, required this.product, this.showSubtotal = true});

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
                  items: const [
                    DropdownMenuItem(value: 'g', child: Text('g')),
                    DropdownMenuItem(value: 'kg', child: Text('kg')),
                  ],
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
        height: 30,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.greenMid, AppColors.greenDark]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => cart.setQty(product.id, product.isPieceUnit ? 1 : QtyHelper.gramPresets.first),
              child: const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 2),
                    Text('Add', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
              ),
            ),
          ),
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
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF7EC),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AppColors.green.withOpacity(.35)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButtonFormField<String>(
                    value: isCustom ? 'custom' : qty.round().toString(),
                    isDense: true,
                    icon: const Icon(Icons.expand_more_rounded, size: 15, color: AppColors.greenDark),
                    dropdownColor: Colors.white,
                    decoration: const InputDecoration(
                      isDense: true,
                      filled: false,
                      contentPadding: EdgeInsets.symmetric(horizontal: 9, vertical: 0),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 10.5, color: AppColors.greenDark, fontWeight: FontWeight.w800),
                    items: [
                      const DropdownMenuItem(value: 'custom', child: Text('Custom', overflow: TextOverflow.ellipsis)),
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
              ),
            ),
            const SizedBox(width: 5),
            InkWell(
              onTap: () => cart.remove(product.id),
              borderRadius: BorderRadius.circular(9),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDECEC),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AppColors.red.withOpacity(.25)),
                ),
                child: const Icon(Icons.delete_outline_rounded, size: 14, color: AppColors.red),
              ),
            ),
          ],
        ),
        if (showSubtotal) ...[
          const SizedBox(height: 5),
          Text(
            'Subtotal ₹${subtotal.toStringAsFixed(2)}',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 10, color: AppColors.inkSoft, fontWeight: FontWeight.w700),
          ),
        ],
      ],
    );
  }
}

// ============================================================
// REMOVE BADGE — the small circular "✕" pinned to a card's top-right
// corner, matching the website. Only shown once a qty is set.
// ============================================================

class _RemoveBadge extends StatelessWidget {
  final MergedProduct product;
  const _RemoveBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    if (cart.qtyOf(product.id) <= 0) return const SizedBox.shrink();

    return Positioned(
      top: 5,
      right: 5,
      child: InkWell(
        onTap: () => cart.remove(product.id),
        customBorder: const CircleBorder(),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(color: Colors.black.withOpacity(.5), shape: BoxShape.circle),
          child: const Icon(Icons.close_rounded, size: 12, color: Colors.white),
        ),
      ),
    );
  }
}

// ============================================================
// GRID CARD
// ============================================================

class ProductGridCard extends StatelessWidget {
  final MergedProduct product;
  const ProductGridCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.025), blurRadius: 9, offset: const Offset(0, 4)),
        ],
      ),
      // If content is ever taller than the grid's fixed row height, it
      // scrolls internally instead of overflowing.
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => openProductDetail(context, product),
              child: Stack(
                children: [
                  SizedBox(
                    height: 78,
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: product.image.isNotEmpty
                          ? Image.network(
                              product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: AppColors.paper),
                            )
                          : Container(color: AppColors.paper),
                    ),
                  ),
                  if (product.discountPercent != null)
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.leaf, borderRadius: BorderRadius.circular(6)),
                        child: Text(
                          '${product.discountPercent}% OFF',
                          style: const TextStyle(color: Colors.white, fontSize: 7.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  _RemoveBadge(product: product),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.nameHi.isNotEmpty ? product.nameHi : product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            if (product.nameHi.isNotEmpty)
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 9, color: AppColors.inkSoft),
              ),
            const SizedBox(height: 4),
            Row(children: [
              Text('₹${product.price.toStringAsFixed(0)}${product.priceSuffix}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.greenDark)),
              if (product.mrp != null) ...[
                const SizedBox(width: 4),
                Text('₹${product.mrp!.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 10, color: AppColors.inkFaint, decoration: TextDecoration.lineThrough)),
              ],
            ]),
            const SizedBox(height: 6),
            QtyControl(product: product, showSubtotal: false),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LIST CARD
// ============================================================

class ProductListCard extends StatelessWidget {
  final MergedProduct product;
  const ProductListCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.025), blurRadius: 9, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => openProductDetail(context, product),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: SizedBox(
                    width: 66,
                    height: 66,
                    child: product.image.isNotEmpty
                        ? Image.network(product.image, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: AppColors.paper))
                        : Container(color: AppColors.paper),
                  ),
                ),
                if (product.discountPercent != null)
                  Positioned(
                    top: 3,
                    left: 3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.leaf, borderRadius: BorderRadius.circular(5)),
                      child: Text('${product.discountPercent}%',
                          style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w700)),
                    ),
                  ),
                _RemoveBadge(product: product),
              ],
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.nameHi.isNotEmpty ? product.nameHi : product.name,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                if (product.nameHi.isNotEmpty)
                  Text(product.name, style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
                const SizedBox(height: 5),
                Row(children: [
                  Text('₹${product.price.toStringAsFixed(0)}${product.priceSuffix}',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.greenDark)),
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
          SizedBox(width: 128, child: QtyControl(product: product)),
        ],
      ),
    );
  }
}