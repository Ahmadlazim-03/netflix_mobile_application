import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../models/movie.dart';
import '../../../services/api_service.dart';
import '../../../services/pocketbase_service.dart';

class ComingSoonTab extends StatefulWidget {
  const ComingSoonTab({Key? key}) : super(key: key);

  @override
  State<ComingSoonTab> createState() => _ComingSoonTabState();
}

class _ComingSoonTabState extends State<ComingSoonTab> {
  late Future<List<Movie>> _upcomingMoviesFuture;
  final ApiService _apiService = ApiService();
  final PocketBaseService _pocketBaseService = PocketBaseService();

  // State untuk melacak film mana saja yang sudah di-set reminder-nya
  final Set<String> _remindedMovieIds = {};
  bool _remindersLoading = true;

  @override
  void initState() {
    super.initState();
    _upcomingMoviesFuture = _apiService.getUpcomingMovies();
    _loadMyReminderStatus();
  }

  // Mengambil status reminder dari backend saat halaman dimuat
  Future<void> _loadMyReminderStatus() async {
    if (!_pocketBaseService.isLoggedIn) {
      if (mounted) setState(() => _remindersLoading = false);
      return;
    }
    final reminders = await _pocketBaseService.getMyReminders();
    if (mounted) {
      setState(() {
        for (var record in reminders) {
          _remindedMovieIds.add(record.getStringValue('movie_id'));
        }
        _remindersLoading = false;
      });
    }
  }

  // Fungsi untuk menambah/menghapus reminder
  Future<void> _handleReminderToggle(Movie movie) async {
    if (_remindersLoading) return;
    if (!_pocketBaseService.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please log in to set reminders.')));
      return;
    }

    final movieId = movie.id.toString();
    final isReminded = _remindedMovieIds.contains(movieId);
    
    // Update UI secara optimis untuk respons yang cepat
    setState(() {
      if (isReminded) {
        _remindedMovieIds.remove(movieId);
      } else {
        _remindedMovieIds.add(movieId);
      }
    });

    try {
      if (isReminded) {
        await _pocketBaseService.removeReminder(movieId);
      } else {
        await _pocketBaseService.addReminder(
          movieId: movieId,
          movieTitle: movie.title,
          releaseDate: movie.releaseDate,
        );
      }
    } catch (e) {
      // Jika gagal, kembalikan UI ke state semula
      if(mounted) {
        setState(() {
          if (isReminded) {
            _remindedMovieIds.add(movieId);
          } else {
            _remindedMovieIds.remove(movieId);
          }
        });
      }
    }
  }
  
  String _formatReleaseDate(String date) {
    if (date.isEmpty) return 'Coming Soon';
    try {
      final dateTime = DateTime.parse(date);
      // Contoh: "Coming Thursday, Jun 19"
      return 'Coming ${DateFormat('EEEE, MMM d').format(dateTime)}';
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
      ),
      body: FutureBuilder<List<Movie>>(
        future: _upcomingMoviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.red));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load data: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No upcoming movies found.', style: TextStyle(color: Colors.white)));
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
    final bool isReminded = _remindedMovieIds.contains(movie.id.toString());

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
                        _formatReleaseDate(movie.releaseDate),
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
                    _buildActionButton(
                      icon: isReminded ? Icons.notifications_active : Icons.notifications_outlined,
                      label: isReminded ? 'Reminder On' : 'Remind Me',
                      onTap: () => _handleReminderToggle(movie),
                      isActive: isReminded,
                    ),
                    SizedBox(height: 24),
                    _buildActionButton(
                      icon: Icons.info_outline,
                      label: 'Info',
                      onTap: () {
                        // Tambahkan navigasi ke halaman detail jika perlu
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    final color = isActive ? Colors.blueAccent : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? color : Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }
}