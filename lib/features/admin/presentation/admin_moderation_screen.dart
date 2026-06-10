import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/mock/mock_admin.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/status_badge.dart';
import '../../../shared/components/empty_state.dart';

class AdminModerationScreen extends StatefulWidget {
  const AdminModerationScreen({super.key});

  @override
  State<AdminModerationScreen> createState() => _AdminModerationScreenState();
}

class _AdminModerationScreenState extends State<AdminModerationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reports = MockAdmin.recentReports;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Laporan Masuk'),
                Tab(text: 'Sedang Ditinjau'),
                Tab(text: 'Riwayat'),
              ],
              labelColor: isDark ? AppColors.secondary : AppColors.primary,
              unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
              indicatorColor: isDark ? AppColors.secondary : AppColors.primary,
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildReportList(isDark, reports.where((r) => r['status'] == 'open').toList()),
                  _buildReportList(isDark, reports.where((r) => r['status'] == 'in_progress').toList()),
                  _buildReportList(isDark, reports.where((r) => r['status'] == 'resolved').toList()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16.h,
        left: 20.w,
        right: 20.w,
        bottom: 12.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.cardDark, AppColors.primaryDark.withValues(alpha: 0.5)]
              : [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Moderasi',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : Colors.white,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -20),
          SizedBox(height: 4.h),
          Text(
            'Review laporan dan konten pengguna',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? AppColors.textSecondaryDark : Colors.white.withValues(alpha: 0.85),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -20),
        ],
      ),
    );
  }

  Widget _buildReportList(bool isDark, List<Map<String, dynamic>> reports) {
    if (reports.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline_rounded,
        title: 'Semua Bersih',
        message: 'Tidak ada laporan yang perlu ditinjau',
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: reports.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildReportCard(isDark, report).animate().fadeIn(
          duration: 300.ms,
          delay: (index * 100).ms,
        ).slideY(begin: 20, duration: 300.ms);
      },
    );
  }

  Widget _buildReportCard(bool isDark, Map<String, dynamic> report) {
    final priorityColor = report['priority'] == 'high'
        ? AppColors.error
        : report['priority'] == 'medium'
            ? AppColors.warning
            : AppColors.info;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  report['priority'] == 'high'
                      ? Icons.priority_high_rounded
                      : Icons.low_priority_rounded,
                  color: priorityColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report['title'] as String,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: AppColors.error.withValues(alpha: 0.7)),
                        SizedBox(width: 4.w),
                        Text(
                          report['location'] as String,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: report['status'] == 'open'
                    ? 'Terbuka'
                    : report['status'] == 'in_progress'
                        ? 'Ditinjau'
                        : 'Selesai',
                type: report['status'] as String,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                report['date'] as String,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                ),
              ),
              Row(
                children: [
                  if (report['status'] != 'resolved') ...[
                    _buildActionButton(isDark, Icons.check_circle_outline, AppColors.success, 'Setujui'),
                    SizedBox(width: 8.w),
                    _buildActionButton(isDark, Icons.block_outlined, AppColors.error, 'Tolak'),
                  ] else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Telah ditindaklanjuti',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(bool isDark, IconData icon, Color color, String label) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label (Mock)'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
