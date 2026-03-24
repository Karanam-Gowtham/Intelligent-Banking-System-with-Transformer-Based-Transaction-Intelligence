import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/common/risk_alerts_screen.dart';

class AppRouter {
  static const String riskAlerts = '/risk-alerts';
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  static const String profile = '/profile';

  static final GoRouter router = GoRouter(
    initialLocation: riskAlerts,
    routes: [
      GoRoute(
        path: riskAlerts,
        name: 'risk-alerts',
        builder: (context, state) => const RiskAlertsScreen(),
      ),
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Dashboard Screen - Coming Soon')),
        ),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Settings Screen - Coming Soon')),
        ),
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Profile Screen - Coming Soon')),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Page not found: ${state.uri}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(riskAlerts),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
