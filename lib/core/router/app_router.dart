import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'route_names.dart';
import 'route_paths.dart';

import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/home/presentation/citizen_shell.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/pickup/presentation/pickup_screen.dart';
import '../../features/pickup/presentation/pickup_detail_screen.dart';
import '../../features/pickup/presentation/pickup_tracking_screen.dart';
import '../../features/education/presentation/education_scan_screen.dart';
import '../../features/education/presentation/scan_result_screen.dart';
import '../../features/reward/presentation/reward_screen.dart';
import '../../features/reward/presentation/reward_detail_screen.dart';
import '../../features/home/presentation/profile_screen.dart';
import '../../features/home/presentation/settings_screen.dart';
import '../../features/home/presentation/activity_history_screen.dart';
import '../../features/home/presentation/notifications_screen.dart';
import '../../features/home/presentation/eco_challenges_screen.dart';
import '../../features/home/presentation/achievements_screen.dart';
import '../../features/home/presentation/help_center_screen.dart';
import '../../features/home/presentation/report_issue_screen.dart';
import '../../features/admin/presentation/admin_shell.dart';
import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/admin/presentation/admin_users_screen.dart';
import '../../features/admin/presentation/admin_reports_screen.dart';
import '../../features/admin/presentation/admin_collectors_screen.dart';
import '../../features/admin/presentation/admin_tps_screen.dart';
import '../../features/admin/presentation/admin_notifications_screen.dart';
import '../../features/admin/presentation/admin_settings_screen.dart';
import '../../features/admin/presentation/admin_moderation_screen.dart';
import '../../features/collector/presentation/collector_shell.dart';
import '../../features/collector/presentation/collector_dashboard_screen.dart';
import '../../features/collector/presentation/collector_tasks_screen.dart';
import '../../features/collector/presentation/collector_earnings_screen.dart';
import '../../features/collector/presentation/collector_history_screen.dart';
import '../../features/collector/presentation/collector_task_detail_screen.dart';
import '../../features/collector/presentation/collector_settings_screen.dart';

