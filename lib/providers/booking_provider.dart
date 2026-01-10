import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/appwrite_database_service.dart';
import '../models/booking_model.dart';
import '../models/enums.dart';

// Booking service provider
final bookingServiceProvider = Provider<AppwriteDatabaseService>((ref) {
  return AppwriteDatabaseService();
});

// User bookings provider
final userBookingsProvider = FutureProvider.family<List<BookingModel>, String>((ref, userId) async {
  final databaseService = ref.watch(bookingServiceProvider);
  return await databaseService.getUserBookings(userId);
});

// Active booking provider
final activeBookingProvider = FutureProvider.family<BookingModel?, String>((ref, userId) async {
  final bookings = await ref.watch(userBookingsProvider(userId).future);
  return bookings.where((booking) => booking.status.name == 'active').firstOrNull;
});

// Booking state provider
final bookingStateProvider = StateNotifierProvider<BookingStateNotifier, AsyncValue<List<BookingModel>>>((ref) {
  return BookingStateNotifier(ref.watch(bookingServiceProvider));
});

// Create booking notifier
final createBookingNotifierProvider = StateNotifierProvider<CreateBookingNotifier, AsyncValue<BookingModel?>>((ref) {
  return CreateBookingNotifier(ref.watch(bookingServiceProvider));
});

class BookingStateNotifier extends StateNotifier<AsyncValue<List<BookingModel>>> {
  final AppwriteDatabaseService _databaseService;

  BookingStateNotifier(this._databaseService) : super(const AsyncValue.loading());

  Future<void> loadUserBookings(String userId) async {
    try {
      state = const AsyncValue.loading();
      final bookings = await _databaseService.getUserBookings(userId);
      state = AsyncValue.data(bookings);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    try {
      await _databaseService.cancelBooking(bookingId);
      // Reload bookings to get updated data
      // Note: We'd need to store the userId to reload properly
      // For now, we'll just update the state optimistically
      state.whenData((bookings) {
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
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> refreshBookings(String userId) async {
    await loadUserBookings(userId);
  }
}

class CreateBookingNotifier extends StateNotifier<AsyncValue<BookingModel?>> {
  final AppwriteDatabaseService _databaseService;

  CreateBookingNotifier(this._databaseService) : super(const AsyncValue.data(null));

  Future<void> createBooking({
    required String userId,
    required String stationId,
    required String slotId,
    required int durationHours,
    required double pricePerHour,
  }) async {
    try {
      state = const AsyncValue.loading();
      final booking = await _databaseService.createBooking(
        userId: userId,
        stationId: stationId,
        slotId: slotId,
        durationHours: durationHours,
        pricePerHour: pricePerHour,
      );
      state = AsyncValue.data(booking);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
