import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/components/glass_card.dart';
import '../../../shared/components/premium_button.dart';

class ScanResultScreen extends StatefulWidget {
  final String? wasteType;

  const ScanResultScreen({super.key, this.wasteType});

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> with TickerProviderStateMixin {
  late AnimationController _pointsController;
  late Animation<int> _pointsAnim;
  bool _isLogged = false;

  @override
  void initState() {
    super.initState();
    _pointsController = AnimationController(vsync: this, duration: 1500.ms);
    _pointsAnim = IntTween(begin: 0, end: 10).animate(_pointsController);
    _pointsController.forward();
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wasteType = widget.wasteType ?? 'Campur';

    final wasteInfo = {
      'Organik': {
        'color': AppColors.success,
        'icon': Icons.eco,
        'tips': [
          'Gunakan sampah organik untuk membuat kompos di rumah',
          'Pisahkan sisa makanan dari kemasan sebelum dibuang',
          'Sampah organik bisa diolah menjadi pupuk cair (POC)',
        ],
        'description': 'Sampah organik adalah sampah yang berasal dari makhluk hidup dan mudah terurai secara alami.',
      },
      'Plastik': {
        'color': AppColors.info,
        'icon': Icons.local_drink,
        'tips': [
          'Bersihkan botol plastik sebelum dibuang ke tempat daur ulang',
          'Pilah plastik berdasarkan kode resin (PET, HDPE, dll)',
          'Kurangi penggunaan kantong plastik sekali pakai',
        ],
        'description': 'Sampah plastik membutuhkan waktu hingga 450 tahun untuk terurai secara alami.',
      },
      'Kertas': {
        'color': AppColors.warning,
        'icon': Icons.description,
        'tips': [
          'Kertas karton dan koran bisa didaur ulang hingga 5-7 kali',
          'Pisahkan kertas yang masih bersih dari yang terkontaminasi makanan',
          'Kumpulkan kertas bekas untuk dijual ke pengepul',
        ],
        'description': 'Daur ulang 1 ton kertas dapat menyelamatkan 17 pohon dan 26.000 liter air.',
      },
      'Campur': {
        'color': AppColors.gold,
        'icon': Icons.recycling,
        'tips': [
          'Pisahkan sampah organik dan anorganik sebelum dibuang',
          'Gunakan tempat sampah terpisah untuk jenis yang berbeda',
          'Sampah campuran yang sudah terpilah lebih mudah didaur ulang',
        ],
        'description': 'Memilah sampah sejak dari rumah adalah langkah awal menuju lingkungan yang lebih bersih.',
      },
    };

    final info = wasteInfo[wasteType]!;
    final wasteColor = info['color'] as Color;
    final confidence = 0.92 + (wasteType.length * 0.01);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Scan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Informasi dibagikan')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultCard(context, isDark, wasteType, wasteColor, info, confidence),
            SizedBox(height: 24.h),
            _buildTipsCard(context, isDark, info['tips'] as List<String>, wasteColor),
            SizedBox(height: 24.h),
            _buildPointsCard(context, isDark, wasteColor),
            SizedBox(height: 24.h),
            _buildInfoCard(context, isDark, info['description'] as String),
            SizedBox(height: 24.h),
            _buildActions(context, isDark, wasteType),
            SizedBox(height: 32.h),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, bool isDark, String wasteType, Color wasteColor, Map<String, dynamic> info, double confidence) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [wasteColor, wasteColor.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(info['icon'] as IconData, size: 48, color: Colors.white),
              ).animate().scale(duration: 500.ms, begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut),
              SizedBox(height: 16.h),
              Text(
                wasteType,
                style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 20, duration: 400.ms, delay: 200.ms),
              SizedBox(height: 8.h),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: Colors.white),
                    SizedBox(width: 6.w),
                    Text(
                      'Tingkat Keyakinan ${(confidence * 100).toInt()}%',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 20, duration: 400.ms, delay: 400.ms),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 20, duration: 400.ms);
  }

  Widget _buildTipsCard(BuildContext context, bool isDark, List<String> tips, Color wasteColor) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: wasteColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.lightbulb_outline, color: wasteColor, size: 20),
              ),
              SizedBox(width: 12.w),
              Text('Tips Daur Ulang', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary)),
            ],
          ),
          SizedBox(height: 16.h),
          ...tips.asMap().entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: entry.key < tips.length - 1 ? 12.h : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 2.h),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(color: wasteColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Center(child: Text('${entry.key + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: wasteColor))),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(entry.value, style: TextStyle(fontSize: 13.sp, height: 1.4, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 20, duration: 400.ms, delay: 300.ms);
  }

  Widget _buildPointsCard(BuildContext context, bool isDark, Color wasteColor) {
    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.gold, AppColors.warning], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.stars_rounded, color: Colors.white, size: 28),
          ).animate().scale(duration: 400.ms, begin: const Offset(0, 0), end: const Offset(1, 1), curve: Curves.elasticOut),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Poin Diperoleh', style: TextStyle(fontSize: 13.sp, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                SizedBox(height: 4.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AnimatedBuilder(
                      animation: _pointsAnim,
                      builder: (context, child) => Text(
                        '+${_pointsAnim.value}',
                        style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w800, color: AppColors.gold, letterSpacing: -0.5),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Text('poin', style: TextStyle(fontSize: 13.sp, color: AppColors.gold.withValues(alpha: 0.7))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLogged)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 14, color: AppColors.success),
                  SizedBox(width: 4.w),
                  Text('Tercatat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 20, duration: 400.ms, delay: 500.ms);
  }

  Widget _buildInfoCard(BuildContext context, bool isDark, String description) {
    return GlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.info_outline, color: AppColors.info, size: 20),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              description,
              style: TextStyle(fontSize: 13.sp, height: 1.4, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 600.ms).slideY(begin: 20, duration: 400.ms, delay: 600.ms);
  }

  Widget _buildActions(BuildContext context, bool isDark, String wasteType) {
    return Column(
      children: [
        PremiumButton(
          text: _isLogged ? 'Sudah Tercatat' : 'Catat Sampah Ini',
          icon: _isLogged ? Icons.check_circle : Icons.save_outlined,
          onPressed: () {
            if (!_isLogged) {
              setState(() => _isLogged = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sampah berhasil dicatat!')),
              );
            }
          },
          color: _isLogged ? AppColors.success : null,
        ).animate().fadeIn(duration: 400.ms, delay: 700.ms).slideY(begin: 20, duration: 400.ms, delay: 700.ms),
        SizedBox(height: 12.h),
        PremiumButton(
          text: 'Pelajari Lebih Lanjut',
          icon: Icons.school_outlined,
          isOutlined: true,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Membuka panduan $wasteType...')),
            );
          },
        ).animate().fadeIn(duration: 400.ms, delay: 800.ms).slideY(begin: 20, duration: 400.ms, delay: 800.ms),
      ],
    );
  }
}
