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
          // This setting get's permissions for Apple Reminders
          ListTile(
            title: const Text('Reminders Permissions'),
            tileColor: Colors.grey[300],
            onTap: () {
              // Handle tap for Apple Reminders
            },
          ),
          // Add more ListTile widgets for more settings options
        ],
      ),
    );
  }
}