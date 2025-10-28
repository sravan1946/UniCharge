import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Script to populate Firestore with sample data
/// Run with: dart lib/scripts/add_sample_data.dart

void main() async {
  try {
    print('🚀 Initializing Firebase...');
    await Firebase.initializeApp();
    
    print('✓ Firebase initialized');
    
    // Check if user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('⚠️  Warning: No user logged in. Data will be added anonymously.');
    } else {
      print('✓ User: ${user.email}');
    }
    
    final firestore = FirebaseFirestore.instance;
    
    print('\n📦 Adding stations...\n');
    
    final stationsJson = _getSampleStations();
    
    for (var stationData in stationsJson) {
      final stationRef = firestore.collection('stations').doc();
      final stationId = stationRef.id;
      
      await stationRef.set({
        ...stationData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      print('✓ Added: ${stationData['name']}');
      
      // Add slots for this station
      final totalSlots = stationData['totalSlots'] as int;
      final stationType = stationData['type'] as String;
      
      for (int i = 0; i < totalSlots; i++) {
        final slotType = _getSlotType(stationType, i, totalSlots);
        final isAvailable = i < (totalSlots * 0.8).floor();
        
        final slotData = {
          'stationId': stationId,
          'slotIndex': i,
          'type': slotType,
          'status': isAvailable ? 'available' : 'occupied',
          'lastUpdated': FieldValue.serverTimestamp(),
        };
        
        // Add battery status for charging pads
        if (slotType == 'chargingPad') {
          slotData['batteryStatus'] = _getRandomBatteryStatus(i);
        }
        
        // Occasional reservations
        if (isAvailable && i % 5 == 0) {
          slotData['status'] = 'reserved';
          final reservedUntil = DateTime.now().add(Duration(hours: 3));
          slotData['reservedUntil'] = Timestamp.fromDate(reservedUntil);
        }
        
        await firestore.collection('slots').add(slotData);
      }
      
      print('  ✓ Added $totalSlots slots\n');
    }
    
    print('\n📋 Adding sample bookings...\n');
    
    // Add sample bookings for testing
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final stations = await firestore.collection('stations').limit(3).get();
      final slots = await firestore.collection('slots').limit(3).get();
      
      if (stations.docs.isNotEmpty && slots.docs.isNotEmpty) {
        final stationId = stations.docs.first.id;
        final slotId = slots.docs.first.id;
        
        // Add a completed booking
        await firestore.collection('bookings').add({
          'userId': user.uid,
          'stationId': stationId,
          'slotId': slotId,
          'startTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2, hours: 2))),
          'endTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
          'durationHours': 2,
          'pricePerHour': 50.0,
          'totalPrice': 100.0,
          'status': 'completed',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Add an active booking
        await firestore.collection('bookings').add({
          'userId': user.uid,
          'stationId': stationId,
          'slotId': slotId,
          'startTime': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1))),
          'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 1))),
          'durationHours': 2,
          'pricePerHour': 50.0,
          'totalPrice': 100.0,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        print('✓ Added sample bookings');
      }
    }
    
    print('${'=' * 60}');
    print('✅ Sample data added successfully!');
    print('${'=' * 60}\n');
    
    exit(0);
  } catch (e, stackTrace) {
    print('❌ Error: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

List<Map<String, dynamic>> _getSampleStations() {
  return [
    {
      'name': 'Central Plaza Charging Hub',
      'address': '123 Main Street, Bangalore, Karnataka 560001',
      'latitude': 12.9716,
      'longitude': 77.5946,
      'type': 'hybrid',
      'pricePerHour': 50.0,
      'batterySwap': true,
      'totalSlots': 20,
      'availableSlots': 15,
      'imageUrl': 'https://images.unsplash.com/photo-1593941707882-a5bac6861d08?w=800',
      'amenities': ['Restrooms', 'Cafe', 'EV Charging', 'WiFi', 'Security'],
    },
    {
      'name': 'Tech Park Station',
      'address': '456 Tech Drive, Whitefield, Bangalore 560066',
      'latitude': 12.9698,
      'longitude': 77.7500,
      'type': 'charging',
      'pricePerHour': 60.0,
      'batterySwap': false,
      'totalSlots': 15,
      'availableSlots': 12,
      'imageUrl': 'https://images.unsplash.com/photo-1616679605464-6c8de5bae404?w=800',
      'amenities': ['WiFi', 'ATM', 'Parking', '24/7 Service'],
    },
    {
      'name': 'MG Road Parking Plaza',
      'address': '789 MG Road, Bangalore 560025',
      'latitude': 12.9719,
      'longitude': 77.6099,
      'type': 'parking',
      'pricePerHour': 30.0,
      'batterySwap': false,
      'totalSlots': 30,
      'availableSlots': 25,
      'imageUrl': 'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
      'amenities': ['Security', 'Restrooms', 'Covered Parking'],
    },
    {
      'name': 'Indiranagar Smart Station',
      'address': '321 100 Feet Road, Indiranagar, Bangalore 560038',
      'latitude': 12.9784,
      'longitude': 77.6408,
      'type': 'hybrid',
      'pricePerHour': 55.0,
      'batterySwap': true,
      'totalSlots': 18,
      'availableSlots': 10,
      'imageUrl': 'https://images.unsplash.com/photo-1504384308090-c894fd734ba4?w=800',
      'amenities': ['Charging', 'Battery Swap', 'Security', 'WiFi'],
    },
    {
      'name': 'Airport Express Charging',
      'address': 'Near Kempegowda Airport, Bangalore 560300',
      'latitude': 13.1986,
      'longitude': 77.7066,
      'type': 'charging',
      'pricePerHour': 70.0,
      'batterySwap': true,
      'totalSlots': 25,
      'availableSlots': 20,
      'imageUrl': 'https://images.unsplash.com/photo-1547525842-54dd3ea5517d?w=800',
      'amenities': ['Restrooms', 'Restaurant', 'Free WiFi', '24/7 Service', 'Battery Swap'],
    },
    {
      'name': 'Koramangala Parking Complex',
      'address': '234 6th Block, Koramangala, Bangalore 560095',
      'latitude': 12.9352,
      'longitude': 77.6245,
      'type': 'parking',
      'pricePerHour': 35.0,
      'batterySwap': false,
      'totalSlots': 40,
      'availableSlots': 35,
      'imageUrl': 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800',
      'amenities': ['Covered Parking', 'Security', 'Restrooms', 'Water Facility'],
    },
  ];
}

String _getSlotType(String stationType, int index, int totalSlots) {
  if (stationType == 'parking') {
    return 'parkingSpace';
  } else if (stationType == 'charging') {
    return 'chargingPad';
  } else {
    // hybrid: mix of both
    if (index < totalSlots / 2) {
      return 'chargingPad';
    } else {
      return 'parkingSpace';
    }
  }
}

String _getRandomBatteryStatus(int index) {
  final statuses = ['charged', 'charging', 'empty'];
  return statuses[index % 3];
}

