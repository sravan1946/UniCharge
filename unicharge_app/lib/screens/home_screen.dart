import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/appwrite_service.dart';
import '../services/location_service.dart';
import '../models/station.dart';
import 'station_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  
  List<Station> _stations = [];
  List<Station> _filteredStations = [];
  bool _isLoading = false;
  String? _errorMessage;
  Position? _currentLocation;
  Station? _selectedStation;
  final TextEditingController _searchController = TextEditingController();
  
  final _appwriteService = AppwriteService();
  final _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _loadStations();
    _requestLocationPermission();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update markers when stations or filtered stations change
    setState(() {
      _updateMarkers(_filteredStations);
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterStations(_searchController.text);
  }

  Future<void> _loadStations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stations = await _appwriteService.getStations();
      setState(() {
        _stations = stations;
        _filteredStations = stations;
        _isLoading = false;
      });
      // Update markers after loading stations
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMarkers(_filteredStations);
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterStations(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredStations = _stations;
      });
    } else {
      setState(() {
        _filteredStations = _stations.where((station) {
          final searchLower = query.toLowerCase();
          return station.name.toLowerCase().contains(searchLower) ||
              station.address.toLowerCase().contains(searchLower);
        }).toList();
      });
    }
    _updateMarkers(_filteredStations);
  }

  Future<void> _requestLocationPermission() async {
    await _locationService.requestLocationPermission();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      setState(() {
        _currentLocation = position;
      });
      
      if (_mapController != null && position != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(position.latitude, position.longitude),
            15.0,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    }
  }

  void _onMarkerTapped(Station station) {
    setState(() {
      _selectedStation = station;
    });
    // Move camera to selected station
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(station.latitude, station.longitude),
        16.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: Colors.white,
        child: const Icon(Icons.my_location, color: Color(0xFF2196F3)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            ElevatedButton(
              onPressed: _loadStations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Update markers before building map
    if (_stations.isNotEmpty && _filteredStations.isNotEmpty) {
      _updateMarkers(_filteredStations);
    }
    
    return _buildMap();
  }

  Widget _buildMap() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: _currentLocation != null
                ? LatLng(_currentLocation!.latitude, _currentLocation!.longitude)
                : const LatLng(12.9716, 77.5946), // Default to Bangalore
            zoom: 15.0,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          onTap: (position) {
            // Close bottom sheet when tapping on map
            setState(() {
              _selectedStation = null;
            });
          },
        ),
        // Search bar
        Positioned(
          top: 48,
          left: 16,
          right: 16,
          child: _buildSearchBar(),
        ),
        // Station info bottom sheet
        if (_selectedStation != null)
          _buildStationBottomSheet(_selectedStation!),
      ],
    );
  }

  Widget _buildSearchBar() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                // Trigger rebuild to show/hide clear button
              });
            },
            decoration: InputDecoration(
              hintText: 'Search nearby stations',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : const Icon(Icons.location_on, color: Color(0xFF2196F3)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStationBottomSheet(Station station) {
    final occupiedSlots = station.totalSlots - station.availableSlots;
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StationDetailsScreen(station: station),
            ),
          );
        },
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  // Station name
                  Text(
                    station.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Address
                  Text(
                    station.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Slots info
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Slots',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        '$occupiedSlots occupied',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price
                  Row(
                    children: [
                      Text(
                        '\$${station.pricePerHour.toStringAsFixed(2)}/hr',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        iconSize: 28,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.ev_station),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              child: Icon(Icons.local_parking),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '',
          ),
        ],
        onTap: (index) {
          // Handle navigation
        },
      ),
    );
  }

  void _updateMarkers(List<Station> stations) {
    setState(() {
      _markers = stations.map((station) {
        return Marker(
          markerId: MarkerId(station.id),
          position: LatLng(station.latitude, station.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          anchor: const Offset(0.5, 1.0),
          infoWindow: const InfoWindow(), // Hide info window
          onTap: () => _onMarkerTapped(station),
        );
      }).toSet();
    });
  }
}
