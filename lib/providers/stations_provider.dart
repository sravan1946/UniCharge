import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firestore_database_service.dart';
import '../models/station_model.dart';
import '../models/slot_model.dart';

// Database service provider
final databaseServiceProvider = Provider<FirestoreDatabaseService>((ref) {
  return FirestoreDatabaseService();
});

// Real-time slot status provider
final slotStatusProvider = StreamProvider.family<SlotModel?, String>((ref, slotId) {
  final databaseService = ref.watch(databaseServiceProvider);
  
  return databaseService.subscribeToSlots('temp').map((slots) {
    // Find the specific slot by ID
    return slots.where((s) => s.id == slotId).firstOrNull;
  });
});

// Real-time station slots provider with availability checking
final stationSlotsWithAvailabilityProvider = StreamProvider.family<List<SlotModel>, String>((ref, stationId) {
  final databaseService = ref.watch(databaseServiceProvider);
  
  return databaseService.subscribeToSlots(stationId);
});

// Nearby stations provider
final nearbyStationsProvider = FutureProvider.family<List<StationModel>, Position>((ref, position) async {
  final databaseService = ref.watch(databaseServiceProvider);
  return await databaseService.getNearbyStations(
    latitude: position.latitude,
    longitude: position.longitude,
    radiusKm: 50.0, // Increased to 50km to show more stations
  );
});

// Selected station provider
final selectedStationProvider = StateProvider<StationModel?>((ref) => null);

// Station by ID provider
final stationByIdProvider = FutureProvider.family<StationModel?, String>((ref, stationId) async {
  final databaseService = ref.watch(databaseServiceProvider);
  try {
    return await databaseService.getStationById(stationId);
  } catch (e) {
    return null;
  }
});

// Station slots provider - stream-based for real-time updates
final stationSlotsProvider = StreamProvider.family<List<SlotModel>, String>((ref, stationId) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.subscribeToSlots(stationId);
});

// Stations state provider
final stationsStateProvider = StateNotifierProvider<StationsStateNotifier, AsyncValue<List<StationModel>>>((ref) {
  return StationsStateNotifier(ref.watch(databaseServiceProvider));
});

// Real-time stations provider
final realtimeStationsProvider = StreamProvider<List<StationModel>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return databaseService.subscribeToStations();
});

// Slots state provider
final slotsStateProvider = StateNotifierProvider.family<SlotsStateNotifier, AsyncValue<List<SlotModel>>, String>((ref, stationId) {
  return SlotsStateNotifier(ref.watch(databaseServiceProvider), stationId);
});

class StationsStateNotifier extends StateNotifier<AsyncValue<List<StationModel>>> {
  final FirestoreDatabaseService _databaseService;

  StationsStateNotifier(this._databaseService) : super(const AsyncValue.loading());

  double _radiusKm = 50.0;
  bool _showAll = true;

  void setRadius(double radiusKm) {
    _radiusKm = radiusKm;
  }

  void setShowAll(bool showAll) {
    _showAll = showAll;
  }

  Future<void> loadNearbyStations(Position position, {double? radiusKm, bool? showAll}) async {
    try {
      if (mounted) {
        state = const AsyncValue.loading();
      }
      final stations = await _databaseService.getNearbyStations(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusKm: radiusKm ?? _radiusKm,
        showAll: showAll ?? _showAll,
      );
      if (mounted) {
        state = AsyncValue.data(stations);
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> refreshStations(Position position) async {
    await loadNearbyStations(position);
  }
}

class SlotsStateNotifier extends StateNotifier<AsyncValue<List<SlotModel>>> {
  final FirestoreDatabaseService _databaseService;
  final String _stationId;

  SlotsStateNotifier(this._databaseService, this._stationId) : super(const AsyncValue.loading()) {
    loadSlots();
  }

  Future<void> loadSlots() async {
    try {
      if (mounted) {
        state = const AsyncValue.loading();
      }
      final slots = await _databaseService.getSlotsByStationId(_stationId);
      if (mounted) {
        state = AsyncValue.data(slots);
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
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
      await _databaseService.updateSlotStatus(
        slotId: slotId,
        status: status,
        batteryStatus: batteryStatus,
        reservedByUserId: reservedByUserId,
        reservedUntil: reservedUntil,
      );
      // Reload slots to get updated data
      if (mounted) {
        await loadSlots();
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> refreshSlots() async {
    await loadSlots();
  }
}
