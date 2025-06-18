import 'package:flutter/material.dart';
import 'package:netflix_mobile_application/services/pocketbase_service.dart';
import 'package:provider/provider.dart';

import '../../../providers/movie_provider.dart';
import '../../../widgets/content_row.dart';
import '../../../widgets/featured_content.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _authService = PocketBaseService();
  Uri? _avatarUrl;
  String _userInitial = 'U';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    if (_authService.isLoggedIn) {
      final user = _authService.currentUser;
      if (user != null && mounted) {
        // Mengambil nama dan membuat huruf inisial sebagai fallback
        final userName = user.getStringValue('name').isNotEmpty 
            ? user.getStringValue('name')
            : user.getStringValue('email').split('@').first;

        setState(() {
          _avatarUrl = _authService.getUserAvatarUrl();
          if (userName.isNotEmpty) {
            _userInitial = userName[0].toUpperCase();
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, movieProvider, child) {
        if (movieProvider.isLoading && movieProvider.trendingMovies.isEmpty) {
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
                  movies: movieProvider.trendingMovies,
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
                  SizedBox(width: 10),
                  // --- AVATAR PENGGUNA YANG DINAMIS ---
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: Colors.blue,
                    backgroundImage: _avatarUrl != null 
                        ? NetworkImage(_avatarUrl.toString()) 
                        : null,
                    child: _avatarUrl == null
                        ? Text(
                            _userInitial,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
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