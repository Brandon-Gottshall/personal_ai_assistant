import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key); // Add key parameter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Setting 1'),
            onTap: () {
              // Handle tap for Setting 1
            },
          ),
          ListTile(
            title: const Text('Setting 2'),
            onTap: () {
              // Handle tap for Setting 2
            },
          ),
          // Add more ListTile widgets for more settings options
        ],
      ),
    );
  }
}