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
    
    // Watch for any active cooldown
    final isAnyCooldownActive = ref.watch(isAnyCooldownActiveProvider);
    ref.watch(remainingCooldownSecondsProvider);
    
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
                    centerTitle: true,
                  ),
                ),
                
                // Cooldown Status Bar (if active)
                if (isAnyCooldownActive)
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      color: Colors.amber.shade100,
                      child: Row(
                        children: [
                          const Icon(Icons.timer, color: Colors.orange),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Every emergency is 1 minute interval, please wait, be safe and standby',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
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
                                color: Colors.black.withValues(alpha: 0.2),
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
                        
                        // Emergency buttons - removed color change for cooldown
                        EmergencyButton(
                          label: 'POLICE',
                          color: Colors.blue.shade700, // Always use original color
                          icon: Icons.local_police,
                          onPressed: (isCalling || ref.watch(isButtonInCooldownProvider(EmergencyType.police)))
                              ? null
                              : () => ref
                                  .read(emergencyServiceProvider.notifier)
                                  .callEmergency(EmergencyType.police),
                        ),
                        EmergencyButton(
                          label: 'AMBULANCE',
                          color: Colors.red.shade700, // Always use original color
                          icon: Icons.medical_services,
                          onPressed: (isCalling || ref.watch(isButtonInCooldownProvider(EmergencyType.ambulance)))
                              ? null
                              : () => ref
                                  .read(emergencyServiceProvider.notifier)
                                  .callEmergency(EmergencyType.ambulance),
                        ),
                        EmergencyButton(
                          label: 'FIRE',
                          color: Colors.red.shade700, // Always use original color
                          icon: Icons.local_fire_department,
                          onPressed: (isCalling || ref.watch(isButtonInCooldownProvider(EmergencyType.fire)))
                              ? null
                              : () => ref
                                  .read(emergencyServiceProvider.notifier)
                                  .callEmergency(EmergencyType.fire),
                        ),
                        EmergencyButton(
                          label: 'FLOOD',
                          color: Colors.orange.shade700, // Always use original color
                          icon: Icons.water,
                          onPressed: (isCalling || ref.watch(isButtonInCooldownProvider(EmergencyType.flood)))
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
            
            // Loading indicator (non-modal)
            if (isCalling)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Sending Emergency Alert.',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
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