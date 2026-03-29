// lib/utils/constants.dart

import 'package:flutter/material.dart';

class Constants {
  // 🔑 API Keys
  static const String geminiApiKey = 'AIzaSyDW5GVSXrzqWdHbnyd9hCcD8xHVONVS9nk';
  static const String newsApiKey = 'cf8765960bf344119c2ff14301aade92';

  // 🎨 Colors
  static const Color primaryColor = Color(0xFF6366F1);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textColor = Color(0xFF1E293B);

  // ⚙️ SharedPreferences Keys
  static const String themeKey = 'is_dark_mode';
  static const String userNameKey = 'user_display_name'; // ADD THIS LINE

  // 📱 App Info
  static const String appName = 'SimpleNews AI';
  static const String appVersion = '1.0.0';
}
