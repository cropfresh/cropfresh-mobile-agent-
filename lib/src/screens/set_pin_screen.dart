/**
 * Set PIN Screen - Story 2.6 (AC4)
 * 
 * Mandatory PIN change after first login.
 * Validates PIN format (no sequential/repeated digits).
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/routes.dart';
import '../config/theme.dart';
import '../services/api_service.dart';

class SetPinScreen extends StatefulWidget {
  final String temporaryToken;
  final String agentName;

  const SetPinScreen({
    super.key,
    required this.temporaryToken,
    required this.agentName,
  });

  @override
  State<SetPinScreen> createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePin = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  /// Validate PIN format (no sequential or repeated digits)
  String? _validatePin(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a PIN';
    }
    if (value.length != 4) {
      return 'PIN must be 4 digits';
    }
    if (_isSequential(value)) {
      return 'Avoid sequential numbers like 1234';
    }
    if (_isRepeated(value)) {
      return 'Avoid repeated digits like 1111';
    }
    return null;
  }

  bool _isSequential(String pin) {
    const patterns = [
      '0123', '1234', '2345', '3456', '4567', '5678', '6789',
      '9876', '8765', '7654', '6543', '5432', '4321', '3210'
    ];
    return patterns.contains(pin);
  }

  bool _isRepeated(String pin) {
    return RegExp(r'^(\d)\1{3}$').hasMatch(pin);
  }

  Future<void> _handleSetPin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _apiService.setPin(
      widget.temporaryToken,
      _pinController.text,
      _confirmPinController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);

      if (response.success && response.data != null) {
        // Navigate to onboarding if training required, else dashboard
        if (response.data!.requiresTraining) {
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        }
      } else {
        setState(() => _errorMessage = response.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),

                // Header
                _buildHeader(),
                const SizedBox(height: 48),

                // New PIN field
                _buildPinField(),
                const SizedBox(height: 16),

                // Confirm PIN field
                _buildConfirmPinField(),
                const SizedBox(height: 8),

                // PIN rules
                _buildPinRules(),
                const SizedBox(height: 24),

                // Error message
                if (_errorMessage != null) _buildErrorMessage(),

                // Set PIN button
                _buildSetPinButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Security icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.secondaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.security,
            size: 48,
            color: AppColors.secondaryGreen,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome, ${widget.agentName}!',
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Create a secure 4-digit PIN for quick login',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPinField() {
    return TextFormField(
      controller: _pinController,
      keyboardType: TextInputType.number,
      obscureText: _obscurePin,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      decoration: InputDecoration(
        labelText: 'New PIN',
        hintText: 'Enter 4-digit PIN',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscurePin ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscurePin = !_obscurePin),
        ),
      ),
      validator: _validatePin,
    );
  }

  Widget _buildConfirmPinField() {
    return TextFormField(
      controller: _confirmPinController,
      keyboardType: TextInputType.number,
      obscureText: _obscureConfirm,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      decoration: InputDecoration(
        labelText: 'Confirm PIN',
        hintText: 'Re-enter PIN',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
        ),
      ),
      validator: (value) {
        if (value != _pinController.text) {
          return 'PINs do not match';
        }
        return null;
      },
    );
  }

  Widget _buildPinRules() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRule('4 digits only', true),
          const SizedBox(height: 4),
          _buildRule('No sequential (1234, 4321)', true),
          const SizedBox(height: 4),
          _buildRule('No repeated (1111, 2222)', true),
        ],
      ),
    );
  }

  Widget _buildRule(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: isValid ? AppColors.success : AppColors.textLight,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isValid ? AppColors.textSecondary : AppColors.textLight,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetPinButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleSetPin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondaryGreen,
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
          : const Text('Set PIN'),
    );
  }
}
