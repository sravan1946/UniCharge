import 'package:appwrite/appwrite.dart';
import 'dart:math' as Math;
import '../core/appwrite_config.dart';
import '../models/station_model.dart';
import '../models/slot_model.dart';
import '../models/booking_model.dart';
import '../models/user_profile_model.dart';

class AppwriteDatabaseService {
  final Databases _databases = AppwriteConfig.databases;

  // Station operations
  Future<List<StationModel>> getNearbyStations({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.stationsCollectionId,
        queries: [
          Query.limit(50),
          Query.orderDesc('createdAt'),
        ],
      );

      final stations = result.documents.map((doc) {
        final data = doc.data;
        
        // Parse amenities from string to list if needed
        List<String> amenitiesList = [];
        if (data['amenities'] != null) {
          if (data['amenities'] is List) {
            amenitiesList = List<String>.from(data['amenities']);
          } else if (data['amenities'] is String) {
            amenitiesList = (data['amenities'] as String).split(',').map((s) => s.trim()).toList();
          }
        }
        
        return StationModel.fromJson({
          'id': doc.$id,
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
          'createdAt': data['createdAt'],
          'updatedAt': data['updatedAt'],
        });
      }).toList();

      // Filter by distance (simple implementation)
      return stations.where((station) {
        final distance = _calculateDistance(
          latitude, longitude,
          station.latitude, station.longitude,
        );
        return distance <= radiusKm;
      }).toList();
    } on AppwriteException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  Future<StationModel> getStationById(String stationId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.stationsCollectionId,
        documentId: stationId,
      );

      final data = doc.data;
      
      // Parse amenities from string to list if needed
      List<String> amenitiesList = [];
      if (data['amenities'] != null) {
        if (data['amenities'] is List) {
          amenitiesList = List<String>.from(data['amenities']);
        } else if (data['amenities'] is String) {
          amenitiesList = (data['amenities'] as String).split(',').map((s) => s.trim()).toList();
        }
      }
      
      return StationModel.fromJson({
        'id': doc.$id,
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
        'createdAt': data['createdAt'],
        'updatedAt': data['updatedAt'],
      });
    } on AppwriteException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  // Slot operations
  Future<List<SlotModel>> getSlotsByStationId(String stationId) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.slotsCollectionId,
        queries: [
          Query.equal('stationId', stationId),
          Query.orderAsc('slotIndex'),
        ],
      );

      return result.documents.map((doc) {
        final data = doc.data;
        return SlotModel.fromJson({
          'id': doc.$id,
          'stationId': data['stationId'],
          'slotIndex': (data['slotIndex'] is String) ? int.parse(data['slotIndex']) : data['slotIndex'],
          'type': data['type'],
          'status': data['status'],
          'batteryStatus': data['batteryStatus'],
          'lastUpdated': data['lastUpdated'],
          'reservedByUserId': data['reservedByUserId'],
          'reservedUntil': data['reservedUntil'],
        });
      }).toList();
    } on AppwriteException catch (e) {
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
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.slotsCollectionId,
        documentId: slotId,
        data: {
          'status': status,
          if (batteryStatus != null) 'batteryStatus': batteryStatus,
          if (reservedByUserId != null) 'reservedByUserId': reservedByUserId,
          if (reservedUntil != null) 'reservedUntil': reservedUntil.toIso8601String(),
          'lastUpdated': DateTime.now().toIso8601String(),
        },
      );
    } on AppwriteException catch (e) {
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
      final bookingId = ID.unique();
      final startTime = DateTime.now();
      final totalPrice = durationHours * pricePerHour;

      await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.bookingsCollectionId,
        documentId: bookingId,
        data: {
          'userId': userId,
          'stationId': stationId,
          'slotId': slotId,
          'status': 'active',
          'startTime': startTime.toIso8601String(),
          'pricePerHour': pricePerHour,
          'durationHours': durationHours,
          'totalPrice': totalPrice,
          'createdAt': DateTime.now().toIso8601String(),
        },
      );

      // Update slot status to occupied
      await updateSlotStatus(
        slotId: slotId,
        status: 'occupied',
        reservedByUserId: userId,
      );

      return BookingModel.fromJson({
        'id': bookingId,
        'userId': userId,
        'stationId': stationId,
        'slotId': slotId,
        'status': 'active',
        'startTime': startTime.toIso8601String(),
        'pricePerHour': pricePerHour,
        'durationHours': durationHours,
        'totalPrice': totalPrice,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } on AppwriteException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    try {
      final result = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.bookingsCollectionId,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('createdAt'),
          Query.limit(50),
        ],
      );

      return result.documents.map((doc) {
        final data = doc.data;
        return BookingModel.fromJson({
          'id': doc.$id,
          'userId': data['userId'],
          'stationId': data['stationId'],
          'slotId': data['slotId'],
          'status': data['status'],
          'startTime': data['startTime'],
          'endTime': data['endTime'],
          'pricePerHour': data['pricePerHour'],
          'durationHours': data['durationHours'],
          'totalPrice': data['totalPrice'],
          'createdAt': data['createdAt'],
          'cancelledAt': data['cancelledAt'],
          'cancellationReason': data['cancellationReason'],
        });
      }).toList();
    } on AppwriteException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.bookingsCollectionId,
        documentId: bookingId,
        data: {
          'status': 'cancelled',
          'cancelledAt': DateTime.now().toIso8601String(),
          'cancellationReason': 'User cancelled',
        },
      );
    } on AppwriteException catch (e) {
      throw _handleDatabaseException(e);
    }
  }

  // User profile operations
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      final doc = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.usersCollectionId,
        documentId: userId,
      );

      final data = doc.data;
      return UserProfileModel.fromJson({
        'id': doc.$id,
        'email': data['email'],
        'name': data['name'],
        'phoneNumber': data['phoneNumber'],
        'profileImageUrl': data['profileImageUrl'],
        'totalBookings': data['totalBookings'],
        'totalHoursParked': data['totalHoursParked'],
        'loyaltyPoints': data['loyaltyPoints'],
        'createdAt': data['createdAt'],
        'updatedAt': data['updatedAt'],
        'preferences': data['preferences'],
      });
    } on AppwriteException catch (e) {
      throw _handleDatabaseException(e);
    }
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

  String _handleDatabaseException(AppwriteException e) {
    switch (e.code) {
      case 400:
        return 'Invalid request data';
      case 401:
        return 'Unauthorized access';
      case 404:
        return 'Resource not found';
      case 409:
        return 'Resource already exists';
      case 429:
        return 'Too many requests. Please try again later';
      default:
        return e.message ?? 'Database operation failed';
    }
  }
}
