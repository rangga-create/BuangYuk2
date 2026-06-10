import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/status_badge.dart';
import '../../../shared/mock/mock_admin.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _activeTab = 'All';
  String? _expandedReportId;

  List<Map<String, dynamic>> get _filteredReports {
    final reports = MockAdmin.recentReports;

    if (_activeTab == 'All') return reports;
    return reports.where((r) {
      final status = r['status'] as String;
      switch (_activeTab) {
        case 'Open':
          return status == 'open';
        case 'Proses':
          return status == 'in_progress';
        case 'Selesai':
          return status == 'resolved';
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Laporan',
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryStats(context, isDark),
            const SizedBox(height: 20),
            _buildFilterTabs(context, isDark),
            const SizedBox(height: 20),
            _buildReportList(context, isDark),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStats(BuildContext context, bool isDark) {
    final reports = MockAdmin.recentReports;
    final total = reports.length;
    final open = reports.where((r) => r['status'] == 'open').length;
    final inProgress = reports.where((r) => r['status'] == 'in_progress').length;
    final resolved = reports.where((r) => r['status'] == 'resolved').length;

    return Row(
      children: [
        _statItem(context, 'Total', total.toString(), Icons.assignment_rounded, AppColors.info, isDark),
        const SizedBox(width: 8),
        _statItem(context, 'Open', open.toString(), Icons.error_outline_rounded, AppColors.error, isDark),
        const SizedBox(width: 8),
        _statItem(context, 'Diproses', inProgress.toString(), Icons.hourglass_top_rounded, AppColors.warning, isDark),
        const SizedBox(width: 8),
        _statItem(context, 'Selesai', resolved.toString(), Icons.check_circle_outline_rounded, AppColors.success, isDark),
      ],
    ).animate().fadeIn(duration: 300.ms).moveY(begin: 15, duration: 300.ms);
  }

  Widget _statItem(BuildContext context, String label, String value, IconData icon, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : color.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, bool isDark) {
    final tabs = ['All', 'Open', 'Proses', 'Selesai'];

    return GlassCard(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: tabs.map((tab) {
          final isActive = _activeTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = tab),
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isDark ? AppColors.secondary : AppColors.primary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  tab == 'All' ? 'Semua' : tab,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isActive
                        ? Colors.white
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 350.ms).moveY(begin: 20, duration: 350.ms);
  }

  Widget _buildReportList(BuildContext context, bool isDark) {
    final reports = _filteredReports;

    return Column(
      children: reports.map((r) {
        final id = r['id'] as String;
        final type = r['type'] as String;
        final title = r['title'] as String;
        final location = r['location'] as String;
        final status = r['status'] as String;
        final priority = r['priority'] as String;
        final date = r['date'] as String;
        final isExpanded = _expandedReportId == id;

        Color priorityColor;
        String priorityLabel;
        switch (priority) {
          case 'high':
            priorityColor = AppColors.error;
            priorityLabel = 'Prioritas Tinggi';
            break;
          case 'medium':
            priorityColor = AppColors.warning;
            priorityLabel = 'Prioritas Sedang';
            break;
          default:
            priorityColor = AppColors.info;
            priorityLabel = 'Prioritas Rendah';
        }

        IconData typeIcon;
        switch (type) {
          case 'sampah_berserakan':
            typeIcon = Icons.cleaning_services_rounded;
            break;
          case 'petugas_tidak_datang':
            typeIcon = Icons.person_off_rounded;
            break;
          case 'tps_penuh':
            typeIcon = Icons.delete_sweep_rounded;
            break;
          default:
            typeIcon = Icons.lightbulb_outline_rounded;
        }

        String statusLabel;
        switch (status) {
          case 'open':
            statusLabel = 'Open';
            break;
          case 'in_progress':
            statusLabel = 'Diproses';
            break;
          case 'resolved':
            statusLabel = 'Selesai';
            break;
          default:
            statusLabel = status;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                InkWell(
                  onTap: () => setState(() {
                    _expandedReportId = isExpanded ? null : id;
                  }),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            typeIcon,
                            color: priorityColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: priorityColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      priorityLabel.split(' ').last,
                                      style: GoogleFonts.inter(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: priorityColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 13,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    location,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  StatusBadge(label: statusLabel, type: status),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    date,
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    id,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0,
                          duration: 200.ms,
                          child: Icon(
                            Icons.expand_more_rounded,
                            size: 20,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                AnimatedCrossFade(
                  crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
                  duration: 200.ms,
                  firstChild: Container(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const SizedBox(height: 8),
                        _detailInfo(context, 'ID Laporan', id, isDark),
                        const SizedBox(height: 6),
                        _detailInfo(context, 'Lokasi', location, isDark),
                        const SizedBox(height: 6),
                        _detailInfo(context, 'Prioritas', priorityLabel, isDark),
                        const SizedBox(height: 6),
                        _detailInfo(context, 'Status', statusLabel, isDark),
                        const SizedBox(height: 6),
                        _detailInfo(context, 'Dilaporkan', date, isDark),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.check_rounded, size: 18),
                                  label: const Text('Tandai Selesai'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.success,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.flag_rounded, size: 18),
                                  label: const Text('Tindak Lanjut'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.warning,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn(duration: 400.ms).moveY(begin: 25, duration: 400.ms);
  }

  Widget _detailInfo(BuildContext context, String label, String value, bool isDark) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
