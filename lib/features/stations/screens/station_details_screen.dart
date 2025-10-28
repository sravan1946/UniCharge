import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicharge/models/station_model.dart';
import 'package:unicharge/models/enums.dart';
import 'package:unicharge/features/stations/screens/multi_step_booking_screen.dart';

class StationDetailsScreen extends ConsumerStatefulWidget {
  final StationModel station;

  const StationDetailsScreen({
    super.key,
    required this.station,
  });

  @override
  ConsumerState<StationDetailsScreen> createState() => _StationDetailsScreenState();
}

class _StationDetailsScreenState extends ConsumerState<StationDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.station.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              // TODO: Show on map
            },
          ),
        ],
      ),
      body: _buildStationDetails(),
    );
  }

  Widget _buildStationDetails() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Station info card
          _buildStationInfoCard(),
          
          const SizedBox(height: 16),
          
          // Booking section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Book a Slot',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose your preferred time and slot',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Book button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MultiStepBookingScreen(
                            station: widget.station,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Book Slot',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationInfoCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.ev_station,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.station.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTypeChip(widget.station.type),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Station details
          _buildInfoItem(Icons.location_on, widget.station.address),
          _buildInfoItem(Icons.attach_money, '₹${widget.station.pricePerHour.toStringAsFixed(0)}/hour'),
          _buildInfoItem(Icons.layers, '${widget.station.totalSlots} total slots'),
          _buildInfoItem(Icons.check_circle, '${widget.station.availableSlots} available slots'),
        ],
      ),
    );
  }

  Widget _buildTypeChip(StationType type) {
    final (text, color) = switch (type) {
      StationType.charging => ('Charging Station', Colors.blue),
      StationType.parking => ('Parking Station', Colors.green),
      StationType.hybrid => ('Hybrid Station', Colors.purple),
    };
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
