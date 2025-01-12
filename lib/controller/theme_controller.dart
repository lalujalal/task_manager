// lib/controller/theme_controller.dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ThemeController extends GetxController {
  // Default theme mode
  bool isDarkMode = false;

  // Method to toggle theme
  void toggleTheme() {
    isDarkMode = !isDarkMode;
    update(); // Notify listeners to rebuild
  }

  // Get the current theme data
  ThemeData get themeData {
    return isDarkMode ? darkTheme : lightTheme;
  }

  // Define light and dark themes
  final lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.light,
  );

  final darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    brightness: Brightness.dark,
  );
}
