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
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _loadTrailerAndInitializePlayer();
  }

  Future<void> _loadTrailerAndInitializePlayer() async {
    try {
      final trailerKey = await _trailerService.getBestTrailerKey(widget.movie.id);

      if (mounted) {
        if (trailerKey != null) {
          _controller = YoutubePlayerController(
            initialVideoId: trailerKey,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              // --- PERBAIKAN DI SINI: Kembalikan ke TRUE untuk Windows ---
              mute: true, 
              forceHD: true,
              loop: false,
              controlsVisibleAtStart: true, // Tampilkan kontrol di awal
            ),
          );
          setState(() => _isLoading = false);
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Trailer for "${widget.movie.title}" not available.';
          });
        }
      }
    } catch(e) {
       if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load trailer. Please check your connection.';
          });
       }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.red)
          : _errorMessage != null
            ? _buildErrorWidget()
            : YoutubePlayer(
                controller: _controller!,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.red,
                progressColors: const ProgressBarColors(
                  playedColor: Colors.red,
                  handleColor: Colors.redAccent,
                ),
                // Tombol kembali manual jika diperlukan
                topActions: [
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 25.0),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 20),
          Text(
            _errorMessage ?? 'An unknown error occurred.',
            style: TextStyle(color: Colors.white, fontSize: 18),
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
}