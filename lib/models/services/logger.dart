// lib/models/services/logger.dart
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';


class LoggerService {
  // Private constructor
  LoggerService._privateConstructor();

  // Singleton instance
  static final LoggerService _instance = LoggerService._privateConstructor();

  // Factory constructor to return the same instance
  factory LoggerService() {
    return _instance;
  }

  Future<void> _logToFile(String message) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/app_logs.txt');
    await file.writeAsString('$message\n', mode: FileMode.append);
  }

  // Method to log messages
  void log(String message) {
    if (kDebugMode) {
      print(message); // For development
      // In production, you might want to integrate with a logging framework
    } else {
      _logToFile(message); // For production
    }
  }
}
