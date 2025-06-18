import 'package:flutter/material.dart';
import '../../models/movie.dart';
import '../../services/pocketbase_service.dart';

class DownloadsTab extends StatefulWidget {
  const DownloadsTab({Key? key}) : super(key: key);

  @override
  State<DownloadsTab> createState() => _DownloadsTabState();
}

class _DownloadsTabState extends State<DownloadsTab> {
  final _pocketBaseService = PocketBaseService();
  late Future<List<Movie>> _downloadedMoviesFuture;

  @override
  void initState() {
    super.initState();
    _loadDownloads();
  }

  void _loadDownloads() {
    setState(() {
      _downloadedMoviesFuture = _pocketBaseService.getMyDownloads();
    });
  }

  Future<void> _handleDelete(String movieId) async {
    try {
      await _pocketBaseService.deleteDownloadedMovie(movieId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download removed.'), backgroundColor: Colors.green),
        );
        _loadDownloads(); // Muat ulang daftar setelah berhasil dihapus
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDeleteConfirmationDialog(Movie movie) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Delete Download', style: TextStyle(color: Colors.white)),
          content: Text('Are you sure you want to delete "${movie.title}" from your downloads?', style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _handleDelete(movie.id.toString());
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('My Downloads'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            tooltip: 'Refresh List',
            icon: Icon(Icons.refresh),
            onPressed: _loadDownloads,
          ),
        ],
      ),
      body: FutureBuilder<List<Movie>>(
        future: _downloadedMoviesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.red));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_for_offline_outlined, size: 100, color: Colors.grey),
                  SizedBox(height: 20),
                  Text('No Downloads Yet', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          
          final downloadedMovies = snapshot.data!;
          return ListView.builder(
            itemCount: downloadedMovies.length,
            itemBuilder: (context, index) {
              final movie = downloadedMovies[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                child: Row(
                  children: [
                    Container(
                      width: 130,
                      height: 75,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        image: DecorationImage(image: NetworkImage(movie.fullPosterPath), fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(movie.title, style: TextStyle(color: Colors.white, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                          SizedBox(height: 4),
                          Text('Downloaded', style: TextStyle(color: Colors.blueAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => _showDeleteConfirmationDialog(movie),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}