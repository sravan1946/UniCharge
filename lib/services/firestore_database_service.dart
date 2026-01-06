import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as Math;
import '../core/firebase_config.dart';
import '../models/station_model.dart';
import '../models/slot_model.dart';
import '../models/booking_model.dart';
import '../models/user_profile_model.dart';

class FirestoreDatabaseService {
  final FirebaseFirestore _firestore = FirebaseConfig.firestore;

  // Station operations
  Future<List<StationModel>> getNearbyStations({
    required double latitude,
    required double longitude,
    double radiusKm = 50.0, // Default increased
    bool showAll = false, // New parameter to show all stations
  }) async {
    try {
      print('Getting nearby stations...');
      final snapshot = await _firestore
          .collection(FirebaseConfig.stationsCollection)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      print('Stations fetched: ${snapshot.docs.length}');
      final stations = snapshot.docs.map((doc) {
        final data = doc.data();
        
        // Parse amenities from string to list if needed
        List<String> amenitiesList = [];
        if (data['amenities'] != null) {
          if (data['amenities'] is List) {
            amenitiesList = List<String>.from(data['amenities']);
          } else if (data['amenities'] is String) {
            amenitiesList = (data['amenities'] as String).split(',').map((s) => s.trim()).toList();
          }
        }
        
        final createdAt = data['createdAt'];
        final updatedAt = data['updatedAt'];
        
        return StationModel.fromJson({
          'id': doc.id,
          'name': data['name'],
          'address': data['address'],
          'latitude': (data['latitude'] is String) ? double.parse(data['latitude']) : data['latitude'],
          'longitude': (data['longitude'] is String) ? double.parse(data['longitude']) : data['longitude'],
          'type': _parseStationType(data['type']),
          'pricePerHour': (data['pricePerHour'] is String) ? double.parse(data['pricePerHour']) : data['pricePerHour'],
          'batterySwap': (data['batterySwap'] is String) ? data['batterySwap'] == 'true' : data['batterySwap'],
          'totalSlots': (data['totalSlots'] is String) ? int.parse(data['totalSlots']) : data['totalSlots'],
          'availableSlots': (data['availableSlots'] is String) ? int.parse(data['availableSlots']) : data['availableSlots'],
          'imageUrl': data['imageUrl'] ?? '',
          'amenities': amenitiesList,
          'createdAt': createdAt is Timestamp ? createdAt.toDate().toIso8601String() : null,
          'updatedAt': updatedAt is Timestamp ? updatedAt.toDate().toIso8601String() : null,
        });
      }).toList();

      // Filter by distance (simple implementation)
      // If showAll is true, return all stations without distance filtering
      if (showAll) {
        // Sort by distance but return all
        stations.sort((a, b) {
          final distA = _calculateDistance(latitude, longitude, a.latitude, a.longitude);
          final distB = _calculateDistance(latitude, longitude, b.latitude, b.longitude);
          return distA.compareTo(distB);
        });
        return stations;
      }
      
      // Filter by radius
      final filtered = stations.where((station) {
        final distance = _calculateDistance(
          latitude, longitude,
          station.latitude, station.longitude,
        );
        return distance <= radiusKm;
      }).toList();
      
      // Sort by distance
      filtered.sort((a, b) {
        final distA = _calculateDistance(latitude, longitude, a.latitude, a.longitude);
        final distB = _calculateDistance(latitude, longitude, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });
      
      return filtered;
    } on FirebaseException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  Future<StationModel> getStationById(String stationId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.stationsCollection)
          .doc(stationId)
          .get();

      if (!doc.exists) {
        throw Exception('Station not found');
      }

      final data = doc.data()!;
      
      // Parse amenities from string to list if needed
      List<String> amenitiesList = [];
      if (data['amenities'] != null) {
        if (data['amenities'] is List) {
          amenitiesList = List<String>.from(data['amenities']);
        } else if (data['amenities'] is String) {
          amenitiesList = (data['amenities'] as String).split(',').map((s) => s.trim()).toList();
        }
      }
      
      final createdAt = data['createdAt'];
      final updatedAt = data['updatedAt'];
      
      return StationModel.fromJson({
        'id': doc.id,
        'name': data['name'],
        'address': data['address'],
        'latitude': (data['latitude'] is String) ? double.parse(data['latitude']) : data['latitude'],
        'longitude': (data['longitude'] is String) ? double.parse(data['longitude']) : data['longitude'],
        'type': _parseStationType(data['type']),
        'pricePerHour': (data['pricePerHour'] is String) ? double.parse(data['pricePerHour']) : data['pricePerHour'],
        'batterySwap': (data['batterySwap'] is String) ? data['batterySwap'] == 'true' : data['batterySwap'],
        'totalSlots': (data['totalSlots'] is String) ? int.parse(data['totalSlots']) : data['totalSlots'],
        'availableSlots': (data['availableSlots'] is String) ? int.parse(data['availableSlots']) : data['availableSlots'],
        'imageUrl': data['imageUrl'] ?? '',
        'amenities': amenitiesList,
        'createdAt': createdAt is Timestamp ? createdAt.toDate().toIso8601String() : null,
        'updatedAt': updatedAt is Timestamp ? updatedAt.toDate().toIso8601String() : null,
      });
    } on FirebaseException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  // Slot operations
  Future<List<SlotModel>> getSlotsByStationId(String stationId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.slotsCollection)
          .where('stationId', isEqualTo: stationId)
          .orderBy('slotIndex')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SlotModel.fromJson({
          'id': doc.id,
          'stationId': data['stationId'],
          'slotIndex': (data['slotIndex'] is String) ? int.parse(data['slotIndex']) : data['slotIndex'],
          'type': data['type'],
          'status': data['status'],
          'batteryStatus': data['batteryStatus'],
          'lastUpdated': data['lastUpdated']?.toIso8601String(),
          'reservedByUserId': data['reservedByUserId'],
          'reservedUntil': data['reservedUntil']?.toIso8601String(),
        });
      }).toList();
    } on FirebaseException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  Future<void> updateSlotStatus({
    required String slotId,
    required String status,
    String? batteryStatus,
    String? reservedByUserId,
    DateTime? reservedUntil,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      };
      
      if (batteryStatus != null) updateData['batteryStatus'] = batteryStatus;
      if (reservedByUserId != null) updateData['reservedByUserId'] = reservedByUserId;
      if (reservedUntil != null) updateData['reservedUntil'] = Timestamp.fromDate(reservedUntil);

      await _firestore
          .collection(FirebaseConfig.slotsCollection)
          .doc(slotId)
          .update(updateData);
    } on FirebaseException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  // Booking operations
  Future<BookingModel> createBooking({
    required String userId,
    required String stationId,
    required String slotId,
    required int durationHours,
    required double pricePerHour,
  }) async {
    try {
      final startTime = DateTime.now();
      final totalPrice = durationHours * pricePerHour;

      final docRef = await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .add({
            'userId': userId,
            'stationId': stationId,
            'slotId': slotId,
            'status': 'active',
            'startTime': Timestamp.fromDate(startTime),
            'pricePerHour': pricePerHour,
            'durationHours': durationHours,
            'totalPrice': totalPrice,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Update slot status to occupied
      await updateSlotStatus(
        slotId: slotId,
        status: 'occupied',
        reservedByUserId: userId,
      );

      return BookingModel.fromJson({
        'id': docRef.id,
        'userId': userId,
        'stationId': stationId,
        'slotId': slotId,
        'status': 'active',
        'startTime': startTime.toIso8601String(),
        'pricePerHour': pricePerHour,
        'durationHours': durationHours,
        'totalPrice': totalPrice,
        'createdAt': startTime.toIso8601String(),
      });
    } on FirebaseException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BookingModel.fromJson({
          'id': doc.id,
          'userId': data['userId'],
          'stationId': data['stationId'],
          'slotId': data['slotId'],
          'status': data['status'],
          'startTime': (data['startTime'] as Timestamp?)?.toDate().toIso8601String(),
          'endTime': (data['endTime'] as Timestamp?)?.toDate().toIso8601String(),
          'pricePerHour': data['pricePerHour'],
          'durationHours': data['durationHours'],
          'totalPrice': data['totalPrice'],
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
          'cancelledAt': (data['cancelledAt'] as Timestamp?)?.toDate().toIso8601String(),
          'cancellationReason': data['cancellationReason'],
        });
      }).toList();
    } on FirebaseException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .doc(bookingId)
          .update({
            'status': 'cancelled',
            'cancelledAt': FieldValue.serverTimestamp(),
            'cancellationReason': 'User cancelled',
          });
    } on FirebaseException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  // User profile operations
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) {
        throw Exception('User profile not found');
      }

      final data = doc.data()!;
      return UserProfileModel.fromJson({
        'id': doc.id,
        'email': data['email'],
        'name': data['name'],
        'phoneNumber': data['phoneNumber'],
        'profileImageUrl': data['profileImageUrl'],
        'totalBookings': data['totalBookings'],
        'totalHoursParked': data['totalHoursParked'],
        'loyaltyPoints': data['loyaltyPoints'],
        'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
        'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
        'preferences': data['preferences'],
      });
    } on FirebaseException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  // Realtime listeners
  Stream<List<SlotModel>> subscribeToSlots(String stationId) {
    return _firestore
        .collection(FirebaseConfig.slotsCollection)
        .where('stationId', isEqualTo: stationId)
        .orderBy('slotIndex')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return SlotModel.fromJson({
              'id': doc.id,
              'stationId': data['stationId'],
              'slotIndex': (data['slotIndex'] is String) ? int.parse(data['slotIndex']) : data['slotIndex'],
              'type': data['type'],
              'status': data['status'],
              'batteryStatus': data['batteryStatus'],
              'lastUpdated': (data['lastUpdated'] as Timestamp?)?.toDate().toIso8601String(),
              'reservedByUserId': data['reservedByUserId'],
              'reservedUntil': (data['reservedUntil'] as Timestamp?)?.toDate().toIso8601String(),
            });
          }).toList();
        });
  }

  Stream<List<BookingModel>> subscribeToUserBookings(String userId) {
    return _firestore
        .collection(FirebaseConfig.bookingsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return BookingModel.fromJson({
              'id': doc.id,
              'userId': data['userId'],
              'stationId': data['stationId'],
              'slotId': data['slotId'],
              'status': data['status'],
              'startTime': (data['startTime'] as Timestamp?)?.toDate().toIso8601String(),
              'endTime': (data['endTime'] as Timestamp?)?.toDate().toIso8601String(),
              'pricePerHour': data['pricePerHour'],
              'durationHours': data['durationHours'],
              'totalPrice': data['totalPrice'],
              'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
              'cancelledAt': (data['cancelledAt'] as Timestamp?)?.toDate().toIso8601String(),
              'cancellationReason': data['cancellationReason'],
            });
          }).toList();
        });
  }

  Stream<List<StationModel>> subscribeToStations() {
    return _firestore
        .collection(FirebaseConfig.stationsCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            List<String> amenitiesList = [];
            if (data['amenities'] != null) {
              if (data['amenities'] is List) {
                amenitiesList = List<String>.from(data['amenities']);
              } else if (data['amenities'] is String) {
                amenitiesList = (data['amenities'] as String).split(',').map((s) => s.trim()).toList();
              }
            }
            return StationModel.fromJson({
              'id': doc.id,
              'name': data['name'],
              'address': data['address'],
              'latitude': (data['latitude'] is String) ? double.parse(data['latitude']) : data['latitude'],
              'longitude': (data['longitude'] is String) ? double.parse(data['longitude']) : data['longitude'],
              'type': _parseStationType(data['type']),
              'pricePerHour': (data['pricePerHour'] is String) ? double.parse(data['pricePerHour']) : data['pricePerHour'],
              'batterySwap': (data['batterySwap'] is String) ? data['batterySwap'] == 'true' : data['batterySwap'],
              'totalSlots': (data['totalSlots'] is String) ? int.parse(data['totalSlots']) : data['totalSlots'],
              'availableSlots': (data['availableSlots'] is String) ? int.parse(data['availableSlots']) : data['availableSlots'],
              'imageUrl': data['imageUrl'] ?? '',
              'amenities': amenitiesList,
              'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String(),
              'updatedAt': (data['updatedAt'] as Timestamp?)?.toDate().toIso8601String(),
            });
          }).toList();
        });
  }

  // Helper methods
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);
    final double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(_degreesToRadians(lat1)) *
            Math.cos(_degreesToRadians(lat2)) *
            Math.sin(dLon / 2) *
            Math.sin(dLon / 2);
    final double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (Math.pi / 180);
  }
  
  String _parseStationType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'charging':
          return 'charging';
        case 'parking':
          return 'parking';
        case 'hybrid':
          return 'hybrid';
        default:
          return 'hybrid';
      }
    }
    return type.toString();
  }

  String _handleDatabaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Unauthorized access';
      case 'not-found':
        return 'Resource not found';
      case 'already-exists':
        return 'Resource already exists';
      case 'resource-exhausted':
        return 'Too many requests. Please try again later';
      default:
        return e.message ?? 'Database operation failed';
    }
  }
}

