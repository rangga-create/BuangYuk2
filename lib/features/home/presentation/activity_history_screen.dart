import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/mock/mock_activities.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/empty_state.dart';

class ActivityHistoryScreen extends StatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  String _selectedFilter = 'Semua';

  final List<Map<String, String>> _filters = [
    {'key': 'Semua', 'label': 'Semua', 'icon': 'all_inclusive'},
    {'key': 'pickup', 'label': 'Pickup', 'icon': 'local_shipping'},
    {'key': 'scan', 'label': 'Scan', 'icon': 'document_scanner'},
    {'key': 'achievement', 'label': 'Pencapaian', 'icon': 'emoji_events'},
    {'key': 'reward', 'label': 'Reward', 'icon': 'card_giftcard'},
    {'key': 'challenge', 'label': 'Tantangan', 'icon': 'assignment_turned_in'},
  ];

  List<Map<String, dynamic>> get _filteredActivities {
    if (_selectedFilter == 'Semua') return MockActivities.activities;
    return MockActivities.activities.where((a) => a['type'] == _selectedFilter).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedActivities {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final activity in _filteredActivities) {
      final dateLabel = Formatters.dateLabel(activity['date'] as String);
      grouped.putIfAbsent(dateLabel, () => []).add(activity);
    }
    return grouped;
  }

  IconData _getFilterIcon(String name) {
    switch (name) {
      case 'all_inclusive': return Icons.all_inclusive;
      case 'local_shipping': return Icons.local_shipping;
      case 'document_scanner': return Icons.document_scanner;
      case 'emoji_events': return Icons.emoji_events;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'assignment_turned_in': return Icons.assignment_turned_in;
      default: return Icons.circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final grouped = _groupedActivities;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Aktivitas'),
      ),
      body: Column(
        children: [
          _buildFilterTabs(context, isDark),
          Expanded(
            child: _filteredActivities.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      EmptyState(
                        icon: Icons.history_outlined,
                        title: 'Belum Ada Aktivitas',
                        message: 'Aktivitas Anda akan muncul di sini',
                      ),
                    ],
                  )
                : ListView(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                    children: grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    entry.key,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.secondary : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...entry.value.map((activity) {
                            final points = activity['points'] as int;
                            final color = Color(activity['color'] as int);
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: GlassCard(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(activity['icon'] as IconData, color: color, size: 22),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(activity['title'] as String, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                                          SizedBox(height: 2.h),
                                          Text(activity['description'] as String, style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          SizedBox(height: 4.h),
                                          Text(Formatters.formatDate(activity['date'] as String), style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${points >= 0 ? '+' : ''}$points',
                                          style: TextStyle(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.w800,
                                            color: points >= 0 ? AppColors.success : AppColors.error,
                                          ),
                                        ),
                                        if (activity['kg_saved'] != null)
                                          Text(
                                            '${activity['kg_saved']} kg',
                                            style: TextStyle(fontSize: 11.sp, color: AppColors.success),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(duration: 300.ms).slideX(begin: 20, duration: 300.ms);
                          }),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, bool isDark) {
    return SizedBox(
      height: 48.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        children: _filters.map((f) {
          final isSelected = _selectedFilter == f['key'];
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = f['key']!),
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.secondary : AppColors.primary)
                    : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getFilterIcon(f['icon']!),
                    size: 16,
                    color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    f['label']!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
