import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class ApiService {
  static const String _baseUrl = 'https://api.themoviedb.org/3';
  static const String _apiKey = 'c940dbd4f269cdf93e84d9a9e657ce9a'; 
  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  Future<List<Movie>> getTrendingMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/trending/movie/week?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load trending movies');
      }
    } catch (e) {
      // Return mock data if API fails
      return _getMockMovies();
    }
  }

  Future<List<Movie>> getPopularMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load popular movies');
      }
    } catch (e) {
      return _getMockMovies();
    }
  }

  Future<List<Movie>> getTopRatedMovies() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load top rated movies');
      }
    } catch (e) {
      return _getMockMovies();
    }
  }

  Future<List<Movie>> getNetflixOriginals() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/discover/tv?api_key=$_apiKey&with_networks=213'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load Netflix originals');
      }
    } catch (e) {
      return _getMockMovies();
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/search/movie?api_key=$_apiKey&query=$query'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];
        return results.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search movies');
      }
    } catch (e) {
      return _getMockMovies();
    }
  }

  List<Movie> _getMockMovies() {
    return [
      Movie(
        id: 1,
        title: 'Stranger Things',
        overview: 'When a young boy vanishes, a small town uncovers a mystery involving secret experiments, terrifying supernatural forces and one strange little girl.',
        posterPath: '/placeholder.jpg',
        backdropPath: '/placeholder.jpg',
        voteAverage: 8.7,
        releaseDate: '2016-07-15',
        genreIds: [18, 9648, 10765],
        adult: false,
        originalLanguage: 'en',
        originalTitle: 'Stranger Things',
        popularity: 1000.0,
        voteCount: 5000,
        video: false,
      ),
      Movie(
        id: 2,
        title: 'The Witcher',
        overview: 'Geralt of Rivia, a mutated monster-hunter for hire, journeys toward his destiny in a turbulent world where people often prove more wicked than beasts.',
        posterPath: '/placeholder.jpg',
        backdropPath: '/placeholder.jpg',
        voteAverage: 8.2,
        releaseDate: '2019-12-20',
        genreIds: [18, 10759, 10765],
        adult: false,
        originalLanguage: 'en',
        originalTitle: 'The Witcher',
        popularity: 900.0,
        voteCount: 4500,
        video: false,
      ),
      Movie(
        id: 3,
        title: 'Money Heist',
        overview: 'To carry out the biggest heist in history, a mysterious man called The Professor recruits a band of eight robbers who have a single characteristic: none of them has anything to lose.',
        posterPath: '/placeholder.jpg',
        backdropPath: '/placeholder.jpg',
        voteAverage: 8.3,
        releaseDate: '2017-05-02',
        genreIds: [80, 18],
        adult: false,
        originalLanguage: 'es',
        originalTitle: 'La Casa de Papel',
        popularity: 850.0,
        voteCount: 4200,
        video: false,
      ),
      Movie(
        id: 4,
        title: 'Dark',
        overview: 'A family saga with a supernatural twist, set in a German town, where the disappearance of two young children exposes the relationships among four families.',
        posterPath: '/placeholder.jpg',
        backdropPath: '/placeholder.jpg',
        voteAverage: 8.8,
        releaseDate: '2017-12-01',
        genreIds: [80, 18, 9648, 10765],
        adult: false,
        originalLanguage: 'de',
        originalTitle: 'Dark',
        popularity: 800.0,
        voteCount: 3800,
        video: false,
      ),
      Movie(
        id: 5,
        title: 'Ozark',
        overview: 'A financial advisor drags his family from Chicago to the Missouri Ozarks, where he must launder \$500 million in five years to appease a drug boss.',
        posterPath: '/placeholder.jpg',
        backdropPath: '/placeholder.jpg',
        voteAverage: 8.4,
        releaseDate: '2017-07-21',
        genreIds: [80, 18],
        adult: false,
        originalLanguage: 'en',
        originalTitle: 'Ozark',
        popularity: 750.0,
        voteCount: 3500,
        video: false,
      ),
    ];
  }
}