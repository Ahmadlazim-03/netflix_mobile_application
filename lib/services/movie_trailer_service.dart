import 'dart:convert';
import 'package:http/http.dart' as http;

class MovieTrailerService {
  static const String _tmdbApiKey = 'c940dbd4f269cdf93e84d9a9e657ce9a';
  static const String _tmdbBaseUrl = 'https://api.themoviedb.org/3';

  Future<String?> getBestTrailerKey(int movieId) async {
    print('1. [TrailerService] Mencari trailer untuk movie ID: $movieId');
    try {
      final response = await http.get(Uri.parse('$_tmdbBaseUrl/movie/$movieId/videos?api_key=$_tmdbApiKey'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        if (results.isEmpty) {
          print('🔴 [TrailerService] Tidak ada video ditemukan.');
          return null;
        }
        
        final trailers = results.where((v) => v['site'] == 'YouTube' && v['type'] == 'Trailer');
        if (trailers.isNotEmpty) {
          final key = trailers.first['key'];
          print('✅ [TrailerService] Trailer ditemukan: $key');
          return key;
        }

        final teasers = results.where((v) => v['site'] == 'YouTube' && v['type'] == 'Teaser');
        if (teasers.isNotEmpty) {
          final key = teasers.first['key'];
          print('🟡 [TrailerService] Tidak ada trailer, menggunakan teaser: $key');
          return key;
        }
        
        print('🔴 [TrailerService] Tidak ada Trailer atau Teaser resmi.');
        return null;
      }
      return null;
    } catch (e) {
      print('🔴 [TrailerService] Error: $e');
      return null;
    }
  }
}