import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/mock/mock_pickups.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/premium_button.dart';
import '../../../shared/components/avatar_widget.dart';

class PickupTrackingScreen extends StatefulWidget {
  final Map<String, dynamic>? pickup;

  const PickupTrackingScreen({super.key, this.pickup});

  @override
  State<PickupTrackingScreen> createState() => _PickupTrackingScreenState();
}

class _PickupTrackingScreenState extends State<PickupTrackingScreen> {
  late Timer _timer;
  int _secondsRemaining = 720;
  int _progressStep = 0;
  final List<String> _statusMessages = [
    'Petugas sedang menuju lokasi Anda...',
    'Petugas sudah dekat!',
    'Petugas hampir sampai!',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          if (_secondsRemaining > 0) _secondsRemaining--;
          if (_progressStep < 2) _progressStep++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress => 1.0 - (_secondsRemaining / 720);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = widget.pickup ?? MockPickups.activePickups[1];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lacak Penjemputan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.push(RoutePaths.pickupDetail, extra: p),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLiveStatusIndicator(context, isDark),
            SizedBox(height: 24.h),
            _buildAnimatedMap(context, isDark),
            SizedBox(height: 24.h),
            _buildProgressSection(context, isDark),
            SizedBox(height: 24.h),
            _buildCollectorCard(context, isDark, p),
            SizedBox(height: 24.h),
            _buildPickupInfo(context, isDark, p),
            SizedBox(height: 24.h),
            _buildActions(context, isDark),
            SizedBox(height: 32.h),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildLiveStatusIndicator(BuildContext context, bool isDark) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.success.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2),
              ],
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            duration: 800.ms,
            begin: const Offset(1, 1),
            end: const Offset(1.3, 1.3),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Langsung', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                SizedBox(height: 2.h),
                AnimatedSwitcher(
                  duration: 400.ms,
                  child: Text(
                    _statusMessages[_progressStep.clamp(0, 2)],
                    key: ValueKey(_progressStep),
                    style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text('Estimasi', style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
              SizedBox(height: 2.h),
              Text(
                _formattedTime,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: _secondsRemaining < 120 ? AppColors.error : AppColors.warning,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 20, duration: 400.ms);
  }

  Widget _buildAnimatedMap(BuildContext context, bool isDark) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Container(
        height: 280.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight].map((c) => c.withValues(alpha: 0.08)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 48.sp, color: isDark ? AppColors.secondary : AppColors.primary.withValues(alpha: 0.3)),
                  SizedBox(height: 8.h),
                  Text('Peta Langsung', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                  SizedBox(height: 4.h),
                  Text('Lokasi diperbarui langsung', style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.6) : AppColors.textHint.withValues(alpha: 0.7))),
                ],
              ),
            ),
            AnimatedPositioned(
              duration: 800.ms,
              curve: Curves.easeInOut,
              left: 20.w + (_progress * 100).w,
              bottom: 60.h,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
                  ],
                ),
                child: Icon(Icons.local_shipping, color: AppColors.warning, size: 28),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: -5, duration: 600.ms),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.gps_fixed, size: 14, color: AppColors.info),
                    SizedBox(width: 4.w),
                    Text('Langsung', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.info)),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20.w,
              bottom: 30.h,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.white),
                    SizedBox(width: 4.w),
                    Text('Tujuan', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 20, duration: 400.ms, delay: 200.ms);
  }

  Widget _buildProgressSection(BuildContext context, bool isDark) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Perjalanan', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              Text('${(_progress * 100).toInt()}%', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.warning)),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 10,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.warning.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: 1200.ms, color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.2)),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildLocationDot('Lokasi Awal', true, isDark),
              _buildLocationDot('Perjalanan', _progress > 0.3, isDark),
              _buildLocationDot('Lokasi Anda', _progress > 0.7, isDark),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 20, duration: 400.ms, delay: 300.ms);
  }

  Widget _buildLocationDot(String label, bool active, bool isDark) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: active ? AppColors.success : (isDark ? AppColors.textSecondaryDark : Colors.grey.shade300),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(height: 4.h),
        Text(label, style: TextStyle(fontSize: 10.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
      ],
    );
  }

  Widget _buildCollectorCard(BuildContext context, bool isDark, Map<String, dynamic> p) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Petugas', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          SizedBox(height: 16.h),
          Row(
            children: [
              AvatarWidget(
                name: p['collector_name'] ?? 'Petugas',
                radius: 28.r,
                showBadge: true,
                isOnline: true,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['collector_name'] ?? 'Ahmad Rizki', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                        ),
                        SizedBox(width: 6.w),
                        Text('Online', style: TextStyle(fontSize: 12.sp, color: AppColors.success, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menghubungi petugas...'))),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.phone, size: 24, color: AppColors.success),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.directions_car, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
              SizedBox(width: 8.w),
              Text('Motor Roda Tiga', style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              const Spacer(),
              Icon(Icons.star, size: 16, color: AppColors.gold),
              SizedBox(width: 4.w),
              Text('4.8', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.gold)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 20, duration: 400.ms, delay: 400.ms);
  }

  Widget _buildPickupInfo(BuildContext context, bool isDark, Map<String, dynamic> p) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Detail Penjemputan', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          SizedBox(height: 12.h),
          _infoRow(Icons.location_on_outlined, 'Alamat', p['address'] as String, isDark),
          SizedBox(height: 8.h),
          _infoRow(Icons.category_outlined, 'Jenis Sampah', p['waste_type'] as String, isDark),
          SizedBox(height: 8.h),
          _infoRow(Icons.scale_outlined, 'Volume', p['volume'] as String, isDark),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 20, duration: 400.ms, delay: 500.ms);
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
        SizedBox(width: 8.w),
        Text('$label: ', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
        Expanded(child: Text(value, style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary))),
      ],
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    return Column(
      children: [
        PremiumButton(
          text: 'Hubungi Petugas',
          icon: Icons.phone,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Menghubungi petugas...')),
            );
          },
        ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 20, duration: 400.ms, delay: 600.ms),
        SizedBox(height: 12.h),
        PremiumButton(
          text: 'Batalkan Permintaan',
          icon: Icons.cancel_outlined,
          isOutlined: true,
          color: AppColors.error,
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Batalkan Penjemputan?'),
                content: const Text('Anda yakin ingin membatalkan penjemputan ini?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tidak')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Penjemputan dibatalkan')),
                      );
                      context.pop();
                    },
                    child: const Text('Ya, Batalkan'),
                  ),
                ],
              ),
            );
          },
        ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideY(begin: 20, duration: 400.ms, delay: 700.ms),
      ],
    );
  }
}