Page<Object?> _buildPageWithTransition(Widget child) {
  return CustomTransitionPage<Object?>(
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(
            begin: const Offset(0.1, 0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: FadeTransition(
          opacity: animation.drive(CurveTween(curve: Curves.easeOut)),
          child: child,
        ),
      );
    },
  );
}

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        pageBuilder: (context, state) => _buildPageWithTransition(const SplashScreen()),
      ),
      GoRoute(
        path: RoutePaths.onboarding,
        name: RouteNames.onboarding,
        pageBuilder: (context, state) => _buildPageWithTransition(const OnboardingScreen()),
      ),
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        pageBuilder: (context, state) => _buildPageWithTransition(const LoginScreen()),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        pageBuilder: (context, state) => _buildPageWithTransition(const RegisterScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) => CitizenShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            name: RouteNames.home,
            pageBuilder: (context, state) => _buildPageWithTransition(const HomeScreen()),
          ),
          GoRoute(
            path: RoutePaths.pickup,
            name: RouteNames.pickup,
            pageBuilder: (context, state) => _buildPageWithTransition(const PickupScreen()),
            routes: [
              GoRoute(
                path: 'detail',
                name: RouteNames.pickupDetail,
                pageBuilder: (context, state) => _buildPageWithTransition(const PickupDetailScreen()),
              ),
              GoRoute(
                path: 'tracking',
                name: RouteNames.pickupTracking,
                pageBuilder: (context, state) => _buildPageWithTransition(const PickupTrackingScreen()),
              ),
            ],
          ),
          GoRoute(
            path: RoutePaths.scan,
            name: RouteNames.scan,
            pageBuilder: (context, state) => _buildPageWithTransition(const EducationScanScreen()),
          ),
          GoRoute(
            path: RoutePaths.scanResult,
            name: RouteNames.scanResult,
            pageBuilder: (context, state) => _buildPageWithTransition(const ScanResultScreen()),
          ),
          GoRoute(
            path: RoutePaths.reward,
            name: RouteNames.reward,
            pageBuilder: (context, state) => _buildPageWithTransition(const RewardScreen()),
          ),
          GoRoute(
            path: RoutePaths.rewardDetail,
            name: RouteNames.rewardDetail,
            pageBuilder: (context, state) => _buildPageWithTransition(const RewardDetailScreen()),
          ),
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            pageBuilder: (context, state) => _buildPageWithTransition(const ProfileScreen()),
          ),
          GoRoute(
            path: RoutePaths.settings,
            name: RouteNames.settings,
            pageBuilder: (context, state) => _buildPageWithTransition(const SettingsScreen()),
          ),
          GoRoute(
            path: RoutePaths.activityHistory,
            name: RouteNames.activityHistory,
            pageBuilder: (context, state) => _buildPageWithTransition(const ActivityHistoryScreen()),
          ),
          GoRoute(
            path: RoutePaths.notifications,
            name: RouteNames.notifications,
            pageBuilder: (context, state) => _buildPageWithTransition(const NotificationsScreen()),
          ),
          GoRoute(
            path: RoutePaths.ecoChallenges,
            name: RouteNames.ecoChallenges,
            pageBuilder: (context, state) => _buildPageWithTransition(const EcoChallengesScreen()),
          ),
          GoRoute(
            path: RoutePaths.achievements,
            name: RouteNames.achievements,
            pageBuilder: (context, state) => _buildPageWithTransition(const AchievementsScreen()),
          ),
          GoRoute(
            path: RoutePaths.helpCenter,
            name: RouteNames.helpCenter,
            pageBuilder: (context, state) => _buildPageWithTransition(const HelpCenterScreen()),
          ),
          GoRoute(
            path: RoutePaths.reportIssue,
            name: RouteNames.reportIssue,
            pageBuilder: (context, state) => _buildPageWithTransition(const ReportIssueScreen()),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => AdminShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.adminDashboard,
            name: RouteNames.adminDashboard,
            pageBuilder: (context, state) => _buildPageWithTransition(const AdminDashboardScreen()),
          ),
          GoRoute(
            path: RoutePaths.adminUsers,
            name: RouteNames.adminUsers,
            pageBuilder: (context, state) => _buildPageWithTransition(const AdminUsersScreen()),
          ),
          GoRoute(
            path: RoutePaths.adminReports,
            name: RouteNames.adminReports,
            pageBuilder: (context, state) => _buildPageWithTransition(const AdminReportsScreen()),
          ),
          GoRoute(
            path: RoutePaths.adminCollectors,
            name: RouteNames.adminCollectors,
            pageBuilder: (context, state) => _buildPageWithTransition(const AdminCollectorsScreen()),
          ),
          GoRoute(
            path: RoutePaths.adminTPS,
            name: RouteNames.adminTPS,
            pageBuilder: (context, state) => _buildPageWithTransition(const AdminTpsScreen()),
          ),
          GoRoute(
            path: RoutePaths.adminNotifications,
            name: RouteNames.adminNotifications,
            pageBuilder: (context, state) => _buildPageWithTransition(const AdminNotificationsScreen()),
          ),
          GoRoute(
            path: RoutePaths.adminSettings,
            name: RouteNames.adminSettings,
            pageBuilder: (context, state) => _buildPageWithTransition(const AdminSettingsScreen()),
          ),
          GoRoute(
            path: RoutePaths.adminModeration,
            name: RouteNames.adminModeration,
            pageBuilder: (context, state) => _buildPageWithTransition(const AdminModerationScreen()),
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) => CollectorShell(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.collectorHome,
            name: RouteNames.collectorHome,
            pageBuilder: (context, state) => _buildPageWithTransition(const CollectorDashboardScreen()),
          ),
          GoRoute(
            path: RoutePaths.collectorTasks,
            name: RouteNames.collectorTasks,
            pageBuilder: (context, state) => _buildPageWithTransition(const CollectorTasksScreen()),
          ),
          GoRoute(
            path: RoutePaths.collectorTaskDetail,
            name: RouteNames.collectorTaskDetail,
            pageBuilder: (context, state) => _buildPageWithTransition(const CollectorTaskDetailScreen()),
          ),
          GoRoute(
            path: RoutePaths.collectorEarnings,
            name: RouteNames.collectorEarnings,
            pageBuilder: (context, state) => _buildPageWithTransition(const CollectorEarningsScreen()),
          ),
          GoRoute(
            path: RoutePaths.collectorHistory,
            name: RouteNames.collectorHistory,
            pageBuilder: (context, state) => _buildPageWithTransition(const CollectorHistoryScreen()),
          ),
          GoRoute(
            path: RoutePaths.collectorSettings,
            name: RouteNames.collectorSettings,
            pageBuilder: (context, state) => _buildPageWithTransition(const CollectorSettingsScreen()),
          ),
        ],
      ),
    ],
  );
});
