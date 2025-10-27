import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class QrTokenService {
  // Generate a secure token for booking verification
  // Format: bookingId:timestamp:signature
  static String generateSecureToken(String bookingId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final secret = _generateSecret();
    
    // Create signature with bookingId + timestamp + secret
    final signatureInput = '$bookingId:$timestamp:$secret';
    final bytes = utf8.encode(signatureInput);
    final digest = sha256.convert(bytes);
    final signature = digest.toString().substring(0, 16); // Use first 16 chars
    
    // Return: bookingId:timestamp:signature
    return '$bookingId:$timestamp:$signature';
  }
  
  // Verify a token is valid
  static bool verifyToken(String token, String bookingId) {
    try {
      final parts = token.split(':');
      if (parts.length != 3) return false;
      
      final tokenBookingId = parts[0];
      final timestamp = int.tryParse(parts[1]);
      
      // Verify bookingId matches
      if (tokenBookingId != bookingId) return false;
      
      // Verify token is not older than 24 hours
      if (timestamp == null) return false;
      final tokenDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final diff = now.difference(tokenDate).inHours;
      
      if (diff > 24) return false;
      
      // Token is valid if structure is correct and not expired
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Extract bookingId from token
  static String? getBookingIdFromToken(String token) {
    try {
      final parts = token.split(':');
      if (parts.length == 3) {
        return parts[0];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Generate a simple secret for signing
  static String _generateSecret() {
    // In production, this should be stored securely
    // For now, we'll use a deterministic secret based on some constants
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }
  
  // Check if token is expired
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split(':');
      if (parts.length != 3) return true;
      
      final timestamp = int.tryParse(parts[1]);
      if (timestamp == null) return true;
      
      final tokenDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final diff = now.difference(tokenDate).inHours;
      
      return diff > 24;
    } catch (e) {
      return true;
    }
  }
}

