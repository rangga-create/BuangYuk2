import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/wallet_provider.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/avatar_widget.dart';
import '../../../shared/components/stats_row.dart';
import '../../../shared/components/premium_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(userProfileProvider);
    final walletAsync = ref.watch(walletProvider);
    final user = userAsync.asData?.value ?? {};
    final wallet = walletAsync.asData?.value ?? {};
    final balance = (wallet['balance'] ?? 0) as int;
    final totalEarned = (wallet['totalEarned'] ?? 0) as int;
    final name = user['fullName'] ?? 'Pengguna';
    final email = user['email'] ?? '';
    final phone = user['phone'] ?? '-';
    final address = user['address'] ?? '-';
    final photoUrl = user['photoUrl'] as String?;
    final role = user['role'] ?? 'citizen';
    final city = user['city'] ?? '';
    final district = user['district'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(RoutePaths.settings),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              child: Column(
                children: [
                  AvatarWidget(imageUrl: photoUrl, name: name, radius: 40.r, showBadge: true, isOnline: true),
                  SizedBox(height: 16.h),
                  Text(name, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                  SizedBox(height: 4.h),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                    child: Text(role == 'collector' ? 'Petugas' : role == 'citizen' ? 'Warga' : 'Admin',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                  SizedBox(height: 8.h),
                  Text(email, style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                  SizedBox(height: 4.h),
                  Text(city.isNotEmpty ? '$district, $city' : '', style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 20, duration: 400.ms),
            SizedBox(height: 24.h),
            StatsRow(
              items: [
                StatItem(icon: Icons.stars_rounded, value: Formatters.formatPoints(balance), label: 'Poin', color: AppColors.gold),
                StatItem(icon: Icons.eco, value: Formatters.formatPoints(totalEarned), label: 'Total Poin', color: AppColors.success),
              ],
            ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 20, duration: 400.ms, delay: 200.ms),
            SizedBox(height: 24.h),
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Informasi Pribadi', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                  SizedBox(height: 16.h),
                  _infoTile(context, isDark, Icons.phone_outlined, 'Telepon', phone),
                  const Divider(height: 24),
                  _infoTile(context, isDark, Icons.location_on_outlined, 'Alamat', address),
                  const Divider(height: 24),
                  _infoTile(context, isDark, Icons.email_outlined, 'Email', email),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 20, duration: 400.ms, delay: 300.ms),
            SizedBox(height: 24.h),
            PremiumButton(
              text: 'Keluar',
              icon: Icons.logout,
              isOutlined: true,
              color: AppColors.error,
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Keluar?'),
                    content: const Text('Anda akan keluar dari aplikasi.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Keluar', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) context.go(RoutePaths.login);
                }
              },
            ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 20, duration: 400.ms, delay: 400.ms),
            SizedBox(height: 32.h),
          ],
        ),
      ),
      ),
    );
  }

  Widget _infoTile(BuildContext context, bool isDark, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
              SizedBox(height: 2.h),
              Text(value, style: TextStyle(fontSize: 14.sp, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
