import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../bloc/app_bloc.dart';
import '../models/station.dart';
import '../widgets/station_card.dart';
import 'station_details_screen.dart';
import 'admin_dashboard.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  bool _showList = false;

  @override
  void initState() {
    super.initState();
    context.read<AppBloc>().add(LoadStations());
    context.read<AppBloc>().add(RequestLocationPermission());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UniCharge'),
        actions: [
          IconButton(
            icon: Icon(_showList ? Icons.map : Icons.list),
            onPressed: () {
              setState(() {
                _showList = !_showList;
              });
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'admin',
                child: Text('Admin Dashboard'),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Text('Settings'),
              ),
            ],
            onSelected: (value) {
              if (value == 'admin') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminDashboard(),
                  ),
                );
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<AppBloc, AppState>(
        listener: (context, state) {
          if (state is AppError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AppLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AppError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AppBloc>().add(LoadStations());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AppLoaded) {
            _updateMarkers(state.stations);
            
            if (_showList) {
              return _buildStationList(state.stations);
            } else {
              return _buildMap(state);
            }
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<AppBloc>().add(GetCurrentLocation());
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildMap(AppLoaded state) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: state.currentLocation != null
                ? LatLng(state.currentLocation!.latitude, state.currentLocation!.longitude)
                : const LatLng(12.9716, 77.5946), // Default to Bangalore
            zoom: 15.0,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              'Find nearby parking and charging stations',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStationList(List<Station> stations) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        return StationCard(
          station: station,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StationDetailsScreen(station: station),
              ),
            );
          },
        );
      },
    );
  }

  void _updateMarkers(List<Station> stations) {
    _markers = stations.map((station) {
      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.latitude, station.longitude),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: '${station.availableSlots}/${station.totalSlots} slots available',
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StationDetailsScreen(station: station),
            ),
          );
        },
      );
    }).toSet();
  }
}
