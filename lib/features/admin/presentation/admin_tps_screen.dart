import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/components/status_badge.dart';
import '../../../shared/components/animated_progress.dart';
import '../../../shared/mock/mock_admin.dart';

class AdminTpsScreen extends ConsumerWidget {
  const AdminTpsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tpsList = MockAdmin.tpsData;

    return Scaffold(
      appBar: AppBar(
        title: Text('TPS', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildSummaryRow(context, tpsList, isDark),
          const SizedBox(height: 20),
          _buildMapPlaceholder(context, tpsList.length, isDark),
          const SizedBox(height: 20),
          _buildTpsList(context, tpsList, isDark),
          const SizedBox(height: 32),
        ]),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, List<Map<String, dynamic>> tpsList, bool isDark) {
    final total = tpsList.length;
    final operational = tpsList.where((t) => t['status'] != 'non_operational').length;
    final atCapacity = tpsList.where((t) => ((t['capacity'] as num?)?.toDouble() ?? 0) >= 80).length;
    final nonOperational = total - operational;

    return Row(children: [
      Expanded(child: _summaryBox('Total TPS', '$total', Icons.location_on_rounded, AppColors.info, isDark)),
      const SizedBox(width: 10),
      Expanded(child: _summaryBox('Beroperasi', '$operational', Icons.check_circle_rounded, AppColors.success, isDark)),
      const SizedBox(width: 10),
      Expanded(child: _summaryBox('Penuh', '$atCapacity', Icons.warning_rounded, AppColors.error, isDark)),
      const SizedBox(width: 10),
      Expanded(child: _summaryBox('Tutup', '$nonOperational', Icons.cancel_rounded, isDark ? AppColors.textSecondaryDark : AppColors.textHint, isDark)),
    ]).animate().fadeIn(duration: 300.ms).moveY(begin: 15, duration: 300.ms);
  }

  Widget _summaryBox(String label, String value, IconData icon, Color color, bool isDark) {
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

  Widget _buildMapPlaceholder(BuildContext context, int totalTps, bool isDark) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(colors: [(isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.08), (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.02)]),
        ),
        child: Stack(children: [
          Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.map_rounded, size: 48, color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.3)),
            const SizedBox(height: 8),
            Text('Peta Lokasi TPS', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.5))),
            const SizedBox(height: 4),
            Text('$totalTps titik TPS terpantau', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
          ])),
          if (totalTps > 0)
            ...List.generate(totalTps.clamp(0, 8), (i) {
              final x = 0.12 + (i * 0.1);
              final y = 0.15 + (i % 4) * 0.22;
              final colors = [AppColors.success, AppColors.warning, AppColors.error, AppColors.success, AppColors.warning, AppColors.info, AppColors.success, AppColors.warning];
              return Positioned(
                left: MediaQuery.of(context).size.width * x * 0.4,
                top: 15 + y * 60,
                child: Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: colors[i].withValues(alpha: 0.7), shape: BoxShape.circle,
                    border: Border.all(color: isDark ? AppColors.surfaceDark : Colors.white, width: 2)),
                ),
              );
            }),
          Positioned(top: 12, right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: isDark ? AppColors.secondary : AppColors.primary, borderRadius: BorderRadius.circular(8)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.my_location_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text('Lihat Peta', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
              ]),
            ),
          ),
        ]),
      ),
    ).animate().fadeIn(duration: 350.ms).moveY(begin: 20, duration: 350.ms);
  }

  Widget _buildTpsList(BuildContext context, List<Map<String, dynamic>> tpsList, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SectionHeader(title: 'Daftar TPS', actionLabel: 'Atur Ulang', actionIcon: Icons.refresh_rounded, onActionTap: () {}),
        const SizedBox(height: 16),
        if (tpsList.isEmpty)
          Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(children: [
            Icon(Icons.location_off_rounded, size: 48, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
            const SizedBox(height: 12),
            Text('Belum ada data TPS', style: GoogleFonts.inter(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
            const SizedBox(height: 4),
            Text('Data akan muncul setelah admin menambahkan TPS', style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.6) : AppColors.textHint.withValues(alpha: 0.6))),
          ])))
        else
          ...tpsList.map((tps) {
            final name = tps['name'] as String? ?? '-';
            final capacity = (tps['capacity'] as num?)?.toDouble() ?? 0;
            final status = tps['status'] as String? ?? 'low';
            final location = tps['location'] as String? ?? '-';

            Color capacityColor; Color dotColor; String statusLabel;
            switch (status) {
              case 'critical': capacityColor = AppColors.error; dotColor = AppColors.error; statusLabel = 'Kritis'; break;
              case 'high': case 'medium': capacityColor = AppColors.warning; dotColor = AppColors.warning; statusLabel = 'Tinggi'; break;
              default: capacityColor = AppColors.success; dotColor = AppColors.success; statusLabel = 'Aman';
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark.withValues(alpha: 0.5) : AppColors.backgroundLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.withValues(alpha: 0.06)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: capacityColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(Icons.delete_outline_rounded, size: 20, color: capacityColor)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(location, style: GoogleFonts.inter(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                    ])),
                    StatusBadge(label: statusLabel, type: status),
                  ]),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: AnimatedProgressBar(value: capacity / 100, color: capacityColor, height: 6)),
                    const SizedBox(width: 12),
                    Text('${capacity.toInt()}%', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: capacityColor)),
                  ]),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(capacity < 60 ? 'Kapasitas tersedia' : capacity < 80 ? 'Hampir penuh' : 'Segera dikosongkan',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: capacityColor)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: isDark ? AppColors.cardDark : Colors.white, borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1))),
                      child: Text('Detail', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                    ),
                  ]),
                ]),
              ),
            );
          }),
      ]),
    ).animate().fadeIn(duration: 400.ms).moveY(begin: 25, duration: 400.ms);
  }
}
