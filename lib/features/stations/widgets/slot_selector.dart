import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicharge/models/slot_model.dart';
import 'package:unicharge/models/booking_model.dart';
import 'package:unicharge/models/enums.dart';

class SlotSelector extends ConsumerWidget {
  final List<SlotModel> slots;
  final String? selectedSlotId;
  final Function(String?) onSlotSelected;
  final Map<String, List<BookingModel>> slotBookings;

  const SlotSelector({
    super.key,
    required this.slots,
    required this.selectedSlotId,
    required this.onSlotSelected,
    required this.slotBookings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sort slots by slotIndex
    final sortedSlots = List<SlotModel>.from(slots)
      ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Select a slot and choose your time',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Slots list with timeline
        ...sortedSlots.map((slot) {
          final isSelected = slot.id == selectedSlotId;
          final bookings = slotBookings[slot.id] ?? [];
          final isOccupied = slot.status == SlotStatus.occupied;
          final isMaintenance = slot.status == SlotStatus.maintenance;
          final isSelectable = !isOccupied && !isMaintenance;
          
          return _buildSlotCard(context, slot, isSelected, bookings, isSelectable);
        }),
      ],
    );
  }

  Widget _buildSlotCard(
    BuildContext context,
    SlotModel slot,
    bool isSelected,
    List<BookingModel> bookings,
    bool isSelectable,
  ) {
    final now = DateTime.now();
    
    // Generate time slots (every 30 minutes from 8 AM to 10 PM)
    final timeSlots = <DateTime>[];
    for (var hour = 8; hour < 22; hour++) {
      timeSlots.add(DateTime(now.year, now.month, now.day, hour, 0));
      if (hour < 21) {
        timeSlots.add(DateTime(now.year, now.month, now.day, hour, 30));
      }
    }

    // Determine which slots are booked
    final bookedSlots = <DateTime>{};
    for (final booking in bookings) {
      final start = booking.startTime;
      final end = booking.endTime ?? start.add(Duration(hours: booking.durationHours));
      
      // Check each 30-minute slot
      for (final slotTime in timeSlots) {
        if (slotTime.isBefore(end) && slotTime.add(const Duration(minutes: 30)).isAfter(start)) {
          bookedSlots.add(slotTime);
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slot header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Slot number badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : _getStatusColor(slot.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${slot.slotIndex + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.white,
                        ),
                      ),
                      if (slot.type == SlotType.chargingPad)
                        Icon(
                          Icons.bolt,
                          size: 16,
                          color: Colors.white,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                
                // Slot info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Slot ${slot.slotIndex + 1}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusChip(context, slot.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSlotTypeText(slot.type),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                
                // Selection indicator
                IconButton(
                  icon: Icon(
                    isSelected 
                        ? Icons.radio_button_checked 
                        : Icons.radio_button_unchecked,
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                  onPressed: isSelectable
                      ? () => onSlotSelected(isSelected ? null : slot.id)
                      : null,
                ),
              ],
            ),
          ),
          
          // Timeline
          if (isSelected) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Availability Timeline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTimeline(context, timeSlots, bookedSlots),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<DateTime> timeSlots, Set<DateTime> bookedSlots) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: timeSlots.map((slotTime) {
          final isBooked = bookedSlots.contains(slotTime);
          final isHalfHour = slotTime.minute == 30;
          
          // Only show full hours at the top
          if (isHalfHour) {
            return Container(
              width: 30,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: isBooked ? Colors.red.shade200 : Colors.green.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            );
          }
          
          // Show hour labels and visual indicators
          return Container(
            width: 40,
            margin: const EdgeInsets.only(right: 4),
            child: SizedBox(
              height: 60,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hour label
                  Text(
                    '${slotTime.hour}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Status indicator
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: isBooked 
                          ? Colors.red.shade300 
                          : Colors.green.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Full hour indicator
                  if (!isHalfHour)
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: isBooked 
                            ? Colors.red.shade400 
                            : Colors.green.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, SlotStatus status) {
    final (text, color, icon) = _getStatusInfo(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color, IconData) _getStatusInfo(SlotStatus status) {
    switch (status) {
      case SlotStatus.available:
        return ('Available', Colors.green, Icons.check_circle);
      case SlotStatus.occupied:
        return ('Occupied', Colors.grey, Icons.event_busy);
      case SlotStatus.reserved:
        return ('Reserved', Colors.orange, Icons.schedule);
      case SlotStatus.maintenance:
        return ('Maintenance', Colors.red, Icons.build);
    }
  }

  Color _getStatusColor(SlotStatus status) {
    switch (status) {
      case SlotStatus.available:
        return Colors.green;
      case SlotStatus.occupied:
        return Colors.grey.shade600;
      case SlotStatus.reserved:
        return Colors.orange.shade600;
      case SlotStatus.maintenance:
        return Colors.red;
    }
  }

  String _getSlotTypeText(SlotType type) {
    switch (type) {
      case SlotType.parkingSpace:
        return 'Parking Space';
      case SlotType.chargingPad:
        return 'Charging Pad';
    }
  }
}
