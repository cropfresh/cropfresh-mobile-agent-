/**
 * API Service - Story 2.6
 * 
 * HTTP client for backend communication.
 * Handles agent login, PIN setup, training, and dashboard data.
 */

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// API response wrapper
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final String? error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.error,
  });
}

/// API Service for backend communication
class ApiService {
  // TODO: Move to environment config
  static const String baseUrl = 'http://10.0.2.2:8080/v1'; // Android emulator localhost
  
  /// Perform agent first-time login with temporary PIN
  Future<ApiResponse<LoginData>> login(String mobile, String pin) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agent/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mobile_number': mobile,
          'pin': pin,
        }),
      );

      final json = jsonDecode(response.body);
      
      if (response.statusCode == 200 && json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'],
          data: LoginData.fromJson(json['data']),
        );
      } else {
        return ApiResponse(
          success: false,
          message: json['message'] ?? 'Login failed',
          error: json['error'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error. Please check your connection.',
        error: 'NETWORK_ERROR',
      );
    }
  }

  /// Set new permanent PIN
  Future<ApiResponse<SetPinData>> setPin(
    String tempToken, 
    String newPin, 
    String confirmPin,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/agent/set-pin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'temporary_token': tempToken,
          'new_pin': newPin,
          'confirm_pin': confirmPin,
        }),
      );

      final json = jsonDecode(response.body);
      
      if (response.statusCode == 200 && json['success'] == true) {
        // Save tokens locally
        final data = SetPinData.fromJson(json['data']);
        await _saveTokens(data.accessToken, data.refreshToken);
        
        return ApiResponse(
          success: true,
          message: json['message'],
          data: data,
        );
      } else {
        return ApiResponse(
          success: false,
          message: json['message'] ?? 'Failed to set PIN',
          error: json['error'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error. Please try again.',
        error: 'NETWORK_ERROR',
      );
    }
  }

  /// Mark training as complete
  Future<ApiResponse<TrainingData>> completeTraining() async {
    try {
      final token = await _getAccessToken();
      final response = await http.post(
        Uri.parse('$baseUrl/agent/complete-training'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final json = jsonDecode(response.body);
      
      if (response.statusCode == 200 && json['success'] == true) {
        return ApiResponse(
          success: true,
          message: json['message'],
          data: TrainingData.fromJson(json['data']),
        );
      } else {
        return ApiResponse(
          success: false,
          message: json['message'] ?? 'Training completion failed',
          error: json['error'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error.',
        error: 'NETWORK_ERROR',
      );
    }
  }

  /// Get dashboard data
  Future<ApiResponse<DashboardData>> getDashboard() async {
    try {
      final token = await _getAccessToken();
      final response = await http.get(
        Uri.parse('$baseUrl/agent/dashboard'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final json = jsonDecode(response.body);
      
      if (response.statusCode == 200 && json['success'] == true) {
        return ApiResponse(
          success: true,
          data: DashboardData.fromJson(json['data']),
        );
      } else {
        return ApiResponse(
          success: false,
          message: json['message'] ?? 'Failed to load dashboard',
          error: json['error'],
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Network error.',
        error: 'NETWORK_ERROR',
      );
    }
  }

  // Token management helpers
  Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}

// Data models
class LoginData {
  final bool requiresPinChange;
  final String temporaryToken;
  final String agentName;

  LoginData({
    required this.requiresPinChange,
    required this.temporaryToken,
    required this.agentName,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      requiresPinChange: json['requires_pin_change'] ?? true,
      temporaryToken: json['temporary_token'] ?? '',
      agentName: json['agent_name'] ?? 'Agent',
    );
  }
}

class SetPinData {
  final String accessToken;
  final String refreshToken;
  final bool requiresTraining;

  SetPinData({
    required this.accessToken,
    required this.refreshToken,
    required this.requiresTraining,
  });

  factory SetPinData.fromJson(Map<String, dynamic> json) {
    return SetPinData(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      requiresTraining: json['requires_training'] ?? true,
    );
  }
}

class TrainingData {
  final String status;
  final bool dashboardUnlocked;

  TrainingData({
    required this.status,
    required this.dashboardUnlocked,
  });

  factory TrainingData.fromJson(Map<String, dynamic> json) {
    return TrainingData(
      status: json['status'] ?? '',
      dashboardUnlocked: json['dashboard_unlocked'] ?? false,
    );
  }
}

class DashboardData {
  final String agentName;
  final int pendingTasks;
  final String zoneName;
  final List<String> villages;
  final int farmerCount;
  final int verificationsToday;
  final double accuracyPercent;

  DashboardData({
    required this.agentName,
    required this.pendingTasks,
    required this.zoneName,
    required this.villages,
    required this.farmerCount,
    required this.verificationsToday,
    required this.accuracyPercent,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final zone = json['zone'] ?? {};
    final performance = json['performance'] ?? {};
    return DashboardData(
      agentName: json['agent_name'] ?? 'Agent',
      pendingTasks: json['pending_tasks'] ?? 0,
      zoneName: zone['name'] ?? '',
      villages: List<String>.from(zone['villages'] ?? []),
      farmerCount: zone['farmer_count'] ?? 0,
      verificationsToday: performance['verifications_today'] ?? 0,
      accuracyPercent: (performance['accuracy_percent'] ?? 0).toDouble(),
    );
  }
}
