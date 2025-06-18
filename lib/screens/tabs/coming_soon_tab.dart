import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../models/movie.dart';
import '../../../services/api_service.dart';
import '../../../services/pocketbase_service.dart'; // Import service PocketBase

class ComingSoonTab extends StatefulWidget {
  const ComingSoonTab({Key? key}) : super(key: key);

  @override
  State<ComingSoonTab> createState() => _ComingSoonTabState();
}

class _ComingSoonTabState extends State<ComingSoonTab> {
  late Future<List<Movie>> _upcomingMoviesFuture;
  final ApiService _apiService = ApiService();

  // --- TAMBAHAN BARU UNTUK AVATAR ---
  final _authService = PocketBaseService();
  Uri? _avatarUrl;
  String _userInitial = 'U';
  // ------------------------------------

  @override
  void initState() {
    super.initState();
    // Ambil data film yang akan datang
    _upcomingMoviesFuture = _apiService.getUpcomingMovies();
    // Ambil juga data pengguna untuk avatar
    _loadUserData();
  }

  // --- FUNGSI BARU UNTUK MENGAMBIL DATA AVATAR ---
  void _loadUserData() {
    if (_authService.isLoggedIn) {
      final user = _authService.currentUser;
      if (user != null && mounted) {
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
  // ---------------------------------------------

  String _formatReleaseDate(String date) {
    if (date.isEmpty) return 'TBA';
    try {
      final dateTime = DateTime.parse(date);
      return 'Coming ${DateFormat('EEEE, MMM d').format(dateTime)}'; // Contoh: "Coming Tuesday, Jun 19"
    } catch (_) {
      return 'Coming Soon';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Coming Soon'),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.cast)),
          // --- APPBAR ACTION DIPERBARUI ---
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.blue,
              backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl.toString()) : null,
              child: _avatarUrl == null
                  ? Text(
                      _userInitial,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ),
          // --------------------------------
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: _upcomingMoviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.red));
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Failed to load upcoming movies.', style: TextStyle(color: Colors.white)));
          }

          final movies = snapshot.data!;
          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _buildComingSoonItem(movie);
            },
          );
        },
      ),
    );
  }

  Widget _buildComingSoonItem(Movie movie) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedNetworkImage(
            imageUrl: movie.fullBackdropPath,
            fit: BoxFit.cover,
            height: 220,
            width: double.infinity,
            placeholder: (context, url) => Container(height: 220, color: Colors.grey[900]),
            errorWidget: (context, url, error) => Container(height: 220, color: Colors.grey[900], child: Icon(Icons.error)),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _formatReleaseDate(movie.releaseDate), // Menggunakan helper format tanggal
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        movie.overview,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[400], fontSize: 14, height: 1.4),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  children: [
                    _buildActionButton(icon: Icons.notifications_outlined, label: 'Remind Me'),
                    SizedBox(height: 24),
                    _buildActionButton(icon: Icons.info_outline, label: 'Info'),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label}) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}