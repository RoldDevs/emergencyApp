import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/providers/firstaid_video_service.dart';

class VideoCategorySelector extends ConsumerWidget {
  const VideoCategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: VideoCategory.values.map((category) {
          final isSelected = category == selectedCategory;
          final categoryName = _getCategoryName(category);
          final categoryIcon = _getCategoryIcon(category);
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => ref.read(selectedCategoryProvider.notifier).state = category,
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? _getCategoryColor(category) 
                      : Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _getCategoryColor(category).withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      categoryIcon,
                      color: isSelected 
                          ? Colors.white 
                          : Colors.grey.withValues(alpha: 0.7),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      categoryName,
                      style: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : Colors.grey.withValues(alpha: 0.7),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
  
  String _getCategoryName(VideoCategory category) {
    switch (category) {
      case VideoCategory.firstAid:
        return 'First Aid';
      case VideoCategory.flood:
        return 'Flood';
      case VideoCategory.fire:
        return 'Fire';
      case VideoCategory.crime:
        return 'Crime Prevention';
    }
  }
  
  IconData _getCategoryIcon(VideoCategory category) {
    switch (category) {
      case VideoCategory.firstAid:
        return Icons.medical_services;
      case VideoCategory.flood:
        return Icons.water;
      case VideoCategory.fire:
        return Icons.local_fire_department;
      case VideoCategory.crime:
        return Icons.security;
    }
  }
  
  Color _getCategoryColor(VideoCategory category) {
    switch (category) {
      case VideoCategory.firstAid:
        return Colors.red;
      case VideoCategory.flood:
        return Colors.orange;
      case VideoCategory.fire:
        return Colors.red;
      case VideoCategory.crime:
        return Colors.blue;
    }
  }
}
