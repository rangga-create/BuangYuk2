import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/mock/mock_challenges.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/components/animated_progress.dart';
import '../../../shared/components/empty_state.dart';

class EcoChallengesScreen extends StatelessWidget {
  const EcoChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekly = MockChallenges.weeklyChallenges;

    final completed = weekly.where((c) => (c['progress'] as int) >= (c['target'] as int)).toList();
    final active = weekly.where((c) => (c['progress'] as int) < (c['target'] as int)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tantangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => context.push(RoutePaths.achievements),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDark, weekly),
            SizedBox(height: 24.h),
            if (active.isNotEmpty) ...[
          SectionHeader(title: 'Tantangan Aktif (${active.length})'),
          SizedBox(height: 12.h),
          ...active.asMap().entries.map((e) => _buildChallengeCard(context, isDark, e.value, index: e.key)),
          SizedBox(height: 24.h),
            ],
            if (completed.isNotEmpty) ...[
              SectionHeader(title: 'Selesai (${completed.length})'),
              SizedBox(height: 12.h),
              ...completed.asMap().entries.map((e) => _buildChallengeCard(context, isDark, e.value, index: e.key)),
            ],
            if (weekly.isEmpty)
              const EmptyState(
                icon: Icons.assignment_outlined,
                title: 'Belum Ada Tantangan',
                message: 'Tantangan baru akan muncul setiap minggu',
              ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, List<Map<String, dynamic>> challenges) {
    final totalPoints = challenges.fold<int>(0, (sum, c) => sum + (c['progress'] as int) * (c['points_reward'] as int) ~/ (c['target'] as int).clamp(1, 999999));
    final totalPossible = challenges.fold<int>(0, (sum, c) => sum + (c['points_reward'] as int));
    final overallProgress = totalPossible > 0 ? totalPoints / totalPossible : 0.0;

    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.assignment_turned_in, color: Colors.white, size: 28),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Progres Mingguan', style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                SizedBox(height: 4.h),
                Text('${(overallProgress * 100).toInt()}%', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                SizedBox(height: 8.h),
                AnimatedProgressBar(value: overallProgress.clamp(0.0, 1.0), height: 8, color: AppColors.primary),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('+$totalPoints', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.gold)),
                Text('poin', style: TextStyle(fontSize: 10, color: AppColors.gold.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 20, duration: 400.ms);
  }

  Widget _buildChallengeCard(BuildContext context, bool isDark, Map<String, dynamic> challenge, {int index = 0}) {
    final progress = (challenge['progress'] as int) / (challenge['target'] as int);
    final isCompleted = progress >= 1.0;
    final color = Color(challenge['icon_color'] as int);
    final difficultyColors = {'Mudah': AppColors.success, 'Sedang': AppColors.warning, 'Sulit': AppColors.error};
    final difficultyColor = difficultyColors[challenge['difficulty']] ?? AppColors.info;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCompleted ? AppColors.success.withValues(alpha: 0.12) : color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : challenge['icon'] as IconData,
                    color: isCompleted ? AppColors.success : color,
                    size: 24,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(challenge['title'] as String, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      SizedBox(height: 2.h),
                      Text(challenge['description'] as String, style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: difficultyColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(challenge['difficulty'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: difficultyColor)),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            AnimatedProgressBar(
              value: progress.clamp(0.0, 1.0),
              height: 8,
              color: isCompleted ? AppColors.success : color,
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${challenge['progress']}/${challenge['target']}',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                ),
                Row(
                  children: [
                    Text('Deadline: ${challenge['deadline']}', style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                    SizedBox(width: 12.w),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars_rounded, size: 14, color: AppColors.gold),
                          SizedBox(width: 4.w),
                          Text('+${challenge['points_reward']}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 100).ms).slideY(begin: 15, duration: 300.ms);
  }

  List<Map<String, dynamic>> get challenges => MockChallenges.weeklyChallenges;
}
