import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/mock/mock_pickups.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/empty_state.dart';

class CollectorHistoryScreen extends StatefulWidget {
  const CollectorHistoryScreen({super.key});

  @override
  State<CollectorHistoryScreen> createState() => _CollectorHistoryScreenState();
}

class _CollectorHistoryScreenState extends State<CollectorHistoryScreen> {
  int _selectedFilter = 0;
  final _filters = ['Semua', 'Minggu Ini', 'Bulan Ini'];

  List<Map<String, dynamic>> get _history => MockPickups.collectorHistory;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final history = _history;

    final totalEarnings = history.fold<int>(0, (sum, t) => sum + (t['earnings'] as int));
    final avgRating = history.isEmpty
        ? 0.0
        : history.fold<double>(0.0, (sum, t) => sum + (t['rating'] as num).toDouble()) / history.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Tugas'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsSummary(isDark, history.length, totalEarnings, avgRating)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 15),
                const SizedBox(height: 16),
                _buildFilterRow(isDark),
                const SizedBox(height: 14),
                if (history.isEmpty)
                  EmptyState(
                    icon: Icons.history,
                    title: 'Belum ada riwayat',
                    message: 'Riwayat tugas akan muncul setelah Anda menyelesaikan penjemputan',
                  )
                else
                  ...history.asMap().entries.map((entry) =>
                    _buildHistoryCard(isDark, entry.value, entry.key),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(bool isDark, int total, int earnings, double avgRating) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statItem(
                  isDark,
                  Icons.assignment_turned_in,
                  '$total',
                  'Total Tugas',
                  AppColors.primary,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.textHint.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _statItem(
                  isDark,
                  Icons.account_balance_wallet,
                  Formatters.formatCurrency(earnings),
                  'Total Pendapatan',
                  AppColors.warning,
                ),
              ),
              Container(
                height: 40,
                width: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.textHint.withValues(alpha: 0.1),
              ),
              Expanded(
                child: _statItem(
                  isDark,
                  Icons.star,
                  avgRating.toStringAsFixed(1),
                  'Rating Rata-rata',
                  AppColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(bool isDark, IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _filters.asMap().entries.map((entry) {
          final idx = entry.key;
          final label = entry.value;
          final isSelected = _selectedFilter == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = idx),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.primaryDark : AppColors.primary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryCard(bool isDark, Map<String, dynamic> item, int index) {
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: (index * 80).ms),
        MoveEffect(begin: const Offset(0, 15), duration: 300.ms, delay: (index * 80).ms),
      ],
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_circle, color: AppColors.success, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['citizen_name'],
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['address'],
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
                  Text(
                    Formatters.formatCurrency(item['earnings']),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Divider(color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.textHint.withValues(alpha: 0.08)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.formatDate(item['completed_at']),
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.category, size: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                  const SizedBox(width: 4),
                  Text(
                    item['waste_type'],
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  _buildStars(item['rating'] as int),
                ],
              ),
              if (item['feedback'] != null && (item['feedback'] as String).isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.format_quote, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item['feedback'],
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating ? Icons.star : Icons.star_outline,
          size: 14,
          color: i < rating ? AppColors.gold : AppColors.textHint,
        );
      }),
    );
  }
}
