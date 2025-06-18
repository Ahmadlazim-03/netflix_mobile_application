import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/movie_provider.dart';
import '../../../widgets/content_row.dart';
import '../../../widgets/featured_content.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        if (movieProvider.isLoading) {
          return Center(child: CircularProgressIndicator(color: Colors.red));
        }

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 500,
              floating: false,
              pinned: true,
              backgroundColor: Colors.black,
              flexibleSpace: FlexibleSpaceBar(
                background: FeaturedContent(
                  movie: movieProvider.featuredMovie,
                ),
              ),
              title: Row(
                children: [
                  Text(
                    'NETFLIX',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1.2,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.cast, color: Colors.white),
                    onPressed: () {},
                  ),
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 20),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                SizedBox(height: 20),
                ContentRow(
                  title: 'Trending Now',
                  movies: movieProvider.trendingMovies,
                ),
                ContentRow(
                  title: 'Netflix Originals',
                  movies: movieProvider.netflixOriginals,
                ),
                ContentRow(
                  title: 'Popular Movies',
                  movies: movieProvider.popularMovies,
                ),
                ContentRow(
                  title: 'Top Rated',
                  movies: movieProvider.topRatedMovies,
                ),
                SizedBox(height: 50),
              ]),
            ),
          ],
        );
      },
    );
  }
}