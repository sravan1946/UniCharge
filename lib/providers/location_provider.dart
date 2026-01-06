import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Current location provider
final currentLocationProvider = FutureProvider<Position?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.getCurrentLocation();
});

// Location permission provider
final locationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  return await locationService.checkPermission();
});

// Location state provider
final locationStateProvider = StateNotifierProvider<LocationStateNotifier, AsyncValue<Position?>>((ref) {
  return LocationStateNotifier(ref.watch(locationServiceProvider));
});

class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      
      // If permission is denied, we should not request here - let the permission dialog handle it
      if (permission == LocationPermission.denied) {
        // Return null to indicate permission is needed
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Please enable in settings.');
      }

      // If permission is already granted, get the position
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        // Get current position
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      }

      return null;
    } catch (e) {
      if (e.toString().contains('permanently denied')) {
        rethrow;
      }
      // For other errors, return null so the UI can handle it
      return null;
    }
  }

  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get location after permission is granted
  Future<Position?> getLocationAfterPermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }
}

class LocationStateNotifier extends StateNotifier<AsyncValue<Position?>> {
  final LocationService _locationService;

  LocationStateNotifier(this._locationService) : super(const AsyncValue.loading()) {
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      state = const AsyncValue.loading();
      final position = await _locationService.getCurrentLocation();
      state = AsyncValue.data(position);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshLocation() async {
    await getCurrentLocation();
  }
}
