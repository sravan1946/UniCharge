import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/app_bloc.dart';
import '../models/station.dart';
import '../models/slot.dart';
import '../widgets/slot_grid.dart';
import '../widgets/booking_bottom_sheet.dart';

class StationDetailsScreen extends StatefulWidget {
  final Station station;

  const StationDetailsScreen({
    super.key,
    required this.station,
  });

  @override
  State<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends State<StationDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AppBloc>().add(LoadStationDetails(widget.station.id));
    context.read<AppBloc>().add(LoadSlots(widget.station.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.station.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<AppBloc>().add(LoadSlots(widget.station.id));
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
                      context.read<AppBloc>().add(LoadSlots(widget.station.id));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is AppLoaded) {
            return _buildStationDetails(state);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStationDetails(AppLoaded state) {
    final station = state.selectedStation ?? widget.station;
    final slots = state.slots;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStationInfo(station),
          const SizedBox(height: 24),
          _buildStationStats(station, slots),
          const SizedBox(height: 24),
          _buildSlotGrid(slots),
          const SizedBox(height: 24),
          _buildAmenities(station),
        ],
      ),
    );
  }

  Widget _buildStationInfo(Station station) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    station.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getTypeColor(station.type),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    station.type.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              station.address,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber[600], size: 20),
                const SizedBox(width: 4),
                Text(
                  station.rating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 16),
                Icon(Icons.attach_money, color: Colors.grey[600], size: 20),
                const SizedBox(width: 4),
                Text(
                  '₹${station.pricePerHour.toInt()}/hour',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationStats(Station station, List<Slot> slots) {
    final availableSlots = slots.where((slot) => slot.isAvailable).length;
    final occupiedSlots = slots.where((slot) => slot.isOccupied).length;
    final reservedSlots = slots.where((slot) => slot.isReserved).length;
    final maintenanceSlots = slots.where((slot) => slot.isMaintenance).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Available',
            availableSlots.toString(),
            Colors.green,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Occupied',
            occupiedSlots.toString(),
            Colors.red,
            Icons.cancel,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Reserved',
            reservedSlots.toString(),
            Colors.blue,
            Icons.schedule,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Maintenance',
            maintenanceSlots.toString(),
            Colors.orange,
            Icons.build,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlotGrid(List<Slot> slots) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select a Slot',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        SlotGrid(
          slots: slots,
          onSlotSelected: (slot) {
            if (slot.isAvailable) {
              _showBookingBottomSheet(slot);
            }
          },
        ),
      ],
    );
  }

  Widget _buildAmenities(Station station) {
    if (station.amenities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: station.amenities.map((amenity) {
            return Chip(
              label: Text(amenity),
              backgroundColor: Colors.blue[100],
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showBookingBottomSheet(Slot slot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BookingBottomSheet(
        slot: slot,
        station: widget.station,
        onBook: () {
          Navigator.pop(context);
          context.read<AppBloc>().add(ReserveSlot(slot.id, widget.station.id));
        },
      ),
    );
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
}
