/**
 * CropFresh Agent App - Story 2.6
 * 
 * Field Agent mobile application for:
 * - Pre-provisioned account login
 * - PIN-based authentication
 * - Farm visits and quality verification
 * 
 * Uses CropFresh Pro theme (Material 3).
 */

import 'package:flutter/material.dart';
import 'src/config/theme.dart';
import 'src/config/routes.dart';

void main() {
  runApp(const CropFreshAgentApp());
}

class CropFreshAgentApp extends StatelessWidget {
  const CropFreshAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CropFresh Agent',
      debugShowCheckedModeBanner: false,
      
      // CropFresh Pro theme
      theme: AppTheme.lightTheme,
      
      // Navigation
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
