import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/mock/mock_activities.dart';
import '../../../shared/mock/mock_challenges.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/components/status_badge.dart';
import '../../../shared/components/stats_row.dart';
import '../../../shared/components/avatar_widget.dart';
import '../../../shared/components/animated_progress.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/pickup_provider.dart';
import '../../../shared/providers/notification_provider.dart';
import '../../../shared/providers/wallet_provider.dart';
import 'notification_center.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pointsController;
  late AnimationController _kgController;
  late Animation<int> _pointsAnim;
  late Animation<double> _kgAnim;

  @override
  void initState() {
    super.initState();
    _pointsController = AnimationController(vsync: this, duration: 1200.ms);
    _kgController = AnimationController(vsync: this, duration: 1200.ms);
    _pointsAnim = IntTween(begin: 0, end: 0).animate(_pointsController);
    _kgAnim = Tween<double>(begin: 0, end: 0).animate(_kgController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wallet = ref.read(walletProvider).asData?.value;
    final user = ref.read(userProfileProvider).asData?.value;
    final points = (wallet?['totalEarned'] ?? user?['total_points'] ?? 0) as int;
    final kg = (user?['total_kg_saved'] ?? 0).toDouble();
    _pointsAnim = IntTween(begin: 0, end: points).animate(_pointsController);
    _kgAnim = Tween<double>(begin: 0, end: kg).animate(_kgController);
    _pointsController.forward();
    _kgController.forward();
  }

  @override
  void dispose() {
    _pointsController.dispose();
    _kgController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(userProfileProvider);
    final activePickupsAsync = ref.watch(activePickupsProvider);
    final walletAsync = ref.watch(walletProvider);

    final user = userAsync.asData?.value ?? {};
    final activePickups = activePickupsAsync.asData?.value ?? [];
    final wallet = walletAsync.asData?.value;
    final activities = MockActivities.activities;
    final weeklyChallenges = MockChallenges.weeklyChallenges;
    final achievements = MockChallenges.achievements;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context, isDark, user),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPointsRow(context, isDark, user, wallet),
                  SizedBox(height: 24.h),
                  if (activePickups.isNotEmpty) ...[
                    _buildActivePickup(context, isDark, activePickups.first),
                    SizedBox(height: 24.h),
                  ],
                  _buildWeeklyChallenges(context, isDark, weeklyChallenges),
                  SizedBox(height: 24.h),
                  _buildQuickActions(context, isDark),
                  SizedBox(height: 24.h),
                  _buildAchievements(context, isDark, achievements),
                  SizedBox(height: 24.h),
                  _buildRecentActivity(context, isDark, activities),
                  SizedBox(height: 24.h),
                  _buildMoreStats(context, isDark, user),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, Map<String, dynamic> user) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16.h, left: 20.w, right: 20.w, bottom: 32.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.cardDark, AppColors.primaryDark.withValues(alpha: 0.5)]
              : [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark ? AppColors.textSecondaryDark : Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideX(begin: -20, duration: 400.ms),
                  SizedBox(height: 4.h),
                  Text(
                    user['name'] ?? user['fullName'] ?? 'Pengguna',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.textPrimaryDark : Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -20, duration: 400.ms, delay: 100.ms),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const NotificationCenter(),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: (isDark ? Colors.white : Colors.white).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.notifications_outlined, color: isDark ? AppColors.textPrimaryDark : Colors.white, size: 22),
                        ),
                        Consumer(builder: (context, ref, _) {
                          final unreadCount = ref.watch(unreadCountProvider).asData?.value ?? 0;
                          if (unreadCount <= 0) return const SizedBox.shrink();
                          return Positioned(
                            right: 4, top: 4,
                            child: Container(
                              width: 18, height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                                border: Border.all(color: isDark ? AppColors.cardDark : AppColors.primary, width: 2),
                              ),
                              child: Center(child: Text('$unreadCount', style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w700))),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  AvatarWidget(
                    imageUrl: user['photoUrl'] ?? user['avatar_url'],
                    name: user['name'] ?? user['fullName'] ?? 'User',
                    radius: 22.r,
                    onTap: () => context.push(RoutePaths.profile),
                    showBadge: true,
                    isOnline: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsRow(BuildContext context, bool isDark, Map<String, dynamic> user, Map<String, dynamic>? wallet) {
    return Transform.translate(
      offset: Offset(0, -24.h),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Poin', style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4.h),
                  AnimatedBuilder(
                    animation: _pointsAnim,
                    builder: (context, child) => Text(
                      Formatters.formatPoints(_pointsAnim.value),
                      style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary, letterSpacing: -0.5),
                    ),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 40, color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.textHint.withValues(alpha: 0.15)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Sampah Diselamatkan', style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  SizedBox(height: 4.h),
                  AnimatedBuilder(
                    animation: _kgAnim,
                    builder: (context, child) => Text(
                      Formatters.formatKg(_kgAnim.value),
                      style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: AppColors.success, letterSpacing: -0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivePickup(BuildContext context, bool isDark, Map<String, dynamic> pickup) {
    final statusLabels = {
      'requested': 'Menunggu', 'assigned': 'Ditugaskan', 'accepted': 'Diterima',
      'on_the_way': 'Dalam Perjalanan', 'arrived': 'Tiba', 'picked_up': 'Terambil',
      'completed': 'Selesai', 'cancelled': 'Dibatalkan',
    };
    final status = pickup['status'] as String? ?? 'requested';
    final statusLabel = statusLabels[status] ?? status;
    final statusColor = status == 'requested' || status == 'assigned'
        ? AppColors.info : status == 'accepted' || status == 'on_the_way'
            ? AppColors.warning : AppColors.success;

    return GlassCard(
      onTap: () => context.push(RoutePaths.pickupDetail, extra: pickup),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.local_shipping, color: statusColor, size: 20),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Penjemputan Aktif', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    SizedBox(height: 2.h),
                    Text(pickup['id'] as String? ?? '', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                  ],
                ),
              ),
              StatusBadge(label: statusLabel, type: status),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.location_on_outlined, size: 16, color: AppColors.error),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(pickup['address'] as String? ?? pickup['location']?.toString() ?? '', style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(Icons.category_outlined, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
              SizedBox(width: 6.w),
              Text('${pickup['waste_type'] ?? 'Campur'}  \u2022  ${pickup['weightKg']?.toString() ?? pickup['volume'] ?? ''} kg', style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              const Spacer(),
              if (pickup['estimated_arrival'] != null)
                Text('Estimasi: ${pickup['estimated_arrival']}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning)),
            ],
          ),
          SizedBox(height: 12.h),
          AnimatedProgressBar(
            value: status == 'requested' || status == 'assigned' ? 0.25 : status == 'accepted' || status == 'on_the_way' ? 0.6 : 0.85,
            color: statusColor,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 20, duration: 400.ms, delay: 200.ms);
  }

  Widget _buildWeeklyChallenges(BuildContext context, bool isDark, List<Map<String, dynamic>> challenges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Tantangan Mingguan', actionLabel: 'Lihat Semua', onActionTap: () => context.push(RoutePaths.ecoChallenges)),
        SizedBox(height: 12.h),
        ...challenges.take(2).toList().asMap().entries.map((e) {
            final challenge = e.value;
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: GlassCard(
                onTap: () => context.push(RoutePaths.ecoChallenges),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Color(challenge['icon_color'] as int).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                      child: Icon(challenge['icon'] as IconData, color: Color(challenge['icon_color'] as int), size: 24),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(challenge['title'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                          SizedBox(height: 4.h),
                          AnimatedProgressBar(value: (challenge['progress'] as int) / (challenge['target'] as int), color: Color(challenge['icon_color'] as int)),
                          SizedBox(height: 4.h),
                          Text('${challenge['progress']}/${challenge['target']}', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                      child: Text('+${challenge['points_reward']}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gold)),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: (e.key * 150 + 300).ms).slideY(begin: 15, duration: 300.ms);
          }),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, bool isDark) {
    final actions = [
      {'icon': Icons.local_shipping_outlined, 'label': 'Jemput Sampah', 'route': RoutePaths.pickup, 'color': AppColors.primary},
      {'icon': Icons.document_scanner_outlined, 'label': 'Scan Sampah', 'route': RoutePaths.scan, 'color': AppColors.info},
      {'icon': Icons.emoji_events_outlined, 'label': 'Tukar Poin', 'route': RoutePaths.reward, 'color': AppColors.gold},
      {'icon': Icons.lightbulb_outline, 'label': 'Eco Tips', 'route': RoutePaths.helpCenter, 'color': AppColors.warning},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Aksi Cepat'),
        SizedBox(height: 12.h),
        Row(
          children: actions.map((action) {
            final color = action['color'] as Color;
            return Expanded(
              child: GestureDetector(
                onTap: () => context.push(action['route'] as String),
                child: Container(
                  margin: EdgeInsets.only(right: actions.indexOf(action) < actions.length - 1 ? 8.w : 0),
                  padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 4.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : color.withValues(alpha: 0.1)),
                    boxShadow: [BoxShadow(color: color.withValues(alpha: isDark ? 0.05 : 0.06), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                        child: Icon(action['icon'] as IconData, color: color, size: 24),
                      ),
                      SizedBox(height: 8.h),
                      Text(action['label'] as String, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievements(BuildContext context, bool isDark, List<Map<String, dynamic>> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Pencapaian', actionLabel: 'Lihat Semua', onActionTap: () => context.push(RoutePaths.achievements)),
        SizedBox(height: 12.h),
        SizedBox(
          height: 90.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            separatorBuilder: (_, _) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final ach = achievements[index];
              final isCompleted = ach['is_completed'] as bool;
              final achColor = Color(ach['icon_color'] as int);
              final progress = (ach['progress'] as int) / (ach['target'] as int);
              return GestureDetector(
                onTap: () => context.push(RoutePaths.achievements),
                child: Container(
                  width: 100.w,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCompleted ? AppColors.gold.withValues(alpha: 0.3) : isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1),
                    ),
                    boxShadow: isCompleted ? [BoxShadow(color: AppColors.gold.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4))] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(ach['icon'] as IconData, color: isCompleted ? AppColors.gold : achColor.withValues(alpha: 0.5), size: 28),
                      SizedBox(height: 6.h),
                      Text(ach['title'] as String, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                      SizedBox(height: 4.h),
                      AnimatedProgressBar(value: progress.clamp(0.0, 1.0), height: 4, color: isCompleted ? AppColors.gold : achColor),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms, delay: (index * 100 + 400).ms).slideY(begin: 15, duration: 300.ms);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, bool isDark, List<Map<String, dynamic>> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'Aktivitas Terbaru', actionLabel: 'Riwayat', onActionTap: () => context.push(RoutePaths.activityHistory)),
        SizedBox(height: 12.h),
        ...activities.take(3).toList().asMap().entries.map((e) {
          final activity = e.value;
          final color = Color(activity['color'] as int);
          final points = activity['points'] as int;
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                    child: Icon(activity['icon'] as IconData, color: color, size: 22)),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(activity['title'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      SizedBox(height: 2.h),
                      Text(activity['description'] as String, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                  SizedBox(width: 8.w),
                  Text('${points >= 0 ? '+' : ''}$points',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: points >= 0 ? AppColors.success : AppColors.error)),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 300.ms, delay: (e.key * 120 + 400).ms).slideX(begin: 20, duration: 300.ms);
        }),
      ],
    );
  }

  Widget _buildMoreStats(BuildContext context, bool isDark, Map<String, dynamic> user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Statistik Lainnya'),
        SizedBox(height: 12.h),
        StatsRow(
          items: [
            StatItem(icon: Icons.recycling, value: Formatters.formatPoints(user['total_pickups'] as int? ?? 0), label: 'Pickups', color: AppColors.primary),
            StatItem(icon: Icons.local_fire_department, value: '${user['streak_days'] ?? 0}', label: 'Streak', color: AppColors.warning),
            StatItem(icon: Icons.emoji_events, value: user['level'] as String? ?? 'Warga Baru', label: 'Level', color: AppColors.gold),
            StatItem(icon: Icons.people, value: '${user['total_pickups'] ?? 0}', label: 'Peringkat #${user['level_rank'] ?? 0}', color: AppColors.info),
          ],
        ),
      ],
    );
  }
}
