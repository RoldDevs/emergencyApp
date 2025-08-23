import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emergency_app/urls/video_urls.dart';

enum VideoCategory {
  firstAid,
  flood,
  fire,
  crime,
}

class Video {
  final String id;
  final String title;
  final String thumbnailUrl;
  final VideoCategory category;

  Video({
    required this.id,
    required this.title,
    required this.thumbnailUrl,
    required this.category,
  });

  factory Video.fromMap(Map<String, String> map) {
    return Video(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      thumbnailUrl: map['thumbnail'] ?? '',
      category: _getCategoryFromString(map['category'] ?? ''),
    );
  }

  static VideoCategory _getCategoryFromString(String category) {
    switch (category) {
      case 'firstAid':
        return VideoCategory.firstAid;
      case 'flood':
        return VideoCategory.flood;
      case 'fire':
        return VideoCategory.fire;
      case 'crime':
        return VideoCategory.crime;
      default:
        return VideoCategory.firstAid;
    }
  }
}

class FirstAidVideoService extends StateNotifier<List<Video>> {
  FirstAidVideoService() : super(_loadVideos());

  List<Video> getVideosByCategory(VideoCategory category) {
    return state.where((video) => video.category == category).toList();
  }

  // Load videos from the URLs file
  static List<Video> _loadVideos() {
    final allVideosMap = VideoUrls.getAllVideos();
    return allVideosMap.map((videoMap) => Video.fromMap(videoMap)).toList();
  }
}

final firstAidVideoServiceProvider = StateNotifierProvider<FirstAidVideoService, List<Video>>(
  (ref) => FirstAidVideoService(),
);

final selectedCategoryProvider = StateProvider<VideoCategory>(
  (ref) => VideoCategory.firstAid,
);

final filteredVideosProvider = Provider<List<Video>>(
  (ref) {
    final videos = ref.watch(firstAidVideoServiceProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    return videos.where((video) => video.category == selectedCategory).toList();
  },
);