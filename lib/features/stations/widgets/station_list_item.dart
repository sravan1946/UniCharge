import 'package:flutter/material.dart';
import 'package:unicharge/models/station_model.dart';
import 'package:unicharge/models/enums.dart';
import 'package:unicharge/core/constants/app_colors.dart';

class StationListItem extends StatelessWidget {
  final StationModel station;
  final VoidCallback onTap;

  const StationListItem({
    super.key,
    required this.station,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Station name and type
              Row(
                children: [
                  Expanded(
                    child: Text(
                      station.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildTypeChip(context),
                ],
              ),
              const SizedBox(height: 8),
              
              // Address
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      station.address,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Station details
              Row(
                children: [
                  _buildInfoItem(
                    context,
                    '${station.availableSlots}/${station.totalSlots}',
                    'Available',
                    Icons.local_parking,
                    station.availableSlots > 0 ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 16),
                  _buildInfoItem(
                    context,
                    '₹${station.pricePerHour.toInt()}/hr',
                    'Price',
                    Icons.currency_rupee,
                    AppColors.primary,
                  ),
                  const SizedBox(width: 16),
                  if (station.batterySwap)
                    _buildInfoItem(
                      context,
                      'Swap',
                      'Battery',
                      Icons.swap_horiz,
                      AppColors.warning,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Amenities
              if (station.amenities.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: station.amenities.take(3).map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        amenity,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (station.type) {
      case StationType.charging:
        color = AppColors.success;
        icon = Icons.electric_bolt;
        label = 'Charging';
        break;
      case StationType.parking:
        color = AppColors.warning;
        icon = Icons.local_parking;
        label = 'Parking';
        break;
      case StationType.hybrid:
        color = AppColors.primary;
        icon = Icons.electric_car;
        label = 'Hybrid';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
