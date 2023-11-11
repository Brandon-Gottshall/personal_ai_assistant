// lib/main.dart

import 'package:flutter/material.dart';
import 'Pages/AssistantHomePage/assistant_home_page.dart';  // Import AssistantHomePage
import 'Pages/Settings_Page/settings_page.dart';  // Import Settings

void main() {
  runApp(const MyAIAssistantApp());
}

class MyAIAssistantApp extends StatelessWidget {
  const MyAIAssistantApp({Key? key}) : super(key: key); // Add key parameter


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Assistant',
      home: const AssistantHomePage(),
      routes: {
        '/settings': (context) => const SettingsPage(), // Add route for SettingsPage
      },
    );
  }
}
