// lib/movie/movie_video_player.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../models/movie.dart';
import '../../services/movie_trailer_service.dart';

class MovieVideoPlayer extends StatefulWidget {
  final Movie movie;

  const MovieVideoPlayer({Key? key, required this.movie}) : super(key: key);

  @override
  _MovieVideoPlayerState createState() => _MovieVideoPlayerState();
}

class _MovieVideoPlayerState extends State<MovieVideoPlayer> {
  final MovieTrailerService _trailerService = MovieTrailerService();
  YoutubePlayerController? _controller;
  
  // State untuk melacak status loading
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // Mematikan UI system agar menjadi fullscreen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadTrailerAndInitializePlayer();
  }

  Future<void> _loadTrailerAndInitializePlayer() async {
    // Ambil key trailer dari service
    final trailerKey = await _trailerService.getBestTrailerKey(widget.movie.id);

    if (mounted) {
      if (trailerKey != null) {
        setState(() {
          _controller = YoutubePlayerController(
            initialVideoId: trailerKey,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
              forceHD: true, // Memaksa kualitas HD
              loop: false,
            ),
          );
          _isLoading = false;
          _hasError = false;
        });
      } else {
        // Jika tidak ada trailer ditemukan
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _buildPlayerContent(),
      ),
    );
  }

  Widget _buildPlayerContent() {
    if (_isLoading) {
      return const CircularProgressIndicator(color: Colors.red);
    }
    
    if (_hasError) {
      return _buildErrorWidget();
    }

    if (_controller != null) {
      // Widget YoutubePlayerUI akan menyediakan semua kontrol yang dibutuhkan
      return YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        onReady: () {
          print('🎬 Player is ready.');
        },
      );
    }
    
    return _buildErrorWidget(); // Fallback jika controller null karena suatu alasan
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 80),
          const SizedBox(height: 20),
          Text(
            'Trailer Not Available',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            'We couldn\'t find a trailer for "${widget.movie.title}".',
            style: TextStyle(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back),
            label: Text('Go Back'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Pastikan controller di-dispose
    _controller?.dispose();
    // Mengembalikan UI system ke mode normal saat keluar dari halaman
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }
}