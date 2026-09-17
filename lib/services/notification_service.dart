import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles push notifications for the customer app.
///
/// Topics used (must match the notify-worker exactly):
///   customer_all_users        — every customer, auto-subscribed on app start
///   customer_shop_<SHOPID>    — customers who opened that specific shop
///
/// NOTE: Firebase's web SDK does not support subscribeToTopic() at all —
/// calling it throws UnimplementedError on Chrome/web. Since the real app
/// ships as an Android APK and Chrome is only used for quick local testing,
/// every method here simply no-ops on web (via kIsWeb) instead of crashing.
/// Everything works normally on an actual Android/iOS build.
class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Call once, early in main() after Firebase.initializeApp().
  static Future<void> init() async {
    if (kIsWeb) return;

    if (_initialized) return;
    _initialized = true;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _local.initialize(initSettings);

    // Every customer gets announcements/ads/app-update notifications.
    await _messaging.subscribeToTopic('customer_all_users');

    // Foreground messages don't show a system notification by default on
    // Android — this shows one using flutter_local_notifications so the
    // user sees it even while the app is open.
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  /// Call when a customer opens a specific shop, so that shop's
  /// notifications reach them too. Safe to call every time the shop
  /// screen opens — re-subscribing to an already-subscribed topic is a
  /// no-op.
  static Future<void> subscribeToShop(String shopId) async {
    if (kIsWeb) return;
    await _messaging.subscribeToTopic('customer_shop_$shopId');
  }

  static Future<void> _showForegroundNotification(
    RemoteMessage message,
  ) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'shopdekho_default',
      'ShopDekho Notifications',
      channelDescription: 'Announcements, offers, and price updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _local.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      notification.title,
      notification.body,
      details,
    );
  }
}
