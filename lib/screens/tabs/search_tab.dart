import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/movie.dart';
import '../../../providers/movie_provider.dart';

class SearchTab extends StatelessWidget {
  const SearchTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search for a show, movie, genre, etc.',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
            filled: true,
            fillColor: Colors.grey[850],
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          if (movieProvider.isLoading) {
            return Center(child: CircularProgressIndicator(color: Colors.red));
          }
          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2 / 3,
            ),
            itemCount: movieProvider.popularMovies.length,
            itemBuilder: (context, index) {
              final movie = movieProvider.popularMovies[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  movie.fullPosterPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      Container(color: Colors.grey[900]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}