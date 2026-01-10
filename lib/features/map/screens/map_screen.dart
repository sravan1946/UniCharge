import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:unicharge/providers/location_provider.dart';
import 'package:unicharge/providers/stations_provider.dart';
import 'package:unicharge/models/station_model.dart';
import 'package:unicharge/models/enums.dart';
import 'package:unicharge/features/map/widgets/station_preview_sheet.dart';
import 'package:unicharge/features/stations/screens/station_details_screen.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  StationModel? _selectedStation;
  List<StationModel> _lastStations = [];

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationStateProvider);
    final stationsState = ref.watch(stationsStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Stations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _goToCurrentLocation();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          locationState.when(
            data: (position) {
              if (position == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64),
                      SizedBox(height: 16),
                      Text('Location access required'),
                      Text('Please enable location services'),
                    ],
                  ),
                );
              }

              // Update markers when stations load
              return stationsState.when(
                data: (stations) {
                  // Update markers if stations changed (check by IDs)
                  final currentIds = stations.map((s) => s.id).toSet();
                  final lastIds = _lastStations.map((s) => s.id).toSet();
                  if (!currentIds.containsAll(lastIds) || currentIds.length != lastIds.length) {
                    _lastStations = stations;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _updateMarkers(stations, position);
                    });
                  }
                  
                  return GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(position.latitude, position.longitude),
                      zoom: 13,
                    ),
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                      _loadStations(position);
                    },
                    markers: _markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    onTap: (LatLng position) {
                      setState(() {
                        _selectedStation = null;
                      });
                    },
                  );
                },
                loading: () => GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(position.latitude, position.longitude),
                    zoom: 13,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _loadStations(position);
                  },
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64),
                      const SizedBox(height: 16),
                      Text('Error loading stations: $error'),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(stationsStateProvider);
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(locationStateProvider);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),

          // Legend
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Legend',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLegendItem('Free', Colors.yellow),
                  _buildLegendItem('Charging', Colors.green),
                  _buildLegendItem('Parking', Colors.orange),
                  _buildLegendItem('Hybrid', Colors.deepPurple),
                ],
              ),
            ),
          ),

          // Station preview sheet
          if (_selectedStation != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildStationPreviewSheet(_selectedStation!),
            ),
        ],
      ),
    );
  }

  Widget _buildStationPreviewSheet(StationModel station) {
    return StationPreviewSheet(
      station: station,
      onViewDetails: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StationDetailsScreen(station: station),
          ),
        ).then((_) {
          setState(() {
            _selectedStation = null;
          });
        });
      },
      onClose: () {
        setState(() {
          _selectedStation = null;
        });
      },
    );
  }

  void _loadStations(Position position) {
    // Load stations with showAll=true to get all stations
    ref.read(stationsStateProvider.notifier).loadNearbyStations(
      position,
      radiusKm: 50.0,
      showAll: true, // Show all stations on map
    );
  }

  void _updateMarkers(List<StationModel> stations, Position userPosition) {
    setState(() {
      _markers.clear();
      
      // Add user location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(userPosition.latitude, userPosition.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );

      // Add station markers with enhanced information
      for (final station in stations) {
        BitmapDescriptor icon;
        // Choose color based on station type and price
        if (station.pricePerHour == 0) {
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow); // Free
        } else if (station.type == StationType.parking) {
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange); // Parking
        } else if (station.type == StationType.charging) {
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen); // Charging
        } else {
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet); // Hybrid
        }
        
        // Build rich snippet with more information
        String typeLabel = _getStationTypeLabel(station.type);
        String batterySwapLabel = station.batterySwap ? ' ✓ Swap' : '';
        String priceLabel = station.pricePerHour == 0 ? 'FREE' : '₹${station.pricePerHour.toInt()}/hr';
        
        _markers.add(
          Marker(
            markerId: MarkerId(station.id),
            position: LatLng(station.latitude, station.longitude),
            icon: icon,
            infoWindow: InfoWindow(
              title: station.name,
              snippet: '$typeLabel • ${station.availableSlots}/${station.totalSlots} slots • $priceLabel$batterySwapLabel',
            ),
            onTap: () {
              setState(() {
                _selectedStation = station;
              });
            },
          ),
        );
      }
    });
  }

  void _goToCurrentLocation() {
    final locationState = ref.read(locationStateProvider);
    locationState.whenData((position) {
      if (position != null && _mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    });
  }

  String _getStationTypeLabel(StationType type) {
    switch (type) {
      case StationType.charging:
        return '🔌 Charging';
      case StationType.parking:
        return '🚗 Parking';
      case StationType.hybrid:
        return '⚡ Hybrid';
    }
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black54, width: 1),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
