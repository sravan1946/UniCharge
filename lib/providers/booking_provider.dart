import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_database_service.dart';
import '../models/booking_model.dart';
import '../models/enums.dart';

// Booking service provider
final bookingServiceProvider = Provider<FirestoreDatabaseService>((ref) {
  return FirestoreDatabaseService();
});

// User bookings provider (stream-based for real-time updates)
final userBookingsProvider = StreamProvider.family<List<BookingModel>, String>((ref, userId) {
  final databaseService = ref.watch(bookingServiceProvider);
  return databaseService.subscribeToUserBookings(userId);
});

// Active booking provider (includes reserved and active bookings) - stream-based for real-time updates
final activeBookingProvider = StreamProvider.family<BookingModel?, String>((ref, userId) {
  final databaseService = ref.watch(bookingServiceProvider);
  return databaseService.subscribeToUserBookings(userId).map((bookings) {
    return bookings.where((booking) => 
      booking.status.name == 'active' || booking.status.name == 'reserved'
    ).firstOrNull;
  });
});

// Booking state provider
final bookingStateProvider = StateNotifierProvider<BookingStateNotifier, AsyncValue<List<BookingModel>>>((ref) {
  return BookingStateNotifier(ref.watch(bookingServiceProvider));
});

// Slot availability provider
final slotAvailabilityProvider = FutureProvider.family<List<BookingModel>, String>((ref, slotId) async {
  final databaseService = ref.watch(bookingServiceProvider);
  final now = DateTime.now();
  final endOfDay = DateTime(now.year, now.month, now.day + 7); // Check next 7 days
  return await databaseService.getSlotBookings(
    slotId: slotId,
    startDate: now,
    endDate: endOfDay,
  );
});

// Check if slot is available for specific time range
final slotAvailabilityCheckProvider = FutureProvider.family<bool, Map<String, dynamic>>((ref, params) async {
  final databaseService = ref.watch(bookingServiceProvider);
  return await databaseService.isSlotAvailable(
    slotId: params['slotId'] as String,
    startTime: params['startTime'] as DateTime,
    endTime: params['endTime'] as DateTime,
  );
});

// Get detailed slot availability information
final slotAvailabilityDetailsProvider = FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
  final databaseService = ref.watch(bookingServiceProvider);
  return await databaseService.getSlotAvailabilityDetails(
    slotId: params['slotId'] as String,
    startTime: params['startTime'] as DateTime,
    endTime: params['endTime'] as DateTime,
  );
});

// Create booking notifier
final createBookingNotifierProvider = StateNotifierProvider<CreateBookingNotifier, AsyncValue<BookingModel?>>((ref) {
  return CreateBookingNotifier(ref.watch(bookingServiceProvider));
});

class BookingStateNotifier extends StateNotifier<AsyncValue<List<BookingModel>>> {
  final FirestoreDatabaseService _databaseService;

  BookingStateNotifier(this._databaseService) : super(const AsyncValue.loading());

  Future<void> loadUserBookings(String userId) async {
    try {
      if (mounted) {
        state = const AsyncValue.loading();
      }
      final bookings = await _databaseService.getUserBookings(userId);
      if (mounted) {
        state = AsyncValue.data(bookings);
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _databaseService.cancelBooking(bookingId);
      // Reload bookings to get updated data
      // Note: We'd need to store the userId to reload properly
      // For now, we'll just update the state optimistically
      if (mounted) {
        state.whenData((bookings) {
          if (mounted) {
            final updatedBookings = bookings.map((booking) {
              if (booking.id == bookingId) {
                return booking.copyWith(
                  status: BookingStatus.cancelled,
                  cancelledAt: DateTime.now(),
                  cancellationReason: 'User cancelled',
                );
              }
              return booking;
            }).toList();
            state = AsyncValue.data(updatedBookings);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Activate a reserved booking (when QR code is scanned)
  /// Sets booking status from reserved → active, slot from reserved → occupied
  Future<void> activateBooking({
    required String bookingId,
    required String slotId,
  }) async {
    try {
      await _databaseService.activateBooking(
        bookingId: bookingId,
        slotId: slotId,
      );
      // Update state optimistically
      if (mounted) {
        state.whenData((bookings) {
          if (mounted) {
            final updatedBookings = bookings.map((booking) {
              if (booking.id == bookingId) {
                return booking.copyWith(status: BookingStatus.active);
              }
              return booking;
            }).toList();
            state = AsyncValue.data(updatedBookings);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// Complete an active booking
  /// Sets booking status from active → completed, slot from occupied → available
  Future<void> completeBooking({
    required String bookingId,
    required String slotId,
  }) async {
    try {
      await _databaseService.completeBooking(
        bookingId: bookingId,
        slotId: slotId,
      );
      // Update state optimistically
      if (mounted) {
        state.whenData((bookings) {
          if (mounted) {
            final updatedBookings = bookings.map((booking) {
              if (booking.id == bookingId) {
                return booking.copyWith(status: BookingStatus.completed);
              }
              return booking;
            }).toList();
            state = AsyncValue.data(updatedBookings);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<void> refreshBookings(String userId) async {
    await loadUserBookings(userId);
  }
}

class CreateBookingNotifier extends StateNotifier<AsyncValue<BookingModel?>> {
  final FirestoreDatabaseService _databaseService;

  CreateBookingNotifier(this._databaseService) : super(const AsyncValue.data(null));

  Future<void> createBooking({
    required String userId,
    required String stationId,
    required String slotId,
    required int durationHours,
    required double pricePerHour,
    DateTime? customStartTime,
  }) async {
    try {
      if (mounted) {
        state = const AsyncValue.loading();
      }
      final booking = await _databaseService.createBooking(
        userId: userId,
        stationId: stationId,
        slotId: slotId,
        durationHours: durationHours,
        pricePerHour: pricePerHour,
        customStartTime: customStartTime,
      );
      if (mounted) {
        state = AsyncValue.data(booking);
      }
    } catch (e) {
      if (mounted) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  void reset() {
    if (mounted) {
      state = const AsyncValue.data(null);
    }
  }
}
