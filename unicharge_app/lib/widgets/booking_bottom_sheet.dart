import 'package:flutter/material.dart';
import '../models/slot.dart';
import '../models/station.dart';

class BookingBottomSheet extends StatefulWidget {
  final Slot slot;
  final Station station;
  final VoidCallback onBook;

  const BookingBottomSheet({
    super.key,
    required this.slot,
    required this.station,
    required this.onBook,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  int _duration = 1; // hours
  String _notes = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Book Slot ${widget.slot.slotIndex}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            widget.station.name,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 20),
          _buildSlotInfo(),
          const SizedBox(height: 20),
          _buildDurationSelector(),
          const SizedBox(height: 20),
          _buildNotesField(),
          const SizedBox(height: 20),
          _buildPriceInfo(),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildSlotInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getSlotColor(widget.slot),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getSlotIcon(widget.slot),
              color: _getSlotIconColor(widget.slot),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Slot ${widget.slot.slotIndex}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  widget.slot.type == SlotType.parkingSpace
                      ? 'Parking Space'
                      : 'Charging Pad',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                if (widget.slot.batteryStatus != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        _getBatteryIcon(widget.slot.batteryStatus!),
                        color: _getBatteryColor(widget.slot.batteryStatus!),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getBatteryStatusText(widget.slot.batteryStatus!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getBatteryColor(widget.slot.batteryStatus!),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _duration.toDouble(),
                min: 1,
                max: 24,
                divisions: 23,
                label: '$_duration hour${_duration > 1 ? 's' : ''}',
                onChanged: (value) {
                  setState(() {
                    _duration = value.round();
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$_duration hour${_duration > 1 ? 's' : ''}',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: (value) {
            setState(() {
              _notes = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Add any special instructions...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPriceInfo() {
    final totalPrice = widget.station.pricePerHour * _duration;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Price',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '₹${totalPrice.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            '₹${widget.station.pricePerHour.toInt()}/hour × $_duration hour${_duration > 1 ? 's' : ''}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: widget.onBook,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Book Now'),
          ),
        ),
      ],
    );
  }

  Color _getSlotColor(Slot slot) {
    switch (slot.status) {
      case SlotStatus.available:
        return Colors.green[100]!;
      case SlotStatus.occupied:
        return Colors.red[100]!;
      case SlotStatus.reserved:
        return Colors.blue[100]!;
      case SlotStatus.maintenance:
        return Colors.orange[100]!;
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

  String _getBatteryStatusText(BatteryStatus status) {
    switch (status) {
      case BatteryStatus.charged:
        return 'Fully Charged';
      case BatteryStatus.charging:
        return 'Charging';
      case BatteryStatus.swapped:
        return 'Battery Swapped';
      case BatteryStatus.empty:
        return 'Empty';
    }
  }
}
