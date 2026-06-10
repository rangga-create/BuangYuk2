import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/components/avatar_widget.dart';
import '../../../shared/components/animated_progress.dart';

final _collectorsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('role', isEqualTo: 'collector')
      .snapshots()
      .map((s) => s.docs.map((d) => {...d.data(), 'id': d.id}).toList());
});

class AdminCollectorsScreen extends ConsumerWidget {
  const AdminCollectorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final collectorsAsync = ref.watch(_collectorsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Petugas', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
      ),
      body: collectorsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Gagal: $e')),
        data: (collectors) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildSummaryStats(context, collectors, isDark),
              const SizedBox(height: 20),
              _buildTopCollectors(context, collectors, isDark),
              const SizedBox(height: 24),
              _buildPerformanceSection(context, collectors, isDark),
              const SizedBox(height: 32),
            ]),
          );
        },
      ),
    );
  }

  Widget _buildSummaryStats(BuildContext context, List<Map<String, dynamic>> collectors, bool isDark) {
    final total = collectors.length;
    final available = collectors.where((c) => c['isAvailable'] == true || c['isAvailable'] == null).length;

    return Row(children: [
      Expanded(child: _statBox(context, 'Total Petugas', '$total', Icons.group_rounded, AppColors.info, isDark)),
      const SizedBox(width: 10),
      Expanded(child: _statBox(context, 'Tersedia', '$available', Icons.check_circle_rounded, AppColors.success, isDark)),
      const SizedBox(width: 10),
      Expanded(child: _statBox(context, 'Rating', '4.8', Icons.star_rounded, AppColors.warning, isDark)),
      const SizedBox(width: 10),
      Expanded(child: _statBox(context, 'Komplet', '94%', Icons.task_alt_rounded, AppColors.primary, isDark)),
    ]).animate().fadeIn(duration: 300.ms).moveY(begin: 15, duration: 300.ms);
  }

  Widget _statBox(BuildContext context, String label, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : color.withValues(alpha: 0.1))),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w500, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
      ]),
    );
  }

  Widget _buildTopCollectors(BuildContext context, List<Map<String, dynamic>> collectors, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(title: 'Petugas Terbaik', actionLabel: 'Peringkat', actionIcon: Icons.arrow_forward_rounded, onActionTap: () {}),
        const SizedBox(height: 16),
        if (collectors.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Belum ada petugas', style: GoogleFonts.inter(color: isDark ? AppColors.textSecondaryDark : AppColors.textHint))))
        else
          ...[...collectors.take(5)].asMap().entries.map((entry) {
            final index = entry.key;
            final c = entry.value;
            final name = c['fullName'] as String? ?? 'Petugas ${index + 1}';
            final email = c['email'] as String? ?? '-';
            final avatar = c['photoUrl'] as String?;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark.withValues(alpha: 0.5) : AppColors.backgroundLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.withValues(alpha: 0.06)),
                ),
                child: Row(children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: index < 3 ? [AppColors.gold, AppColors.silver, AppColors.bronze][index] : (isDark ? AppColors.cardDark : Colors.grey.withValues(alpha: 0.1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Text('${index + 1}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800,
                      color: index < 3 ? Colors.black87 : (isDark ? AppColors.textSecondaryDark : AppColors.textHint)))),
                  ),
                  const SizedBox(width: 12),
                  AvatarWidget(imageUrl: avatar, name: name, radius: 22, showBadge: true, isOnline: true),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    Text(email, style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                  ])),
                ]),
              ),
            );
          }),
      ]),
    ).animate().fadeIn(duration: 400.ms).moveY(begin: 25, duration: 400.ms);
  }

  Widget _buildPerformanceSection(BuildContext context, List<Map<String, dynamic>> collectors, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Kinerja Petugas', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, letterSpacing: -0.3)),
        const SizedBox(height: 20),
        if (collectors.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('Belum ada data', style: GoogleFonts.inter(color: isDark ? AppColors.textSecondaryDark : AppColors.textHint))))
        else
          ...collectors.take(8).map((c) {
            final name = c['fullName'] as String? ?? '-';
            final progress = ((collectors.indexOf(c) % 10) / 10.0);

            Color barColor = progress >= 0.8 ? AppColors.success : (progress >= 0.6 ? AppColors.warning : AppColors.info);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(children: [
                SizedBox(width: 40, child: Text(name.split(' ').first, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary), overflow: TextOverflow.ellipsis)),
                const SizedBox(width: 12),
                Expanded(child: AnimatedProgressBar(value: progress, color: barColor, height: 8)),
                const SizedBox(width: 12),
                SizedBox(width: 40, child: Text('${(progress * 100).toInt()}%', textAlign: TextAlign.right,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: barColor))),
              ]),
            );
          }),
      ]),
    ).animate().fadeIn(duration: 450.ms).moveY(begin: 30, duration: 450.ms);
  }
}
