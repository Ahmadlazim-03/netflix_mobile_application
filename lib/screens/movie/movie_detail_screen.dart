import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

import '../../models/movie.dart';
import '../../providers/movie_provider.dart';
import '../../services/movie_trailer_service.dart';
import '../../services/pocketbase_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/content_row.dart';
import 'movie_video_player.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieDetailScreenState createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showAppBarTitle = false;
  
  // Instance Service
  final _pocketBaseService = PocketBaseService();
  final _trailerService = MovieTrailerService();
  
  // State untuk tombol-tombol interaksi
  bool _isLiked = false;
  bool _isDisliked = false;
  bool _isMyListStatusLoading = true;
  bool _isInMyList = false;
  
  // State untuk fungsionalitas Download
  bool _isDownloaded = false;
  bool _isDownloadStatusLoading = true;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Memanggil fungsi pengecekan saat halaman dimuat
    _checkIfDownloaded();
    _checkMyListStatus();
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 300 && !_showAppBarTitle) {
      if(mounted) setState(() => _showAppBarTitle = true);
      _animationController.forward();
    } else if (_scrollController.offset <= 300 && _showAppBarTitle) {
      if(mounted) setState(() => _showAppBarTitle = false);
      _animationController.reverse();
    }
  }

  // --- FUNGSI-FUNGSI LOGIKA ---

  Future<void> _checkMyListStatus() async {
    if (!_pocketBaseService.isLoggedIn) {
      if (mounted) setState(() => _isMyListStatusLoading = false);
      return;
    }
    final result = await _pocketBaseService.isInMyList(widget.movie.id.toString());
    if (mounted) {
      setState(() {
        _isInMyList = result;
        _isMyListStatusLoading = false;
      });
    }
  }

  Future<void> _handleMyListToggle() async {
    if (!_pocketBaseService.isLoggedIn) {
      _showSnackBar('Please log in to use My List.');
      return;
    }

    final originalState = _isInMyList;
    setState(() => _isInMyList = !originalState); // Optimistic UI update

    try {
      if (originalState) {
        await _pocketBaseService.removeFromMyList(widget.movie.id.toString());
        _showSnackBar('Removed from My List');
      } else {
        await _pocketBaseService.addToMyList(widget.movie.id.toString());
        _showSnackBar('Added to My List');
      }
    } catch (e) {
      setState(() => _isInMyList = originalState); // Revert on error
      _showSnackBar('An error occurred. Please try again.', isError: true);
    }
  }
  
  Future<void> _checkIfDownloaded() async {
    if (!_pocketBaseService.isLoggedIn) {
      if(mounted) setState(() => _isDownloadStatusLoading = false);
      return;
    }
    final result = await _pocketBaseService.isMovieDownloaded(widget.movie.id.toString());
    if (mounted) {
      setState(() {
        _isDownloaded = result;
        _isDownloadStatusLoading = false;
      });
    }
  }

  Future<void> _handleDownload() async {
    if (!_pocketBaseService.isLoggedIn) {
      _showSnackBar('Please log in to download movies.');
      return;
    }
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final trailerKey = await _trailerService.getBestTrailerKey(widget.movie.id);
      if (trailerKey == null) {
        throw Exception('No trailer found for this movie.');
      }

      await _pocketBaseService.addMovieToDownloads(
        movieId: widget.movie.id.toString(),
        trailerKey: trailerKey,
        onReceiveProgress: (count, total) {
          if (total != -1 && mounted) {
            setState(() {
              _downloadProgress = count / total;
            });
          }
        },
      );
      if (mounted) {
        _showSnackBar('Movie downloaded successfully!');
        setState(() {
          _isDownloaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceFirst("Exception: ", ""));
      }
    } finally {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
    }
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red[700] : Colors.grey[800],
    ));
  }

  // --- WIDGET BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(),
          SliverList(
            delegate: SliverChildListDelegate([
              _buildMovieInfo(),
              _buildActionButtons(),
              _buildDescription(),
              _buildCastAndCrew(),
              _buildMoreLikeThis(),
              SizedBox(height: 50),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      backgroundColor: Colors.black,
      leading: Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
        child: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      title: _showAppBarTitle
          ? FadeTransition(opacity: _fadeAnimation, child: Text(widget.movie.title, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))
          : null,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: widget.movie.fullBackdropPath,
              fit: BoxFit.cover,
              placeholder: (c, u) => Center(child: CircularProgressIndicator(color: Colors.red)),
              errorWidget: (c, u, e) => Icon(Icons.error, color: Colors.white),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  stops: [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieInfo() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.movie.title, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Row(
            children: [
              Text('${(widget.movie.voteAverage * 10).toInt()}% Match', style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
              SizedBox(width: 16),
              Text(widget.movie.releaseDate.isNotEmpty ? widget.movie.releaseDate.split('-')[0] : 'N/A', style: TextStyle(color: Colors.white70, fontSize: 14)),
              SizedBox(width: 16),
              Container(padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2)), child: Text('HD', style: TextStyle(color: Colors.white70, fontSize: 12))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity, height: 45,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MovieVideoPlayer(movie: widget.movie))),
              icon: Icon(Icons.play_arrow, color: Colors.black, size: 28),
              label: Text('Play', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 45,
            child: ElevatedButton.icon(
              onPressed: _isDownloaded || _isDownloadStatusLoading || _isDownloading ? null : _handleDownload,
              icon: _isDownloading ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(value: _downloadProgress > 0 ? _downloadProgress : null, color: Colors.white, strokeWidth: 2.5)) : Icon(_isDownloaded ? Icons.check_circle_outline : Icons.download, color: Colors.white),
              label: Text(_isDownloadStatusLoading ? 'Checking...' : (_isDownloading ? 'Downloading ${(_downloadProgress * 100).toStringAsFixed(0)}%' : (_isDownloaded ? 'Downloaded' : 'Download')), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.withOpacity(0.3), disabledBackgroundColor: Colors.grey.withOpacity(0.2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            ),
          ),
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionIcon(
                icon: _isMyListStatusLoading ? Icons.hourglass_empty : (_isInMyList ? Icons.check : Icons.add),
                label: 'My List',
                onTap: _isMyListStatusLoading ? () {} : _handleMyListToggle,
              ),
              _buildActionIcon(icon: _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined, label: 'Rate', onTap: () => setState(() { _isLiked = !_isLiked; _isDisliked = false; })),
              _buildActionIcon(icon: _isDisliked ? Icons.thumb_down : Icons.thumb_down_alt_outlined, label: 'Not for me', onTap: () => setState(() { _isDisliked = !_isDisliked; _isLiked = false; })),
              _buildActionIcon(icon: Icons.share, label: 'Share', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: 6),
          Text(label, style: TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Text(widget.movie.overview, style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
    );
  }

  Widget _buildCastAndCrew() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: _buildInfoRow('Starring:', 'Millie Bobby Brown, Finn Wolfhard, etc.'),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.white70, fontSize: 12),
        children: [TextSpan(text: label), TextSpan(text: ' $value', style: TextStyle(color: Colors.white))],
      ),
    );
  }

  Widget _buildMoreLikeThis() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Consumer<MovieProvider>(
        builder: (context, movieProvider, child) {
          return ContentRow(
            title: 'More Like This',
            movies: movieProvider.popularMovies.where((m) => m.id != widget.movie.id).toList(),
          );
        },
      ),
    );
  }
}