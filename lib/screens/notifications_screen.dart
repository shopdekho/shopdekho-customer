import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await NotificationService.getHistory();
    // Clears the badge — opening this screen counts as "seen".
    await NotificationService.markAllRead();
    if (!mounted) return;
    setState(() {
      _items = history;
      _loading = false;
    });
  }

  Future<void> _deleteAt(int index) async {
    final removed = _items[index];
    setState(() => _items.removeAt(index));
    await NotificationService.deleteAt(index);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted "${removed['title'] ?? ''}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all notifications?'),
        content: const Text('This can\'t be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await NotificationService.clearAll();
    if (!mounted) return;
    setState(() => _items = []);
  }

  IconData _iconFor(String type) {
    switch (type) {
      case 'price_update':
        return Icons.price_change_rounded;
      case 'offer':
        return Icons.local_offer_rounded;
      case 'update':
        return Icons.system_update_rounded;
      case 'shop':
        return Icons.storefront_rounded;
      case 'trust':
        return Icons.verified_user_rounded;
      default:
        return Icons.campaign_rounded;
    }
  }

  String _relativeTime(String iso) {
    try {
      final d = DateTime.parse(iso);
      final diff = DateTime.now().difference(d);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${d.day}/${d.month}/${d.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F7),
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: _clearAll,
              child: const Text('Clear All', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.green))
          : _items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔔', style: TextStyle(fontSize: 44)),
                      const SizedBox(height: 12),
                      const Text('No notifications yet',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "You'll see price updates, offers, and announcements here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(14),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final item = _items[i];
                    // A stable-ish key so Dismissible tracks the right item
                    // even as the list shrinks after a delete.
                    final key = ValueKey('${item['timestamp']}_${item['title']}');

                    return Dismissible(
                      key: key,
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _deleteAt(i),
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE4EAE4)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.025),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.green.withOpacity(.10),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _iconFor(item['type'] as String? ?? 'announcement'),
                                size: 19,
                                color: AppColors.green,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] as String? ?? '',
                                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item['body'] as String? ?? '',
                                    style: const TextStyle(fontSize: 12, color: AppColors.inkSoft, height: 1.35),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _relativeTime(item['timestamp'] as String? ?? ''),
                                    style: const TextStyle(fontSize: 10.5, color: AppColors.inkFaint),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
