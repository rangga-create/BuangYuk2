import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/route_paths.dart';
import '../../../shared/components/premium_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = [
    _OnboardingPageData(
      icon: Icons.eco_rounded,
      title: 'Selamat Datang di BuangYuk',
      description: 'Aplikasi pengelolaan sampah pintar untuk masa depan yang lebih hijau dan bersih.',
      color: AppColors.success,
      benefits: [
        'Kelola sampah dengan mudah',
        'Dapatkan poin & reward',
        'Pantau jadwal pickup',
      ],
    ),
    _OnboardingPageData(
      icon: Icons.recycling_rounded,
      title: 'Bagaimana Cara Kerjanya?',
      description: 'Hanya 3 langkah mudah untuk memulai gaya hidup hijau bersama BuangYuk.',
      color: AppColors.info,
      benefits: [
        'Pilih jenis sampah yang akan diangkut',
        'Tentukan jadwal pickup',
        'Dapatkan poin dan tukarkan reward',
      ],
    ),
    _OnboardingPageData(
      icon: Icons.rocket_launch_rounded,
      title: 'Siap Memulai?',
      description: 'Bergabunglah dengan ribuan pengguna lain dalam mewujudkan lingkungan yang lebih bersih.',
      color: AppColors.warning,
      benefits: [
        'Komunitas peduli lingkungan',
        'Pantau dampak positif Anda',
        'Raih prestasi & badge eksklusif',
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.surfaceDark, AppColors.backgroundDark]
                : [AppColors.primarySurface, AppColors.backgroundLight],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(isDark),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) => _buildPage(_pages[index], isDark),
                ),
              ),
              _buildIndicator(isDark),
              _buildBottomButtons(isDark),
              SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentPage > 0)
            TextButton.icon(
              onPressed: () => _pageController.previousPage(
                duration: 300.ms,
                curve: Curves.easeInOut,
              ),
              icon: Icon(
                Icons.arrow_back_rounded,
                size: 18,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
              label: Text(
                'Kembali',
                style: GoogleFonts.inter(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            const SizedBox.shrink(),
          TextButton(
            onPressed: () => context.go(RoutePaths.login),
            child: Text(
              'Lewati',
              style: GoogleFonts.inter(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPageData page, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  page.color.withValues(alpha: 0.2),
                  page.color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              page.icon,
              size: 96,
              color: page.color,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 40),
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).moveY(begin: 20),
          const SizedBox(height: 16),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 15,
              height: 1.4,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms).moveY(begin: 20),
          const SizedBox(height: 32),
          ...page.benefits.map((benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: page.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: page.color,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  benefit,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildIndicator(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: 300.ms,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 28 : 8,
          height: 8,
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.primaryGradient : null,
            color: isActive
                ? null
                : (isDark
                    ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                    : AppColors.textHint.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildBottomButtons(bool isDark) {
    final isLast = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          PremiumButton(
            text: isLast ? 'Mulai Sekarang' : 'Lanjutkan',
            icon: isLast ? Icons.arrow_forward_rounded : null,
            color: isDark ? AppColors.secondary : AppColors.primary,
            onPressed: () {
              if (isLast) {
                context.go(RoutePaths.login);
              } else {
                _pageController.nextPage(
                  duration: 300.ms,
                  curve: Curves.easeInOut,
                );
              }
            },
          ),
          if (!isLast) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go(RoutePaths.login),
              child: Text(
                'Sudah punya akun? Masuk',
                style: GoogleFonts.inter(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final List<String> benefits;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.benefits,
  });
}
