import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/notification_provider.dart';

class NotificationCenter extends ConsumerWidget {
  const NotificationCenter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);
    final notifications = notificationsAsync.asData?.value ?? [];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40, height: 4,
            decoration: BoxDecoration(color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.3) : Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifikasi', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              ],
            ),
          ),
          const Divider(height: 1),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
            child: notifications.isEmpty
                ? const Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Belum ada notifikasi')))
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: notifications.take(10).length,
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return _NotificationItem(notif: notif, isDark: isDark)
                          .animate().fadeIn(duration: 300.ms, delay: (index * 80).ms).slideX(begin: 0.2, duration: 300.ms, delay: (index * 80).ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final Map<String, dynamic> notif;
  final bool isDark;

  const _NotificationItem({required this.notif, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isRead = notif['is_read'] as bool? ?? false;
    final type = notif['type'] as String? ?? 'system';
    final title = notif['title'] as String? ?? '';
    final body = notif['body'] as String? ?? '';

    Color iconColor;
    IconData iconData;
    switch (type) {
      case 'pickup': iconColor = AppColors.info; iconData = Icons.local_shipping; break;
      case 'reward': iconColor = AppColors.warning; iconData = Icons.card_giftcard; break;
      case 'achievement': iconColor = AppColors.gold; iconData = Icons.emoji_events; break;
      default: iconColor = AppColors.primary; iconData = Icons.notifications_rounded; break;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead ? Colors.transparent : (isDark ? AppColors.cardDark : AppColors.primarySurface).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
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
                  if (!isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                ]),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
