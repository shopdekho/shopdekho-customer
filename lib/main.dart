
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
      backgroundColor: const Color(0xFF123D32),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFA7D8B9),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Center(
                child: Text(
                  'V',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'VisibleOn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 27,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'YOUR NEIGHBORHOOD. CONNECTED.',
              style: TextStyle(
                color: Color(0xFFC4E5D3),
                fontSize: 10,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFA7D8B9),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
