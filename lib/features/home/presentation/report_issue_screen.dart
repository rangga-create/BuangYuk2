import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/premium_button.dart';

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedType = 'sampah_berserakan';
  String? _selectedLocation;
  bool _isLoading = false;
  bool _isSubmitted = false;

  final _issueTypes = [
    {'value': 'sampah_berserakan', 'label': 'Sampah Berserakan', 'icon': Icons.cleaning_services_outlined},
    {'value': 'petugas_tidak_datang', 'label': 'Petugas Tidak Datang', 'icon': Icons.person_off_outlined},
    {'value': 'tps_penuh', 'label': 'TPS Penuh', 'icon': Icons.delete_outline},
    {'value': 'jadwal_berubah', 'label': 'Perubahan Jadwal', 'icon': Icons.schedule_outlined},
    {'value': 'aplikasi_error', 'label': 'Error Aplikasi', 'icon': Icons.bug_report_outlined},
    {'value': 'saran', 'label': 'Saran & Masukan', 'icon': Icons.lightbulb_outline},
    {'value': 'lainnya', 'label': 'Lainnya', 'icon': Icons.more_horiz_outlined},
  ];

  final _locations = [
    'Jakarta Pusat',
    'Jakarta Selatan',
    'Jakarta Utara',
    'Jakarta Timur',
    'Jakarta Barat',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isSubmitted = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDark),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _isSubmitted
                    ? _buildSuccessState(isDark)
                    : _buildForm(isDark),
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
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: isDark ? AppColors.textPrimaryDark : Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8.w),
          Text(
            'Laporkan Masalah',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : Colors.white,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24.h),
          Text(
            'Jenis Masalah',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 20),
          SizedBox(height: 12.h),
          ..._issueTypes.asMap().entries.map((entry) {
            final index = entry.key;
            final type = entry.value;
            final isSelected = _selectedType == type['value'];
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                onTap: () => setState(() => _selectedType = type['value'] as String),
                hasBorder: isSelected,
                tintColor: isDark ? AppColors.secondary : AppColors.primary,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (isSelected
                            ? (isDark ? AppColors.secondary : AppColors.primary)
                            : AppColors.textHint
                        ).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        type['icon'] as IconData,
                        size: 22,
                        color: isSelected
                            ? (isDark ? AppColors.secondary : AppColors.primary)
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        type['label'] as String,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded,
                        color: isDark ? AppColors.secondary : AppColors.primary, size: 22),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: (index * 80).ms).slideX(begin: 20, duration: 300.ms);
          }),
          SizedBox(height: 16.h),
          Text(
            'Lokasi',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 20),
          SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
            initialValue: _selectedLocation,
            hint: Text('Pilih lokasi', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
            items: _locations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc))).toList(),
            onChanged: (v) => setState(() => _selectedLocation = v),
            decoration: InputDecoration(
              filled: true,
              fillColor: isDark ? AppColors.cardDark : Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.error, size: 20),
            ),
            style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            validator: (v) => v == null ? 'Pilih lokasi' : null,
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 20),
          SizedBox(height: 16.h),
          Text(
            'Deskripsi',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 20),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _descriptionController,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Jelaskan masalah Anda secara detail...',
              filled: true,
              fillColor: isDark ? AppColors.cardDark : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
              alignLabelWithHint: true,
            ),
            style: TextStyle(color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Deskripsi tidak boleh kosong' : null,
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 20),
          SizedBox(height: 32.h),
          PremiumButton(
            text: 'Kirim Laporan',
            icon: Icons.send_rounded,
            isLoading: _isLoading,
            onPressed: _onSubmit,
          ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 20),
          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSuccessState(bool isDark) {
    return Padding(
      padding: EdgeInsets.only(top: 60.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.12),
            ),
            child: Icon(Icons.check_circle_rounded, size: 64, color: AppColors.success),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          SizedBox(height: 24.h),
          Text(
            'Laporan Terkirim!',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 20),
          SizedBox(height: 8.h),
          Text(
            'Tim kami akan menindaklanjuti laporan Anda dalam 1x24 jam.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              height: 1.4,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 20),
          SizedBox(height: 32.h),
          PremiumButton(
            text: 'Kembali',
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.pop(context),
          ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
        ],
      ),
    );
  }
}
