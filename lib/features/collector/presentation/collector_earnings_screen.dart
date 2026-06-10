import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/mock/mock_users.dart';
import '../../../shared/mock/mock_pickups.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/components/empty_state.dart';

class CollectorEarningsScreen extends StatefulWidget {
  const CollectorEarningsScreen({super.key});

  @override
  State<CollectorEarningsScreen> createState() => _CollectorEarningsScreenState();
}

class _CollectorEarningsScreenState extends State<CollectorEarningsScreen> {
  String _selectedPeriod = 'Minggu';
  final _periods = ['Hari Ini', 'Minggu', 'Bulan'];

  final _weeklyEarnings = [120000, 95000, 150000, 110000, 130000, 45000, 0];
  final _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  int _totalEarnings = 0;

  @override
  void initState() {
    super.initState();
    _totalEarnings = MockUsers.collectorUser['total_earnings'] as int;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = MockUsers.collectorUser;
    final transactions = MockPickups.collectorHistory;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
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
                  top: MediaQuery.of(context).padding.top + 70,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Pendapatan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: _totalEarnings),
                      duration: const Duration(milliseconds: 1500),
                      builder: (context, value, child) => Text(
                        Formatters.formatCurrency(value),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                    ).animate().fadeIn(duration: 500.ms),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.trending_up, size: 16, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          '+12% dari minggu lalu',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildTodayCard(isDark, user).animate().fadeIn(duration: 300.ms).slideY(begin: 15),
                const SizedBox(height: 16),
                _buildPeriodSelector(isDark),
                const SizedBox(height: 14),
                _buildChart(isDark),
                const SizedBox(height: 20),
                SectionHeader(title: 'Riwayat Transaksi'),
                const SizedBox(height: 12),
                if (transactions.isEmpty)
                  EmptyState(
                    icon: Icons.receipt_long,
                    title: 'Belum ada transaksi',
                    message: 'Transaksi akan muncul setelah Anda menyelesaikan tugas',
                  )
                else
                  ...transactions.asMap().entries.map((entry) =>
                    _buildTransactionCard(isDark, entry.value, entry.key),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard(bool isDark, Map<String, dynamic> user) {
    return GlassCardGradient(
      gradient: AppColors.primaryGradient,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pendapatan Hari Ini',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  Formatters.formatCurrency(user['today_earnings']),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user['tasks_completed_today']} tugas selesai',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              size: 32,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: _periods.map((period) {
          final isSelected = _selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
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
                  period,
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

  Widget _buildChart(bool isDark) {
    final maxEarning = _weeklyEarnings.reduce((a, b) => a > b ? a : b);
    final total = _weeklyEarnings.reduce((a, b) => a + b);

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Pendapatan $_selectedPeriod',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                Formatters.formatCurrency(total),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
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
                          Text(
                            '${(_weeklyEarnings[i] / 1000).toInt()}k',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Animate(
                          effects: [ScaleEffect(begin: const Offset(1, 0), duration: (400 + i * 80).ms)],
                          child: Container(
                            height: (height * 90).clamp(4, 90.0),
                            decoration: BoxDecoration(
                              gradient: isToday
                                  ? AppColors.accentGradient
                                  : LinearGradient(
                                      colors: [
                                        isDark ? AppColors.cardDark : AppColors.primary.withValues(alpha: 0.3),
                                        isDark ? AppColors.primaryDark : AppColors.primaryLight.withValues(alpha: 0.15),
                                      ],
                                    ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _days[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                            color: isToday
                                ? (isDark ? AppColors.secondary : AppColors.primary)
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                          ),
                        ),
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

  Widget _buildTransactionCard(bool isDark, Map<String, dynamic> transaction, int index) {
    return Animate(
      effects: [
        FadeEffect(duration: 300.ms, delay: (index * 80).ms),
        MoveEffect(begin: const Offset(0, 15), duration: 300.ms, delay: (index * 80).ms),
      ],
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['citizen_name'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.formatDate(transaction['completed_at']),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                Formatters.formatCurrency(transaction['earnings']),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
