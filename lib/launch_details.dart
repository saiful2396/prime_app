import 'package:flutter/material.dart';

class LaunchDetails extends StatelessWidget {
  String? body;

  LaunchDetails({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Launch Details'), centerTitle: true),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(body.toString()),
          ),
        ),
      ),
    );
  }
}
