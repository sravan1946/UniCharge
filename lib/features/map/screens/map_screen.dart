import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:unicharge/providers/location_provider.dart';
import 'package:unicharge/providers/stations_provider.dart';
import 'package:unicharge/models/enums.dart';
import 'package:unicharge/models/station_model.dart';
import 'package:unicharge/features/map/widgets/station_preview_sheet.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  StationModel? _selectedStation;

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationStateProvider);

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

              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 15,
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

          // Search bar
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
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
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search stations...',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search
                },
              ),
            ),
          ),

          // Filter chips
          Positioned(
            top: 80,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Charging', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Parking', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Battery Swap', false),
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
              child: StationPreviewSheet(
                station: _selectedStation!,
                onViewDetails: () {
                  // TODO: Navigate to station details
                },
                onClose: () {
                  setState(() {
                    _selectedStation = null;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        // TODO: Implement filter
      },
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  void _loadStations(Position position) {
    ref.read(stationsStateProvider.notifier).loadNearbyStations(position);
    
    ref.listen(stationsStateProvider, (previous, next) {
      next.whenData((stations) {
        _updateMarkers(stations, position);
      });
    });
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

      // Add station markers
      for (final station in stations) {
        _markers.add(
          Marker(
            markerId: MarkerId(station.id),
            position: LatLng(station.latitude, station.longitude),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              station.type == StationType.charging ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueOrange,
            ),
            infoWindow: InfoWindow(
              title: station.name,
              snippet: '${station.availableSlots}/${station.totalSlots} slots available',
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
}
