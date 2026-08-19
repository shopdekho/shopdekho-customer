import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/cart_model.dart';
import '../services/qty_helper.dart';
import '../theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.greenMid, AppColors.greenDark]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: const Column(
                  children: [
                    Text('🧺', style: TextStyle(fontSize: 34)),
                    SizedBox(height: 4),
                    Text('Your Bill', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17.5)),
                    SizedBox(height: 7),
                    Text('Show this screen to the shopkeeper', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Table(
                    columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1), 2: FlexColumnWidth(1)},
                    children: [
                      const TableRow(children: [
                        Padding(padding: EdgeInsets.symmetric(vertical: 7), child: Text('Item', style: TextStyle(fontSize: 10.5, color: AppColors.inkSoft, fontWeight: FontWeight.w700))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 7), child: Text('Qty', style: TextStyle(fontSize: 10.5, color: AppColors.inkSoft, fontWeight: FontWeight.w700))),
                        Padding(padding: EdgeInsets.symmetric(vertical: 7), child: Text('Amount', textAlign: TextAlign.right, style: TextStyle(fontSize: 10.5, color: AppColors.inkSoft, fontWeight: FontWeight.w700))),
                      ]),
                      ...bill.items.map((it) {
                        final fmt = QtyHelper.format(it.qty, it.product.isPieceUnit);
                        return TableRow(children: [
                          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(it.product.name, style: const TextStyle(fontSize: 12.5))),
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
                  decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.line, style: BorderStyle.solid))),
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
      return '${it.product.name} - ${fmt.value}${fmt.label} - ₹${it.subtotal.toStringAsFixed(2)}';
    }).join('\n');
    Share.share('$lines\nTotal: ₹${bill.total.toStringAsFixed(2)}');
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    final bill = cart.calcBill();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart / Bill Summary')),
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
                  child: ListView(
                    padding: const EdgeInsets.all(14),
                    children: [
                      ...bill.items.map((it) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: AppColors.line),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 54, height: 54,
                                      child: it.product.image.isNotEmpty
                                          ? Image.network(it.product.image, fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Container(color: AppColors.paper))
                                          : Container(color: AppColors.paper),
                                    ),
                                  ),
                                  const SizedBox(width: 11),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(it.product.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                        Text(
                                          '${QtyHelper.format(it.qty, it.product.isPieceUnit).value} ${QtyHelper.format(it.qty, it.product.isPieceUnit).label}',
                                          style: const TextStyle(fontSize: 11.5, color: AppColors.inkSoft),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text('₹${it.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                                  IconButton(
                                    icon: const Icon(Icons.close, size: 16, color: AppColors.red),
                                    onPressed: () => cart.remove(it.product.id),
                                  ),
                                ],
                              ),
                            ),
                          )),
                      Container(
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
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 11, 16, 16),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: AppColors.line)),
                  ),
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
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Show to Shopkeeper'),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
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
