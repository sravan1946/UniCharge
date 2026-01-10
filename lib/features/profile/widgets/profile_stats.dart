import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../services/firestore_database_service.dart';

class ProfileStats extends ConsumerWidget {
  const ProfileStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) return const SizedBox.shrink();
    return FutureBuilder(
      future: FirestoreDatabaseService().getUserProfile(user.uid),
      builder: (context, snapshot) {
        final profile = snapshot.data;
        final bookingsState = ref.watch(userBookingsProvider(user.uid));
        
        return bookingsState.when(
          data: (bookings) {
            final totalBookings = bookings.length;
            final totalHours = bookings.fold<double>(
              0.0,
              (sum, booking) => sum + booking.durationHours,
            );
            final loyaltyPoints = profile?.loyaltyPoints ?? 0;
            final moneySaved = (totalBookings * 50).toString(); // Rough estimate
            
            return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Statistics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats grid
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            totalBookings.toString(),
                            'Total Bookings',
                            Icons.book_online,
                            AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            totalHours.toStringAsFixed(0),
                            'Hours Parked',
                            Icons.access_time,
                            AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            context,
                            loyaltyPoints.toString(),
                            'Loyalty Points',
                            Icons.stars,
                            AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatItem(
                            context,
                            '₹$moneySaved',
                            'Money Saved',
                            Icons.savings,
                            AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Achievement section
                    Text(
                      'Achievements',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildAchievement(
                          context,
                          totalBookings > 0 ? 'First Booking' : 'Get Started',
                          Icons.emoji_events,
                          totalBookings > 0 ? AppColors.warning : Colors.grey,
                          unlocked: totalBookings > 0,
                        ),
                        const SizedBox(width: 12),
                        _buildAchievement(
                          context,
                          totalBookings >= 10 ? '10 Bookings' : 'Keep Going',
                          Icons.local_fire_department,
                          totalBookings >= 10 ? AppColors.error : Colors.grey,
                          unlocked: totalBookings >= 10,
                        ),
                        const SizedBox(width: 12),
                        _buildAchievement(
                          context,
                          totalHours >= 100 ? '100 Hours' : 'Keep Going',
                          Icons.timer,
                          totalHours >= 100 ? AppColors.primary : Colors.grey,
                          unlocked: totalHours >= 100,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (e, stack) => Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Error loading stats: $e'),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievement(
    BuildContext context,
    String title,
    IconData icon,
    Color color, {
    bool unlocked = true,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
