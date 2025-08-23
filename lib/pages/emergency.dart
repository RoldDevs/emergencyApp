import 'package:emergency_app/utils/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/components/emergency_button.dart';
import 'package:emergency_app/providers/emergency_service.dart';
import 'package:emergency_app/models/emergency_notification.dart'; 

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCalling = ref.watch(isCallingProvider);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background with gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.primaryColor, Colors.white],
                ),
              ),
            ),
            
            // Main content
            CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: size.height * 0.11,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppTheme.primaryColor, 
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'Emergency',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Remove the custom gradient background and use the theme color
                    centerTitle: true,
                  ),
                ),
                
                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color.fromRGBO(0, 0, 0, 0.5),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency Services',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFE53935),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap a button below to call for immediate assistance, or to make sure you are safe.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        EmergencyButton(
                          label: 'POLICE',
                          color: Colors.blue.shade700,
                          icon: Icons.local_police,
                          onPressed: isCalling
                              ? null
                              : () => ref
                                  .read(emergencyServiceProvider.notifier)
                                  .callEmergency(EmergencyType.police),
                        ),
                        EmergencyButton(
                          label: 'AMBULANCE',
                          color: Colors.red.shade700,
                          icon: Icons.medical_services,
                          onPressed: isCalling
                              ? null
                              : () => ref
                                  .read(emergencyServiceProvider.notifier)
                                  .callEmergency(EmergencyType.ambulance),
                        ),
                        EmergencyButton(
                          label: 'FIRE',
                          color: Colors.red.shade700,
                          icon: Icons.local_fire_department,
                          onPressed: isCalling
                              ? null
                              : () => ref
                                  .read(emergencyServiceProvider.notifier)
                                  .callEmergency(EmergencyType.fire),
                        ),
                        EmergencyButton(
                          label: 'FLOOD',
                          color: Colors.orange.shade700,
                          icon: Icons.water,
                          onPressed: isCalling
                              ? null
                              : () => ref
                                  .read(emergencyServiceProvider.notifier)
                                  .callEmergency(EmergencyType.flood),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Loading overlay
            if (isCalling)
              Container(
                color: const Color.fromRGBO(0, 0, 0, 0.5),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Connecting to emergency services.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please stay on this screen',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}