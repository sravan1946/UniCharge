import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/appwrite_realtime_service.dart';
import '../models/slot_model.dart';
import '../models/booking_model.dart';

// Realtime service provider
final realtimeServiceProvider = Provider<AppwriteRealtimeService>((ref) {
  return AppwriteRealtimeService();
});

// Realtime connection provider
final realtimeConnectionProvider = StateNotifierProvider<RealtimeConnectionNotifier, bool>((ref) {
  return RealtimeConnectionNotifier(ref.watch(realtimeServiceProvider));
});

// Slot updates provider
final slotUpdatesProvider = StreamProvider.family<List<SlotModel>, String>((ref, stationId) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.subscribeToSlots(stationId);
});

// User booking updates provider
final userBookingUpdatesProvider = StreamProvider.family<List<BookingModel>, String>((ref, userId) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.subscribeToUserBookings(userId);
});

// All updates provider
final allUpdatesProvider = StreamProvider<void>((ref) {
  final realtimeService = ref.watch(realtimeServiceProvider);
  return realtimeService.subscribeToAllUpdates();
});

class RealtimeConnectionNotifier extends StateNotifier<bool> {
  final AppwriteRealtimeService _realtimeService;

  RealtimeConnectionNotifier(this._realtimeService) : super(false);

  void connect() {
    state = true;
  }

  void disconnect() {
    _realtimeService.closeAllSubscriptions();
    state = false;
  }

  void toggleConnection() {
    if (state) {
      disconnect();
    } else {
      connect();
    }
  }
}
