import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/appwrite_service.dart';
import '../services/auth_state.dart';
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
  List<Slot> _slots = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  final _appwriteService = AppwriteService();

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final slots = await _appwriteService.getSlots(widget.station.id);
      setState(() {
        _slots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _reserveSlot(Slot slot) async {
    final authState = context.read<AuthState>();
    if (authState.currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _appwriteService.createBooking(
        userId: authState.currentUser!.id,
        stationId: widget.station.id,
        slotId: slot.id,
        price: widget.station.pricePerHour,
      );

      await _appwriteService.updateSlot(slot.id, {
        'status': 'reserved',
        'reserved_by': authState.currentUser!.id,
      });

      // Reload slots
      await _loadSlots();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Slot reserved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reserve slot: $e')),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.station.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSlots,
          ),
        ],
      ),
      body: _buildBody(),
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
              onPressed: _loadSlots,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStationInfo(widget.station),
          const SizedBox(height: 24),
          _buildStationStats(widget.station, _slots),
          const SizedBox(height: 24),
          _buildSlotGrid(_slots),
          const SizedBox(height: 24),
          _buildAmenities(widget.station),
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
          _reserveSlot(slot);
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
