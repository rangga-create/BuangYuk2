import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/mock/mock_pickups.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/status_badge.dart';
import '../../../shared/components/empty_state.dart';
import '../../../core/router/route_paths.dart';

class CollectorTasksScreen extends StatefulWidget {
  const CollectorTasksScreen({super.key});

  @override
  State<CollectorTasksScreen> createState() => _CollectorTasksScreenState();
}

class _CollectorTasksScreenState extends State<CollectorTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabs = ['Semua', 'Menunggu', 'Berjalan', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredTasks(int tabIndex) {
    final tasks = MockPickups.collectorTasks;
    switch (tabIndex) {
      case 1:
        return tasks.where((t) => t['status'] == 'pending').toList();
      case 2:
        return tasks.where((t) => t['status'] == 'in_progress' || t['status'] == 'assigned').toList();
      case 3:
        return tasks.where((t) => t['status'] == 'completed').toList();
      default:
        return tasks;
    }
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas Penjemputan'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: isDark ? AppColors.secondary : AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
          indicatorColor: isDark ? AppColors.secondary : AppColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          dividerHeight: 0,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: List.generate(_tabs.length, (index) {
          final tasks = _filteredTasks(index);
          if (tasks.isEmpty) {
            return _buildEmptyState(index);
          }
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: isDark ? AppColors.secondary : AppColors.primary,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              itemCount: tasks.length,
              itemBuilder: (context, i) => _buildTaskCard(isDark, tasks[i], i),
            ),
          );
        }),
      ),
      ),
    );
  }

  Widget _buildEmptyState(int tabIndex) {
    final messages = [
      'Tidak ada tugas tersedia',
      'Semua tugas sudah ditugaskan',
      'Tidak ada tugas dalam proses',
      'Belum ada tugas selesai',
    ];
    return EmptyState(
      icon: Icons.task_alt,
      title: messages[tabIndex],
      message: 'Tugas baru akan muncul di sini ketika tersedia',
    );
  }

  Widget _buildTaskCard(bool isDark, Map<String, dynamic> task, int index) {
    Color statusColor;
    switch (task['status']) {
      case 'in_progress':
        statusColor = AppColors.warning;
      case 'assigned':
        statusColor = AppColors.info;
      case 'pending':
        statusColor = AppColors.textHint;
      default:
        statusColor = AppColors.success;
    }

    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: (index * 80).ms),
        MoveEffect(begin: const Offset(0, 20), duration: 300.ms, delay: (index * 80).ms),
      ],
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassCard(
          onTap: () => context.push(RoutePaths.collectorTaskDetail),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.person, size: 18, color: statusColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task['citizen_name'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task['address'],
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(label: task['status_label'], type: task['status']),
                ],
              ),
              const SizedBox(height: 12),
              Divider(color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.textHint.withValues(alpha: 0.08)),
              const SizedBox(height: 10),
              Row(
                children: [
                  _chip(Icons.schedule, task['scheduled_time'], isDark),
                  const SizedBox(width: 12),
                  _chip(Icons.location_on, '${task['distance_km']} km', isDark),
                  const SizedBox(width: 12),
                  _chip(Icons.category, task['waste_type'], isDark),
                  if (task['volume'] != null) ...[
                    const SizedBox(width: 12),
                    _chip(Icons.inventory_2, task['volume'], isDark),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.monetization_on, size: 16, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.formatCurrency(task['earnings']),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task['status'] == 'in_progress' ? 'Lanjutkan' : 'Lihat Detail',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.secondary : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(IconData icon, String text, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
