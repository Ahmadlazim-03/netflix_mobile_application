import 'dart:convert';
import 'package:http/http.dart' as http;

class VideoService {
  static const String _tmdbApiKey = 'c940dbd4f269cdf93e84d9a9e657ce9a';
  static const String _tmdbBaseUrl = 'https://api.themoviedb.org/3';

  // Get trailers from TMDB
  Future<List<VideoTrailer>> getMovieTrailers(int movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$_tmdbBaseUrl/movie/$movieId/videos?api_key=$_tmdbApiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        
        return results
            .where((video) => video['site'] == 'YouTube' && video['type'] == 'Trailer')
            .map((video) => VideoTrailer.fromJson(video))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching trailers: $e');
      return [];
    }
  }

  // Convert YouTube ID to playable URL
  String getYouTubeUrl(String videoKey) {
    return 'https://www.youtube.com/watch?v=$videoKey';
  }

  // Sample videos for demo (replace with your actual video sources)
  List<String> getSampleVideos() {
    return [
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
    ];
  }

  // For production: integrate with your video hosting service
  Future<String?> getStreamingUrl(int movieId) async {
    // Option 1: Your own video hosting
    // return 'https://your-cdn.com/movies/$movieId.mp4';
    
    // Option 2: Third-party streaming service
    // return await _getFromStreamingService(movieId);
    
    // For demo: return sample video
    final samples = getSampleVideos();
    return samples[movieId % samples.length];
  }
}

class VideoTrailer {
  final String key;
  final String name;
  final String site;
  final String type;

  VideoTrailer({
    required this.key,
    required this.name,
    required this.site,
    required this.type,
  });

  factory VideoTrailer.fromJson(Map<String, dynamic> json) {
    return VideoTrailer(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      site: json['site'] ?? '',
      type: json['type'] ?? '',
    );
  }

  String get youtubeUrl => 'https://www.youtube.com/watch?v=$key';
  String get youtubeThumbnail => 'https://img.youtube.com/vi/$key/maxresdefault.jpg';
}