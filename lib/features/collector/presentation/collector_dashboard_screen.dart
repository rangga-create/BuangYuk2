import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/components/stats_row.dart';
import '../../../shared/components/status_badge.dart';
import '../../../shared/components/avatar_widget.dart';
import '../../../shared/components/animated_progress.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/route_paths.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/pickup_provider.dart';

class CollectorDashboardScreen extends ConsumerStatefulWidget {
  const CollectorDashboardScreen({super.key});

  @override
  ConsumerState<CollectorDashboardScreen> createState() => _CollectorDashboardScreenState();
}

class _CollectorDashboardScreenState extends ConsumerState<CollectorDashboardScreen> {
  bool _isAvailable = true;

  final _weeklyEarnings = [120000, 95000, 150000, 110000, 130000, 45000, 0];
  final _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(userProfileProvider);
    final tasksAsync = ref.watch(collectorTasksProvider);

    final user = userAsync.asData?.value ?? {};
    final activeTask = (tasksAsync.asData?.value ?? [])
        .where((t) => t['status'] == 'accepted' || t['status'] == 'on_the_way' || t['status'] == 'assigned')
        .toList();

    final name = user['fullName'] ?? user['name'] ?? 'Petugas';
    final avatarUrl = user['photoUrl'];
    final level = user['level'] ?? 'Petugas Aktif';
    final tasksCompletedToday = user['tasks_completed_today'] ?? 0;
    final todayEarnings = user['today_earnings'] ?? 0;
    final totalEarnings = user['total_earnings'] ?? 0;
    final tasksCompletedTotal = user['tasks_completed_total'] ?? 0;
    final rating = user['tasks_rated'] ?? '4.8';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [AppColors.cardDark, AppColors.surfaceDark]
                        : [AppColors.primarySurface, AppColors.backgroundLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 50,
                  left: 20,
                  right: 20,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    AvatarWidget(
                      imageUrl: avatarUrl,
                      name: name,
                      radius: 28,
                      showBadge: true,
                      isOnline: _isAvailable,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ).animate().fadeIn(duration: 300.ms).slideX(begin: -10),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              level,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isDark ? AppColors.secondary : AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6, height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _isAvailable ? AppColors.success : AppColors.textHint,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isAvailable ? 'Aktif' : 'Offline',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _isAvailable ? AppColors.success : AppColors.textHint),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            SizedBox(
                              height: 24,
                              child: Switch(
                                value: _isAvailable,
                                onChanged: (v) => setState(() => _isAvailable = v),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(Icons.settings_rounded, size: 20,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                          onPressed: () => context.push(RoutePaths.collectorSettings),
                          tooltip: 'Pengaturan',
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsRow(isDark, tasksCompletedToday, todayEarnings, rating).animate().fadeIn(duration: 400.ms).slideY(begin: 20),
                const SizedBox(height: 16),
                _buildQuickStats(isDark, totalEarnings, tasksCompletedTotal, rating).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 20),
                const SizedBox(height: 20),
                if (activeTask.isNotEmpty) ...[
                  SectionHeader(title: 'Tugas Aktif'),
                  const SizedBox(height: 12),
                  _buildActiveTask(isDark, activeTask.first),
                  const SizedBox(height: 20),
                ],
                SectionHeader(title: 'Pendapatan Mingguan'),
                const SizedBox(height: 12),
                _buildEarningsChart(isDark),
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'Riwayat Tugas',
                  actionLabel: 'Lihat Semua',
                  onActionTap: () => context.go(RoutePaths.collectorHistory),
                  actionIcon: Icons.arrow_forward,
                ),
                const SizedBox(height: 12),
                _buildRecentTasks(isDark),
              ]),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildStatsRow(bool isDark, dynamic completedToday, dynamic earningsToday, dynamic rating) {
    return StatsRow(
      items: [
        StatItem(
          icon: Icons.check_circle,
          value: '$completedToday',
          label: 'Selesai Hari Ini',
          color: AppColors.success,
        ),
        StatItem(
          icon: Icons.account_balance_wallet,
          value: Formatters.formatCurrency(earningsToday is int ? earningsToday : 0),
          label: 'Pendapatan Hari Ini',
          color: AppColors.warning,
        ),
        StatItem(
          icon: Icons.star,
          value: '$rating',
          label: 'Rating',
          color: AppColors.gold,
        ),
      ],
    );
  }

  Widget _buildQuickStats(bool isDark, dynamic totalEarnings, dynamic totalTasks, dynamic rating) {
    final completed = totalTasks is int ? totalTasks : 0;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _quickStatItem(isDark, Icons.assignment_turned_in, Formatters.formatCurrency(totalEarnings is int ? totalEarnings : 0), 'Total Pendapatan')),
              Container(height: 40, width: 1, color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.textHint.withValues(alpha: 0.1)),
              Expanded(child: _quickStatItem(isDark, Icons.recycling, '$totalTasks', 'Total Tugas')),
              Container(height: 40, width: 1, color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.textHint.withValues(alpha: 0.1)),
              Expanded(child: _quickStatItem(isDark, Icons.star_half, '$rating', 'Rating Rata-rata')),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.textHint.withValues(alpha: 0.08)),
          const SizedBox(height: 14),
          Row(
            children: [
              Text('Level Progress', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              const Spacer(),
              Text('$completed/15 hari ini', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedProgressBar(value: completed / 15.0, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _quickStatItem(bool isDark, IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: isDark ? AppColors.secondary : AppColors.primary),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
      ],
    );
  }

  Widget _buildActiveTask(bool isDark, Map<String, dynamic> task) {
    final statusLabels = {'assigned': 'Ditugaskan', 'accepted': 'Diterima', 'on_the_way': 'Dalam Perjalanan', 'arrived': 'Tiba'};
    final status = task['status'] as String? ?? 'assigned';
    final statusLabel = statusLabels[status] ?? status;
    final citizenName = task['citizenName'] ?? task['citizen_name'] ?? 'Warga';
    final address = task['address'] ?? task['location']?.toString() ?? 'Alamat tidak tersedia';
    final weightKg = task['weightKg'] ?? 0;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      tintColor: AppColors.success.withValues(alpha: 0.05),
      onTap: () => context.push(RoutePaths.collectorTaskDetail),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.directions_bike, color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(citizenName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Text(address, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              StatusBadge(label: statusLabel, type: status),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.textHint.withValues(alpha: 0.08)),
          const SizedBox(height: 10),
          Row(
            children: [
              _detailChip(Icons.schedule, task['scheduled_time'] ?? 'Sekarang', isDark),
              const SizedBox(width: 16),
              _detailChip(Icons.location_on, '${task['distance_km'] ?? 0} km', isDark),
              const SizedBox(width: 16),
              _detailChip(Icons.category, '${weightKg} kg', isDark),
              const Spacer(),
              Text(Formatters.formatCurrency(task['earnings'] is int ? task['earnings'] : 0),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.success)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailChip(IconData icon, String text, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildEarningsChart(bool isDark) {
    final maxEarning = _weeklyEarnings.reduce((a, b) => a > b ? a : b);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Minggu Ini', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              const Spacer(),
              Text(Formatters.formatCurrency(_weeklyEarnings.reduce((a, b) => a + b)),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_weeklyEarnings.length, (i) {
                final height = maxEarning > 0 ? _weeklyEarnings[i] / maxEarning : 0.0;
                final isToday = i == DateTime.now().weekday - 1;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (height > 0)
                          Text(Formatters.formatCurrency(_weeklyEarnings[i]),
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                        const SizedBox(height: 4),
                        Animate(
                          effects: [ScaleEffect(begin: const Offset(1, 0), duration: (400 + i * 80).ms)],
                          child: Container(
                            height: (height * 80).clamp(4, 80.0),
                            decoration: BoxDecoration(
                              gradient: isToday
                                  ? AppColors.accentGradient
                                  : LinearGradient(colors: [isDark ? AppColors.cardDark : AppColors.primary.withValues(alpha: 0.3), isDark ? AppColors.primaryDark : AppColors.primaryLight.withValues(alpha: 0.2)]),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(_days[i], style: TextStyle(fontSize: 10, fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                          color: isToday ? (isDark ? AppColors.secondary : AppColors.primary) : (isDark ? AppColors.textSecondaryDark : AppColors.textHint))),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTasks(bool isDark) {
    final tasksAsync = ref.watch(collectorHistoryProvider);
    final recent = (tasksAsync.asData?.value ?? []).take(4).toList();
    if (recent.isEmpty) {
      return GlassCard(child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('Belum ada riwayat tugas', textAlign: TextAlign.center,
          style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textHint, fontSize: 13)),
      ));
    }
    return Column(
      children: recent.map((task) {
        final weightKg = task['weightKg'] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.check_circle, size: 20, color: AppColors.success)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Pickup ${task['id']?.toString().substring(0, 8) ?? ''}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                  Text('$weightKg kg - Selesai', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text('+${(weightKg is num ? weightKg.toInt() : 0) * 1000}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
