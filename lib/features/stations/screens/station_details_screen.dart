import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicharge/models/station_model.dart';
import 'package:unicharge/models/slot_model.dart';
import 'package:unicharge/models/enums.dart';
import 'package:unicharge/providers/stations_provider.dart';
import 'package:unicharge/providers/auth_provider.dart';
import 'package:unicharge/providers/booking_provider.dart';
import 'package:unicharge/features/stations/widgets/slot_selector.dart';
import 'package:unicharge/features/bookings/screens/booking_confirmation_screen.dart';

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
  String? _selectedSlotId;
  int _selectedDuration = 2; // hours

  @override
  Widget build(BuildContext context) {
    final slotsState = ref.watch(slotsStateProvider(widget.station.id));

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
      body: slotsState.when(
        data: (slots) => _buildStationDetails(slots),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64),
              const SizedBox(height: 16),
              Text('Error loading slots: $error'),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(slotsStateProvider(widget.station.id));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationDetails(List<SlotModel> slots) {
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
                // Duration selector
                _buildDurationSelector(),
                
                const SizedBox(height: 24),
                
                // Slot selector
                Text(
                  'Select a Slot',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                SlotSelector(
                  slots: slots,
                  selectedSlotId: _selectedSlotId,
                  onSlotSelected: (slotId) {
                    setState(() {
                      _selectedSlotId = slotId;
                    });
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Booking info
                if (_selectedSlotId != null) _buildBookingInfo(),
                
                const SizedBox(height: 24),
                
                // Book button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedSlotId != null ? () => _showBookingDialog() : null,
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
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.station.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTypeChip(widget.station.type),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.station.address,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem(Icons.access_time, '₹${widget.station.pricePerHour.toInt()}/hr'),
              const SizedBox(width: 16),
              _buildInfoItem(Icons.local_parking, '${widget.station.availableSlots}/${widget.station.totalSlots} available'),
            ],
          ),
          if (widget.station.batterySwap) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.battery_saver, size: 18, color: const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  const Text(
                    'Battery Swap Available',
                    style: TextStyle(
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final amenity in widget.station.amenities)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    amenity,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(StationType type) {
    final colorMap = {
      StationType.parking: const Color(0xFF3B82F6), // Blue
      StationType.charging: const Color(0xFF10B981), // Emerald
      StationType.hybrid: const Color(0xFFF59E0B), // Amber
    };

    final color = colorMap[type] ?? Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        type.displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('1 hr')),
                  ButtonSegment(value: 2, label: Text('2 hr')),
                  ButtonSegment(value: 4, label: Text('4 hr')),
                  ButtonSegment(value: 8, label: Text('8 hr')),
                ],
                selected: {_selectedDuration},
                onSelectionChanged: (Set<int> selection) {
                  setState(() {
                    _selectedDuration = selection.first;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBookingInfo() {
    return Consumer(
      builder: (context, ref, child) {
        final slots = ref.read(slotsStateProvider(widget.station.id)).value ?? [];
        final slot = slots.firstWhere((s) => s.id == _selectedSlotId);
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Booking Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSummaryRow('Slot Type', slot.type.displayName),
              _buildSummaryRow('Duration', '$_selectedDuration hours'),
              _buildSummaryRow('Price', '₹${(widget.station.pricePerHour * _selectedDuration).toStringAsFixed(0)}'),
              _buildSummaryRow('Total', '₹${(widget.station.pricePerHour * _selectedDuration).toStringAsFixed(0)}', isTotal: true),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: (isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                : Theme.of(context).textTheme.bodyMedium)?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog() {
    // Get slot information
    final slots = ref.read(slotsStateProvider(widget.station.id)).value ?? [];
    final selectedSlot = slots.firstWhere((s) => s.id == _selectedSlotId);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Booking'),
        content: Text(
          'Book Slot ${selectedSlot.slotIndex + 1} for $_selectedDuration hours at ${widget.station.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmBooking();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBooking() async {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please log in to book a slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      // Create booking via the booking provider
      // This will automatically set slot status to 'reserved'
      await ref.read(createBookingNotifierProvider.notifier).createBooking(
        userId: user.uid,
        stationId: widget.station.id,
        slotId: _selectedSlotId!,
        durationHours: _selectedDuration,
        pricePerHour: widget.station.pricePerHour,
      );

      if (mounted) {
        // Get the created booking to show QR code
        final bookingState = ref.read(createBookingNotifierProvider);
        bookingState.whenData((booking) {
          if (booking != null && mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BookingConfirmationScreen(booking: booking),
              ),
            );
          }
        });
        
        // If no booking data, just show success and go back
        bookingState.whenOrNull(
          data: (booking) => null, // Already handled above
          error: (error, stack) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error creating booking: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

