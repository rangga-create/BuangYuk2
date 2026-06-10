import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/components/status_badge.dart';
import '../../../shared/components/premium_button.dart';
import '../../../shared/providers/notification_provider.dart';

class AdminNotificationsScreen extends ConsumerStatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  ConsumerState<AdminNotificationsScreen> createState() => _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends ConsumerState<AdminNotificationsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _selectedAudience = 'Semua Pengguna';
  bool _isSending = false;

  final List<String> _audienceOptions = ['Semua Pengguna', 'Warga', 'Petugas', 'Admin'];

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    if (_titleController.text.isEmpty || _bodyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Harap isi judul dan pesan'), backgroundColor: AppColors.warning),
      );
      return;
    }
    setState(() => _isSending = true);
    try {
      final db = FirebaseFirestore.instance;
      final title = _titleController.text.trim();
      final body = _bodyController.text.trim();
      String? roleFilter;
      if (_selectedAudience == 'Warga') roleFilter = 'citizen';
      else if (_selectedAudience == 'Petugas') roleFilter = 'collector';
      else if (_selectedAudience == 'Admin') roleFilter = 'super_admin';

      final batch = db.batch();
      QuerySnapshot userSnap;
      if (roleFilter != null) {
        userSnap = await db.collection('users').where('role', isEqualTo: roleFilter).get();
      } else {
        userSnap = await db.collection('users').get();
      }
      for (final doc in userSnap.docs) {
        final notifRef = db.collection('notifications').doc();
        batch.set(notifRef, {
          'uid': doc.id, 'type': 'system', 'title': title, 'body': body,
          'is_read': false, 'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      _titleController.clear();
      _bodyController.clear();
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notifikasi dikirim ke ${userSnap.docs.length} pengguna'), backgroundColor: AppColors.success),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e'), backgroundColor: AppColors.error));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(allNotificationsProvider);
    final notifications = notificationsAsync.asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Notifikasi')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(gradient: AppColors.accentGradient, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Text('Kirim Notifikasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Judul', hintText: 'Masukkan judul...', prefixIcon: Icon(Icons.title_rounded, size: 22)),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _bodyController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Isi Pesan', hintText: 'Tulis pesan...', prefixIcon: Icon(Icons.message_rounded, size: 22), alignLabelWithHint: true),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedAudience,
                      decoration: const InputDecoration(labelText: 'Target Audiens', prefixIcon: Icon(Icons.people_rounded, size: 22)),
                      items: _audienceOptions.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
                      onChanged: (v) => setState(() => _selectedAudience = v!),
                    ),
                    const SizedBox(height: 20),
                    PremiumButton(
                      text: _isSending ? 'Mengirim...' : 'Kirim Sekarang',
                      icon: Icons.send_rounded,
                      isLoading: _isSending,
                      onPressed: _sendNotification,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms).moveY(begin: 15, duration: 300.ms),
              const SizedBox(height: 28),
              SectionHeader(title: 'Riwayat Notifikasi (${notifications.length})', actionLabel: ''),
              const SizedBox(height: 16),
              if (notifications.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text('Belum ada notifikasi', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                ))
              else
                ...notifications.take(20).map((n) => _buildNotificationItem(n, isDark)),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> n, bool isDark) {
    final title = n['title'] as String? ?? '';
    final body = n['body'] as String? ?? '';
    final type = n['type'] as String? ?? 'system';
    final isRead = n['is_read'] as bool? ?? false;
    IconData typeIcon;
    Color typeColor;
    switch (type) {
      case 'reward': typeIcon = Icons.card_giftcard_rounded; typeColor = AppColors.warning; break;
      case 'pickup': typeIcon = Icons.local_shipping_rounded; typeColor = AppColors.info; break;
      case 'achievement': typeIcon = Icons.emoji_events_rounded; typeColor = AppColors.gold; break;
      default: typeIcon = Icons.notifications_rounded; typeColor = AppColors.primary;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(typeIcon, size: 20, color: typeColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(title, style: TextStyle(fontSize: 13, fontWeight: isRead ? FontWeight.w500 : FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary))),
                      if (!isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(body, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StatusBadge(
                        label: type == 'reward' ? 'Reward' : type == 'pickup' ? 'Pickup' : 'Sistem',
                        type: type == 'reward' ? 'success' : type == 'pickup' ? 'info' : 'warning',
                      ),
                    ],
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
