import 'package:flutter/material.dart';
import 'package:unicharge/models/slot_model.dart';
import 'package:unicharge/models/enums.dart';

class SlotSelector extends StatelessWidget {
  final List<SlotModel> slots;
  final String? selectedSlotId;
  final Function(String?) onSlotSelected;

  const SlotSelector({
    super.key,
    required this.slots,
    required this.selectedSlotId,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Sort slots by slotIndex
    final sortedSlots = List<SlotModel>.from(slots)
      ..sort((a, b) => a.slotIndex.compareTo(b.slotIndex));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend
        _buildLegend(context),
        
        const SizedBox(height: 16),
        
        // Slots grid
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final slot in sortedSlots)
              _buildSlotButton(context, slot),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildLegendItem(context, Colors.green, 'Available'),
          const SizedBox(width: 16),
          _buildLegendItem(context, Colors.grey, 'Occupied'),
          const SizedBox(width: 16),
          _buildLegendItem(context, Colors.orange, 'Reserved'),
          const SizedBox(width: 16),
          _buildLegendItem(context, Colors.blue, 'Selected'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(BuildContext context, Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black26),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSlotButton(BuildContext context, SlotModel slot) {
    final isSelected = slot.id == selectedSlotId;
    final color = _getSlotColor(slot.status, isSelected);
    final canSelect = slot.status == SlotStatus.available;

    return InkWell(
      onTap: canSelect
          ? () => onSlotSelected(isSelected ? null : slot.id)
          : null,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.black26,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${slot.slotIndex + 1}',
                    style: TextStyle(
                      color: _getTextColor(color),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  if (slot.type == SlotType.chargingPad)
                    Icon(
                      Icons.bolt,
                      size: 12,
                      color: _getTextColor(color),
                    ),
                ],
              ),
            ),
            // Show lock icon for unavailable slots
            if (!canSelect)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock,
                    size: 16,
                    color: _getTextColor(color),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getSlotColor(SlotStatus status, bool isSelected) {
    if (isSelected) {
      return Colors.blue;
    }

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

  Color _getTextColor(Color backgroundColor) {
    // Calculate luminance to determine text color
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}

