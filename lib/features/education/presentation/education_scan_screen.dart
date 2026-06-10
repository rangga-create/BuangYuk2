import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/constants.dart';
import '../../../shared/components/premium_button.dart';

class EducationScanScreen extends StatefulWidget {
  const EducationScanScreen({super.key});

  @override
  State<EducationScanScreen> createState() => _EducationScanScreenState();
}

class _EducationScanScreenState extends State<EducationScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  bool _isScanning = false;
  String? _selectedWasteType;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(vsync: this, duration: 2000.ms);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _startScan() {
    if (_selectedWasteType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis sampah terlebih dahulu')),
      );
      return;
    }

    setState(() => _isScanning = true);
    _scanController.repeat(reverse: true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _scanController.stop();
        setState(() => _isScanning = false);
        context.push(RoutePaths.scanResult, extra: _selectedWasteType);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0A0A) : AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text('Scan Sampah'),
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? AppColors.textPrimaryDark : Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildCameraPreview(context, isDark),
            ),
            _buildBottomSheet(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(BuildContext context, bool isDark) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                  : [AppColors.primaryDark, AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 220.w,
                height: 220.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedWasteType != null
                              ? (AppConstants.wasteTypeIcons.firstWhere((t) => t['label'] == _selectedWasteType)['icon'] as IconData)
                              : Icons.document_scanner_outlined,
                          size: 56.sp,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          _selectedWasteType != null
                              ? 'Scan $_selectedWasteType'
                              : 'Arahkan ke sampah',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withValues(alpha: 0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (_isScanning)
                      Positioned(
                        left: 0,
                        right: 0,
                        child: AnimatedBuilder(
                          animation: _scanController,
                          builder: (context, child) {
                            return Container(
                              height: 3,
                              width: double.infinity,
                              margin: EdgeInsets.only(top: _scanController.value * 200.h),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.accent.withValues(alpha: 0.8),
                                    AppColors.accent,
                                    AppColors.accent.withValues(alpha: 0.8),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (_isScanning)
                      ...List.generate(4, (i) {
                        final corners = [
                          Alignment.topLeft,
                          Alignment.topRight,
                          Alignment.bottomLeft,
                          Alignment.bottomRight,
                        ];
                        return Container(
                          width: 20,
                          height: 20,
                          alignment: corners[i],
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              border: Border(
                                top: i < 2 ? BorderSide(color: AppColors.accent, width: 3) : BorderSide.none,
                                bottom: i >= 2 ? BorderSide(color: AppColors.accent, width: 3) : BorderSide.none,
                                left: i % 2 == 0 ? BorderSide(color: AppColors.accent, width: 3) : BorderSide.none,
                                right: i % 2 == 1 ? BorderSide(color: AppColors.accent, width: 3) : BorderSide.none,
                              ),
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),
              SizedBox(height: 24.h),
              if (!_isScanning)
                GestureDetector(
                  onTap: _startScan,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 4),
                      ],
                    ),
                    child: Icon(Icons.document_scanner, size: 32, color: Colors.white),
                  ).animate().scale(duration: 400.ms, begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
                )
              else
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: AppColors.accent,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              if (!_isScanning) ...[
                SizedBox(height: 12.h),
                Text(
                  'Ketuk untuk memindai',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white.withValues(alpha: 0.6)),
                ),
              ],
            ],
          ),
        ),
        if (_isScanning)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              color: AppColors.success.withValues(alpha: 0.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                  SizedBox(width: 8.w),
                  Text('Memindai sampah...', style: TextStyle(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                ],
              ),
            ).animate().fadeIn(duration: 200.ms),
          ),
      ],
    );
  }

  Widget _buildBottomSheet(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, MediaQuery.of(context).padding.bottom + 16.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.textSecondaryDark.withValues(alpha: 0.3) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text('Pilih Jenis Sampah', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
          SizedBox(height: 12.h),
          Row(
            children: AppConstants.wasteTypeIcons.map((type) {
              final isSelected = _selectedWasteType == type['label'];
              final color = type['color'] as Color;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedWasteType = type['label'] as String),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withValues(alpha: 0.15) : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? color : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(type['icon'] as IconData, color: isSelected ? color : (isDark ? AppColors.textSecondaryDark : AppColors.textHint), size: 28),
                        SizedBox(height: 6.h),
                        Text(type['label'] as String, style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? color : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                        )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
          PremiumButton(
            text: _isScanning ? 'Memindai...' : 'Mulai Pindai',
            icon: _isScanning ? Icons.hourglass_top : Icons.document_scanner,
            isLoading: _isScanning,
            onPressed: _isScanning ? () {} : _startScan,
          ),
        ],
      ),
    );
  }
}
