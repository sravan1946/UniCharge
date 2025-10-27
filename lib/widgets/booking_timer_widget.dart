import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicharge/models/booking_model.dart';
import 'package:unicharge/models/enums.dart';
import 'package:unicharge/providers/booking_provider.dart';

/// A widget that automatically completes a booking when end time is reached
class BookingTimerWidget extends ConsumerStatefulWidget {
  final BookingModel booking;
  final Widget child;

  const BookingTimerWidget({
    super.key,
    required this.booking,
    required this.child,
  });

  @override
  ConsumerState<BookingTimerWidget> createState() => _BookingTimerWidgetState();
}

class _BookingTimerWidgetState extends ConsumerState<BookingTimerWidget> {
  Timer? _completionTimer;

  @override
  void initState() {
    super.initState();
    _scheduleCompletion();
  }

  @override
  void didUpdateWidget(BookingTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.booking.id != widget.booking.id ||
        oldWidget.booking.endTime != widget.booking.endTime) {
      _completionTimer?.cancel();
      _scheduleCompletion();
    }
  }

  void _scheduleCompletion() {
    if (widget.booking.endTime == null) {
      return;
    }

    final now = DateTime.now();
    final endTime = widget.booking.endTime!;
    
    if (endTime.isBefore(now)) {
      // End time has passed, complete immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _completeBooking();
      });
      return;
    }

    // Schedule completion for end time
    final duration = endTime.difference(now);
    _completionTimer = Timer(duration, () {
      _completeBooking();
    });
  }

  Future<void> _completeBooking() async {
    try {
      // Only complete if booking is still active or reserved
      if (widget.booking.status == BookingStatus.active ||
          widget.booking.status == BookingStatus.reserved) {
        
        await ref.read(bookingStateProvider.notifier).completeBooking(
          bookingId: widget.booking.id,
          slotId: widget.booking.slotId,
        );

        // Show notification if mounted
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your booking has been completed automatically'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Handle error silently to avoid disrupting user experience
      debugPrint('Error auto-completing booking: $e');
    }
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

