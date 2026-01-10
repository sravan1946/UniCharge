import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_config.dart';

class DataInitializer {
  static Future<void> addSampleData() async {
    try {
      print('🚀 Starting to add sample data...');
      
      // Check if data already exists
      final snapshot = await FirebaseConfig.firestore.collection(FirebaseConfig.stationsCollection).limit(1).get();
      if (snapshot.docs.isNotEmpty) {
        print('Sample data already exists');
        return;
      }

      final stations = [
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
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
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
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
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
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
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
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
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
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
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
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      for (final stationData in stations) {
        final stationRef = FirebaseConfig.firestore.collection(FirebaseConfig.stationsCollection).doc();
        final stationId = stationRef.id;
        
        await stationRef.set(stationData);
        print('✓ Added: ${stationData['name']}');
        
        final totalSlots = stationData['totalSlots'] as int;
        final stationType = stationData['type'] as String;
        
        final slotTypes = <String>[];
        if (stationType == 'parking') {
          slotTypes.addAll(List.filled(totalSlots, 'parkingSpace'));
        } else if (stationType == 'charging') {
          slotTypes.addAll(List.filled(totalSlots, 'chargingPad'));
        } else {
          final chargingPads = (totalSlots / 2).floor();
          slotTypes.addAll(List.filled(chargingPads, 'chargingPad'));
          slotTypes.addAll(List.filled(totalSlots - chargingPads, 'parkingSpace'));
          slotTypes.shuffle();
        }
        
        for (int i = 0; i < totalSlots; i++) {
          final slotType = slotTypes[i];
          final isAvailable = i < (totalSlots * 0.8).floor();
          
          final slotData = {
            'stationId': stationId,
            'slotIndex': i,
            'type': slotType,
            'status': isAvailable ? 'available' : 'occupied',
            'lastUpdated': FieldValue.serverTimestamp(),
          };
          
          if (slotType == 'chargingPad') {
            final batteryStatuses = ['charged', 'charging', 'empty'];
            slotData['batteryStatus'] = batteryStatuses[i % 3];
          }
          
          if (isAvailable && i % 5 == 0) {
            slotData['status'] = 'reserved';
            final reservedUntil = DateTime.now().add(Duration(hours: 3));
            slotData['reservedUntil'] = Timestamp.fromDate(reservedUntil);
          }
          
          await FirebaseConfig.firestore.collection(FirebaseConfig.slotsCollection).add(slotData);
        }
        
        print('  ✓ Added $totalSlots slots');
      }
      
      print('✅ All sample data added!');
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }
}

