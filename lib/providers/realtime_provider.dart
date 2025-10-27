import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_database_service.dart';
import '../models/slot_model.dart';
import '../models/booking_model.dart';

// Realtime service provider
final realtimeServiceProvider = Provider<FirestoreDatabaseService>((ref) {
  return FirestoreDatabaseService();
});

// Slot updates provider
final slotUpdatesProvider = StreamProvider.family<List<SlotModel>, String>((ref, stationId) {
  final databaseService = ref.watch(realtimeServiceProvider);
  return databaseService.subscribeToSlots(stationId);
});

// User booking updates provider
final userBookingUpdatesProvider = StreamProvider.family<List<BookingModel>, String>((ref, userId) {
  final databaseService = ref.watch(realtimeServiceProvider);
  return databaseService.subscribeToUserBookings(userId);
});

// Station updates provider
final stationUpdatesProvider = StreamProvider<List>((ref) {
  final databaseService = ref.watch(realtimeServiceProvider);
  return databaseService.subscribeToStations();
});
