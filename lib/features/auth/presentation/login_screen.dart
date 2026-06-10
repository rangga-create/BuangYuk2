import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buang_yuk/l10n/app_localizations.dart';
import '../../../core/router/route_paths.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../shared/components/premium_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(String role) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi email dan password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final userRole = doc.data()?['role'] as String?;

      if (!mounted) return;
      setState(() => _isLoading = false);

      final targetRole = userRole ?? role;
      switch (targetRole) {
        case 'citizen':
          context.go(RoutePaths.home);
          break;
        case 'collector':
          context.go(RoutePaths.collectorHome);
          break;
        case 'admin':
        case 'tps_manager':
        case 'government_admin':
        case 'super_admin':
          context.go(RoutePaths.adminDashboard);
          break;
        default:
          context.go(RoutePaths.home);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Akun tidak ditemukan';
          break;
        case 'wrong-password':
          message = 'Password salah';
          break;
        case 'invalid-email':
          message = 'Email tidak valid';
          break;
        case 'user-disabled':
          message = 'Akun telah dinonaktifkan';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak percobaan, coba lagi nanti';
          break;
        default:
          message = 'Login gagal: ${e.message ?? e.code}';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.secondary : AppColors.primary)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.eco_rounded,
                    size: 48,
                    color: isDark ? AppColors.secondary : AppColors.primary,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(
                  l10n.loginTitle,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                const SizedBox(height: 8),
                Text(
                  l10n.loginSubtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                const SizedBox(height: 40),
                CustomTextField(
                  label: l10n.emailLabel,
                  hint: 'contoh@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ).animate().fadeIn(duration: 400.ms, delay: 400.ms).moveY(begin: 20),
                const SizedBox(height: 16),
                CustomTextField(
                  label: l10n.passwordLabel,
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  controller: _passwordController,
                ).animate().fadeIn(duration: 400.ms, delay: 500.ms).moveY(begin: 20),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Lupa Password?'),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
                const SizedBox(height: 16),
                PremiumButton(
                  text: 'Login as Citizen',
                  isLoading: _isLoading,
                  icon: Icons.person,
                  onPressed: () => _login('citizen'),
                ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
                const SizedBox(height: 12),
                PremiumButton(
                  text: 'Login as Collector',
                  isLoading: _isLoading,
                  icon: Icons.local_shipping,
                  isOutlined: true,
                  color: isDark ? AppColors.secondary : AppColors.primary,
                  onPressed: () => _login('collector'),
                ).animate().fadeIn(duration: 400.ms, delay: 800.ms),
                const SizedBox(height: 12),
                PremiumButton(
                  text: 'Login as Admin',
                  isLoading: _isLoading,
                  icon: Icons.admin_panel_settings,
                  isOutlined: true,
                  color: AppColors.warning,
                  onPressed: () => _login('admin'),
                ).animate().fadeIn(duration: 400.ms, delay: 900.ms),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.registerPrompt,
                      style: TextStyle(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        l10n.registerLink,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.secondary : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 1000.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
