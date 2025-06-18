import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart'; // Pastikan path ini sesuai dengan proyek Anda

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = 'c940dbd4f269cdf93e84d9a9e657ce9a'; // Ganti dengan API Key Anda

  // Fungsi helper untuk mengurangi duplikasi kode
  Future<List<Movie>> _fetchMovies(String endpoint) async {
    final response = await http.get(Uri.parse('$_baseUrl$endpoint&api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Memastikan 'results' ada dan merupakan sebuah List
      if (data['results'] != null && data['results'] is List) {
        final results = data['results'] as List;
        return results.map((json) => Movie.fromJson(json)).toList();
      }
      return []; // Kembalikan list kosong jika tidak ada results
    } else {
      throw Exception('Failed to load movies from $endpoint');
    }
  }

  Future<List<Movie>> getTrendingMovies() => _fetchMovies('/trending/movie/week?');
  Future<List<Movie>> getPopularMovies() => _fetchMovies('/movie/popular?');
  Future<List<Movie>> getTopRatedMovies() => _fetchMovies('/movie/top_rated?');
  Future<List<Movie>> getNetflixOriginals() => _fetchMovies('/discover/tv?with_networks=213');
  Future<List<Movie>> searchMovies(String query) => _fetchMovies('/search/movie?query=$query');

  Future<Movie> getMovieDetails(String movieId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/$movieId?api_key=$_apiKey'),
      );
      if (response.statusCode == 200) {
        return Movie.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load movie details for id: $movieId');
      }
    } catch (e) {
      throw Exception('Error fetching details for movie $movieId: $e');
    }
  }
}