import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/constants.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/section_header.dart';
import '../../../shared/components/status_badge.dart';
import '../../../shared/components/premium_button.dart';
import '../../../shared/components/empty_state.dart';
import '../../../shared/providers/pickup_provider.dart';

class PickupScreen extends ConsumerStatefulWidget {
  const PickupScreen({super.key});

  @override
  ConsumerState<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends ConsumerState<PickupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _volumeController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedWasteType;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _addressController.dispose();
    _volumeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jemput Sampah'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Jadwalkan'),
            Tab(text: 'Aktif'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildScheduleForm(context, isDark),
            _buildActivePickups(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleForm(BuildContext context, bool isDark) {
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 160.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight].map((c) => c.withValues(alpha: 0.15)).toList(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map_outlined, size: 40.sp, color: isDark ? AppColors.secondary : AppColors.primary),
                        SizedBox(height: 8.h),
                        Text('Peta Lokasi', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                        SizedBox(height: 4.h),
                        Text('Ketuk untuk pilih lokasi', style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                      ],
                    ),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.my_location, size: 14, color: Colors.white),
                            SizedBox(width: 4.w),
                            Text('Lokasi Saya', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 20, duration: 400.ms),

              SizedBox(height: 24.h),
              Text('Detail Penjemputan', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
              SizedBox(height: 16.h),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.textHint.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alamat Lengkap', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan alamat',
                        prefixIcon: Icon(Icons.location_on_outlined, size: 20, color: AppColors.error),
                        filled: true,
                        fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 16.h),

                    Text('Jenis Sampah', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: AppConstants.wasteTypeIcons.map((type) {
                        final isSelected = _selectedWasteType == type['label'];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedWasteType = type['label'] as String),
                          child: AnimatedContainer(
                            duration: 200.ms,
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (type['color'] as Color).withValues(alpha: 0.15)
                                  : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? type['color'] as Color
                                    : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(type['icon'] as IconData, size: 18, color: isSelected ? type['color'] as Color : (isDark ? AppColors.textSecondaryDark : AppColors.textHint)),
                                SizedBox(width: 6.w),
                                Text(type['label'] as String, style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? type['color'] as Color : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                )),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.h),

                    Text('Estimasi Volume (kg)', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _volumeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Contoh: 5',
                        prefixIcon: Icon(Icons.scale_outlined, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                        filled: true,
                        fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    Text('Tanggal & Waktu', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 1)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (date != null) {
                          if (!context.mounted) return;
                          final time = await showTimePicker(
                            context: context,
                            initialTime: const TimeOfDay(hour: 9, minute: 0),
                          );
                          if (time != null) {
                            setState(() => _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                          }
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                            SizedBox(width: 12.w),
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} ${_selectedDate!.hour.toString().padLeft(2, '0')}:${_selectedDate!.minute.toString().padLeft(2, '0')} WIB'
                                  : 'Pilih tanggal & waktu',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: _selectedDate != null
                                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)
                                    : (isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),

                    Text('Catatan (Opsional)', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                    SizedBox(height: 8.h),
                    TextFormField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan catatan untuk petugas',
                        prefixIcon: Icon(Icons.notes_outlined, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                        filled: true,
                        fillColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 20, duration: 400.ms, delay: 200.ms),

              SizedBox(height: 24.h),
              PremiumButton(
                text: 'Pesan Penjemputan',
                icon: Icons.check_circle_outline,
                onPressed: _submitPickup,
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 20, duration: 400.ms, delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  void _submitPickup() {
    if (_selectedWasteType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih jenis sampah terlebih dahulu')));
      return;
    }
    final kgText = _volumeController.text;
    final weightKg = double.tryParse(kgText) ?? 1.0;
    ref.read(pickupServiceProvider).createPickup(
      lat: -6.2,
      lng: 106.8,
      weightKg: weightKg,
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pesanan Dikirim'),
        content: const Text('Petugas terdekat akan segera menuju lokasi Anda.'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(ctx); Navigator.pop(ctx); }, child: const Text('OK')),
        ],
      ),
    );
  }

  Widget _buildActivePickups(BuildContext context, bool isDark) {
    final activePickupsAsync = ref.watch(activePickupsProvider);
    final historyPickupsAsync = ref.watch(pickupHistoryProvider);
    final activePickups = activePickupsAsync.asData?.value ?? [];
    final historyPickups = historyPickupsAsync.asData?.value ?? [];

    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: activePickups.isEmpty && historyPickups.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 80),
                EmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: 'Belum Ada Penjemputan',
                  message: 'Jadwalkan penjemputan sampah pertama Anda dan dapatkan poin!',
                ),
              ],
            )
          : ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(20.w),
              children: [
                if (activePickups.isNotEmpty) ...[
                  SectionHeader(title: 'Penjemputan Aktif (${activePickups.length})'),
                  SizedBox(height: 12.h),
                  ...activePickups.asMap().entries.map((e) => _buildPickupCard(context, isDark, e.value, true, index: e.key)),
                  SizedBox(height: 24.h),
                ],
                if (historyPickups.isNotEmpty) ...[
                  SectionHeader(
                    title: 'Riwayat',
                    actionLabel: 'Lihat Semua',
                    onActionTap: () => context.push(RoutePaths.activityHistory),
                  ),
                  SizedBox(height: 12.h),
                  ...historyPickups.take(3).toList().asMap().entries.map((e) => _buildPickupCard(context, isDark, e.value, false, index: e.key)),
                ],
              ],
            ),
    );
  }

  Widget _buildPickupCard(BuildContext context, bool isDark, Map<String, dynamic> pickup, bool isActive, {int index = 0}) {
    final statusLabels = {
      'requested': 'Diminta',
      'assigned': 'Ditugaskan',
      'accepted': 'Diterima',
      'on_the_way': 'Dalam Perjalanan',
      'arrived': 'Tiba',
      'picked_up': 'Terambil',
      'completed': 'Selesai',
      'cancelled': 'Dibatalkan',
    };
    final status = pickup['status'] as String? ?? 'requested';
    final statusLabel = statusLabels[status] ?? status;
    final isHistory = !isActive;
    final weightKg = pickup['weightKg'] ?? 0;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GlassCard(
        onTap: () => isActive
            ? (status == 'on_the_way'
                ? context.push(RoutePaths.pickupTracking, extra: pickup)
                : context.push(RoutePaths.pickupDetail, extra: pickup))
            : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (status == 'completed' ? AppColors.success :
                            status == 'on_the_way' ? AppColors.warning :
                            status == 'picked_up' ? AppColors.info :
                            AppColors.info).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    status == 'completed' ? Icons.check_circle :
                    status == 'on_the_way' ? Icons.local_shipping :
                    Icons.schedule,
                    size: 20,
                    color: status == 'completed' ? AppColors.success :
                           status == 'on_the_way' ? AppColors.warning :
                           AppColors.info,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    pickup['id'] as String? ?? '',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                  ),
                ),
                StatusBadge(label: statusLabel, type: status),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined, size: 16, color: AppColors.error),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(pickup['address'] as String? ?? 'Lokasi tidak tersedia', style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.category_outlined, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                SizedBox(width: 6.w),
                Text('${pickup['waste_type'] ?? 'Campur'}', style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                SizedBox(width: 16.w),
                Icon(Icons.scale_outlined, size: 16, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                SizedBox(width: 6.w),
                Text('$weightKg kg', style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
              ],
            ),
            if (isActive && pickup['estimated_arrival'] != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: AppColors.warning),
                  SizedBox(width: 6.w),
                  Text('Estimasi: ${pickup['estimated_arrival']}', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.warning)),
                ],
              ),
            ],
            if (isHistory && pickup['weightKg'] != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.stars_rounded, size: 16, color: AppColors.gold),
                  SizedBox(width: 6.w),
                  Text('${weightKg.toInt() * 10} poin', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.gold)),
                  SizedBox(width: 16.w),
                  Icon(Icons.eco, size: 16, color: AppColors.success),
                  SizedBox(width: 6.w),
                  Text('$weightKg kg', style: TextStyle(fontSize: 13.sp, color: AppColors.success)),
                  const Spacer(),
                ],
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 100).ms).slideY(begin: 15, duration: 300.ms);
  }
}
