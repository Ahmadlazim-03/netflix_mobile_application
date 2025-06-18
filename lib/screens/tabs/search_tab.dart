import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/movie.dart';
import '../../screens/movie/movie_detail_screen.dart'; // Import halaman detail
import '../../../providers/movie_provider.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Tambahkan listener untuk mendeteksi perubahan pada TextField
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Hapus listener dan controller untuk mencegah memory leak
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fungsi yang dipanggil setiap kali teks di search bar berubah
  void _onSearchChanged() {
    // Batalkan timer sebelumnya jika ada
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Buat timer baru. Jika tidak ada ketikan baru selama 500ms,
    // maka jalankan pencarian.
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        final query = _searchController.text;
        // Panggil fungsi search di MovieProvider
        Provider.of<MovieProvider>(context, listen: false).searchMovies(query);
      }
    });
  }

  Widget _buildSearchResults(MovieProvider movieProvider) {
    // Tampilan jika hasil pencarian ditemukan
    if (movieProvider.searchResults.isEmpty) {
      return Center(
        child: Text(
          'No results found for "${_searchController.text}"',
          style: TextStyle(color: Colors.grey, fontSize: 18),
        ),
      );
    }
    
    return GridView.builder(
      padding: EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2 / 3,
      ),
      itemCount: movieProvider.searchResults.length,
      itemBuilder: (context, index) {
        final movie = movieProvider.searchResults[index];
        return _buildMovieItem(context, movie);
      },
    );
  }

  Widget _buildTopSearches(MovieProvider movieProvider) {
    // Tampilan awal sebelum pengguna melakukan pencarian
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Text('Top Searches', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: movieProvider.popularMovies.length,
            itemBuilder: (context, index) {
              final movie = movieProvider.popularMovies[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie))),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Image.network(movie.fullBackdropPath, width: 140, height: 80, fit: BoxFit.cover),
                      SizedBox(width: 16),
                      Expanded(child: Text(movie.title, style: TextStyle(color: Colors.white, fontSize: 16))),
                      Icon(Icons.play_circle_outline, color: Colors.white, size: 30),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieItem(BuildContext context, Movie movie) {
    // Widget untuk setiap item di dalam GridView, sekarang bisa diklik
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail saat poster film diklik
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          movie.fullPosterPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) => Container(color: Colors.grey[900]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          controller: _searchController, // Hubungkan controller ke TextField
          decoration: InputDecoration(
            hintText: 'Search for a show, movie, genre, etc.',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.grey[850],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
            suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () {
                    _searchController.clear(); // Tombol untuk menghapus teks
                  },
                )
              : null,
          ),
          style: TextStyle(color: Colors.white),
          autofocus: true,
        ),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: Colors.red));
          }
          // Logika untuk menampilkan hasil pencarian atau tampilan awal
          if (_searchController.text.isNotEmpty) {
            return _buildSearchResults(movieProvider);
          } else {
            return _buildTopSearches(movieProvider);
          }
        },
      ),
    );
  }
}