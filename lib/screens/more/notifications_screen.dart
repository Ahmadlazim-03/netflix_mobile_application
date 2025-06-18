import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('Notifications Screen', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}