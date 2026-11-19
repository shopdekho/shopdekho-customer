import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
// `show` keeps zxing2's many exported names (BarcodeFormat, Result, ...)
// from clashing with qr_code_scanner_plus's own names.
import 'package:zxing2/qrcode.dart'
    show
        RGBLuminanceSource,
        BinaryBitmap,
        HybridBinarizer,
        GlobalHistogramBinarizer,
        QRCodeReader;

import 'shop_screen.dart';
import 'search_screen.dart';

/// Decodes a QR code from raw image bytes (a photo/screenshot picked from
/// the gallery). Top-level so it can run in a background isolate via
/// compute() — decoding a large photo on the UI thread would freeze the
/// app for a moment.
///
/// Returns the QR's text, or null if no QR code could be found.
String? _decodeQrFromImageBytes(Uint8List bytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;

  // Downscale very large photos (e.g. 12MP camera shots): slower to
  // decode and no more accurate.
  var image = decoded;
  const maxSide = 1600;
  if (image.width > maxSide || image.height > maxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: maxSide)
        : img.copyResize(image, height: maxSide);
  }

  final candidates = <img.Image>[image];
  // A half-size copy sometimes decodes when the full-size one doesn't
  // (it softens noise/blur in photos of printed QR codes).
  if (image.width > 600 && image.height > 600) {
    candidates.add(img.copyResize(image, width: image.width ~/ 2));
  }

  for (final candidate in candidates) {
    final pixels = candidate
        .convert(numChannels: 4)
        .getBytes(order: img.ChannelOrder.abgr)
        .buffer
        .asInt32List();

    final source =
        RGBLuminanceSource(candidate.width, candidate.height, pixels);

    final bitmaps = [
      BinaryBitmap(HybridBinarizer(source)),
      BinaryBitmap(GlobalHistogramBinarizer(source)),
    ];

    for (final bitmap in bitmaps) {
      try {
        return QRCodeReader().decode(bitmap).text;
      } catch (_) {
        // Not found with this binarizer/scale — try the next combination.
      }
    }
  }

  return null;
}

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
  final ImagePicker _picker = ImagePicker();

  QRViewController? _controller;
  bool _handled = false;
  bool _decoding = false;
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

  void _showError(String message) {
    setState(() => _errorText = message);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _errorText = null);
    });
  }

  void _openShop(String shopId) {
    _handled = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ShopScreen(shopId: shopId)),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    controller.scannedDataStream.listen((scanData) {
      final raw = scanData.code;
      if (_handled || _decoding || raw == null) return;

      final shopId = _validate(raw);
      if (shopId == null) {
        _showError('Invalid ShopDekho QR');
        return;
      }

      controller.pauseCamera();
      _openShop(shopId);
    });
  }

  /// Lets the customer pick a saved QR image (e.g. one shared over
  /// WhatsApp) instead of pointing the camera at another device.
  Future<void> _scanFromGallery() async {
    if (_decoding || _handled) return;

    // The picker opens another screen — pause the live camera meanwhile.
    _controller?.pauseCamera();

    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return; // user cancelled the picker

      setState(() => _decoding = true);

      final bytes = await picked.readAsBytes();
      final raw = await compute(_decodeQrFromImageBytes, bytes);

      if (!mounted) return;

      if (raw == null) {
        _showError('No QR code found in this image');
        return;
      }

      final shopId = _validate(raw);
      if (shopId == null) {
        _showError('Invalid ShopDekho QR');
        return;
      }

      _openShop(shopId);
    } catch (_) {
      if (mounted) _showError('Could not read this image');
    } finally {
      if (mounted) {
        setState(() => _decoding = false);
        if (!_handled) _controller?.resumeCamera();
      }
    }
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
                  // Fixed-width side slots keep the title centered even
                  // though the right side has two buttons.
                  SizedBox(
                    width: 104,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(.12)),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Scan Shop QR',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Color(0xFF3DBE68),
                          fontWeight: FontWeight.w700,
                          fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    width: 104,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Scan from gallery',
                          onPressed: _scanFromGallery,
                          icon: const Icon(Icons.photo_library_rounded,
                              color: Colors.white),
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(.12)),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Flashlight',
                          onPressed: () => _controller?.toggleFlash(),
                          icon: const Icon(Icons.bolt, color: Colors.white),
                          style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(.12)),
                        ),
                      ],
                    ),
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
                  if (_decoding)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black54,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                            color: Color(0xFF3DBE68)),
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
        color: isError
            ? Colors.red.withOpacity(.75)
            : Colors.black.withOpacity(.55),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600)),
    );
  }
}