import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../../services/pocketbase_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _pocketBaseService = PocketBaseService();
  late Future<List<RecordModel>> _remindersFuture;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  // Fungsi untuk memuat atau memuat ulang data
  void _loadReminders() {
    setState(() {
      _remindersFuture = _pocketBaseService.getMyReminders();
    });
  }

  // --- FUNGSI BARU UNTUK MENGHAPUS NOTIFIKASI ---
  Future<void> _handleDelete(String movieId) async {
    try {
      await _pocketBaseService.removeReminder(movieId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reminder removed.'), backgroundColor: Colors.green[700]),
        );
        // Panggil _loadReminders() untuk me-refresh daftar di UI
        _loadReminders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove reminder.'), backgroundColor: Colors.red[700]),
        );
      }
    }
  }

  String _formatDate(String date) {
    if (date.isEmpty) return 'TBA';
    try {
      final dateTime = DateTime.parse(date);
      // Contoh: "June 19, 2025"
      return DateFormat('MMMM d, yyyy').format(dateTime);
    } catch (_) {
      return 'Date unavailable';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.black,
        actions: [
          // Tombol refresh manual
          IconButton(
            tooltip: 'Refresh Notifications',
            icon: Icon(Icons.refresh),
            onPressed: _loadReminders,
          ),
        ],
      ),
      body: FutureBuilder<List<RecordModel>>(
        future: _remindersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.red));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'You have no new notifications.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }

          final reminders = snapshot.data!;
          return ListView.builder(
            itemCount: reminders.length,
            itemBuilder: (context, index) {
              final reminder = reminders[index];
              final title = reminder.getStringValue('movie_title');
              final movieId = reminder.getStringValue('movie_id');
              final releaseDate = _formatDate(reminder.getStringValue('release_date'));

              return Container(
                color: index == 0 ? Colors.grey[900] : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notifications_active, color: Colors.blueAccent, size: 32),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reminder Set', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(
                            '"$title" is coming on $releaseDate.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    // --- TOMBOL HAPUS BARU ---
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.grey),
                      tooltip: 'Delete Reminder',
                      onPressed: () => _handleDelete(movieId),
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