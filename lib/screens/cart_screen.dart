import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/cart_model.dart';
import '../services/qty_helper.dart';
import '../theme/app_theme.dart';
import 'products_screen.dart';

class CartScreen extends StatefulWidget {
  final String shopName;
  final String shopId;

  const CartScreen({
    super.key,
    required this.shopName,
    required this.shopId,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _grid = true;

  void _showShopkeeperModal(BuildContext context, CartModel cart) {
    final bill = cart.calcBill();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 560),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.greenMid, AppColors.greenDark]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    const Text('🏪', style: TextStyle(fontSize: 30)),
                    const SizedBox(height: 6),
                    Text(
                      widget.shopName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17.5),
                    ),
                    const SizedBox(height: 7),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Store ID: ${widget.shopId}',
                        style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text('Show this screen to the shopkeeper', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Table(
                    columnWidths: const {0: FlexColumnWidth(2.2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
                    children: [
                      const TableRow(children: [
                        Padding(padding: EdgeInsets.symmetric(vertical: 7), child: Text('Item', style: TextStyle(fontSize: 10.5, color: AppColors.inkSoft, fontWeight: FontWeight.w700))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 7), child: Text('Qty', style: TextStyle(fontSize: 10.5, color: AppColors.inkSoft, fontWeight: FontWeight.w700))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 7), child: Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontSize: 10.5, color: AppColors.inkSoft, fontWeight: FontWeight.w700))),
                      ]),
                      ...bill.items.map((it) {
                        final fmt = QtyHelper.format(it.qty, it.product.isPieceUnit);
                        return TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(productBillLabel(it.product), style: const TextStyle(fontSize: 12.5)),
                          ),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${fmt.value} ${fmt.label}', style: const TextStyle(fontSize: 12.5))),
                          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('₹${it.subtotal.toStringAsFixed(2)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700))),
                        ]);
                      }),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.only(top: 13),
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text('₹${bill.total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 21, color: AppColors.green)),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('Thank you! 😊', style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _shareBill(bill),
                        child: const Text('Share / Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareBill(BillSummary bill) {
    final lines = bill.items.map((it) {
      final fmt = QtyHelper.format(it.qty, it.product.isPieceUnit);
      return '${productBillLabel(it.product)} - ${fmt.value}${fmt.label} - ₹${it.subtotal.toStringAsFixed(2)}';
    }).join('\n');
    Share.share(
      '${widget.shopName} (Store ID: ${widget.shopId})\n\n'
      '$lines\n'
      'Total: ₹${bill.total.toStringAsFixed(2)}\n\n'
      'https://shopdekho.the-web.top/s/${widget.shopId}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final bill = cart.calcBill();
    final items = bill.items.map((it) => it.product).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        title: const Text('Cart / Bill Summary'),
        actions: [
          if (bill.count > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ViewToggle(isGrid: _grid, onChanged: (v) => setState(() => _grid = v)),
            ),
        ],
      ),
      body: bill.count == 0
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 10),
                  const Text('Your cart is empty', style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Add some vegetables from the list to see your bill here.',
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft)),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Browse Vegetables'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                    // Reuses the exact same cards as the product list — quantity
                    // stays fully editable here too, and the corner "✕" removes
                    // the item, matching the website's cart grid/list.
                    child: _grid
                        ? GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 9,
                              mainAxisSpacing: 9,
                              mainAxisExtent: 205,
                            ),
                            itemCount: items.length,
                            itemBuilder: (_, i) => ProductGridCard(product: items[i]),
                          )
                        : ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) => ProductListCard(product: items[i]),
                          ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.line),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    children: [
                      _billRow('Subtotal', '₹${bill.subtotal.toStringAsFixed(2)}'),
                      if (bill.discount > 0)
                        _billRow('Discount (Special Offer)', '− ₹${bill.discount.toStringAsFixed(2)}', color: AppColors.green),
                      _billRow('Delivery Charges', '₹${bill.delivery.toStringAsFixed(2)}', muted: true),
                      const Divider(height: 20),
                      _billRow('Total Amount', '₹${bill.total.toStringAsFixed(2)}', bold: true),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 11, 14, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Payable', style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft)),
                          Text('₹${bill.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 9),
                      ElevatedButton.icon(
                        onPressed: () => _showShopkeeperModal(context, cart),
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('Show to Shopkeeper'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _billRow(String label, String value, {bool muted = false, bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: bold ? 16 : 13.5, color: muted ? AppColors.inkSoft : AppColors.ink, fontWeight: bold ? FontWeight.w800 : FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: bold ? 16 : 13.5, color: color ?? (bold ? AppColors.green : AppColors.ink), fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}