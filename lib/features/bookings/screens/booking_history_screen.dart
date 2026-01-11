import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/booking_provider.dart';
import '../../../services/firestore_database_service.dart';
import '../../../models/station_model.dart';
import '../../../models/booking_model.dart';
import '../../../models/enums.dart';

class BookingHistoryScreen extends ConsumerWidget {
  const BookingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).value;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view booking history'),
        ),
      );
    }

    final bookingsState = ref.watch(userBookingsProvider(user.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(userBookingsProvider(user.uid));
            },
          ),
        ],
      ),
      body: bookingsState.when(
        data: (bookings) {
          if (bookings.isEmpty) {
            return _buildEmptyState(context);
          }

          // Group bookings by date
          final groupedBookings = _groupBookingsByDate(bookings);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userBookingsProvider(user.uid));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: groupedBookings.length,
              itemBuilder: (context, index) {
                final entry = groupedBookings.entries.elementAt(index);
                final date = entry.key;
                final dayBookings = entry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _formatDateHeader(date),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    // Bookings for this date
                    ...dayBookings.map((booking) => _buildBookingCard(context, booking)),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No Booking History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your booking history will appear here once you make your first booking.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingModel booking) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FutureBuilder<StationModel>(
        future: FirestoreDatabaseService().getStationById(booking.stationId),
        builder: (context, snapshot) {
          final stationName = snapshot.hasData ? snapshot.data!.name : 'Loading...';
          
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stationName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatBookingTime(booking),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(context, booking.status),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      context,
                      Icons.access_time,
                      '${booking.durationHours}h',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      context,
                      Icons.attach_money,
                      '₹${booking.totalPrice.toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, BookingStatus status) {
    final (text, color) = _getStatusInfo(status);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _getStatusInfo(BookingStatus status) {
    switch (status) {
      case BookingStatus.completed:
        return ('Completed', Colors.green);
      case BookingStatus.active:
        return ('Active', Colors.blue);
      case BookingStatus.reserved:
        return ('Reserved', Colors.orange);
      case BookingStatus.pending:
        return ('Pending', Colors.yellow.shade700);
      case BookingStatus.cancelled:
        return ('Cancelled', Colors.red);
    }
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final bookingDate = DateTime(date.year, date.month, date.day);

    if (bookingDate == today) {
      return 'Today';
    } else if (bookingDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('EEEE, MMM d, yyyy').format(date);
    }
  }

  String _formatBookingTime(BookingModel booking) {
    final startTime = DateFormat('h:mm a').format(booking.startTime);
    if (booking.endTime != null) {
      final endTime = DateFormat('h:mm a').format(booking.endTime!);
      return '$startTime - $endTime';
    }
    return startTime;
  }

  Map<DateTime, List<BookingModel>> _groupBookingsByDate(List<BookingModel> bookings) {
    final Map<DateTime, List<BookingModel>> grouped = {};
    
    for (final booking in bookings) {
      final date = DateTime(
        booking.startTime.year,
        booking.startTime.month,
        booking.startTime.day,
      );
      
      if (grouped[date] == null) {
        grouped[date] = [];
      }
      grouped[date]!.add(booking);
    }
    
    // Sort by date (newest first)
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    
    return Map.fromEntries(sortedEntries);
  }
}
