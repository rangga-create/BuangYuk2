import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/mock/mock_pickups.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/avatar_widget.dart';

class PickupDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? pickup;

  const PickupDetailScreen({super.key, this.pickup});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = pickup ?? MockPickups.activePickups.first;

    final statusTimeline = [
      {'label': 'Diminta', 'icon': Icons.send, 'done': true},
      {'label': 'Diterima', 'icon': Icons.check_circle_outline, 'done': p['status'] != 'menunggu'},
      {'label': 'Dijemput', 'icon': Icons.local_shipping, 'done': p['status'] == 'dijemput' || p['status'] == 'selesai'},
      {'label': 'Selesai', 'icon': Icons.task_alt, 'done': p['status'] == 'selesai'},
    ];

    final statusColors = {
      'menunggu': AppColors.info,
      'dalam_perjalanan': AppColors.warning,
      'dijemput': AppColors.secondary,
      'selesai': AppColors.success,
    };
    final statusColor = statusColors[p['status']] ?? AppColors.info;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail ${p['id']}'),
        actions: [
          if (p['status'] == 'dalam_perjalanan' || p['status'] == 'dijemput')
            IconButton(
              icon: const Icon(Icons.navigation),
              onPressed: () => context.push(RoutePaths.pickupTracking, extra: p),
              tooltip: 'Lacak',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusHeader(context, isDark, p, statusColor),
            SizedBox(height: 24.h),
            _buildTimeline(context, isDark, statusTimeline),
            SizedBox(height: 24.h),
            _buildInfoCard(context, isDark, p),
            SizedBox(height: 24.h),
            if (p['collector_name'] != null)
              _buildCollectorInfo(context, isDark, p),
            if (p['status'] != 'selesai') ...[
              SizedBox(height: 24.h),
              _buildMapPlaceholder(context, isDark, p),
            ],
            if (p['status'] == 'selesai' && p['rating'] != null) ...[
              SizedBox(height: 24.h),
              _buildRatingSection(context, isDark, p),
            ],
            if (p['status'] == 'selesai' && p['points_earned'] != null) ...[
              SizedBox(height: 24.h),
              _buildPointsEarned(context, isDark, p),
            ],
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BuildContext context, bool isDark, Map<String, dynamic> p, Color statusColor) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              p['status'] == 'selesai' ? Icons.check_circle : Icons.local_shipping,
              color: statusColor,
              size: 32,
            ),
          ).animate().scale(duration: 400.ms, begin: const Offset(0, 0), end: const Offset(1, 1)),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['status_label'] as String,
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
                SizedBox(height: 4.h),
                Text(
                  Formatters.formatDate(p['date'] as String),
                  style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 20, duration: 400.ms);
  }

  Widget _buildTimeline(BuildContext context, bool isDark, List<Map<String, dynamic>> steps) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status Progres', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        SizedBox(height: 16.h),
        ...steps.asMap().entries.map((entry) {
          final step = entry.value;
          final done = step['done'] as bool;
          final isLast = entry.key == steps.length - 1;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: done ? AppColors.success.withValues(alpha: 0.15) : (isDark ? AppColors.cardDark : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: done ? AppColors.success : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        step['icon'] as IconData,
                        size: 16,
                        color: done ? AppColors.success : (isDark ? AppColors.textSecondaryDark : Colors.grey),
                      ),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 30,
                        color: done ? AppColors.success.withValues(alpha: 0.3) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade200),
                      ),
                  ],
                ),
                SizedBox(width: 12.w),
                Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 30.h, top: 4),
                  child: Text(
                    step['label'] as String,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                      color: done
                          ? AppColors.success
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 20, duration: 400.ms, delay: 200.ms);
  }

  Widget _buildInfoCard(BuildContext context, bool isDark, Map<String, dynamic> p) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Informasi Penjemputan', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          SizedBox(height: 16.h),
          _infoRow(Icons.location_on_outlined, 'Alamat', p['address'] as String, isDark, AppColors.error),
          SizedBox(height: 12.h),
          _infoRow(Icons.category_outlined, 'Jenis Sampah', p['waste_type'] as String, isDark, null),
          SizedBox(height: 12.h),
          _infoRow(Icons.scale_outlined, 'Volume', p['volume'] as String, isDark, null),
          if (p['notes'] != null) ...[
            SizedBox(height: 12.h),
            _infoRow(Icons.notes_outlined, 'Catatan', p['notes'] as String, isDark, null),
          ],
          SizedBox(height: 12.h),
          _infoRow(Icons.calendar_today, 'Tanggal', Formatters.formatDate(p['date'] as String), isDark, null),
          if (p['kg_saved'] != null) ...[
            SizedBox(height: 12.h),
            _infoRow(Icons.eco, 'Sampah Diselamatkan', '${p['kg_saved']} kg', isDark, AppColors.success),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 20, duration: 400.ms, delay: 300.ms);
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark, Color? iconColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: iconColor ?? (isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
        SizedBox(width: 10.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, height: 1.3),
              children: [
                TextSpan(text: '$label: ', style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollectorInfo(BuildContext context, bool isDark, Map<String, dynamic> p) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Petugas', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          SizedBox(height: 16.h),
          Row(
            children: [
              AvatarWidget(
                name: p['collector_name'] as String,
                radius: 24.r,
                showBadge: true,
                isOnline: true,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['collector_name'] as String, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    SizedBox(height: 2.h),
                    Text('Petugas Penjemputan', style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, size: 16, color: AppColors.success),
                    SizedBox(width: 4.w),
                    Text('Hubungi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 20, duration: 400.ms, delay: 400.ms);
  }

  Widget _buildMapPlaceholder(BuildContext context, bool isDark, Map<String, dynamic> p) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lokasi', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          SizedBox(height: 12.h),
          Container(
            height: 160.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight].map((c) => c.withValues(alpha: 0.1)).toList(),
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 36.sp, color: isDark ? AppColors.secondary : AppColors.primary),
                    SizedBox(height: 8.h),
                    Text('Lihat di Maps', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.secondary : AppColors.primary)),
                  ],
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.white),
                        SizedBox(width: 4.w),
                        Text('Lokasi Anda', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 20, duration: 400.ms, delay: 500.ms);
  }

  Widget _buildRatingSection(BuildContext context, bool isDark, Map<String, dynamic> p) {
    final rating = p['rating'] as int;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Penilaian', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          SizedBox(height: 12.h),
          Row(
            children: [
              ...List.generate(5, (i) => Icon(
                i < rating ? Icons.star : Icons.star_border,
                color: AppColors.gold,
                size: 28,
              ).animate().scale(duration: 300.ms, delay: (i * 100).ms, begin: const Offset(0, 0), end: const Offset(1, 1))),
            ],
          ),
          if (p['feedback'] != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '"${p['feedback']}"',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 20, duration: 400.ms, delay: 500.ms);
  }

  Widget _buildPointsEarned(BuildContext context, bool isDark, Map<String, dynamic> p) {
    final points = p['points_earned'] as int;
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.stars_rounded, color: Colors.white, size: 28),
          ).animate().scale(duration: 400.ms, begin: const Offset(0, 0), end: const Offset(1, 1)),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Poin Diperoleh', style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                SizedBox(height: 4.h),
                Text('+$points', style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: AppColors.gold, letterSpacing: -0.5)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 20, duration: 400.ms, delay: 600.ms);
  }
}
