import 'dart:async';
import 'package:appwrite/appwrite.dart';
import '../core/appwrite_config.dart';
import '../models/slot_model.dart';
import '../models/booking_model.dart';

class AppwriteRealtimeService {
  final Realtime _realtime = AppwriteConfig.realtime;
  final Map<String, RealtimeSubscription> _subscriptions = {};

  // Subscribe to slot updates for a specific station
  Stream<List<SlotModel>> subscribeToSlots(String stationId) {
    final channel = 'databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.slotsCollectionId}.documents';
    
    final controller = StreamController<List<SlotModel>>();
    final subscription = _realtime.subscribe([channel]);
    
    subscription.stream.listen((response) {
      if (response.payload.isNotEmpty) {
        final event = response.payload['events'] as List;
        if (event.any((e) => e.toString().contains('stationId=$stationId'))) {
          // This is a slot update for our station
          // In a real implementation, you'd fetch the updated slots
          // For now, we'll return an empty list and let the UI handle it
          controller.add(<SlotModel>[]);
        }
      }
    });
    
    return controller.stream;
  }

  // Subscribe to booking updates for a specific user
  Stream<List<BookingModel>> subscribeToUserBookings(String userId) {
    final channel = 'databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.bookingsCollectionId}.documents';
    
    final controller = StreamController<List<BookingModel>>();
    final subscription = _realtime.subscribe([channel]);
    
    subscription.stream.listen((response) {
      if (response.payload.isNotEmpty) {
        final event = response.payload['events'] as List;
        if (event.any((e) => e.toString().contains('userId=$userId'))) {
          // This is a booking update for our user
          controller.add(<BookingModel>[]);
        }
      }
    });
    
    return controller.stream;
  }

  // Subscribe to station updates
  Stream<void> subscribeToStations() {
    final channel = 'databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.stationsCollectionId}.documents';
    
    final controller = StreamController<void>();
    final subscription = _realtime.subscribe([channel]);
    
    subscription.stream.listen((response) {
      // Handle station updates
      controller.add(null);
    });
    
    return controller.stream;
  }

  // Subscribe to all relevant channels for the app
  Stream<void> subscribeToAllUpdates() {
    final channels = [
      'databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.stationsCollectionId}.documents',
      'databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.slotsCollectionId}.documents',
      'databases.${AppwriteConfig.databaseId}.collections.${AppwriteConfig.bookingsCollectionId}.documents',
    ];
    
    final controller = StreamController<void>();
    final subscription = _realtime.subscribe(channels);
    
    subscription.stream.listen((response) {
      // Handle all updates
      controller.add(null);
    });
    
    return controller.stream;
  }

  // Close all subscriptions
  void closeAllSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.close();
    }
    _subscriptions.clear();
  }

  // Close a specific subscription
  void closeSubscription(String key) {
    final subscription = _subscriptions[key];
    if (subscription != null) {
      subscription.close();
      _subscriptions.remove(key);
    }
  }
}
