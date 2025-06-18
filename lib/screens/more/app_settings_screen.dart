import 'package:flutter/material.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  // Variabel untuk menyimpan state dari setiap pengaturan
  bool _wifiOnlyDownload = true;
  bool _smartDownloads = true;
  String _videoQuality = 'Standard'; // Pilihan: Standard, Higher
  String _cellularDataUsage = 'Automatic'; // Pilihan: Automatic, Wi-Fi Only, Save Data

  // --- Helper untuk membangun judul seksi ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // --- Helper untuk membangun baris dengan switch ---
  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey)),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
      inactiveTrackColor: Colors.grey[700],
      tileColor: Colors.grey[900],
    );
  }

  // --- Helper untuk membangun baris yang bisa di-tap ---
  Widget _buildTappableTile({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      tileColor: Colors.grey[900],
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: Colors.grey)),
          SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }

  // --- Fungsi untuk menampilkan dialog pilihan kualitas video ---
  void _showVideoQualityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850],
          title: Text('Download Video Quality', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: Text('Standard', style: TextStyle(color: Colors.white)),
                subtitle: Text('Downloads faster, uses less storage', style: TextStyle(color: Colors.grey)),
                value: 'Standard',
                groupValue: _videoQuality,
                onChanged: (value) {
                  if (value != null) setState(() => _videoQuality = value);
                  Navigator.of(context).pop();
                },
                activeColor: Colors.red,
              ),
              RadioListTile<String>(
                title: Text('Higher', style: TextStyle(color: Colors.white)),
                subtitle: Text('Uses more storage', style: TextStyle(color: Colors.grey)),
                value: 'Higher',
                groupValue: _videoQuality,
                onChanged: (value) {
                  if (value != null) setState(() => _videoQuality = value);
                  Navigator.of(context).pop();
                },
                activeColor: Colors.red,
              ),
            ],
          ),
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('App Settings'),
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: ListView(
        children: [
          _buildSectionTitle('Video Playback'),
          _buildTappableTile(
            title: 'Cellular Data Usage',
            value: _cellularDataUsage,
            onTap: () { /* Tambahkan dialog untuk ini jika perlu */ },
          ),

          _buildSectionTitle('Downloads'),
          _buildSwitchTile(
            title: 'Wi-Fi Only',
            subtitle: 'Download content only when connected to Wi-Fi.',
            value: _wifiOnlyDownload,
            onChanged: (newValue) {
              setState(() {
                _wifiOnlyDownload = newValue;
              });
            },
          ),
          Divider(height: 1, color: Colors.black),
          _buildTappableTile(
            title: 'Download Video Quality',
            value: _videoQuality,
            onTap: _showVideoQualityDialog,
          ),
          Divider(height: 1, color: Colors.black),
          ListTile(
            tileColor: Colors.grey[900],
            title: Text('Delete All Downloads', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Tambahkan dialog konfirmasi sebelum menghapus semua download
            },
          ),

          _buildSectionTitle('About'),
          ListTile(
            tileColor: Colors.grey[900],
            title: Text('Privacy', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          Divider(height: 1, color: Colors.black),
          ListTile(
            tileColor: Colors.grey[900],
            title: Text('Terms of Use', style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          Divider(height: 1, color: Colors.black),
          ListTile(
            tileColor: Colors.grey[900],
            title: Text('Version', style: TextStyle(color: Colors.white)),
            trailing: Text('1.0.0 (Clone)', style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}