import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  // Helper untuk menampilkan dialog jawaban
  void _showHelpDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(title, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Text(content, style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.red[400])),
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
        title: Text('Help Center'),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          // Bagian Header
          Container(
            padding: EdgeInsets.all(24),
            color: Colors.grey[900],
            child: Column(
              children: [
                Text(
                  'How can we help?',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                // Kolom pencarian (simulasi)
                TextField(
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search for articles',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Bagian Topik Bantuan
          _buildSectionTitle('Popular Topics'),
          _buildHelpTile(
            context,
            icon: Icons.tv,
            title: 'How to watch Netflix on your TV',
            answer: 'You can watch Netflix through any internet-connected device that offers the Netflix app, such as smart TVs, game consoles, streaming media players, set-top boxes, Blu-ray players, smartphones, and tablets.',
          ),
          _buildHelpTile(
            context,
            icon: Icons.payment,
            title: 'How to manage your plan',
            answer: 'You can easily change your Netflix plan at any time. Sign in to your Netflix account on the web, go to the "Account" page and select "Change Plan" under Plan Details.',
          ),
          _buildHelpTile(
            context,
            icon: Icons.lock_reset,
            title: 'How to reset your password',
            answer: 'You can reset your password from the login page by selecting "Need help?" and following the instructions to receive a password reset email or text message.',
          ),

          Divider(color: Colors.grey[850], height: 40),

          // Bagian Kontak
          _buildSectionTitle('Contact Us'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSnackBar(context, 'Calling customer service... (simulation)'),
                    icon: Icon(Icons.call, color: Colors.white),
                    label: Text('Call Us', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showSnackBar(context, 'Starting live chat... (simulation)'),
                    icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
                    label: Text('Live Chat', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  // Widget helper untuk judul setiap seksi
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 12.0),
      child: Text(
        title,
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget helper untuk setiap item FAQ
  Widget _buildHelpTile(BuildContext context, {required IconData icon, required String title, required String answer}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[400]),
      title: Text(title, style: TextStyle(color: Colors.white)),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
      onTap: () => _showHelpDialog(context, title, answer),
    );
  }

  // Helper untuk menampilkan SnackBar simulasi
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue[800],
      ),
    );
  }
}