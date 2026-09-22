import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'shop_screen.dart';
import 'search_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});
  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  // Only accepts https://shopdekho.the-web.top/s/{SHOP_ID} — same as the
  // website's own QR validation, no custom/alternate QR format.
  static const _hostname = 'shopdekho.the-web.top';

  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? _controller;
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

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) {
      final raw = scanData.code;
      if (_handled || raw == null) return;

      final shopId = _validate(raw);
      if (shopId == null) {
        setState(() => _errorText = 'Invalid ShopDekho QR');
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _errorText = null);
        });
        return;
      }

      _handled = true;
      controller.pauseCamera();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ShopScreen(shopId: shopId)),
      );
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    _controller?.pauseCamera();
    _controller?.resumeCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
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
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(.12)),
                  ),
                  const Expanded(
                    child: Text(
                      'Scan Shop QR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(0xFF3DBE68),
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _controller?.toggleFlash(),
                    icon: const Icon(Icons.bolt, color: Colors.white),
                    style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(.12)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  QRView(
                    key: _qrKey,
                    onQRViewCreated: _onQRViewCreated,
                    overlay: QrScannerOverlayShape(
                      borderColor: const Color(0xFF3DBE68),
                      borderRadius: 16,
                      borderLength: 30,
                      borderWidth: 8,
                      cutOutSize: 260,
                    ),
                  ),
                  const Positioned(
                    top: 20,
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
                        context,
                        MaterialPageRoute(builder: (_) => const SearchScreen()),
                      ),
                      child: const Text(
                        'Search Shop ID instead',
                        style: TextStyle(color: Colors.white70),
                      ),
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
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
    );
  }
}
