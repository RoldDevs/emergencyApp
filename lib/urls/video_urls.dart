// This file contains all video URLs used in the application
// Organized by category for better maintainability
// Updated May 2024 with working video URLs

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoUrls {
  // Helper method to convert YouTube URL to ID
  static String _getVideoId(String url) {
    return YoutubePlayer.convertUrlToId(url) ?? '';
  }
  
  // Helper method to generate thumbnail URL from video ID
  static String _getThumbnailUrl(String videoId) {
    return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
  }

  // First Aid Videos
  static Map<String, Map<String, String>> get firstAidVideos {
    return {
      'basic_cpr': {
        'id': _getVideoId('https://www.youtube.com/watch?v=2PngCv7NjaI'), 
        'title': 'How to Perform CPR - First Aid Training',
        'thumbnail': _getThumbnailUrl(_getVideoId('https://www.youtube.com/watch?v=2PngCv7NjaI')),
      },
      'treating_burns': {
        'id': _getVideoId('https://www.youtube.com/watch?v=sauqm3mvJ40'), 
        'title': 'First Aid: How to treat burns',
        'thumbnail': _getThumbnailUrl(_getVideoId('https://www.youtube.com/watch?v=sauqm3mvJ40')),
      },
      'choking_help': {
        'id': _getVideoId('https://www.youtube.com/watch?v=PA9hpOnvtCk'),
        'title': 'How to Help Someone Who Is Choking',
        'thumbnail': _getThumbnailUrl(_getVideoId('https://www.youtube.com/watch?v=PA9hpOnvtCk')),
      },
    };
  }

  // Flood Safety Videos
  static Map<String, Map<String, String>> get floodVideos {
    return {
      'flood_safety': {
        'id': _getVideoId('https://www.youtube.com/watch?v=cqCMXSOo8qc'),
        'title': 'Flood Safety Tips',
        'thumbnail': _getThumbnailUrl(_getVideoId('https://www.youtube.com/watch?v=cqCMXSOo8qc')),
      },
      'during_flood': {
        'id': _getVideoId('https://www.youtube.com/watch?v=MvcId4_UJuU'), 
        'title': 'What to do during a flood',
        'thumbnail': _getThumbnailUrl(_getVideoId('https://www.youtube.com/watch?v=MvcId4_UJuU')),
      },
      'flood_preparation': {
        'id': _getVideoId('https://www.youtube.com/watch?v=c7eX3DbrxOM'), 
        'title': 'How to Prepare for a Flood',
        'thumbnail': _getThumbnailUrl(_getVideoId('https://www.youtube.com/watch?v=c7eX3DbrxOM')),
      },
    };
  }

  // Fire Safety Videos
  static Map<String, Map<String, String>> get fireVideos {
    return {
      'home_fire_safety': {
        'id': _getVideoId('https://www.youtube.com/watch?v=eYvM2GohHr8'), 
        'title': 'Fire Safety at Home',
        'thumbnail': _getThumbnailUrl(_getVideoId('https://www.youtube.com/watch?v=eYvM2GohHr8')),
      },
      'fire_extinguisher': {
        'id': _getVideoId('https://www.youtube.com/watch?v=GVBamXXVD30'), 
        'title': 'How to Use a Fire Extinguisher',
        'thumbnail': _getThumbnailUrl(_getVideoId('https://www.youtube.com/watch?v=GVBamXXVD30')),
      },
      'escape_plan': {
        'id': _getVideoId('https://www.youtube.com/watch?v=9c6pD1QhdSA'),
        'title': 'Creating a Fire Escape Plan',
        'thumbnail': _getThumbnailUrl(_getVideoId('https://www.youtube.com/watch?v=9c6pD1QhdSA')),
      },
    };
  }

  // Crime Prevention Videos
  static Map<String, Map<String, String>> get crimeVideos {
    return {
      'home_security': {
        'id': _getVideoId('https://www.youtube.com/watch?v=jLYECy2-t-0'), 
        'title': 'Home Security Tips',
        'thumbnail': _getThumbnailUrl(_getVideoId('https://www.youtube.com/watch?v=jLYECy2-t-0')),
      },
      'personal_safety': {
        'id': _getVideoId('https://www.youtube.com/watch?v=4myMBdBNxwQ'), 
        'title': 'Personal Safety Tips',
        'thumbnail': _getThumbnailUrl(_getVideoId('https://www.youtube.com/watch?v=4myMBdBNxwQ')),
      },
      'online_safety': {
        'id': _getVideoId('https://www.youtube.com/watch?v=aO858HyFbKI'),
        'title': 'Online Safety and Security',
        'thumbnail': _getThumbnailUrl(_getVideoId('https://www.youtube.com/watch?v=aO858HyFbKI')),
      },
    };
  }

  // Helper method to get all videos as a flat list
  static List<Map<String, String>> getAllVideos() {
    List<Map<String, String>> allVideos = [];
    
    // Add First Aid videos
    firstAidVideos.forEach((key, video) {
      final videoWithCategory = Map<String, String>.from(video);
      videoWithCategory['category'] = 'firstAid';
      allVideos.add(videoWithCategory);
    });
    
    // Add Flood videos
    floodVideos.forEach((key, video) {
      final videoWithCategory = Map<String, String>.from(video);
      videoWithCategory['category'] = 'flood';
      allVideos.add(videoWithCategory);
    });
    
    // Add Fire videos
    fireVideos.forEach((key, video) {
      final videoWithCategory = Map<String, String>.from(video);
      videoWithCategory['category'] = 'fire';
      allVideos.add(videoWithCategory);
    });
    
    // Add Crime videos
    crimeVideos.forEach((key, video) {
      final videoWithCategory = Map<String, String>.from(video);
      videoWithCategory['category'] = 'crime';
      allVideos.add(videoWithCategory);
    });
    
    return allVideos;
  }
  
  // Helper method to get videos by category
  static List<Map<String, String>> getVideosByCategory(String category) {
    switch (category) {
      case 'firstAid':
        return firstAidVideos.entries
            .map((entry) {
              final videoWithCategory = Map<String, String>.from(entry.value);
              videoWithCategory['category'] = 'firstAid';
              return videoWithCategory;
            })
            .toList();
      case 'flood':
        return floodVideos.entries
            .map((entry) {
              final videoWithCategory = Map<String, String>.from(entry.value);
              videoWithCategory['category'] = 'flood';
              return videoWithCategory;
            })
            .toList();
      case 'fire':
        return fireVideos.entries
            .map((entry) {
              final videoWithCategory = Map<String, String>.from(entry.value);
              videoWithCategory['category'] = 'fire';
              return videoWithCategory;
            })
            .toList();
      case 'crime':
        return crimeVideos.entries
            .map((entry) {
              final videoWithCategory = Map<String, String>.from(entry.value);
              videoWithCategory['category'] = 'crime';
              return videoWithCategory;
            })
            .toList();
      default:
        return [];
    }
  }
}