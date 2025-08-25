import 'package:flutter/material.dart';

class EmergencyButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback? onPressed;

  const EmergencyButton({
    super.key,
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Check if button is disabled
    final bool isDisabled = onPressed == null;
    
    // In the EmergencyButton build method, update the gradient colors section
    
    // Define gradient colors based on button type and state
    List<Color> gradientColors;
    
    // Always use the original colors, even when disabled
    if (label == 'POLICE') {
      gradientColors = [Colors.blue.shade700, Colors.white];
    } else if (label == 'AMBULANCE') {
      gradientColors = [Colors.red.shade700, Colors.purple.shade300];
    } else if (label == 'FLOOD') {
      gradientColors = [Colors.orange.shade700, Colors.yellow.shade400];
    } else if (label == 'FIRE') {
      gradientColors = [Colors.red.shade700, Colors.pink.shade300];
    } else {
      // Default fallback gradient
      gradientColors = [
        color,
        color.withValues(alpha: 0.7),
      ];
    } 
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: isDisabled
                ? Colors.grey.withValues(alpha: 0.3)
                : color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.0),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        const BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.1),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: isDisabled ? Colors.grey : color,
                      size: 28.0,
                    ),
                  ),
                  const SizedBox(width: 20.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: isDisabled ? Colors.grey.shade100 : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isDisabled ? 'Temporarily disabled' : 'Tap to call',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: isDisabled 
                                ? Colors.grey.shade300 
                                : const Color.fromRGBO(255, 255, 255, 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: isDisabled ? Colors.grey.shade300 : Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
