import 'package:flutter/material.dart';

class MyListScreen extends StatelessWidget {
  const MyListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('My List'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Text('My List Screen', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}