import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicharge/core/constants/app_colors.dart';
import 'package:unicharge/models/booking_model.dart';
import 'package:unicharge/models/slot_model.dart';
import 'package:unicharge/models/enums.dart';
import 'package:unicharge/providers/stations_provider.dart';
import 'package:unicharge/shared/widgets/rive_charging_widget.dart';

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
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: AppColors.primaryGradient,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.electric_bolt,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Charging in Progress',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
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
            const SizedBox(height: 16),
            
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
                    'Time Remaining',
                    '2h 15m',
                    Icons.timer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
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
            const SizedBox(height: 20),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to station
                    },
                    icon: const Icon(Icons.location_on, size: 18),
                    label: const Text('Navigate', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: End session
                    },
                    icon: const Icon(Icons.stop, size: 18),
                    label: const Text('End', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
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
}
