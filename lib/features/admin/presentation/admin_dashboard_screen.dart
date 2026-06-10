import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/route_paths.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/metrics_card.dart';
import '../../../shared/utils/formatters.dart';

final _adminTotalUsersProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance.collection('users').snapshots().map((s) => s.docs.length);
});
final _adminCollectorsProvider = StreamProvider<int>((ref) {
  return FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'collector').snapshots().map((s) => s.docs.length);
});
final _adminPickupsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance.collection('pickups').orderBy('createdAt', descending: true).limit(50).snapshots().map(
    (s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList(),
  );
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  void _showAddOfficerDialog(BuildContext context) {
    final nameCtl = TextEditingController();
    final emailCtl = TextEditingController();
    final phoneCtl = TextEditingController();
    String selectedRole = 'collector';
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Tambah Petugas'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 12),
            TextField(controller: emailCtl, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 12),
            TextField(controller: phoneCtl, decoration: const InputDecoration(labelText: 'Nomor Telepon', prefixIcon: Icon(Icons.phone_outlined))),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedRole,
              decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.badge_outlined)),
              items: const [
                DropdownMenuItem(value: 'collector', child: Text('Petugas Kolektor')),
                DropdownMenuItem(value: 'tps_manager', child: Text('Manajer TPS')),
                DropdownMenuItem(value: 'government_admin', child: Text('Admin Dinas')),
              ],
              onChanged: (v) => setDialogState(() => selectedRole = v!),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              onPressed: isSaving ? null : () async {
                if (nameCtl.text.trim().isEmpty || emailCtl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama dan email wajib diisi')));
                  return;
                }
                setDialogState(() => isSaving = true);
                try {
                  final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailCtl.text.trim(), password: 'password123');
                  final uid = authResult.user!.uid;
                  final batch = FirebaseFirestore.instance.batch();
                  batch.set(FirebaseFirestore.instance.collection('users').doc(uid), {
                    'uid': uid, 'email': emailCtl.text.trim(), 'role': selectedRole,
                    'fullName': nameCtl.text.trim(), 'phone': phoneCtl.text.trim(), 'address': '-',
                    'district': '-', 'city': '-', 'province': '-', 'photoUrl': '', 'fcmToken': null,
                    'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
                  });
                  batch.set(FirebaseFirestore.instance.collection('rewards').doc(uid), {
                    'uid': uid, 'balance': 0, 'totalEarned': 0, 'updatedAt': FieldValue.serverTimestamp(),
                  });
                  batch.set(FirebaseFirestore.instance.collection('leaderboards').doc(uid), {
                    'uid': uid, 'fullName': nameCtl.text.trim(), 'city': '-', 'district': '-', 'province': '-',
                    'totalPoints': 0, 'totalPickups': 0, 'updatedAt': FieldValue.serverTimestamp(),
                  });
                  batch.set(FirebaseFirestore.instance.collection('notifications').doc(), {
                    'uid': uid, 'type': 'welcome', 'title': 'Selamat Bergabung!',
                    'body': 'Akun petugas telah dibuat untuk ${nameCtl.text.trim()}.',
                    'is_read': false, 'createdAt': FieldValue.serverTimestamp(),
                  });
                  await batch.commit();
                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Petugas ${nameCtl.text.trim()} berhasil ditambahkan')));
                } on FirebaseAuthException catch (e) {
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${e.message ?? e.code}')));
                } catch (e) {
                  setDialogState(() => isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                }
              },
              child: isSaving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final usersAsync = ref.watch(_adminTotalUsersProvider);
    final collectorsAsync = ref.watch(_adminCollectorsProvider);
    final pickupsAsync = ref.watch(_adminPickupsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    final totalUsers = usersAsync.asData?.value ?? 0;
    final totalCollectors = collectorsAsync.asData?.value ?? 0;
    final pickups = pickupsAsync.asData?.value ?? [];
    final completedPickups = pickups.where((p) => p['status'] == 'completed').length;
    final wasteVol = pickups.fold<double>(0, (sum, p) => sum + ((p['wasteVolumeKg'] as num?)?.toDouble() ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => context.go(RoutePaths.adminNotifications)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildWelcomeHeader(context, isDark),
            SizedBox(height: isMobile ? 16 : 24),
            _buildKpiRow(context, totalUsers, totalCollectors, completedPickups, wasteVol, isMobile),
            SizedBox(height: isMobile ? 20 : 28),
            _buildQuickActions(context, isDark, isMobile),
            const SizedBox(height: 24),
            _buildRecentPickups(context, pickups, isDark, isMobile),
            SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context, bool isDark) {
    final now = DateTime.now();
    final days = ['Senin', 'Selasa', 'Rabu', 'Kamis', "Jum'at", 'Sabtu', 'Minggu'];
    final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Selamat Datang Kembali', style: TextStyle(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('Admin Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, letterSpacing: -0.5)),
          const SizedBox(height: 6),
          Row(children: [
            Icon(Icons.calendar_today_rounded, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
            const SizedBox(width: 6),
            Text('${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
          ]),
        ])),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 36),
        ),
      ]),
    ).animate().fadeIn(duration: 300.ms).moveY(begin: 20, duration: 300.ms);
  }

  Widget _buildKpiRow(BuildContext context, int totalUsers, int totalCollectors, int completedPickups, double wasteVol, bool isMobile) {
    final items = [
      MetricsCard(title: 'Total Pengguna', value: Formatters.formatPoints(totalUsers), icon: Icons.people_rounded, color: AppColors.info),
      MetricsCard(title: 'Petugas Aktif', value: '$totalCollectors', icon: Icons.person_search_rounded, color: AppColors.warning),
      MetricsCard(title: 'Pickups Selesai', value: '$completedPickups', icon: Icons.local_shipping_rounded, color: AppColors.success),
      MetricsCard(title: 'Sampah (kg)', value: Formatters.formatKg(wasteVol), icon: Icons.restore_from_trash_rounded, color: AppColors.primary),
    ];

    if (isMobile) {
      return Column(children: [
        Row(children: [Expanded(child: items[0]), const SizedBox(width: 12), Expanded(child: items[1])]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: items[2]), const SizedBox(width: 12), Expanded(child: items[3])]),
      ]);
    }
    return Row(children: items.expand((i) => [Expanded(child: i), const SizedBox(width: 16)]).toList()..removeLast());
  }

  Widget _buildQuickActions(BuildContext context, bool isDark, bool isMobile) {
    return Row(children: [
      Expanded(child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        onTap: () => _showAddOfficerDialog(context),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.person_add_rounded, color: AppColors.success, size: 22)),
          const SizedBox(height: 8),
          Text('Tambah Petugas', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        ]),
      )),
      SizedBox(width: isMobile ? 8 : 12),
      Expanded(child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        onTap: () => context.go(RoutePaths.adminNotifications),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.send_rounded, color: AppColors.warning, size: 22)),
          const SizedBox(height: 8),
          Text('Kirim Notifikasi', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        ]),
      )),
      SizedBox(width: isMobile ? 8 : 12),
      Expanded(child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        onTap: () => context.go(RoutePaths.adminReports),
        child: Column(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.info.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.download_rounded, color: AppColors.info, size: 22)),
          const SizedBox(height: 8),
          Text('Ekspor Laporan', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        ]),
      )),
    ]).animate().fadeIn(duration: 600.ms).moveY(begin: 50, duration: 600.ms);
  }

  Widget _buildRecentPickups(BuildContext context, List<Map<String, dynamic>> pickups, bool isDark, bool isMobile) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.local_shipping_rounded, size: 20),
          const SizedBox(width: 8),
          Text('Pickup Terbaru', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          const Spacer(),
          TextButton(onPressed: () => context.go(RoutePaths.adminReports), child: const Text('Lihat Semua')),
        ]),
        const SizedBox(height: 12),
        if (pickups.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Belum ada pickup', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textHint))))
        else
          ...pickups.take(10).map((p) {
            final status = p['status'] as String? ?? '';
            final citizenName = p['citizenName'] as String? ?? (p['citizenId'] as String? ?? '-');
            final createdAt = p['createdAt'] != null ? (p['createdAt'] as Timestamp).toDate() : DateTime.now();
            final timeStr = _formatTime(createdAt);
            IconData statusIcon; Color statusColor;
            switch (status) {
              case 'completed': statusIcon = Icons.check_circle_rounded; statusColor = AppColors.success; break;
              case 'in_progress': case 'on_the_way': statusIcon = Icons.local_shipping_rounded; statusColor = AppColors.warning; break;
              case 'assigned': statusIcon = Icons.person_search_rounded; statusColor = AppColors.info; break;
              default: statusIcon = Icons.pending_rounded; statusColor = AppColors.textHint;
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark.withValues(alpha: 0.5) : AppColors.backgroundLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  Icon(statusIcon, color: statusColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(citizenName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    Text(timeStr, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                  ])),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text(status.replaceAll('_', ' '), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
                  ),
                ]),
              ),
            );
          }),
      ]),
    ).animate().fadeIn(duration: 500.ms).moveY(begin: 30, duration: 500.ms);
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}
