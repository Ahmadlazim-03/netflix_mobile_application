import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Help'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('Help Screen', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}