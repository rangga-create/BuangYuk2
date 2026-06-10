import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/providers/wallet_provider.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/premium_button.dart';
import '../../../shared/components/animated_progress.dart';

class RewardDetailScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? reward;
  const RewardDetailScreen({super.key, this.reward});

  @override
  ConsumerState<RewardDetailScreen> createState() => _RewardDetailScreenState();
}

class _RewardDetailScreenState extends ConsumerState<RewardDetailScreen> {
  bool _isRedeeming = false;

  Map<String, dynamic> get _reward =>
      widget.reward ?? {'title': 'Reward', 'points_required': 0, 'icon': Icons.card_giftcard, 'color': 0xFF4CAF50, 'description': '', 'terms': '', 'stock': null, 'popular': false, 'type': 'e-wallet'};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reward = _reward;
    final color = Color(reward['color'] as int);
    final pointsRequired = reward['points_required'] as int;
    final walletAsync = ref.watch(walletProvider);
    final userPoints = (walletAsync.asData?.value?['balance'] ?? 0) as int;
    final canAfford = userPoints >= pointsRequired;
    final progress = userPoints > 0 ? (userPoints / pointsRequired).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(title: Text(reward['title'] as String)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                padding: EdgeInsets.zero,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                          child: Icon(reward['icon'] as IconData, size: 52, color: Colors.white),
                        ),
                        SizedBox(height: 16.h),
                        Text(reward['title'] as String, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white), textAlign: TextAlign.center),
                        SizedBox(height: 8.h),
                        Text(reward['description'] as String, style: TextStyle(fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.85)), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 20, duration: 400.ms),
              SizedBox(height: 24.h),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Poin Diperlukan', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: canAfford ? AppColors.success.withValues(alpha: 0.12) : AppColors.warning.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stars_rounded, size: 16, color: canAfford ? AppColors.success : AppColors.warning),
                              SizedBox(width: 4.w),
                              Text(Formatters.formatPoints(pointsRequired), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: canAfford ? AppColors.success : AppColors.warning)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    AnimatedProgressBar(value: progress, height: 10, color: canAfford ? AppColors.success : AppColors.warning, showLabel: true),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Poin Anda: ${Formatters.formatPoints(userPoints)}', style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                        Text(canAfford ? 'Poin mencukupi' : 'Kurang ${Formatters.formatPoints(pointsRequired - userPoints)} poin',
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: canAfford ? AppColors.success : AppColors.error)),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 20, duration: 400.ms, delay: 200.ms),
              SizedBox(height: 24.h),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.description_outlined, size: 20, color: isDark ? AppColors.secondary : AppColors.primary),
                        SizedBox(width: 8.w),
                        Text('Syarat & Ketentuan', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: AppColors.info),
                          SizedBox(width: 8.w),
                          Expanded(child: Text(reward['terms'] as String, style: TextStyle(fontSize: 13.sp, height: 1.4, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary))),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 20, duration: 400.ms, delay: 300.ms),
              SizedBox(height: 24.h),
              PremiumButton(
                text: _isRedeeming ? 'Memproses...' : 'Tukarkan ${Formatters.formatPoints(pointsRequired)} Poin',
                icon: _isRedeeming ? Icons.hourglass_top : Icons.redeem,
                isLoading: _isRedeeming,
                color: canAfford ? null : AppColors.error,
                onPressed: () async {
                  if (_isRedeeming || !canAfford) return;
                  setState(() => _isRedeeming = true);
                  try {
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    await FirebaseFirestore.instance.runTransaction((transaction) async {
                      final walletRef = FirebaseFirestore.instance.collection('rewards').doc(uid);
                      final walletSnap = await transaction.get(walletRef);
                      if (!walletSnap.exists) throw Exception('Wallet not found');
                      final balance = (walletSnap.data()!['balance'] ?? 0) as int;
                      if (balance < pointsRequired) throw Exception('Insufficient balance');
                      transaction.update(walletRef, {
                        'balance': FieldValue.increment(-pointsRequired),
                        'updatedAt': FieldValue.serverTimestamp(),
                      });
                      final txnRef = FirebaseFirestore.instance.collection('reward_transactions').doc();
                      transaction.set(txnRef, {
                        'uid': uid, 'type': 'debit', 'amount': pointsRequired,
                        'description': 'Redeemed for ${reward['title']}',
                        'createdAt': FieldValue.serverTimestamp(),
                      });
                    });
                    if (!mounted) return;
                    setState(() => _isRedeeming = false);
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, size: 48, color: AppColors.success),
                            SizedBox(height: 16.h),
                            Text('Penukaran Berhasil!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                            SizedBox(height: 8.h),
                            Text(reward['title'] as String, style: TextStyle(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                            SizedBox(height: 16.h),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight, borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.stars_rounded, size: 16, color: AppColors.gold),
                                  SizedBox(width: 6.w),
                                  Text('-${Formatters.formatPoints(pointsRequired)} poin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        actions: [TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(context); }, child: const Text('OK'))],
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;
                    setState(() => _isRedeeming = false);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
                  }
                },
              ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 20, duration: 400.ms, delay: 500.ms),
              if (!canAfford) ...[
                SizedBox(height: 8.h),
                Text('Poin Anda belum cukup. Kumpulkan lebih banyak poin dengan melakukan penjemputan!', style: TextStyle(fontSize: 12.sp, color: AppColors.error), textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
