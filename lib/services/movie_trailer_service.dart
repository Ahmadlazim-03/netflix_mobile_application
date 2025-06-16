import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieTrailerService {
  static const String _tmdbApiKey = 'c940dbd4f269cdf93e84d9a9e657ce9a'; // Gunakan API Key Anda
  static const String _tmdbBaseUrl = 'https://api.themoviedb.org/3';

  // Ini adalah satu-satunya fungsi yang seharusnya ada di dalam class ini.
  // Pastikan tidak ada fungsi lama seperti getMovieTrailers.
  Future<String?> getBestTrailerKey(int movieId) async {
    print('🎬 Getting trailer key for movie ID: $movieId');
    try {
      final response = await http.get(
        Uri.parse('$_tmdbBaseUrl/movie/$movieId/videos?api_key=$_tmdbApiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        if (results.isEmpty) {
          print('🎬 No videos found for this movie.');
          return null;
        }
        
        // Cari video dengan tipe "Trailer" dan dari situs "YouTube"
        final trailers = results.where((video) =>
            video['site'] == 'YouTube' && video['type'] == 'Trailer');

        if (trailers.isNotEmpty) {
          // Kembalikan 'key' dari trailer pertama yang ditemukan
          final bestTrailerKey = trailers.first['key'];
          print('🎬 Found trailer key: $bestTrailerKey');
          return bestTrailerKey;
        }

        // Jika tidak ada "Trailer", cari "Teaser" sebagai alternatif
        final teasers = results.where((video) =>
            video['site'] == 'YouTube' && video['type'] == 'Teaser');
        
        if (teasers.isNotEmpty) {
           final bestTeaserKey = teasers.first['key'];
           print('🎬 No trailer found, using teaser key: $bestTeaserKey');
           return bestTeaserKey;
        }
        
        print('🎬 No official Trailer or Teaser found.');
        return null;
      }
      return null;
    } catch (e) {
      print('🎬 Error fetching trailer key from TMDB: $e');
      return null;
    }
  }
}