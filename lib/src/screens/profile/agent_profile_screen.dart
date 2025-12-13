import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// CropFresh Agent App Theme Colors
/// "CropFresh Pro" Theme - Professional, trustworthy
class _AppColors {
  static const Color primary = Color(0xFFF57C00);
  static const Color onPrimary = Colors.white;
  static const Color secondary = Color(0xFF2E7D32);
  static const Color surface = Color(0xFFF5F5F5);
  static const Color surfaceContainer = Colors.white;
  static const Color onSurface = Color(0xFF212121);
  static const Color onSurfaceVariant = Color(0xFF757575);
  static const Color outline = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF57C00), Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Agent Profile Screen - Story 2.7 (AC4)
/// Profile for field agents - mostly read-only with limited editable fields
class AgentProfileScreen extends StatefulWidget {
  const AgentProfileScreen({super.key});

  @override
  State<AgentProfileScreen> createState() => _AgentProfileScreenState();
}

class _AgentProfileScreenState extends State<AgentProfileScreen> {
  bool _isEditing = false;
  bool _hasChanges = false;
  bool _isSaving = false;

  // Agent data (mostly read-only, managed by District Manager)
  final String _agentName = 'Suresh B';
  final String _agentId = 'AGT-KA-2024-0042';
  final String _phoneNumber = '+91 98765 43210';
  final String _zoneName = 'Devanahalli Zone';
  final List<String> _assignedVillages = ['Sadahalli', 'Kodigehalli', 'Begur', 'Budigere'];
  
  // Editable fields
  String _upiId = 'suresh.b@okaxis';
  String _languagePreference = 'Kannada';
  
  final List<String> _languages = ['Kannada', 'Hindi', 'English', 'Tamil', 'Telugu'];

  void _toggleEdit() {
    HapticFeedback.lightImpact();
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) _hasChanges = false;
    });
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _saveChanges() async {
    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      _isSaving = false;
      _isEditing = false;
      _hasChanges = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('Profile updated successfully'),
            ],
          ),
          backgroundColor: _AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: _AppColors.surface,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: _AppColors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton.icon(
            onPressed: _toggleEdit,
            icon: Icon(
              _isEditing ? Icons.close_rounded : Icons.edit_rounded,
              size: 20,
            ),
            label: Text(_isEditing ? 'Cancel' : 'Edit'),
            style: TextButton.styleFrom(
              foregroundColor: _isEditing ? _AppColors.error : _AppColors.primary,
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: _AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      _agentName[0].toUpperCase(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(_agentName, style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold,
                  )),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Field Agent • $_agentId', style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9), fontSize: 13,
                    )),
                  ),
                ],
              ),
            ),
          ),

          // Read-Only Section
          SliverToBoxAdapter(child: _buildSection(
            'Account Information',
            Icons.person_rounded,
            null,
            [
              _buildReadOnlyField('Full Name', _agentName, Icons.badge_rounded),
              _buildReadOnlyField('Mobile Number', _phoneNumber, Icons.phone_android_rounded),
            ],
          )),

          // Zone Assignment (Read-Only)
          SliverToBoxAdapter(child: _buildSection(
            'Zone Assignment',
            Icons.map_rounded,
            'Contact your District Manager to update',
            [
              _buildReadOnlyField('Assigned Zone', _zoneName, Icons.location_city_rounded),
              _buildVillagesList(),
            ],
          )),

          // Editable Section
          SliverToBoxAdapter(child: _buildSection(
            'Preferences',
            Icons.tune_rounded,
            null,
            [
              _buildEditableUpi(),
              _buildLanguageDropdown(),
            ],
          )),

          // Change History
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/profile/history'),
                icon: Icon(Icons.history_rounded),
                label: Text('View Change History'),
                style: TextButton.styleFrom(foregroundColor: _AppColors.primary),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      
      floatingActionButton: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        offset: _hasChanges ? Offset.zero : const Offset(0, 2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _hasChanges ? 1.0 : 0.0,
          child: FloatingActionButton.extended(
            onPressed: _isSaving ? null : _saveChanges,
            backgroundColor: _AppColors.primary,
            foregroundColor: _AppColors.onPrimary,
            icon: _isSaving
                ? SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: _AppColors.onPrimary))
                : Icon(Icons.check_rounded),
            label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, String? infoMessage, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: _AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ))),
                if (infoMessage != null)
                  Tooltip(
                    message: infoMessage,
                    child: Icon(Icons.info_outline, size: 18, color: _AppColors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(label, style: TextStyle(color: _AppColors.onSurfaceVariant, fontWeight: FontWeight.w500, fontSize: 13)),
            const SizedBox(width: 4),
            Icon(Icons.lock_outline, size: 12, color: _AppColors.onSurfaceVariant),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _AppColors.outline),
            ),
            child: Row(children: [
              Icon(icon, size: 20, color: _AppColors.onSurfaceVariant),
              const SizedBox(width: 12),
              Text(value, style: TextStyle(color: _AppColors.onSurfaceVariant)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildVillagesList() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Assigned Villages', style: TextStyle(
              color: _AppColors.onSurfaceVariant, fontWeight: FontWeight.w500, fontSize: 13,
            )),
            const SizedBox(width: 4),
            Icon(Icons.lock_outline, size: 12, color: _AppColors.onSurfaceVariant),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _assignedVillages.map((village) => Chip(
              label: Text(village, style: TextStyle(fontSize: 13)),
              backgroundColor: _AppColors.secondary.withValues(alpha: 0.1),
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableUpi() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('UPI ID (for incentive payments)', style: TextStyle(
            color: _AppColors.onSurfaceVariant, fontWeight: FontWeight.w500, fontSize: 13,
          )),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _isEditing ? _AppColors.primary.withValues(alpha: 0.5) : _AppColors.outline),
            ),
            child: Row(children: [
              Padding(
                padding: const EdgeInsets.only(left: 14),
                child: Icon(Icons.currency_rupee_rounded, size: 20, color: _AppColors.onSurfaceVariant),
              ),
              Expanded(
                child: TextField(
                  enabled: _isEditing,
                  controller: TextEditingController(text: _upiId),
                  decoration: InputDecoration(
                    hintText: 'yourname@upi',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  onChanged: (v) { _upiId = v; _markChanged(); },
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Language Preference', style: TextStyle(
            color: _AppColors.onSurfaceVariant, fontWeight: FontWeight.w500, fontSize: 13,
          )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: _AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _isEditing ? _AppColors.primary.withValues(alpha: 0.5) : _AppColors.outline),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _languagePreference,
                isExpanded: true,
                items: _languages.map((l) => DropdownMenuItem(value: l, child: Row(
                  children: [
                    Icon(Icons.translate, size: 20, color: _AppColors.onSurfaceVariant),
                    const SizedBox(width: 12),
                    Text(l),
                  ],
                ))).toList(),
                onChanged: _isEditing ? (v) {
                  setState(() => _languagePreference = v!);
                  _markChanged();
                } : null,
                icon: Icon(Icons.keyboard_arrow_down_rounded, color: _AppColors.onSurfaceVariant),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
