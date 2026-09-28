import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../firebase_options.dart';

/// Handles push notifications for the customer app: permission, topic
/// subscriptions, foreground display, and a persisted notification
/// history that backs the bell icon's badge + inbox screen.
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

  static const _storageKey = 'notification_history';
  static const _maxStored = 50;

  /// Live unread count — the home screen's bell badge listens to this via
  /// a ValueListenableBuilder, so it updates instantly without a rebuild
  /// hack. Populated from storage on app start via [loadUnreadCount].
  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

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

    // Foreground messages: show a system notification (Android doesn't do
    // this automatically while the app is open) AND record it to history.
    FirebaseMessaging.onMessage.listen((message) {
      _showForegroundNotification(message);
      _recordNotification(message);
    });

    // Notifications that arrive while the app is backgrounded/terminated
    // are handled by firebaseMessagingBackgroundHandler (top-level
    // function below) — registered separately in main.dart.

    await loadUnreadCount();
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

  // ==========================================================
  // HISTORY (backs the bell icon + inbox screen)
  // ==========================================================

  /// Saves an incoming message to local history. Safe to call from the
  /// background isolate too (SharedPreferences works there).
  static Future<void> _recordNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    final list = raw
        .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
        .toList();

    list.insert(0, {
      'title': notification.title ?? '',
      'body': notification.body ?? '',
      'type': message.data['type'] ?? 'announcement',
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    });

    if (list.length > _maxStored) {
      list.removeRange(_maxStored, list.length);
    }

    await prefs.setStringList(
      _storageKey,
      list.map((e) => jsonEncode(e)).toList(),
    );

    await _refreshUnreadCount();
  }

  /// Returns all stored notifications, newest first.
  static Future<List<Map<String, dynamic>>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    return raw.map((e) => Map<String, dynamic>.from(jsonDecode(e))).toList();
  }

  /// Marks every stored notification as read and clears the badge — call
  /// this when the notifications/inbox screen opens.
  static Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    final list = raw
        .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
        .toList();

    for (final item in list) {
      item['read'] = true;
    }

    await prefs.setStringList(
      _storageKey,
      list.map((e) => jsonEncode(e)).toList(),
    );

    unreadCount.value = 0;
  }

  /// Removes a single notification (swipe-to-delete on the inbox screen).
  /// [index] refers to position in the newest-first list from [getHistory].
  static Future<void> deleteAt(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    if (index < 0 || index >= raw.length) return;
    raw.removeAt(index);
    await prefs.setStringList(_storageKey, raw);
    await _refreshUnreadCount();
  }

  /// Removes every stored notification ("Clear all").
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    unreadCount.value = 0;
  }

  /// Recomputes the badge count from storage. Call on app start so the
  /// badge is correct even after notifications arrived while the app was
  /// fully closed.
  static Future<void> loadUnreadCount() async {
    if (kIsWeb) return;
    final list = await getHistory();
    unreadCount.value = list.where((e) => e['read'] != true).length;
  }

  static Future<void> _refreshUnreadCount() => loadUnreadCount();
}

/// Handles a push notification that arrives while the app is backgrounded
/// or fully closed. Firebase requires this to be a top-level (not class
/// member) function, and it may run in a fresh isolate — so it re-inits
/// Firebase itself before touching anything Firebase-related.
///
/// Registered once in main.dart via:
///   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService._recordNotification(message);
}
