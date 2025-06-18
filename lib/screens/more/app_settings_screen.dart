import 'package:flutter/material.dart';

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('App Settings'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('App Settings Screen', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}