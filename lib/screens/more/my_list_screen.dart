import 'package:flutter/material.dart';
import 'package:netflix_mobile_application/screens/movie/movie_detail_screen.dart';
import '../../../models/movie.dart';
import '../../../services/pocketbase_service.dart';

class MyListScreen extends StatefulWidget {
  const MyListScreen({Key? key}) : super(key: key);

  @override
  State<MyListScreen> createState() => _MyListScreenState();
}

class _MyListScreenState extends State<MyListScreen> {
  final _pocketBaseService = PocketBaseService();
  late Future<List<Movie>> _myListFuture;

  @override
  void initState() {
    super.initState();
    _myListFuture = _pocketBaseService.getMyListMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('My List'),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<List<Movie>>(
        future: _myListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.red));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Your list is empty.', style: TextStyle(color: Colors.white, fontSize: 18)));
          }
          
          final movies = snapshot.data!;
          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2 / 3,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    movie.fullPosterPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) => Container(color: Colors.grey[900]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}