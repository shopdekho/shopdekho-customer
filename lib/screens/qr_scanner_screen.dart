import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'shop_screen.dart';
import 'search_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});
  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // Only accepts https://shopdekho.the-web.top/s/{SHOP_ID} — same as the
  // website's validateShopDekhoQrUrl(), no custom/alternate QR format.
  static const _hostname = 'shopdekho.the-web.top';
  final _controller = MobileScannerController();
  bool _handled = false;
  String? _errorText;

  String? _validate(String raw) {
    try {
      final uri = Uri.parse(raw);
      if (uri.scheme != 'https') return null;
      if (uri.host != _hostname) return null;
      final match = RegExp(r'^/s/([A-Za-z0-9]{4,20})$').firstMatch(uri.path);
      if (match == null) return null;
      return match.group(1)!.toUpperCase();
    } catch (_) {
      return null;
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes.isNotEmpty ? capture.barcodes.first.rawValue : null;
    if (raw == null) return;

    final shopId = _validate(raw);
    if (shopId == null) {
      setState(() => _errorText = 'Invalid ShopDekho QR');
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _errorText = null);
      });
      return;
    }

    _handled = true;
    _controller.stop();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ShopScreen(shopId: shopId)));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0D),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(.12)),
                  ),
                  const Expanded(
                    child: Text('Scan Shop QR',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF3DBE68), fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                  IconButton(
                    onPressed: () => _controller.toggleTorch(),
                    icon: const Icon(Icons.bolt, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.white.withOpacity(.12)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  MobileScanner(controller: _controller, onDetect: _onDetect),
                  Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF3DBE68), width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const Positioned(
                    top: 60,
                    child: _Pill(text: 'Scan the ShopDekho QR code'),
                  ),
                  if (_errorText != null)
                    Positioned(
                      bottom: 120,
                      child: _Pill(text: _errorText!, isError: true),
                    ),
                  Positioned(
                    bottom: 20,
                    child: TextButton(
                      onPressed: () => Navigator.pushReplacement(
                          context, MaterialPageRoute(builder: (_) => const SearchScreen())),
                      child: const Text('Search Shop ID instead',
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool isError;
  const _Pill({required this.text, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: isError ? Colors.red.withOpacity(.75) : Colors.black.withOpacity(.55),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
    );
  }
}
