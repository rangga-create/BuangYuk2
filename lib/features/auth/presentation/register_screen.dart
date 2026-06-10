import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buang_yuk/shared/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/route_paths.dart';
import '../../../shared/components/premium_button.dart';
import '../../../core/widgets/custom_text_field.dart';

enum _PasswordStrength { none, weak, medium, strong }

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _addressController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _agreeToTerms = false;
  String _selectedRole = 'citizen';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _addressController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  String? _defaultValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName tidak boleh kosong';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email tidak boleh kosong';
    }
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Email tidak valid';
    }
    return null;
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }
    final phoneRegex = RegExp(r'^[0-9+\- ]{8,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Nomor telepon tidak valid';
    }
    return null;
  }

  String? _passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 8) {
      return 'Password minimal 8 karakter';
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != _passwordController.text) {
      return 'Password tidak cocok';
    }
    return null;
  }

  _PasswordStrength get _passwordStrength {
    final pw = _passwordController.text;
    if (pw.isEmpty) return _PasswordStrength.none;
    int score = 0;
    if (pw.length >= 8) score++;
    if (pw.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(pw)) score++;
    if (RegExp(r'[a-z]').hasMatch(pw)) score++;
    if (RegExp(r'[0-9]').hasMatch(pw)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pw)) score++;
    if (score <= 2) return _PasswordStrength.weak;
    if (score <= 4) return _PasswordStrength.medium;
    return _PasswordStrength.strong;
  }

  String get _passwordStrengthLabel {
    switch (_passwordStrength) {
      case _PasswordStrength.none:
        return '';
      case _PasswordStrength.weak:
        return 'Lemah';
      case _PasswordStrength.medium:
        return 'Sedang';
      case _PasswordStrength.strong:
        return 'Kuat';
    }
  }

  Color _passwordStrengthColor(bool isDark) {
    switch (_passwordStrength) {
      case _PasswordStrength.none:
        return Colors.transparent;
      case _PasswordStrength.weak:
        return AppColors.error;
      case _PasswordStrength.medium:
        return AppColors.warning;
      case _PasswordStrength.strong:
        return AppColors.success;
    }
  }

  void _onSubmit() async {
    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap setujui Syarat & Ketentuan')),
      );
      return;
    }
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final authService = ref.read(authServiceProvider);
        final result = await authService.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim().isEmpty ? '-' : _addressController.text.trim(),
          district: _districtController.text.trim().isEmpty ? '-' : _districtController.text.trim(),
          city: _cityController.text.trim().isEmpty ? '-' : _cityController.text.trim(),
          province: _provinceController.text.trim().isEmpty ? '-' : _provinceController.text.trim(),
        );
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _isSuccess = true;
        });
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          final role = result['role'] as String? ?? _selectedRole;
          if (role == 'collector') {
            context.go(RoutePaths.collectorHome);
          } else {
            context.go(RoutePaths.home);
          }
        });
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        String message;
        switch (e.code) {
          case 'email-already-in-use':
            message = 'Email sudah terdaftar';
            break;
          case 'weak-password':
            message = 'Password terlalu lemah';
            break;
          case 'invalid-email':
            message = 'Email tidak valid';
            break;
          default:
            message = 'Pendaftaran gagal: ${e.message ?? e.code}';
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(isDark, size),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _isSuccess
                    ? _buildSuccessState(isDark)
                    : _buildForm(isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark, Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: size.height * 0.06,
        bottom: size.height * 0.04,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.primaryDark, const Color(0xFF0D3320)]
              : [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -20,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: -40,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: size.width * 0.3,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ).animate().scale(
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),
              const SizedBox(height: 16),
              const Text(
                'Buat Akun',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.2),
              const SizedBox(height: 6),
              Text(
                'Bergabung dalam misi daur ulang',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideY(begin: 0.2),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          CustomTextField(
            label: 'Nama Lengkap',
            hint: 'Masukkan nama lengkap',
            prefixIcon: Icons.person_outline,
            controller: _nameController,
            validator: (v) => _defaultValidator(v, 'Nama lengkap'),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).moveY(begin: 20),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Email',
            hint: 'contoh@email.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            validator: _emailValidator,
          ).animate().fadeIn(duration: 400.ms, delay: 300.ms).moveY(begin: 20),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Nomor Telepon',
            hint: '+62 812-3456-7890',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            controller: _phoneController,
            validator: _phoneValidator,
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).moveY(begin: 20),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Password',
            hint: 'Minimal 8 karakter',
            prefixIcon: Icons.lock_outline,
            isPassword: !_isPasswordVisible,
            controller: _passwordController,
            validator: _passwordValidator,
            suffix: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms).moveY(begin: 20),
          const SizedBox(height: 8),
          _buildPasswordStrength(isDark),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Konfirmasi Password',
            hint: 'Ulangi password',
            prefixIcon: Icons.lock_outline,
            isPassword: !_isConfirmPasswordVisible,
            controller: _confirmPasswordController,
            validator: _confirmPasswordValidator,
            suffix: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 600.ms).moveY(begin: 20),
          const SizedBox(height: 24),
          _buildRoleSelector(isDark).animate().fadeIn(duration: 400.ms, delay: 700.ms).moveY(begin: 20),
          const SizedBox(height: 20),
          _buildAgreementCheckbox(isDark).animate().fadeIn(duration: 400.ms, delay: 800.ms).moveY(begin: 20),
          const SizedBox(height: 24),
          PremiumButton(
            text: 'Daftar',
            isLoading: _isLoading,
            icon: Icons.person_add_outlined,
            onPressed: _onSubmit,
          ).animate().fadeIn(duration: 400.ms, delay: 900.ms).moveY(begin: 20),
          const SizedBox(height: 20),
          _buildSocialDivider(isDark).animate().fadeIn(duration: 400.ms, delay: 1000.ms),
          const SizedBox(height: 20),
          _buildSocialButtons(isDark).animate().fadeIn(duration: 400.ms, delay: 1100.ms).moveY(begin: 20),
          const SizedBox(height: 24),
          _buildLoginLink(isDark).animate().fadeIn(duration: 400.ms, delay: 1200.ms),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPasswordStrength(bool isDark) {
    final strength = _passwordStrength;
    if (strength == _PasswordStrength.none) return const SizedBox.shrink();
    final color = _passwordStrengthColor(isDark);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: strength == _PasswordStrength.weak
                ? 0.33
                : strength == _PasswordStrength.medium
                    ? 0.66
                    : 1.0,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Kekuatan password: $_passwordStrengthLabel',
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildRoleSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar sebagai',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: [
              ButtonSegment(
                value: 'citizen',
                label: const Text('Masyarakat'),
                icon: const Icon(Icons.person_outline, size: 18),
              ),
              ButtonSegment(
                value: 'collector',
                label: const Text('Kolektor'),
                icon: const Icon(Icons.local_shipping_outlined, size: 18),
              ),
            ],
            selected: {_selectedRole},
            onSelectionChanged: (selected) {
              setState(() => _selectedRole = selected.first);
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return isDark ? AppColors.primaryDark : AppColors.primarySurface;
                }
                return Colors.transparent;
              }),
              foregroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return isDark ? AppColors.secondary : AppColors.primary;
                }
                return isDark ? AppColors.textSecondaryDark : AppColors.textHint;
              }),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementCheckbox(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreeToTerms,
            onChanged: (v) => setState(() => _agreeToTerms = v ?? false),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            activeColor: isDark ? AppColors.secondary : AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'Saya setuju dengan '),
                TextSpan(
                  text: 'Syarat & Ketentuan',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.secondary : AppColors.primary,
                  ),
                ),
                const TextSpan(text: ' dan '),
                TextSpan(
                  text: 'Kebijakan Privasi',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.secondary : AppColors.primary,
                  ),
                ),
                const TextSpan(text: ' yang berlaku'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialDivider(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'atau daftar dengan',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Google Sign-In (Mock)')),
              );
            },
            icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
            label: const Text('Google'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              side: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.12),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Apple Sign-In (Mock)')),
              );
            },
            icon: const Icon(Icons.apple, size: 24),
            label: const Text('Apple'),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              side: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.12),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: TextStyle(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: () => context.go(RoutePaths.login),
          child: Text(
            'Masuk',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.secondary : AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessState(bool isDark) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: AppColors.success,
            ),
          ).animate().scale(
            duration: 600.ms,
            curve: Curves.elasticOut,
          ),
          const SizedBox(height: 24),
          const Text(
            'Pendaftaran Berhasil!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(begin: 20),
          const SizedBox(height: 8),
          Text(
            'Selamat datang di BuangYuk',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 500.ms).slideY(begin: 20),
          const SizedBox(height: 40),
          SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: isDark ? AppColors.secondary : AppColors.primary,
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 600.ms),
        ],
      ),
    );
  }
}
