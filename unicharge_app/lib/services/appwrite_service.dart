import 'package:appwrite/appwrite.dart';
import '../constants/appwrite_config.dart';
import '../models/station.dart';
import '../models/slot.dart';
import '../models/booking.dart';
import '../models/user.dart' as app_user;

class AppwriteService {
  late Client _client;
  late Databases _databases;
  late Account _account;

  AppwriteService() {
    _client = Client()
      ..setEndpoint(AppwriteConfig.endpoint)
      ..setProject(AppwriteConfig.projectId)
      ..setSelfSigned(status: false); // Allow cookies to be stored properly
    
    _databases = Databases(_client);
    _account = Account(_client);
  }

  // Authentication methods
  Future<app_user.User?> getCurrentUser() async {
    try {
      final user = await _account.get();
      return app_user.User.fromJson(user.toMap());
    } catch (e) {
      return null;
    }
  }

  Future<app_user.User> signUp(String email, String password, String name) async {
    try {
      final user = await _account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      return app_user.User.fromJson(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  Future<app_user.User> signIn(String email, String password) async {
    try {
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      final user = await _account.get();
      return app_user.User.fromJson(user.toMap());
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _account.deleteSession(sessionId: 'current');
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Station methods
  Future<List<Station>> getStations() async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.stationsCollectionId,
      );
      
      return (response.documents as List)
          .map((doc) => Station.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch stations: $e');
    }
  }

  Future<Station> getStation(String stationId) async {
    try {
      final response = await _databases.getDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.stationsCollectionId,
        documentId: stationId,
      );
      
      return Station.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to fetch station: $e');
    }
  }

  // Slot methods
  Future<List<Slot>> getSlots(String stationId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.slotsCollectionId,
        queries: [
          Query.equal('station_id', stationId),
        ],
      );
      
      return (response.documents as List)
          .map((doc) => Slot.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch slots: $e');
    }
  }

  Future<Slot> updateSlot(String slotId, Map<String, dynamic> data) async {
    try {
      final response = await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.slotsCollectionId,
        documentId: slotId,
        data: data,
      );
      
      return Slot.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update slot: $e');
    }
  }

  // Booking methods
  Future<Booking> createBooking({
    required String userId,
    required String stationId,
    required String slotId,
    required double price,
    String? notes,
  }) async {
    try {
      final response = await _databases.createDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.bookingsCollectionId,
        documentId: ID.unique(),
        data: {
          'user_id': userId,
          'station_id': stationId,
          'slot_id': slotId,
          'status': 'pending',
          'start_time': DateTime.now().toIso8601String(),
          'price': price,
          'notes': notes,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      
      return Booking.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  Future<List<Booking>> getUserBookings(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.bookingsCollectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.orderDesc('created_at'),
        ],
      );
      
      return (response.documents as List)
          .map((doc) => Booking.fromJson(doc.data))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user bookings: $e');
    }
  }

  Future<Booking> updateBooking(String bookingId, Map<String, dynamic> data) async {
    try {
      final response = await _databases.updateDocument(
        databaseId: AppwriteConfig.databaseId,
        collectionId: AppwriteConfig.bookingsCollectionId,
        documentId: bookingId,
        data: {
          ...data,
          'updated_at': DateTime.now().toIso8601String(),
        },
      );
      
      return Booking.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update booking: $e');
    }
  }

  // Realtime subscriptions - temporarily disabled for build
  // TODO: Fix Realtime subscription syntax
  /*
  RealtimeSubscription subscribeToStations(Function(dynamic) callback) {
    return _realtime.subscribe(AppwriteConfig.stationsChannel, callback);
  }

  RealtimeSubscription subscribeToSlots(Function(dynamic) callback) {
    return _realtime.subscribe(AppwriteConfig.slotsChannel, callback);
  }

  RealtimeSubscription subscribeToBookings(Function(dynamic) callback) {
    return _realtime.subscribe(AppwriteConfig.bookingsChannel, callback);
  }

  RealtimeSubscription subscribeToUserBookings(String userId, Function(dynamic) callback) {
    return _realtime.subscribe(
      '${AppwriteConfig.bookingsChannel}?userId=$userId',
      callback
    );
  }
  */
}
