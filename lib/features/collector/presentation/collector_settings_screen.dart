import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/mock/mock_users.dart';
import '../../../shared/components/glass_card.dart';

class CollectorSettingsScreen extends StatefulWidget {
  const CollectorSettingsScreen({super.key});

  @override
  State<CollectorSettingsScreen> createState() => _CollectorSettingsScreenState();
}

class _CollectorSettingsScreenState extends State<CollectorSettingsScreen> {
  bool _notificationsEnabled = true;
  bool _availableForTasks = true;
  bool _shareLocation = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final collector = MockUsers.collectorUser;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 24.h),
                    _buildProfileSection(isDark, collector),
                    SizedBox(height: 24.h),
                    _buildPreferencesSection(isDark),
                    SizedBox(height: 24.h),
                    _buildAccountSection(isDark),
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

  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16.h, left: 20.w, right: 20.w, bottom: 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.cardDark, AppColors.primaryDark.withValues(alpha: 0.5)]
              : [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : Colors.white,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -20),
          SizedBox(height: 4.h),
          Text(
            'Atur preferensi akun',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? AppColors.textSecondaryDark : Colors.white.withValues(alpha: 0.85),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideX(begin: -20),
        ],
      ),
    );
  }

  Widget _buildProfileSection(bool isDark, Map<String, dynamic> collector) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profil',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        GlassCard(
          child: Column(
            children: [
              _buildInfoRow(isDark, 'Nama', collector['name']),
              const Divider(height: 1),
              _buildInfoRow(isDark, 'Email', collector['email']),
              const Divider(height: 1),
              _buildInfoRow(isDark, 'Telepon', collector['phone']),
              const Divider(height: 1),
              _buildInfoRow(isDark, 'Kendaraan', collector['vehicle']),
              const Divider(height: 1),
              _buildInfoRow(isDark, 'Wilayah', collector['region']),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 20),
      ],
    );
  }

  Widget _buildInfoRow(bool isDark, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
          Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _buildPreferencesSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preferensi Tugas',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        GlassCard(
          child: Column(
            children: [
              _buildToggleTile(isDark, 'Tersedia untuk Tugas', 'Terima tugas baru secara otomatis', _availableForTasks, (v) {
                setState(() => _availableForTasks = v);
              }),
              const Divider(height: 1),
              _buildToggleTile(isDark, 'Bagikan Lokasi', 'Izinkan admin melihat lokasi Anda', _shareLocation, (v) {
                setState(() => _shareLocation = v);
              }),
              const Divider(height: 1),
              _buildToggleTile(isDark, 'Notifikasi', 'Terima notifikasi tugas baru', _notificationsEnabled, (v) {
                setState(() => _notificationsEnabled = v);
              }),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 20),
      ],
    );
  }

  Widget _buildToggleTile(bool isDark, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                SizedBox(height: 2.h),
                Text(subtitle, style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                SizedBox(height: 12.h),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: isDark ? AppColors.secondary : AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Akun',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        GlassCard(
          child: Column(
            children: [
              _buildActionTile(isDark, Icons.lock_outline, 'Ubah Password', 'Perbarui password akun'),
              const Divider(height: 1),
              _buildActionTile(isDark, Icons.language_outlined, 'Bahasa', 'Indonesia'),
              const Divider(height: 1),
              _buildActionTile(isDark, Icons.info_outline, 'Versi Aplikasi', '1.0.0'),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 20),
      ],
    );
  }

  Widget _buildActionTile(bool isDark, IconData icon, String title, String subtitle) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$title (Mock)'), behavior: SnackBarBehavior.floating),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  Text(subtitle, style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
