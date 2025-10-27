import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Rich blue palette
  static const Color primary = Color(0xFF3B82F6); // Rich blue
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  
  // Secondary Colors - Cyan-blue
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color secondaryDark = Color(0xFF0891B2);
  static const Color secondaryLight = Color(0xFF22D3EE);
  
  // Accent - Purple-blue
  static const Color accent = Color(0xFF6366F1); // Indigo
  static const Color accentDark = Color(0xFF4F46E5);
  
  // Status Colors - More saturated
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue
  
  // Slot Status Colors - Blue theme palette
  static const Color slotAvailable = Color(0xFF10B981);
  static const Color slotOccupied = Color(0xFF6B7280);
  static const Color slotReserved = Color(0xFF3B82F6);
  static const Color slotMaintenance = Color(0xFFF59E0B);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF0F172A); // Rich dark blue
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B); // Dark blue surface
  
  // Text Colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  
  // Charging Animation Colors - Blue gradient
  static const Color batteryEmpty = Color(0xFFEF4444);
  static const Color batteryLow = Color(0xFFF59E0B);
  static const Color batteryMedium = Color(0xFF3B82F6);
  static const Color batteryFull = Color(0xFF10B981);
  
  // Gradients
  static const LinearGradient chargingGradient = LinearGradient(
    colors: [batteryEmpty, batteryLow, batteryMedium, batteryFull],
    stops: [0.0, 0.33, 0.66, 1.0],
  );
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Dark mode cards
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkAccentGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Blue blur gradients
  static const LinearGradient blueBlurGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF334155), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
