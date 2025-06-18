import 'package:flutter/material.dart';
import '../../services/pocketbase_service.dart'; // Sesuaikan path jika perlu

class MoreTab extends StatefulWidget {
  const MoreTab({Key? key}) : super(key: key);

  @override
  State<MoreTab> createState() => _MoreTabState();
}

class _MoreTabState extends State<MoreTab> {
  final _authService = PocketBaseService();

  String _userEmail = 'Loading...';
  String _userName = 'User';
  Uri? _avatarUrl; 


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null && mounted) {
      setState(() {
        _userEmail = user.getStringValue('email');
        final nameFromData = user.getStringValue('name');
        _userName = nameFromData.isNotEmpty ? nameFromData : _userEmail.split('@').first;
        _avatarUrl = _authService.getUserAvatarUrl(); 
      });
    } else {
      if (mounted) {
        setState(() {
          _userEmail = "Not logged in";
          _userName = "Guest";
        });
      }
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Sign Out', style: TextStyle(color: Colors.white)),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                _authService.logout();
                Navigator.of(dialogContext).pop();
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
              child: Text('Sign Out', style: TextStyle(color: Colors.red)),
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
        title: Text('More'),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue,
                  backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl.toString()) : null,
                  child: _avatarUrl == null 
                      ? Text(
                          _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                          style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        _userEmail,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Divider(color: Colors.grey[850]),
          ...[
            {'icon': Icons.person_outline, 'label': 'Account'},
            {'icon': Icons.notifications_none_outlined, 'label': 'Notifications'},
            {'icon': Icons.check, 'label': 'My List'},
            {'icon': Icons.settings_outlined, 'label': 'App Settings'},
            {'icon': Icons.help_outline, 'label': 'Help'},
            {'icon': Icons.logout, 'label': 'Sign Out'},
          ].map((item) {
            return ListTile(
              leading: Icon(item['icon'] as IconData, color: Colors.grey[400]),
              title: Text(item['label'] as String, style: TextStyle(color: Colors.white, fontSize: 16)),
              trailing: Icon(Icons.chevron_right, color: Colors.grey[600]),
              onTap: () {
                if (item['label'] == 'Sign Out') {
                  _showSignOutDialog(context);
                }
              },
            );
          }).toList(),
        ],
      ),
    );
  }
}