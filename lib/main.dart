
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final startupFuture = initializeApp();

  runApp(ShopDekhoApp(startupFuture: startupFuture));
}

Future<void> initializeApp() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  NotificationService.init();
}

class ShopDekhoApp extends StatelessWidget {
  final Future<void> startupFuture;

  const ShopDekhoApp({
    super.key,
    required this.startupFuture,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VisibleOn',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: FutureBuilder<void>(
        future: startupFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const VisibleOnSplash();
          }

          if (snapshot.hasError) {
            return const StartupErrorScreen();
          }

          return const HomeScreen();
        },
      ),
    );
  }
}


class VisibleOnSplash extends StatelessWidget {
  const VisibleOnSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003D30),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final h = constraints.maxHeight;
          final w = constraints.maxWidth;

          return Stack(
            children: [
              // Background and decorative artwork
              Positioned.fill(
                child: CustomPaint(
                  painter: VisibleOnBackgroundPainter(),
                ),
              ),

              // Main branding
              Positioned(
                top: h * 0.365,
                left: 12,
                right: 12,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Visible',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 46,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -2.0,
                            ),
                          ),
                          TextSpan(
                            text: 'On',
                            style: const TextStyle(
                              color: Color(0xFF8DF000),
                              fontSize: 46,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -2.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 2),

                    // Green underline accent
                    Container(
                      width: 125,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8DF000),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),

                    const SizedBox(height: 23),

                    const Text(
                      'DISCOVER YOUR NEARBY SHOPS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.2,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Location pin with horizontal lines
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: w * 0.22,
                          height: 2,
                          color: const Color(0xFF8DF000),
                        ),
                        const SizedBox(width: 18),
                        const Icon(
                          Icons.location_on,
                          color: Color(0xFF8DF000),
                          size: 38,
                        ),
                        const SizedBox(width: 18),
                        Container(
                          width: w * 0.22,
                          height: 2,
                          color: const Color(0xFF8DF000),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}


/// Lightweight vector artwork. No image assets required.
class VisibleOnBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bg = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF00372D),
          Color(0xFF002D27),
          Color(0xFF003F30),
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRect(Offset.zero & size, bg);

    // Top-left decorative waves
    final wavePaint = Paint()
      ..color = const Color(0xFF087C39)
      ..style = PaintingStyle.fill;

    final wave1 = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.40, 0)
      ..cubicTo(w * 0.25, h * 0.025, w * 0.20, h * 0.10, 0, h * 0.15)
      ..close();

    canvas.drawPath(wave1, wavePaint);

    final wave2 = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.22, 0)
      ..cubicTo(w * 0.14, h * 0.025, w * 0.10, h * 0.065, 0, h * 0.095)
      ..close();

    canvas.drawPath(
      wave2,
      Paint()..color = const Color(0xFF39B82F),
    );

    // Subtle top wave border
    final border = Paint()
      ..color = const Color(0xFF6AD94A).withOpacity(0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final borderPath = Path()
      ..moveTo(0, h * 0.15)
      ..cubicTo(w * 0.20, h * 0.10, w * 0.25, h * 0.025, w * 0.40, 0);

    canvas.drawPath(borderPath, border);

    // Shop and neighborhood illustration
    final shopPaint = Paint()
      ..color = const Color(0xFF63B69A).withOpacity(0.48)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final shopY = h * 0.805;

    // Left building
    canvas.drawRect(
      Rect.fromLTWH(w * 0.09, shopY + 15, w * 0.15, h * 0.12),
      shopPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(w * 0.12, shopY + 35, 14, 16),
      shopPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(w * 0.18, shopY + 35, 14, 16),
      shopPaint,
    );

    // Right building
    canvas.drawRect(
      Rect.fromLTWH(w * 0.73, shopY + 22, w * 0.17, h * 0.12),
      shopPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(w * 0.77, shopY + 40, 15, 16),
      shopPaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(w * 0.84, shopY + 40, 15, 16),
      shopPaint,
    );

    // Main shop body
    final shopRect = Rect.fromLTWH(
      w * 0.30,
      shopY + 60,
      w * 0.40,
      h * 0.16,
    );

    canvas.drawRect(shopRect, shopPaint);

    // Shop roof
    final roof = Path()
      ..moveTo(w * 0.28, shopY + 60)
      ..lineTo(w * 0.37, shopY + 5)
      ..lineTo(w * 0.63, shopY + 5)
      ..lineTo(w * 0.72, shopY + 60);

    canvas.drawPath(roof, shopPaint);

    // Awning
    final awning = Path()
      ..moveTo(w * 0.31, shopY + 38)
      ..lineTo(w * 0.69, shopY + 38);

    canvas.drawPath(awning, shopPaint);

    for (int i = 0; i < 6; i++) {
      final x = w * 0.32 + i * w * 0.06;
      canvas.drawLine(
        Offset(x, shopY + 38),
        Offset(x, shopY + 59),
        shopPaint,
      );
    }

    // Door
    canvas.drawRect(
      Rect.fromLTWH(w * 0.37, shopY + 82, w * 0.10, h * 0.13),
      shopPaint,
    );

    // Shop window
    canvas.drawRect(
      Rect.fromLTWH(w * 0.52, shopY + 82, w * 0.12, h * 0.09),
      shopPaint,
    );

    // Small plants
    final plantPaint = Paint()
      ..color = const Color(0xFF48A87A).withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 4; i++) {
      final x = w * 0.25 + i * 9.0;
      canvas.drawLine(
        Offset(x, shopY + 125),
        Offset(x - 3, shopY + 105),
        plantPaint,
      );
      canvas.drawCircle(
        Offset(x - 4, shopY + 105),
        5,
        plantPaint,
      );
    }

    // Bottom decorative waves
    final bottomWave = Path()
      ..moveTo(0, h * 0.94)
      ..cubicTo(w * 0.30, h * 0.99, w * 0.63, h * 0.95, w, h * 0.91)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    canvas.drawPath(
      bottomWave,
      Paint()..color = const Color(0xFF075A37),
    );

    final bottomBorder = Path()
      ..moveTo(0, h * 0.94)
      ..cubicTo(w * 0.30, h * 0.99, w * 0.63, h * 0.95, w, h * 0.91);

    canvas.drawPath(
      bottomBorder,
      Paint()
        ..color = const Color(0xFF8DF000)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF123D32),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'App start nahi ho paya.\nPlease try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
