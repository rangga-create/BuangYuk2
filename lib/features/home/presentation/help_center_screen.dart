import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/route_paths.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/premium_button.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  int? _expandedIndex;

  final List<Map<String, dynamic>> _faqCategories = [
    {
      'category': 'Penjemputan Sampah',
      'icon': Icons.local_shipping_outlined,
      'color': AppColors.primary,
      'items': [
        {
          'q': 'Bagaimana cara menjadwalkan penjemputan sampah?',
          'a': 'Anda bisa menjadwalkan penjemputan melalui menu "Jemput Sampah" di halaman utama. Pilih alamat, jenis sampah, volume, dan tanggal penjemputan. Petugas akan datang sesuai jadwal.',
        },
        {
          'q': 'Berapa lama waktu penjemputan sampah?',
          'a': 'Petugas biasanya tiba dalam 1-2 jam setelah penjadwalan. Anda bisa melacak lokasi petugas secara langsung melalui fitur lacak.',
        },
        {
          'q': 'Apakah ada minimal volume sampah?',
          'a': 'Tidak ada minimal volume. BuangYuk melayani penjemputan sampah dalam jumlah berapapun, mulai dari 1 kantong.',
        },
        {
          'q': 'Bagaimana jika petugas tidak datang?',
          'a': 'Anda bisa menghubungi petugas melalui tombol "Hubungi" di halaman lacak. Jika tidak ada respons, hubungi customer service kami.',
        },
      ],
    },
    {
      'category': 'Poin & Reward',
      'icon': Icons.stars_rounded,
      'color': AppColors.gold,
      'items': [
        {
          'q': 'Bagaimana cara mendapatkan poin?',
          'a': 'Poin didapatkan dari setiap penjemputan sampah, scan sampah, menyelesaikan tantangan, dan mencapai pencapaian tertentu.',
        },
        {
          'q': 'Apakah poin bisa kadaluarsa?',
          'a': 'Ya, poin akan kadaluarsa setelah 6 bulan tidak ada aktivitas. Pastikan Anda rutin melakukan penjemputan atau menukarkan poin.',
        },
        {
          'q': 'Bagaimana cara menukarkan poin?',
          'a': 'Buka menu "Tukar Poin", pilih reward yang diinginkan, lalu klik tombol "Tukarkan". Poin akan otomatis terpotong.',
        },
      ],
    },
    {
      'category': 'Aplikasi & Akun',
      'icon': Icons.settings_outlined,
      'color': AppColors.info,
      'items': [
        {
          'q': 'Bagaimana cara mengubah profil?',
          'a': 'Anda bisa mengubah profil melalui menu Pengaturan > Profil. Edit nama, email, atau foto profil Anda.',
        },
        {
          'q': 'Apakah data saya aman?',
          'a': 'Kami menjaga keamanan data Anda dengan enkripsi dan tidak membagikan data pribadi tanpa izin. Baca kebijakan privasi kami untuk informasi lebih lanjut.',
        },
        {
          'q': 'Bagaimana cara logout?',
          'a': 'Buka menu Pengaturan, scroll ke bawah dan klik tombol "Keluar". Konfirmasi untuk logout dari aplikasi.',
        },
      ],
    },
    {
      'category': 'Laporan & Masalah',
      'icon': Icons.report_outlined,
      'color': AppColors.error,
      'items': [
        {
          'q': 'Bagaimana cara melaporkan masalah?',
          'a': 'Anda bisa melaporkan masalah melalui menu "Laporkan Masalah" di Pengaturan. Jelaskan masalah yang Anda alami dan kami akan merespon dalam 1x24 jam.',
        },
        {
          'q': 'Bagaimana jika ada petugas yang tidak ramah?',
          'a': 'Silakan laporkan melalui menu Laporan Masalah dengan menyertakan ID penjemputan. Kami akan menindaklanjuti dengan serius.',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pusat Bantuan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              SizedBox(height: 24.h),
              ..._faqCategories.asMap().entries.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCategoryHeader(context, isDark, entry.value),
                      SizedBox(height: 12.h),
                      ...(entry.value['items'] as List<Map<String, String>>).asMap().entries.map((item) {
                        return _buildFaqItem(context, isDark, item.value, entry.key, item.key);
                      }),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: (entry.key * 100).ms).slideY(begin: 15, duration: 300.ms);
              }),
              SizedBox(height: 24.h),
              _buildContactSection(context, isDark),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.help_outline, color: isDark ? AppColors.secondary : AppColors.primary, size: 28),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pusat Bantuan', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                SizedBox(height: 4.h),
                Text('Temukan jawaban untuk pertanyaan Anda', style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 20, duration: 400.ms);
  }

  Widget _buildCategoryHeader(BuildContext context, bool isDark, Map<String, dynamic> category) {
    final color = category['color'] as Color;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(category['icon'] as IconData, color: color, size: 18),
        ),
        SizedBox(width: 10.w),
        Text(
          category['category'] as String,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildFaqItem(BuildContext context, bool isDark, Map<String, String> item, int catIndex, int itemIndex) {
    final globalIndex = _faqCategories.take(catIndex).fold<int>(0, (sum, c) => sum + (c['items'] as List).length) + itemIndex;
    final isExpanded = _expandedIndex == globalIndex;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expandedIndex = isExpanded ? null : globalIndex),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['q']!,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: 200.ms,
                      child: Icon(Icons.expand_more, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  item['a']!,
                  style: TextStyle(fontSize: 13.sp, height: 1.4, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                ),
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: 300.ms,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Butuh Bantuan Lebih Lanjut?', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        SizedBox(height: 12.h),
        PremiumButton(
          text: 'Hubungi Customer Service',
          icon: Icons.headset_mic_outlined,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menghubungi customer service...')),
            );
          },
        ),
        SizedBox(height: 12.h),
        PremiumButton(
          text: 'Laporkan Masalah',
          icon: Icons.report_outlined,
          isOutlined: true,
          onPressed: () => context.push(RoutePaths.reportIssue),
        ),
        SizedBox(height: 16.h),
        Center(
          child: Text(
            'Versi Aplikasi 1.0.0+1',
            style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 20, duration: 400.ms, delay: 400.ms);
  }
}
