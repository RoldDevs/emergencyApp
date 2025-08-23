import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/utils/themes.dart';
import 'package:emergency_app/models/emergency_notification.dart';
import 'package:emergency_app/providers/emergency_notification_service.dart';
import 'package:emergency_app/providers/map_navigation_provider.dart';
import 'package:intl/intl.dart';

class EmergencyListScreen extends ConsumerWidget {
  const EmergencyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyNotificationsAsync = ref.watch(emergencyNotificationServiceProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundPrimary,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Emergency Reports',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: emergencyNotificationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(
                  child: Text('Error loading emergency data: $error'),
                ),
                data: (notifications) {
                  if (notifications.isEmpty) {
                    return const Center(
                      child: Text('No emergency reports available'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final emergency = notifications[index];
                      return EmergencyCard(emergency: emergency);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyCard extends ConsumerWidget {
  final EmergencyNotification emergency;
  
  const EmergencyCard({super.key, required this.emergency});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getEmergencyColor(emergency.type).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency type header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getEmergencyColor(emergency.type).withValues(alpha: 0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getEmergencyColor(emergency.type),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getEmergencyIcon(emergency.type), color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _getEmergencyTypeText(emergency.type),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: emergency.isAcknowledged ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      emergency.isAcknowledged ? 'Acknowledged' : 'Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Emergency details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User info
                  Row(
                    children: [
                      const Icon(Icons.person, size: 18, color: AppTheme.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          emergency.userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        _formatTimestamp(emergency.timestamp),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Contact info
                  if (emergency.userPhone != null && emergency.userPhone!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.phone, size: 18, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Text(
                            emergency.userPhone!,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  
                  // Email info
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.email, size: 18, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          emergency.userEmail,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  
                  // Address info if available
                  if (emergency.userAddress != null && emergency.userAddress!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.home, size: 18, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              emergency.userAddress!,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const Divider(),
                  
                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppTheme.primaryColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${emergency.latitude.toStringAsFixed(4)}, ${emergency.longitude.toStringAsFixed(4)}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Set the selected emergency and navigate to map
                          ref.read(selectedEmergencyProvider.notifier).state = emergency;
                        },
                        icon: const Icon(Icons.map, size: 16),
                        label: const Text('View on Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _getEmergencyColor(emergency.type),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  
                  // Action buttons
                  if (!emergency.isAcknowledged)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () async {
                              // Show loading indicator
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                              
                              try {
                                // Call the acknowledge method
                                await ref
                                    .read(emergencyNotificationServiceProvider.notifier)
                                    .acknowledgeEmergency(emergency.id);
                                
                                if (context.mounted) {
                                  // Close loading dialog
                                  Navigator.pop(context);
                                  
                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Emergency acknowledged successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  // Close loading dialog
                                  Navigator.pop(context);
                                  
                                  // Show error message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _getEmergencyColor(emergency.type),
                              side: BorderSide(color: _getEmergencyColor(emergency.type)),
                            ),
                            child: const Text('Acknowledge'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getEmergencyColor(EmergencyType type) {
    switch (type) {
      case EmergencyType.police:
        return Colors.blue.shade700;
      case EmergencyType.ambulance:
        return Colors.green.shade700;
      case EmergencyType.fire:
        return Colors.red.shade700;
      case EmergencyType.flood:
        return Colors.orange.shade700;
    }
  }
  
  IconData _getEmergencyIcon(EmergencyType type) {
    switch (type) {
      case EmergencyType.police:
        return Icons.local_police;
      case EmergencyType.ambulance:
        return Icons.medical_services;
      case EmergencyType.fire:
        return Icons.local_fire_department;
      case EmergencyType.flood:
        return Icons.water;
    }
  }
  
  String _getEmergencyTypeText(EmergencyType type) {
    switch (type) {
      case EmergencyType.police:
        return 'POLICE';
      case EmergencyType.ambulance:
        return 'AMBULANCE';
      case EmergencyType.fire:
        return 'FIRE';
      case EmergencyType.flood:
        return 'FLOOD';
    }
  }
  
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}