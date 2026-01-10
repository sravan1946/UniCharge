import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/app_bloc.dart';
import '../models/station.dart';
import '../models/slot.dart';
import '../models/booking.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<AppBloc>().add(LoadStations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AppBloc>().add(LoadStations());
            },
          ),
        ],
      ),
      body: BlocBuilder<AppBloc, AppState>(
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
            return _buildDashboard(state);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Stations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(AppLoaded state) {
    switch (_selectedIndex) {
      case 0:
        return _buildOverview(state);
      case 1:
        return _buildStationsList(state.stations);
      case 2:
        return _buildBookingsList(state.userBookings);
      default:
        return _buildOverview(state);
    }
  }

  Widget _buildOverview(AppLoaded state) {
    final totalStations = state.stations.length;
    final totalSlots = state.slots.length;
    final availableSlots = state.slots.where((slot) => slot.isAvailable).length;
    final occupiedSlots = state.slots.where((slot) => slot.isOccupied).length;
    final reservedSlots = state.slots.where((slot) => slot.isReserved).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildStatsGrid(
            totalStations,
            totalSlots,
            availableSlots,
            occupiedSlots,
            reservedSlots,
          ),
          const SizedBox(height: 24),
          _buildRecentActivity(state),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(
    int totalStations,
    int totalSlots,
    int availableSlots,
    int occupiedSlots,
    int reservedSlots,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Stations', totalStations.toString(), Colors.blue),
        _buildStatCard('Total Slots', totalSlots.toString(), Colors.green),
        _buildStatCard('Available', availableSlots.toString(), Colors.green),
        _buildStatCard('Occupied', occupiedSlots.toString(), Colors.red),
        _buildStatCard('Reserved', reservedSlots.toString(), Colors.orange),
        _buildStatCard('Utilization', '${((occupiedSlots + reservedSlots) / totalSlots * 100).toStringAsFixed(1)}%', Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(AppLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (state.userBookings.isEmpty)
              const Text('No recent bookings')
            else
              ...state.userBookings.take(5).map((booking) => _buildActivityItem(booking)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(Booking booking) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getBookingStatusColor(booking.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking ${booking.id.substring(0, 8)}...',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Status: ${booking.status.name}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${booking.price.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationsList(List<Station> stations) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stations.length,
      itemBuilder: (context, index) {
        final station = stations[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getTypeColor(station.type),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getTypeIcon(station.type),
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(station.name),
            subtitle: Text('${station.availableSlots}/${station.totalSlots} slots available'),
            trailing: PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Edit'),
                ),
                const PopupMenuItem(
                  value: 'view',
                  child: Text('View Details'),
                ),
                const PopupMenuItem(
                  value: 'maintenance',
                  child: Text('Maintenance Mode'),
                ),
              ],
              onSelected: (value) {
                _handleStationAction(value, station);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingsList(List<Booking> bookings) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: _getBookingStatusColor(booking.status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getBookingStatusIcon(booking.status),
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text('Booking ${booking.id.substring(0, 8)}...'),
            subtitle: Text('Status: ${booking.status.name}'),
            trailing: Text('₹${booking.price.toStringAsFixed(0)}'),
          ),
        );
      },
    );
  }

  void _handleStationAction(String action, Station station) {
    switch (action) {
      case 'edit':
        // TODO: Implement edit station
        break;
      case 'view':
        // TODO: Implement view station details
        break;
      case 'maintenance':
        // TODO: Implement maintenance mode
        break;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'parking':
        return Colors.green;
      case 'charging':
        return Colors.blue;
      case 'hybrid':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'parking':
        return Icons.local_parking;
      case 'charging':
        return Icons.electric_car;
      case 'hybrid':
        return Icons.ev_station;
      default:
        return Icons.location_on;
    }
  }

  Color _getBookingStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.active:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }

  IconData _getBookingStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Icons.schedule;
      case BookingStatus.active:
        return Icons.check_circle;
      case BookingStatus.completed:
        return Icons.done_all;
      case BookingStatus.cancelled:
        return Icons.cancel;
    }
  }
}
