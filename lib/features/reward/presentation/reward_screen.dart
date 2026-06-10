import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/providers/wallet_provider.dart';

class RewardScreen extends ConsumerStatefulWidget {
  const RewardScreen({super.key});

  @override
  ConsumerState<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends ConsumerState<RewardScreen> with TickerProviderStateMixin {
  late AnimationController _pointsController;
  late Animation<int> _pointsAnim;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<Map<String, String>> _categories = [
    {'key': 'All', 'label': 'Semua', 'icon': 'all_inclusive'},
    {'key': 'e-wallet', 'label': 'E-Wallet', 'icon': 'account_balance_wallet'},
    {'key': 'voucher', 'label': 'Voucher', 'icon': 'local_offer'},
    {'key': 'donation', 'label': 'Donasi', 'icon': 'eco'},
    {'key': 'merchandise', 'label': 'Merch', 'icon': 'shopping_bag'},
  ];

  @override
  void initState() {
    super.initState();
    _pointsController = AnimationController(vsync: this, duration: 1000.ms);
    _pointsAnim = IntTween(begin: 0, end: 0).animate(_pointsController);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wallet = ref.read(walletProvider).asData?.value;
    final balance = (wallet?['balance'] ?? 0) as int;
    _pointsAnim = IntTween(begin: 0, end: balance).animate(_pointsController);
    _pointsController.forward();
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _allRewards => [
    {'id': 'REW-1', 'title': 'Voucher GoPay Rp 50.000', 'description': 'Tukarkan poinmu untuk saldo GoPay Rp 50.000', 'points_required': 5000, 'type': 'e-wallet', 'icon': Icons.account_balance_wallet, 'color': 0xFF1DA1F2, 'popular': true, 'stock': 25, 'terms': '1 voucher per akun per bulan.'},
    {'id': 'REW-2', 'title': 'Diskon Supermarket 10%', 'description': 'Nikmati diskon 10% di supermarket mitra', 'points_required': 2000, 'type': 'voucher', 'icon': Icons.local_offer, 'color': 0xFFFF6B35, 'popular': false, 'stock': 50, 'terms': 'Minimal belanja Rp 100.000.'},
    {'id': 'REW-3', 'title': 'Donasi Pohon Bakau', 'description': 'Donasikan poin untuk menanam 1 pohon bakau', 'points_required': 1500, 'type': 'donation', 'icon': Icons.eco, 'color': 0xFF1B8B3C, 'popular': true, 'stock': null, 'terms': 'Setiap donasi dapat e-sertifikat.'},
    {'id': 'REW-4', 'title': 'Voucher GrabFood Rp 25.000', 'description': 'Tukarkan poin untuk voucher GrabFood', 'points_required': 3500, 'type': 'e-wallet', 'icon': Icons.restaurant, 'color': 0xFF00AA13, 'popular': false, 'stock': 40, 'terms': 'Minimal pemesanan Rp 50.000.'},
    {'id': 'REW-5', 'title': 'Tote Bag Ramah Lingkungan', 'description': 'Dapatkan tote bag premium dari bahan daur ulang', 'points_required': 2500, 'type': 'merchandise', 'icon': Icons.shopping_bag, 'color': 0xFFAB47BC, 'popular': false, 'stock': 15, 'terms': 'Pengiriman 3-5 hari kerja.'},
    {'id': 'REW-6', 'title': 'Pulsa Rp 20.000', 'description': 'Tukarkan poin untuk pulsa semua operator', 'points_required': 1800, 'type': 'e-wallet', 'icon': Icons.phone_android, 'color': 0xFF4CAF50, 'popular': false, 'stock': 100, 'terms': 'Diproses maksimal 1x24 jam.'},
  ];

  List<Map<String, dynamic>> get _filteredRewards {
    var rewards = _allRewards;
    if (_selectedCategory != 'All') {
      rewards = rewards.where((r) => r['type'] == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      rewards = rewards.where((r) => (r['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    return rewards;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final walletAsync = ref.watch(walletProvider);
    final balance = (walletAsync.asData?.value?['balance'] ?? 0) as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tukar Poin'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildPointsHeader(context, isDark, balance),
            _buildSearchBar(context, isDark),
            _buildCategoryTabs(context, isDark),
            Expanded(
              child: _filteredRewards.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 56, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                            SizedBox(height: 16.h),
                            Text('Reward tidak ditemukan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                            SizedBox(height: 8.h),
                            Text('Coba kata kunci lain', style: TextStyle(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
                      itemCount: _filteredRewards.length,
                      itemBuilder: (context, index) {
                        return _buildRewardCard(context, isDark, _filteredRewards[index], balance, index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsHeader(BuildContext context, bool isDark, int balance) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.cardDark, AppColors.primaryDark.withValues(alpha: 0.3)]
              : [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.stars_rounded, size: 28, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Saldo Poin', style: TextStyle(fontSize: 13.sp, color: Colors.white.withValues(alpha: 0.85), fontWeight: FontWeight.w500)),
                SizedBox(height: 4.h),
                AnimatedBuilder(
                  animation: _pointsAnim,
                  builder: (context, _) => Text(
                    Formatters.formatPoints(_pointsAnim.value),
                    style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('Riwayat', style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7))),
                SizedBox(height: 2.h),
                Icon(Icons.history, size: 20, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -20, duration: 400.ms);
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Cari reward...',
            prefixIcon: Icon(Icons.search, size: 20, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, size: 18),
                    onPressed: () => setState(() => _searchQuery = ''),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms);
  }

  Widget _buildCategoryTabs(BuildContext context, bool isDark) {
    return SizedBox(
      height: 44.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat['key'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['key']!),
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.secondary : AppColors.primary)
                    : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIcon(cat['icon']!),
                    size: 16,
                    color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    cat['label']!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 200.ms);
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'all_inclusive': return Icons.all_inclusive;
      case 'account_balance_wallet': return Icons.account_balance_wallet;
      case 'local_offer': return Icons.local_offer;
      case 'eco': return Icons.eco;
      case 'shopping_bag': return Icons.shopping_bag;
      default: return Icons.circle;
    }
  }

  Widget _buildRewardCard(BuildContext context, bool isDark, Map<String, dynamic> reward, int balance, int index) {
    final color = Color(reward['color'] as int);
    final points = reward['points_required'] as int;
    final canAfford = balance >= points;
    final isPopular = reward['popular'] as bool;
    final stock = reward['stock'] as int?;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GlassCard(
        onTap: () => context.push(RoutePaths.rewardDetail, extra: reward),
        child: Row(
          children: [
            Container(
              width: 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(reward['icon'] as IconData, color: color, size: 28),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(reward['title'] as String, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
                      ),
                      if (isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                          child: Text('POPULER', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.gold, letterSpacing: 0.5)),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(reward['description'] as String, style: TextStyle(fontSize: 12.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: canAfford ? AppColors.success.withValues(alpha: 0.12) : AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.stars_rounded, size: 14, color: canAfford ? AppColors.success : AppColors.error),
                            SizedBox(width: 4.w),
                            Text(
                              Formatters.formatPoints(points),
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: canAfford ? AppColors.success : AppColors.error),
                            ),
                          ],
                        ),
                      ),
                      if (stock != null) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Sisa $stock',
                            style: TextStyle(fontSize: 11.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.chevron_right, color: isDark ? AppColors.textSecondaryDark : AppColors.textHint, size: 20),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: (index * 80 + 300).ms).slideX(begin: 20, duration: 300.ms);
  }
}
