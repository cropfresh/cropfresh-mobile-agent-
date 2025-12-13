/**
 * Onboarding Screen - Story 2.6 (AC5)
 * 
 * 5-step swipeable training tutorial.
 * Must complete to unlock dashboard.
 */

import 'package:flutter/material.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../services/api_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final ApiService _apiService = ApiService();
  int _currentPage = 0;
  bool _isLoading = false;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      icon: Icons.person_pin,
      title: 'Your Role',
      description: 'As a CropFresh Field Agent, you help farmers '
          'get the best prices for their produce through quality verification.',
      color: AppColors.primaryOrange,
    ),
    OnboardingStep(
      icon: Icons.camera_alt,
      title: 'Quality Grading',
      description: 'Use the AI-powered camera to grade produce quality. '
          'Take clear photos and the app will suggest the grade.',
      color: AppColors.secondaryGreen,
    ),
    OnboardingStep(
      icon: Icons.location_on,
      title: 'Farm Visits',
      description: 'Check in at farm locations to verify produce. '
          'Your location helps ensure accurate data collection.',
      color: AppColors.info,
    ),
    OnboardingStep(
      icon: Icons.inventory_2,
      title: 'Village Drop Points',
      description: 'Manage collection crates at village drop points. '
          'Track inventory and coordinate pickups.',
      color: AppColors.warning,
    ),
    OnboardingStep(
      icon: Icons.trending_up,
      title: 'Performance Metrics',
      description: 'Track your daily verifications, accuracy scores, '
          'and farmer onboarding progress on your dashboard.',
      color: AppColors.success,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    final response = await _apiService.completeTraining();

    if (mounted) {
      setState(() => _isLoading = false);

      if (response.success) {
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      } else {
        // Show error but still allow proceeding
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Error completing training'),
            backgroundColor: AppColors.error,
          ),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress dots
            Padding(
              padding: const EdgeInsets.all(24),
              child: _buildProgressDots(),
            ),

            // Page view
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemCount: _steps.length,
                itemBuilder: (context, index) => _buildPage(_steps[index]),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: _buildNavigation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _steps.length,
        (index) => Container(
          width: index == _currentPage ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: index == _currentPage
                ? _steps[index].color
                : AppColors.surfaceGrey,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: step.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(step.icon, size: 60, color: step.color),
          ),
          const SizedBox(height: 48),

          // Title
          Text(
            step.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            step.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigation() {
    final isLastPage = _currentPage == _steps.length - 1;

    return Row(
      children: [
        // Skip button (not on last page)
        if (!isLastPage)
          TextButton(
            onPressed: () => _pageController.jumpToPage(_steps.length - 1),
            child: const Text('Skip'),
          ),

        const Spacer(),

        // Next/Done button
        ElevatedButton(
          onPressed: _isLoading ? null : _nextPage,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(140, 56),
            backgroundColor: _steps[_currentPage].color,
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(isLastPage ? 'Get Started' : 'Next'),
        ),
      ],
    );
  }
}

/// Model for onboarding step
class OnboardingStep {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
