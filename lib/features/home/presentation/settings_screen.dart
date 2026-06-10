import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/avatar_widget.dart';
import '../../../shared/components/premium_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _darkMode = false;
  bool _notifications = true;
  bool _emailNotif = true;
  String _language = 'id';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userAsync = ref.watch(userProfileProvider);
    final user = userAsync.asData?.value ?? {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
          _buildProfileSection(context, isDark, user),
          SizedBox(height: 24.h),
          _buildSectionLabel(context, isDark, 'Tampilan'),
          SizedBox(height: 8.h),
          GlassCard(
            child: Column(
              children: [
                _buildToggleTile(context, isDark, 'Mode Gelap', 'Gunakan tema gelap', Icons.dark_mode_outlined, _darkMode, (v) => setState(() => _darkMode = v)),
                const Divider(height: 1),
                _buildLanguageTile(context, isDark),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 15, duration: 300.ms),
          SizedBox(height: 24.h),
          _buildSectionLabel(context, isDark, 'Notifikasi'),
          SizedBox(height: 8.h),
          GlassCard(
            child: Column(
              children: [
                _buildToggleTile(context, isDark, 'Notifikasi Push', 'Terima notifikasi di ponsel', Icons.notifications_outlined, _notifications, (v) => setState(() => _notifications = v)),
                const Divider(height: 1),
                _buildToggleTile(context, isDark, 'Notifikasi Email', 'Terima notifikasi via email', Icons.email_outlined, _emailNotif, (v) => setState(() => _emailNotif = v)),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 15, duration: 300.ms, delay: 100.ms),
          SizedBox(height: 24.h),
          _buildSectionLabel(context, isDark, 'Lainnya'),
          SizedBox(height: 8.h),
          GlassCard(
            child: Column(
              children: [
                _buildNavTile(context, isDark, Icons.help_outline, 'Pusat Bantuan', 'Butuh bantuan?', RoutePaths.helpCenter),
                const Divider(height: 1),
                _buildNavTile(context, isDark, Icons.report_outlined, 'Laporkan Masalah', 'Laporkan bug atau masalah', RoutePaths.reportIssue),
                const Divider(height: 1),
                _buildNavTile(context, isDark, Icons.info_outline, 'Tentang Aplikasi', 'Versi 1.0.0+1', null),
                const Divider(height: 1),
                _buildNavTile(context, isDark, Icons.description_outlined, 'Kebijakan Privasi', 'Pelajari kebijakan privasi', null),
                const Divider(height: 1),
                _buildNavTile(context, isDark, Icons.article_outlined, 'Syarat & Ketentuan', 'Baca syarat dan ketentuan', null),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 15, duration: 300.ms, delay: 200.ms),
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
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 15, duration: 300.ms, delay: 300.ms),
          SizedBox(height: 32.h),
        ],
      ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, bool isDark, Map<String, dynamic> user) {
    final name = user['fullName'] ?? 'Pengguna';
    final email = user['email'] ?? '';
    final photoUrl = user['photoUrl'] as String?;
    return GlassCard(
      child: Row(
        children: [
          AvatarWidget(imageUrl: photoUrl, name: name, radius: 28.r),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                SizedBox(height: 2.h),
                Text(email, style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 15, duration: 300.ms);
  }

  Widget _buildSectionLabel(BuildContext context, bool isDark, String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, letterSpacing: 0.5),
    );
  }

  Widget _buildToggleTile(BuildContext context, bool isDark, String title, String subtitle, IconData icon, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: isDark ? AppColors.secondary : AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                SizedBox(height: 2.h),
                Text(subtitle, style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.language, size: 20, color: isDark ? AppColors.secondary : AppColors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bahasa', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                SizedBox(height: 2.h),
                Text(_language == 'id' ? 'Bahasa Indonesia' : 'English', style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (ctx) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Pilih Bahasa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      ),
                      ListTile(
                        leading: Icon(Icons.check, color: _language == 'id' ? AppColors.primary : Colors.transparent),
                        title: const Text('Bahasa Indonesia'),
                        onTap: () { setState(() => _language = 'id'); Navigator.pop(ctx); },
                      ),
                      ListTile(
                        leading: Icon(Icons.check, color: _language == 'en' ? AppColors.primary : Colors.transparent),
                        title: const Text('English'),
                        onTap: () { setState(() => _language = 'en'); Navigator.pop(ctx); },
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              );
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ganti', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? AppColors.secondary : AppColors.primary)),
                SizedBox(width: 4.w),
                Icon(Icons.chevron_right, size: 18, color: isDark ? AppColors.secondary : AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(BuildContext context, bool isDark, IconData icon, String title, String subtitle, String? route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: InkWell(
        onTap: route != null ? () => context.push(route) : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: isDark ? AppColors.secondary : AppColors.primary),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                  SizedBox(height: 2.h),
                  Text(subtitle, style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
