import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/utils/themes.dart';
import 'package:emergency_app/components/custom_button.dart';
import 'package:emergency_app/providers/auth_service.dart';
import 'package:emergency_app/auth/signin.dart';

class AdminProfileScreen extends ConsumerWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundSecondary,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildAdminAvatar(),
              const SizedBox(height: 16),
              const Text(
                'Admin',
                style: TextStyle(
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
              CustomButton(
                text: 'Logout',
                backgroundColor: Colors.red.shade700,
                onPressed: () => _logout(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminAvatar() {
    return const CircleAvatar(
      radius: 50,
      backgroundColor: AppTheme.primaryColor,
      child: Text(
        'A',
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  void _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authServiceProvider.notifier).signOut();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInPage()),
      (route) => false,
    );
  }
}