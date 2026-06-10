import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/router/route_paths.dart';
import '../../../shared/components/avatar_widget.dart';
import '../../../shared/mock/mock_users.dart';

class AdminShell extends StatefulWidget {
  final Widget child;

  const AdminShell({super.key, required this.child});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 1024;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      key: _scaffoldKey,
      appBar: isDesktop
          ? null
          : AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              title: Text(
                _getTitle(location),
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => context.go(RoutePaths.adminNotifications),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: AvatarWidget(
                    imageUrl: MockUsers.adminUser['avatar_url'],
                    name: MockUsers.adminUser['name'],
                    radius: 18,
                  ),
                ),
              ],
            ),
      drawer: isDesktop ? null : _buildDrawer(context, location, isDark),
      body: Row(
        children: [
          if (isDesktop)
            _buildSidebar(context, location, isDark),
          Expanded(
            child: widget.child,
          ),
        ],
      ),
    );
  }

  String _getTitle(String location) {
    switch (location) {
      case RoutePaths.adminDashboard:
        return 'Dashboard';
      case RoutePaths.adminUsers:
        return 'Manajemen Pengguna';
      case RoutePaths.adminReports:
        return 'Laporan';
      case RoutePaths.adminCollectors:
        return 'Petugas';
      case RoutePaths.adminTPS:
        return 'TPS';
      case RoutePaths.adminNotifications:
        return 'Notifikasi';
      case RoutePaths.adminSettings:
        return 'Pengaturan';
      default:
        return 'Admin';
    }
  }

  Widget _buildDrawer(BuildContext context, String location, bool isDark) {
    return Drawer(
      child: _buildSidebarContent(context, location, isDark),
    );
  }

  Widget _buildSidebar(BuildContext context, String location, bool isDark) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: _buildSidebarContent(context, location, isDark),
    );
  }

  Widget _buildSidebarContent(BuildContext context, String location, bool isDark) {
    final admin = MockUsers.adminUser;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.eco_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BuangYuk',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Admin Panel',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _buildNavItem(
                context,
                icon: Icons.dashboard_rounded,
                label: 'Dashboard',
                location: RoutePaths.adminDashboard,
                currentLocation: location,
                isDark: isDark,
              ),
              _buildNavItem(
                context,
                icon: Icons.people_rounded,
                label: 'Pengguna',
                location: RoutePaths.adminUsers,
                currentLocation: location,
                isDark: isDark,
              ),
              _buildNavItem(
                context,
                icon: Icons.flag_rounded,
                label: 'Laporan',
                location: RoutePaths.adminReports,
                currentLocation: location,
                isDark: isDark,
              ),
              _buildNavItem(
                context,
                icon: Icons.person_search_rounded,
                label: 'Petugas',
                location: RoutePaths.adminCollectors,
                currentLocation: location,
                isDark: isDark,
              ),
              _buildNavItem(
                context,
                icon: Icons.location_on_rounded,
                label: 'TPS',
                location: RoutePaths.adminTPS,
                currentLocation: location,
                isDark: isDark,
              ),
              _buildNavItem(
                context,
                icon: Icons.notifications_rounded,
                label: 'Notifikasi',
                location: RoutePaths.adminNotifications,
                currentLocation: location,
                isDark: isDark,
              ),
              _buildNavItem(
                context,
                icon: Icons.shield_rounded,
                label: 'Moderasi',
                location: RoutePaths.adminModeration,
                currentLocation: location,
                isDark: isDark,
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_rounded,
                label: 'Pengaturan',
                location: RoutePaths.adminSettings,
                currentLocation: location,
                isDark: isDark,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.grey.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                    Navigator.pop(context);
                  }
                  context.go(RoutePaths.adminSettings);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      AvatarWidget(
                        imageUrl: admin['avatar_url'],
                        name: admin['name'],
                        radius: 18,
                        showBadge: true,
                        isOnline: true,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              admin['name'],
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'Admin',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.settings_rounded,
                        size: 20,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textHint,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => context.go(RoutePaths.login),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('Keluar'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String location,
    required String currentLocation,
    required bool isDark,
  }) {
    final isActive = currentLocation == location;
    final activeColor = isDark ? AppColors.secondary : AppColors.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(
                  color: activeColor.withValues(alpha: 0.15),
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                Navigator.pop(context);
              }
              if (currentLocation != location) {
                context.go(location);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? activeColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isActive
                          ? activeColor
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textHint),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      color: isActive
                          ? activeColor
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
                    ),
                  ),
                  if (isActive) ...[
                    const Spacer(),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
