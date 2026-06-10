import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/notification_provider.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/empty_state.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCountAsync = ref.watch(unreadCountProvider);

    final notifications = notificationsAsync.asData?.value ?? [];
    final unreadCount = unreadCountAsync.asData?.value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () => _markAllRead(context, notifications),
              icon: const Icon(Icons.done_all, size: 18),
              label: const Text('Baca Semua'),
            ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? ListView(children: const [
                SizedBox(height: 80),
                EmptyState(icon: Icons.notifications_off_outlined, title: 'Tidak Ada Notifikasi', message: 'Anda akan mendapat notifikasi saat ada aktivitas'),
              ])
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: notifications.length,
                itemBuilder: (context, index) => _buildNotificationItem(context, isDark, notifications[index], index),
              ),
      ),
    );
  }

  void _markAllRead(BuildContext context, List<Map<String, dynamic>> notifications) async {
    final batch = FirebaseFirestore.instance.batch();
    final unread = notifications.where((n) => n['is_read'] == false);
    for (final n in unread) {
      batch.update(FirebaseFirestore.instance.collection('notifications').doc(n['id'] as String), {'is_read': true});
    }
    await batch.commit();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua notifikasi ditandai sudah dibaca')));
  }

  Widget _buildNotificationItem(BuildContext context, bool isDark, Map<String, dynamic> notif, int index) {
    final isRead = notif['is_read'] as bool? ?? false;
    final type = notif['type'] as String? ?? 'system';
    final title = notif['title'] as String? ?? '';
    final body = notif['body'] as String? ?? '';
    final createdAt = notif['createdAt'] != null ? (notif['createdAt'] as Timestamp).toDate() : DateTime.now();

    Color iconColor;
    IconData iconData;
    switch (type) {
      case 'pickup': iconColor = AppColors.info; iconData = Icons.local_shipping; break;
      case 'reward': iconColor = AppColors.warning; iconData = Icons.card_giftcard; break;
      case 'achievement': iconColor = AppColors.gold; iconData = Icons.emoji_events; break;
      default: iconColor = AppColors.primary; iconData = Icons.notifications_rounded; break;
    }

    final timeStr = _formatTime(createdAt);

    return Dismissible(
      key: Key(notif['id'] as String? ?? index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
        child: Icon(Icons.delete_outline, color: AppColors.error),
      ),
      onDismissed: (_) async {
        await FirebaseFirestore.instance.collection('notifications').doc(notif['id'] as String).delete();
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: 6),
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: InkWell(
            onTap: () async {
              if (!isRead) {
                await FirebaseFirestore.instance.collection('notifications').doc(notif['id'] as String).update({'is_read': true});
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(iconData, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(title, style: TextStyle(fontSize: 14, fontWeight: isRead ? FontWeight.w600 : FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
                        if (!isRead) Container(width: 8, height: 8, decoration: BoxDecoration(color: isDark ? AppColors.secondary : AppColors.primary, shape: BoxShape.circle)),
                      ]),
                      const SizedBox(height: 4),
                      Text(body, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(timeStr, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.6) : AppColors.textHint)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 60).ms).slideX(begin: 20, duration: 300.ms);
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
