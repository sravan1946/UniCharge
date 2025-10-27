import 'package:flutter/material.dart';
import '../models/slot.dart';

class SlotGrid extends StatelessWidget {
  final List<Slot> slots;
  final Function(Slot) onSlotSelected;

  const SlotGrid({
    super.key,
    required this.slots,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Group slots by type for better organization
    final parkingSlots = slots.where((slot) => slot.type == SlotType.parkingSpace).toList();
    final chargingSlots = slots.where((slot) => slot.type == SlotType.chargingPad).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (parkingSlots.isNotEmpty) ...[
          _buildSlotSection('Parking Spaces', parkingSlots, context),
          const SizedBox(height: 24),
        ],
        if (chargingSlots.isNotEmpty) ...[
          _buildSlotSection('Charging Pads', chargingSlots, context),
        ],
      ],
    );
  }

  Widget _buildSlotSection(String title, List<Slot> slots, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
          ),
          itemCount: slots.length,
          itemBuilder: (context, index) {
            final slot = slots[index];
            return _buildSlotItem(slot, context);
          },
        ),
      ],
    );
  }

  Widget _buildSlotItem(Slot slot, BuildContext context) {
    return GestureDetector(
      onTap: () => onSlotSelected(slot),
      child: Container(
        decoration: BoxDecoration(
          color: _getSlotColor(slot),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getSlotBorderColor(slot),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getSlotIcon(slot),
              color: _getSlotIconColor(slot),
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              '${slot.slotIndex}',
              style: TextStyle(
                color: _getSlotTextColor(slot),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (slot.batteryStatus != null) ...[
              const SizedBox(height: 2),
              Icon(
                _getBatteryIcon(slot.batteryStatus!),
                color: _getBatteryColor(slot.batteryStatus!),
                size: 12,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getSlotColor(Slot slot) {
    switch (slot.status) {
      case SlotStatus.available:
        return Colors.white;
      case SlotStatus.occupied:
        return Colors.red[100]!;
      case SlotStatus.reserved:
        return Colors.blue[100]!;
      case SlotStatus.maintenance:
        return Colors.orange[100]!;
    }
  }

  Color _getSlotBorderColor(Slot slot) {
    switch (slot.status) {
      case SlotStatus.available:
        return Colors.green;
      case SlotStatus.occupied:
        return Colors.red;
      case SlotStatus.reserved:
        return Colors.blue;
      case SlotStatus.maintenance:
        return Colors.orange;
    }
  }

  Color _getSlotIconColor(Slot slot) {
    switch (slot.status) {
      case SlotStatus.available:
        return Colors.green;
      case SlotStatus.occupied:
        return Colors.red;
      case SlotStatus.reserved:
        return Colors.blue;
      case SlotStatus.maintenance:
        return Colors.orange;
    }
  }

  Color _getSlotTextColor(Slot slot) {
    switch (slot.status) {
      case SlotStatus.available:
        return Colors.green[800]!;
      case SlotStatus.occupied:
        return Colors.red[800]!;
      case SlotStatus.reserved:
        return Colors.blue[800]!;
      case SlotStatus.maintenance:
        return Colors.orange[800]!;
    }
  }

  IconData _getSlotIcon(Slot slot) {
    switch (slot.type) {
      case SlotType.parkingSpace:
        return Icons.local_parking;
      case SlotType.chargingPad:
        return Icons.electric_car;
    }
  }

  IconData _getBatteryIcon(BatteryStatus status) {
    switch (status) {
      case BatteryStatus.charged:
        return Icons.battery_full;
      case BatteryStatus.charging:
        return Icons.battery_charging_full;
      case BatteryStatus.swapped:
        return Icons.swap_horiz;
      case BatteryStatus.empty:
        return Icons.battery_alert;
    }
  }

  Color _getBatteryColor(BatteryStatus status) {
    switch (status) {
      case BatteryStatus.charged:
        return Colors.green;
      case BatteryStatus.charging:
        return Colors.blue;
      case BatteryStatus.swapped:
        return Colors.purple;
      case BatteryStatus.empty:
        return Colors.red;
    }
  }
}
