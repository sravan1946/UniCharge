import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicharge/core/constants/app_colors.dart';
import 'package:unicharge/models/booking_model.dart';
import 'package:unicharge/models/slot_model.dart';
import 'package:unicharge/models/enums.dart';
import 'package:unicharge/providers/stations_provider.dart';
import 'package:unicharge/providers/booking_provider.dart';
import 'package:unicharge/shared/widgets/rive_charging_widget.dart';
import 'package:unicharge/features/bookings/screens/booking_confirmation_screen.dart';

class ChargingStatusCard extends ConsumerWidget {
  final BookingModel booking;

  const ChargingStatusCard({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get slot information
    final slotState = ref.watch(slotsStateProvider(booking.stationId));
    final slot = slotState.value?.firstWhere(
      (s) => s.id == booking.slotId,
      orElse: () => SlotModel(
        id: booking.slotId,
        stationId: booking.stationId,
        slotIndex: 0,
        type: SlotType.parkingSpace,
        status: SlotStatus.available,
        lastUpdated: DateTime.now(),
      ),
    );
    
    return Card(
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF475569), // More muted blue-gray
              const Color(0xFF1E293B),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
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
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.electric_bolt,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    booking.status == BookingStatus.reserved
                        ? 'Booking Reserved'
                        : booking.status == BookingStatus.active
                            ? 'Charging in Progress'
                            : 'Session Active',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Slot ${slot?.slotIndex ?? 0}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Show different content based on booking status
            if (booking.status == BookingStatus.reserved)
              _buildReservedStatus(context, ref, booking)
            else
              _buildActiveStatus(context, slot, booking),
            
            const SizedBox(height: 20),
            
            // Action buttons
            if (booking.status == BookingStatus.reserved)
              _buildReservedActions(context, ref, booking)
            else
              _buildActiveActions(context, ref, slot, booking),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.white.withValues(alpha: 0.8),
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildReservedStatus(BuildContext context, WidgetRef ref, BookingModel booking) {
    return Column(
      children: [
        const Icon(
          Icons.schedule,
          size: 48,
          color: Colors.white70,
        ),
        const SizedBox(height: 16),
        _buildInfoItem(
          context,
          'Booking Time',
          '${booking.durationHours} hours',
          Icons.access_time,
        ),
        const SizedBox(height: 12),
        _buildInfoItem(
          context,
          'End Time',
          booking.endTime != null
              ? '${booking.endTime!.hour.toString().padLeft(2, '0')}:${booking.endTime!.minute.toString().padLeft(2, '0')}'
              : 'N/A',
          Icons.event,
        ),
      ],
    );
  }

  Widget _buildActiveStatus(BuildContext context, SlotModel? slot, BookingModel booking) {
    return Column(
      children: [
        // Charging animation
        const Center(
          child: RiveChargingWidget(
            batteryLevel: 75, // TODO: Get actual battery level
            isCharging: true,
          ),
        ),
        const SizedBox(height: 16),
        
        // Charging details
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                'Battery Level',
                '75%',
                Icons.battery_charging_full,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                context,
                booking.endTime != null ? 'Time Remaining' : 'Duration',
                booking.endTime != null
                    ? '${booking.endTime!.difference(DateTime.now()).inMinutes}min'
                    : '${booking.durationHours}h',
                Icons.timer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                context,
                'Charging Speed',
                '50 kW',
                Icons.speed,
              ),
            ),
            Expanded(
              child: _buildInfoItem(
                context,
                'Session Cost',
                '₹${booking.totalPrice.toStringAsFixed(0)}',
                Icons.currency_rupee,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReservedActions(BuildContext context, WidgetRef ref, BookingModel booking) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingConfirmationScreen(booking: booking),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code, size: 18),
                label: const Text('View QR Code', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Navigate to station
                },
                icon: const Icon(Icons.location_on, size: 18),
                label: const Text('Navigate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _cancelBooking(context, ref, booking),
                icon: const Icon(Icons.cancel, size: 18),
                label: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveActions(BuildContext context, WidgetRef ref, SlotModel? slot, BookingModel booking) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingConfirmationScreen(booking: booking),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code, size: 18),
                label: const Text('View QR Code', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // TODO: Navigate to station
                },
                icon: const Icon(Icons.location_on, size: 18),
                label: const Text('Navigate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _endBooking(context, ref, slot, booking),
                icon: const Icon(Icons.stop, size: 18),
                label: const Text('End', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _cancelBooking(BuildContext context, WidgetRef ref, BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking?'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(bookingStateProvider.notifier).cancelBooking(booking.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking cancelled successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error cancelling booking: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _endBooking(BuildContext context, WidgetRef ref, SlotModel? slot, BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session?'),
        content: const Text('Are you sure you want to end this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final slotId = slot?.id ?? booking.slotId;
                await ref.read(bookingStateProvider.notifier).completeBooking(
                  bookingId: booking.id,
                  slotId: slotId,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Session ended successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error ending session: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Yes, End'),
          ),
        ],
      ),
    );
  }
}
