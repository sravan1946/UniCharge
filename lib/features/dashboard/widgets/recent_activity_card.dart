import 'package:flutter/material.dart';

class RecentActivityCard extends StatelessWidget {
  const RecentActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for recent activity
    final activities = [
      {
        'station': 'MG Road Charging Hub',
        'date': 'Today, 2:30 PM',
        'duration': '2h 15m',
        'cost': '₹150',
        'status': 'completed',
      },
      {
        'station': 'Koramangala Tech Park',
        'date': 'Yesterday, 6:45 PM',
        'duration': '1h 30m',
        'cost': '₹100',
        'status': 'completed',
      },
      {
        'station': 'Whitefield Mall Station',
        'date': '2 days ago, 10:15 AM',
        'duration': '3h 45m',
        'cost': '₹225',
        'status': 'completed',
      },
    ];

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Sessions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...activities.map((activity) => _buildActivityItem(context, activity)),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Navigate to full history
                },
                child: const Text('View All History'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, Map<String, String> activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['station']!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity['date']!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                activity['duration']!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                activity['cost']!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
