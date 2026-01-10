import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF00BCD4); // Teal
  static const Color primaryDark = Color(0xFF0097A7);
  static const Color primaryLight = Color(0xFF4DD0E1);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF4CAF50); // Green
  static const Color secondaryDark = Color(0xFF388E3C);
  static const Color secondaryLight = Color(0xFF81C784);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Slot Status Colors
  static const Color slotAvailable = Color(0xFF4CAF50);
  static const Color slotOccupied = Color(0xFF9E9E9E);
  static const Color slotReserved = Color(0xFF2196F3);
  static const Color slotMaintenance = Color(0xFFFF9800);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  // Charging Animation Colors
  static const Color batteryEmpty = Color(0xFFF44336);
  static const Color batteryLow = Color(0xFFFF9800);
  static const Color batteryMedium = Color(0xFFFFEB3B);
  static const Color batteryFull = Color(0xFF4CAF50);
  
  // Gradients
  static const LinearGradient chargingGradient = LinearGradient(
    colors: [batteryEmpty, batteryLow, batteryMedium, batteryFull],
    stops: [0.0, 0.33, 0.66, 1.0],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
