import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as handler;
import 'package:geolocator/geolocator.dart';

/// Permission status enum
enum PermissionStatus {
  granted,
  denied,
  deniedForever,
  restricted,
}

/// Permission service provider
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

/// Permission state provider
final permissionStateProvider = FutureProvider<PermissionStatus>((ref) async {
  final permissionService = ref.watch(permissionServiceProvider);
  return await permissionService.checkLocationPermission();
});

class PermissionService {
  /// Check current location permission status
  Future<PermissionStatus> checkLocationPermission() async {
    final locationPermission = await handler.Permission.location.status;
    
    if (locationPermission.isGranted) {
      return PermissionStatus.granted;
    } else if (locationPermission.isDenied) {
      return PermissionStatus.denied;
    } else if (locationPermission.isPermanentlyDenied) {
      return PermissionStatus.deniedForever;
    } else if (locationPermission.isRestricted) {
      return PermissionStatus.restricted;
    }
    
    return PermissionStatus.denied;
  }

  /// Request location permissions
  Future<PermissionStatus> requestLocationPermission() async {
    final result = await handler.Permission.location.request();
    
    if (result.isGranted) {
      return PermissionStatus.granted;
    } else if (result.isDenied) {
      return PermissionStatus.denied;
    } else if (result.isPermanentlyDenied) {
      return PermissionStatus.deniedForever;
    }
    
    return PermissionStatus.denied;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await handler.openAppSettings();
  }

  /// Check if we should show permission rationale
  Future<bool> shouldShowRequestRationale() async {
    final status = await checkLocationPermission();
    return status == PermissionStatus.denied;
  }
}

