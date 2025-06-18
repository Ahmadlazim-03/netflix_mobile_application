import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/movie.dart';
import '../screens/movie/movie_detail_screen.dart';
import '../screens/movie/movie_video_player.dart';
import '../services/pocketbase_service.dart';

class FeaturedContent extends StatefulWidget {
  final List<Movie> movies;

  const FeaturedContent({Key? key, required this.movies}) : super(key: key);

  @override
  State<FeaturedContent> createState() => _FeaturedContentState();
}

class _FeaturedContentState extends State<FeaturedContent> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  final _pocketBaseService = PocketBaseService();
  final Set<String> _myListMovieIds = {};
  bool _isMyListLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    if (widget.movies.length > 1) {
      _startTimer();
    }
    _loadMyListStatus();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (Timer timer) {
      if (!mounted) return;
      
      // Hitung halaman berikutnya, kembali ke 0 jika sudah di akhir
      _currentPage = (_currentPage + 1) % widget.movies.length;

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadMyListStatus() async {
    if (!_pocketBaseService.isLoggedIn) {
      if (mounted) setState(() => _isMyListLoading = false);
      return;
    }
    final myList = await _pocketBaseService.getMyListMovies();
    if (mounted) {
      setState(() {
        for (var movie in myList) {
          _myListMovieIds.add(movie.id.toString());
        }
        _isMyListLoading = false;
      });
    }
  }

  Future<void> _handleMyListToggle(Movie movie) async {
    if (_isMyListLoading || !_pocketBaseService.isLoggedIn) return;

    final movieId = movie.id.toString();
    final isInMyList = _myListMovieIds.contains(movieId);

    setState(() {
      if (isInMyList) {
        _myListMovieIds.remove(movieId);
      } else {
        _myListMovieIds.add(movieId);
      }
    });

    try {
      if (isInMyList) {
        await _pocketBaseService.removeFromMyList(movieId);
      } else {
        await _pocketBaseService.addToMyList(movieId);
      }
    } catch (e) {
      // Jika gagal, kembalikan state UI ke semula
      if(mounted) {
        setState(() {
          if (isInMyList) {
            _myListMovieIds.add(movieId);
          } else {
            _myListMovieIds.remove(movieId);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return Container(height: 500, color: Colors.black);
    }
    
    return SizedBox(
      height: 500,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.movies.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return _buildFeaturedItem(context, movie);
            },
          ),
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.movies.length, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  height: 8.0,
                  width: _currentPage == index ? 24.0 : 8.0,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.white : Colors.grey.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedItem(BuildContext context, Movie movie) {
    final bool isInMyList = _myListMovieIds.contains(movie.id.toString());

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie))),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: movie.fullBackdropPath,
            fit: BoxFit.cover,
            placeholder: (c, u) => Container(color: Colors.black),
            errorWidget: (c, u, e) => Container(color: Colors.black),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.transparent, Colors.black],
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 60,
            child: Column(
              children: [
                Text(
                  movie.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black.withOpacity(0.7))],
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  movie.overview,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    height: 1.4,
                    shadows: [Shadow(blurRadius: 5, color: Colors.black.withOpacity(0.7))],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(
                      icon: _isMyListLoading ? Icons.hourglass_empty : (isInMyList ? Icons.check : Icons.add),
                      label: 'My List',
                      onTap: () => _handleMyListToggle(movie),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => MovieVideoPlayer(movie: movie)),
                        );
                      },
                      icon: Icon(Icons.play_arrow, color: Colors.black, size: 28),
                      label: Text('Play', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    SizedBox(width: 20),
                    _buildActionButton(
                      icon: Icons.info_outline,
                      label: 'Info',
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 30),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}