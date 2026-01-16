import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as Math;
import '../core/firebase_config.dart';
import '../models/station_model.dart';
import '../models/slot_model.dart';
import '../models/booking_model.dart';
import '../models/user_profile_model.dart';
import 'qr_token_service.dart';

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
          .get();
      
      // Sort by slotIndex in memory instead of using orderBy query
      final slots = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Slot data: $data'); // Debug print
        
        // Handle lastUpdated - use current time if missing
        DateTime lastUpdated;
        if (data['lastUpdated'] is Timestamp) {
          lastUpdated = data['lastUpdated'].toDate();
        } else if (data['lastUpdated'] != null) {
          try {
            lastUpdated = DateTime.parse(data['lastUpdated']);
          } catch (e) {
            lastUpdated = DateTime.now();
          }
        } else {
          lastUpdated = DateTime.now();
        }
        
        // Handle reservedUntil
        DateTime? reservedUntil;
        if (data['reservedUntil'] is Timestamp) {
          reservedUntil = data['reservedUntil'].toDate();
        } else if (data['reservedUntil'] != null) {
          try {
            reservedUntil = DateTime.parse(data['reservedUntil']);
          } catch (e) {
            reservedUntil = null;
          }
        }
        
        return SlotModel.fromJson({
          'id': doc.id,
          'stationId': data['stationId'] as String? ?? '',
          'slotIndex': (data['slotIndex'] is String) ? int.parse(data['slotIndex']) : (data['slotIndex'] as int? ?? 0),
          'type': _parseSlotType(data['type']),
          'status': _parseSlotStatus(data['status']),
          'batteryStatus': _parseBatteryStatus(data['batteryStatus']),
          'lastUpdated': lastUpdated.toIso8601String(),
          'reservedByUserId': data['reservedByUserId'] as String?,
          'reservedUntil': reservedUntil?.toIso8601String(),
        });
      }).toList();
      
      // Sort by slotIndex
      slots.sort((a, b) => a.slotIndex.compareTo(b.slotIndex));
      
      return slots;
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
    DateTime? customStartTime,
  }) async {
    try {
      final startTime = customStartTime ?? DateTime.now();
      final endTime = startTime.add(Duration(hours: durationHours));
      final totalPrice = durationHours * pricePerHour;

      // Generate a temporary ID for the token before creating the document
      final tempId = _firestore.collection('temp').doc().id;
      
      // Generate QR token (will be updated with actual booking ID after creation)
      final qrToken = '$tempId:${startTime.millisecondsSinceEpoch}:token';

      final docRef = await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .add({
            'userId': userId,
            'stationId': stationId,
            'slotId': slotId,
            'status': 'reserved',
            'startTime': Timestamp.fromDate(startTime),
            'endTime': Timestamp.fromDate(endTime),
            'pricePerHour': pricePerHour,
            'durationHours': durationHours,
            'totalPrice': totalPrice,
            'qrToken': qrToken, // Temporary token
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Generate final secure QR token with actual booking ID
      final finalQrToken = QrTokenService.generateSecureToken(docRef.id);
      
      // Update with final QR token
      await docRef.update({'qrToken': finalQrToken});

      // Update slot status to reserved
      await updateSlotStatus(
        slotId: slotId,
        status: 'reserved',
        reservedByUserId: userId,
        reservedUntil: endTime,
      );

      return BookingModel.fromJson({
        'id': docRef.id,
        'userId': userId,
        'stationId': stationId,
        'slotId': slotId,
        'status': 'reserved',
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'pricePerHour': pricePerHour,
        'durationHours': durationHours,
        'totalPrice': totalPrice,
        'qrToken': finalQrToken,
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
          'qrToken': data['qrToken'],
        });
      }).toList();
    } on FirebaseException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final doc = await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .doc(bookingId)
          .get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data()!;
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
        'qrToken': data['qrToken'],
      });
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

  /// Mark a reserved booking as occupied (when QR code is scanned)
  /// This transitions the booking from reserved → active and slot from reserved → occupied
  Future<void> activateBooking({
    required String bookingId,
    required String slotId,
  }) async {
    try {
      // First, get the booking to check the start time
      final booking = await getBookingById(bookingId);
      if (booking == null) {
        throw Exception('Booking not found');
      }

      // Update booking status to active
      await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .doc(bookingId)
          .update({
            'status': 'active',
          });

      // Update slot status to occupied
      await updateSlotStatus(
        slotId: slotId,
        status: 'occupied',
      );
    } on FirebaseException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  /// Complete a booking and free up the slot
  /// This transitions the booking from active → completed and slot from occupied → available
  Future<void> completeBooking({
    required String bookingId,
    required String slotId,
  }) async {
    try {
      // Update booking status to completed
      await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .doc(bookingId)
          .update({
            'status': 'completed',
          });

      // Update slot status to available
      await updateSlotStatus(
        slotId: slotId,
        status: 'available',
        batteryStatus: null,
        reservedByUserId: null,
        reservedUntil: null,
      );
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

  // Get bookings for a specific slot within a date range
  Future<List<BookingModel>> getSlotBookings({
    required String slotId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(FirebaseConfig.bookingsCollection)
          .where('slotId', isEqualTo: slotId)
          .where('status', whereIn: ['reserved', 'active'])
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
          'qrToken': data['qrToken'],
        });
      }).toList();
    } on FirebaseException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  // Check if a slot is available for a specific time range
  Future<bool> isSlotAvailable({
    required String slotId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      // First check if the slot itself is available (not occupied)
      final slotDoc = await _firestore
          .collection(FirebaseConfig.slotsCollection)
          .doc(slotId)
          .get();
      
      if (!slotDoc.exists) {
        return false; // Slot doesn't exist
      }
      
      final slotData = slotDoc.data()!;
      final slotStatus = slotData['status'] as String?;
      
      // If slot is occupied, it's not available
      if (slotStatus == 'occupied') {
        return false;
      }
      
      // Check for overlapping bookings
      final bookings = await getSlotBookings(
        slotId: slotId,
        startDate: startTime.subtract(const Duration(hours: 1)), // Check slightly before
        endDate: endTime.add(const Duration(hours: 1)), // Check slightly after
      );

      // Check for any overlapping bookings
      for (final booking in bookings) {
        final bookingStart = booking.startTime;
        final bookingEnd = booking.endTime ?? bookingStart.add(Duration(hours: booking.durationHours));
        
        // Check if there's any overlap (with 15-minute buffer)
        final buffer = const Duration(minutes: 15);
        if (startTime.isBefore(bookingEnd.add(buffer)) && endTime.isAfter(bookingStart.subtract(buffer))) {
          return false; // Slot is not available
        }
      }
      
      return true; // Slot is available
    } on FirebaseException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  // Get detailed availability information for a slot
  Future<Map<String, dynamic>> getSlotAvailabilityDetails({
    required String slotId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      final slotDoc = await _firestore
          .collection(FirebaseConfig.slotsCollection)
          .doc(slotId)
          .get();
      
      if (!slotDoc.exists) {
        return {
          'isAvailable': false,
          'reason': 'Slot does not exist',
          'conflictingBookings': <BookingModel>[],
        };
      }
      
      final slotData = slotDoc.data()!;
      final slotStatus = slotData['status'] as String?;
      
      // Get all bookings for the slot
      final bookings = await getSlotBookings(
        slotId: slotId,
        startDate: startTime.subtract(const Duration(hours: 1)),
        endDate: endTime.add(const Duration(hours: 1)),
      );
      
      // Find conflicting bookings
      final conflictingBookings = <BookingModel>[];
      for (final booking in bookings) {
        final bookingStart = booking.startTime;
        final bookingEnd = booking.endTime ?? bookingStart.add(Duration(hours: booking.durationHours));
        
        // Check if there's any overlap (with 15-minute buffer)
        final buffer = const Duration(minutes: 15);
        if (startTime.isBefore(bookingEnd.add(buffer)) && endTime.isAfter(bookingStart.subtract(buffer))) {
          conflictingBookings.add(booking);
        }
      }
      
      // Determine availability
      bool isAvailable = true;
      String reason = 'Available';
      
      if (slotStatus == 'occupied') {
        isAvailable = false;
        reason = 'Slot is currently occupied';
      } else if (conflictingBookings.isNotEmpty) {
        isAvailable = false;
        reason = 'Conflicts with existing bookings';
      }
      
      return {
        'isAvailable': isAvailable,
        'reason': reason,
        'conflictingBookings': conflictingBookings,
        'slotStatus': slotStatus,
      };
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
            
            // Handle lastUpdated
            DateTime lastUpdated;
            if (data['lastUpdated'] is Timestamp) {
              lastUpdated = data['lastUpdated'].toDate();
            } else if (data['lastUpdated'] != null) {
              try {
                lastUpdated = DateTime.parse(data['lastUpdated']);
              } catch (e) {
                lastUpdated = DateTime.now();
              }
            } else {
              lastUpdated = DateTime.now();
            }
            
            // Handle reservedUntil
            DateTime? reservedUntil;
            if (data['reservedUntil'] is Timestamp) {
              reservedUntil = data['reservedUntil'].toDate();
            } else if (data['reservedUntil'] != null) {
              try {
                reservedUntil = DateTime.parse(data['reservedUntil']);
              } catch (e) {
                reservedUntil = null;
              }
            }
            
            return SlotModel.fromJson({
              'id': doc.id,
              'stationId': data['stationId'] as String? ?? '',
              'slotIndex': (data['slotIndex'] is String) ? int.parse(data['slotIndex']) : (data['slotIndex'] as int? ?? 0),
              'type': _parseSlotType(data['type']),
              'status': _parseSlotStatus(data['status']),
              'batteryStatus': _parseBatteryStatus(data['batteryStatus']),
              'lastUpdated': lastUpdated.toIso8601String(),
              'reservedByUserId': data['reservedByUserId'] as String?,
              'reservedUntil': reservedUntil?.toIso8601String(),
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
              'qrToken': data['qrToken'],
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

  String _parseSlotType(dynamic type) {
    if (type == null) return 'parkingSpace';
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'chargingpad':
        case 'charging_pad':
        case 'charging':
          return 'chargingPad';
        case 'parkingspace':
        case 'parking_space':
        case 'parking':
          return 'parkingSpace';
        default:
          return type;
      }
    }
    return type.toString();
  }

  String? _parseBatteryStatus(dynamic batteryStatus) {
    if (batteryStatus == null) return null;
    if (batteryStatus is String) {
      return batteryStatus;
    }
    return null;
  }

  String _parseSlotStatus(dynamic status) {
    if (status == null) return 'available';
    if (status is String) {
      switch (status.toLowerCase()) {
        case 'available':
          return 'available';
        case 'occupied':
          return 'occupied';
        case 'reserved':
          return 'reserved';
        case 'maintenance':
          return 'maintenance';
        default:
          return 'available';
      }
    }
    return status.toString();
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

