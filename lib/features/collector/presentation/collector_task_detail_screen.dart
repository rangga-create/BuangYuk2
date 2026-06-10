import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/mock/mock_pickups.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/status_badge.dart';
import '../../../shared/components/avatar_widget.dart';
import '../../../shared/components/premium_button.dart';
class CollectorTaskDetailScreen extends StatefulWidget {
  const CollectorTaskDetailScreen({super.key});

  @override
  State<CollectorTaskDetailScreen> createState() => _CollectorTaskDetailScreenState();
}

class _CollectorTaskDetailScreenState extends State<CollectorTaskDetailScreen> {
  bool _isLoading = false;
  String _actionMessage = '';

  Map<String, dynamic> get _task => MockPickups.collectorTasks.first;

  void _simulateAction(String action) {
    setState(() {
      _isLoading = true;
      _actionMessage = '';
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _actionMessage = action == 'start'
            ? 'Tugas sedang dimulai...'
            : action == 'complete'
                ? 'Tugas telah diselesaikan!'
                : 'Laporan telah dikirim';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() => _actionMessage = '');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final task = _task;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tugas'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: StatusBadge(label: task['status_label'], type: task['status']),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCitizenCard(isDark, task).animate().fadeIn(duration: 300.ms).slideY(begin: 15),
                  const SizedBox(height: 14),
                  _buildMapPlaceholder(isDark, task).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 15),
                  const SizedBox(height: 14),
                  _buildWasteDetails(isDark, task).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 15),
                  const SizedBox(height: 14),
                  _buildTimeline(isDark).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 15),
                  const SizedBox(height: 20),
                  if (_actionMessage.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _actionMessage,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: -10),
                  if (_actionMessage.isEmpty) ...[
                    _buildActionButtons(isDark, task),
                  ],
                ],
              ),
            ),
            ),
    );
  }

  Widget _buildCitizenCard(bool isDark, Map<String, dynamic> task) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AvatarWidget(
                imageUrl: task['citizen_avatar'],
                name: task['citizen_name'],
                radius: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['citizen_name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () => _showCallDialog(context, task['citizen_phone']),
                          child: Text(
                            task['citizen_phone'],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.secondary : AppColors.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${task['distance_km']} km',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder(bool isDark, Map<String, dynamic> task) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.cardDark, AppColors.surfaceDark]
                : [AppColors.primarySurface, AppColors.backgroundLight],
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map, size: 40, color: isDark ? AppColors.secondary : AppColors.primary.withValues(alpha: 0.4)),
                  const SizedBox(height: 8),
                  Text(
                    task['address'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${task['latitude']}, ${task['longitude']}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.cardDark : Colors.white).withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.textHint.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.navigation, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${task['distance_km']} km',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWasteDetails(bool isDark, Map<String, dynamic> task) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detail Sampah',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _detailItem(isDark, Icons.category, 'Jenis', task['waste_type']),
              const SizedBox(width: 16),
              _detailItem(isDark, Icons.inventory_2, 'Volume', task['volume']),
              const Spacer(),
              _detailItem(isDark, Icons.access_time, 'Jadwal', task['scheduled_time']),
            ],
          ),
          if (task['notes'] != null && (task['notes'] as String).isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.textHint.withValues(alpha: 0.08)),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.note, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task['notes'],
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.06) : AppColors.textHint.withValues(alpha: 0.08)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pendapatan Tugas Ini',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              Text(
                Formatters.formatCurrency(task['earnings']),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailItem(bool isDark, IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeline(bool isDark) {
    final steps = [
      {'label': 'Ditugaskan', 'time': '09:00 WIB', 'done': true},
      {'label': 'Dalam Perjalanan', 'time': '09:15 WIB', 'done': true},
      {'label': 'Tiba di Lokasi', 'time': '--', 'done': false},
      {'label': 'Selesai', 'time': '--', 'done': false},
    ];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(steps.length, (i) {
            final step = steps[i];
            final isDone = step['done'] as bool;
            final isLast = i == steps.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: isDone
                                ? AppColors.success
                                : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDone ? AppColors.success : (isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                              width: isDone ? 0 : 2,
                            ),
                          ),
                          child: isDone
                              ? const Icon(Icons.check, size: 12, color: Colors.white)
                              : null,
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: i < steps.length - 1 && (steps[i + 1]['done'] as bool)
                                  ? AppColors.success.withValues(alpha: 0.4)
                                  : (isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.textHint.withValues(alpha: 0.15)),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step['label'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isDone ? FontWeight.w600 : FontWeight.w500,
                            color: isDone
                                ? AppColors.success
                                : (isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          step['time'] as String,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, Map<String, dynamic> task) {
    if (task['status'] == 'completed') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: AppColors.success, size: 22),
            const SizedBox(width: 8),
            Text(
              'Tugas Telah Selesai',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            if (task['status'] == 'assigned')
              Expanded(
                child: PremiumButton(
                  text: 'Mulai Penjemputan',
                  icon: Icons.play_arrow,
                  isLoading: _isLoading,
                  onPressed: () => _simulateAction('start'),
                ),
              ),
            if (task['status'] == 'in_progress') ...[
              Expanded(
                child: PremiumButton(
                  text: 'Tandai Selesai',
                  icon: Icons.check_circle,
                  color: AppColors.success,
                  isLoading: _isLoading,
                  onPressed: () => _simulateAction('complete'),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        PremiumButton(
          text: 'Laporkan Masalah',
          icon: Icons.flag,
          isOutlined: true,
          color: AppColors.error,
          onPressed: () => _simulateAction('report'),
        ),
      ],
    );
  }

  void _showCallDialog(BuildContext context, String phone) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hubungi Warga'),
        content: Text('Telepon $phone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Memanggil $phone...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Hubungi'),
          ),
        ],
      ),
    );
  }
}
