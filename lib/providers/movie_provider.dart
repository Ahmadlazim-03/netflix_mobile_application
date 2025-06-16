import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Movie> _trendingMovies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _netflixOriginals = [];
  List<Movie> _searchResults = [];
  Movie? _featuredMovie;
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get netflixOriginals => _netflixOriginals;
  List<Movie> get searchResults => _searchResults;
  Movie? get featuredMovie => _featuredMovie;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadMovies() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      // Load different categories of movies
      _trendingMovies = await _apiService.getTrendingMovies();
      _popularMovies = await _apiService.getPopularMovies();
      _topRatedMovies = await _apiService.getTopRatedMovies();
      _netflixOriginals = await _apiService.getNetflixOriginals();
      
      // Set featured movie (first trending movie)
      if (_trendingMovies.isNotEmpty) {
        _featuredMovie = _trendingMovies.first;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchMovies(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchMovies(query);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchResults = [];
    notifyListeners();
  }
}