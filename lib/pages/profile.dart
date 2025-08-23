import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/utils/themes.dart';
import 'package:emergency_app/components/custom_button.dart';
import 'package:emergency_app/components/custom_input_field.dart';
import 'package:emergency_app/providers/auth_service.dart';
import 'package:emergency_app/auth/signin.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _displayNameController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _addressController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider);
    _displayNameController = TextEditingController(text: user?.displayName ?? '');
    _phoneNumberController = TextEditingController(text: user?.phoneNumber ?? '');
    _addressController = TextEditingController(text: user?.address ?? ''); 
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.secondaryColor,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              }
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildProfileAvatar(user.displayName),
              const SizedBox(height: 16),
              Text(
                user.displayName ?? 'User',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              _buildInfoCards(),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Logout',
                backgroundColor: Colors.red.shade700,
                onPressed: _logout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String? displayName) {
    final String firstLetter = (displayName?.isNotEmpty == true) 
        ? displayName![0].toUpperCase() 
        : 'U';
    
    return CircleAvatar(
      radius: 50,
      backgroundColor: AppTheme.primaryColor,
      child: Text(
        firstLetter,
        style: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoCard(
          title: 'Display Name',
          controller: _displayNameController,
          icon: Icons.person,
          isEditable: _isEditing,
        ),
        _buildInfoCard(
          title: 'Phone Number',
          controller: _phoneNumberController,
          icon: Icons.phone,
          isEditable: _isEditing,
        ),
        _buildInfoCard(
          title: 'Address',
          controller: _addressController,
          icon: Icons.home,
          isEditable: _isEditing,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditable,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            isEditable
                ? CustomInputField(
                    controller: controller,
                    labelText: '',
                    hintText: 'Enter $title',
                    prefixIcon: icon,
                  )
                : Row(
                    children: [
                      Icon(icon, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          controller.text.isNotEmpty ? controller.text : 'Not set',
                          style: TextStyle(
                            fontSize: 16,
                            color: controller.text.isNotEmpty
                                ? AppTheme.textPrimary
                                : AppTheme.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 3,  // Allow up to 3 lines for long addresses
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  void _saveProfile() async {
    try {
      await ref.read(authServiceProvider.notifier).updateUserProfile(
        displayName: _displayNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        address: _addressController.text.trim(),
      );
      
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: ${e.toString()}')),
      );
    }
  }

  void _logout() async {
    await ref.read(authServiceProvider.notifier).signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SignInPage()),
        (route) => false,
      );
    }
  }
}