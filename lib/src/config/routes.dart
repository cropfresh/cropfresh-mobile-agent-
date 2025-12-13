/**
 * App Router - Story 2.6
 * 
 * Navigation routes for the Agent app flow:
 * Splash → Login → Set PIN → Onboarding → Dashboard
 * 
 * No language selection screen (per user request).
 */

import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/set_pin_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/dashboard_screen.dart';

/// Named routes for navigation
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String setPin = '/set-pin';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
}

/// Route generator for MaterialApp
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen(), settings);

      case AppRoutes.login:
        return _buildRoute(const LoginScreen(), settings);

      case AppRoutes.setPin:
        final args = settings.arguments as SetPinScreenArgs?;
        return _buildRoute(
          SetPinScreen(
            temporaryToken: args?.temporaryToken ?? '',
            agentName: args?.agentName ?? 'Agent',
          ),
          settings,
        );

      case AppRoutes.onboarding:
        return _buildRoute(const OnboardingScreen(), settings);

      case AppRoutes.dashboard:
        return _buildRoute(const DashboardScreen(), settings);

      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  /// Build a material page route with fade transition
  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// Arguments for SetPinScreen
class SetPinScreenArgs {
  final String temporaryToken;
  final String agentName;

  SetPinScreenArgs({
    required this.temporaryToken,
    required this.agentName,
  });
}
