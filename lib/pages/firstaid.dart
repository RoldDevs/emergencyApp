import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/components/youtube_video_player.dart';
import 'package:emergency_app/components/video_category_selector.dart';
import 'package:emergency_app/providers/firstaid_video_service.dart';
import 'package:emergency_app/utils/themes.dart';

class FirstAidScreen extends ConsumerWidget {
  const FirstAidScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredVideos = ref.watch(filteredVideosProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 50,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _getCategoryTitle(selectedCategory),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getCategoryColor(selectedCategory),
                      _getCategoryColor(selectedCategory)
                          ..withValues(alpha: 0.7), 
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _getCategoryDescription(selectedCategory),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: VideoCategorySelector(),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: filteredVideos.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.videocam_off,
                              size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            'No videos available for ${_getCategoryName(selectedCategory)}',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final video = filteredVideos[index];
                        return YoutubeVideoPlayer(
                          key: ValueKey(
                              '${selectedCategory.toString()}_${video.id}'),
                          videoId: video.id,
                          title: video.title,
                        );
                      },
                      childCount: filteredVideos.length,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  static String _getCategoryTitle(VideoCategory category) {
    switch (category) {
      case VideoCategory.firstAid:
        return 'First Aid Training';
      case VideoCategory.flood:
        return 'Flood Safety';
      case VideoCategory.fire:
        return 'Fire Prevention';
      case VideoCategory.crime:
        return 'Crime Prevention';
    }
  }

  static String _getCategoryName(VideoCategory category) {
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

  static String _getCategoryDescription(VideoCategory category) {
    switch (category) {
      case VideoCategory.firstAid:
        return 'Learn essential first aid techniques to help in emergency situations before professional help arrives.';
      case VideoCategory.flood:
        return 'Discover how to prepare for, survive during, and recover after flooding events.';
      case VideoCategory.fire:
        return 'Learn fire prevention strategies and what to do if a fire breaks out.';
      case VideoCategory.crime:
        return 'Tips and techniques to protect yourself and your property from criminal activity.';
    }
  }

  static Color _getCategoryColor(VideoCategory category) {
    switch (category) {
      case VideoCategory.firstAid:
        return AppTheme.primaryColor;
      case VideoCategory.flood:
        return AppTheme.primaryColor;
      case VideoCategory.fire:
        return AppTheme.primaryColor;
      case VideoCategory.crime:
        return AppTheme.primaryColor;
    }
  }
}
