import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicharge/providers/auth_provider.dart';
import 'package:unicharge/providers/realtime_provider.dart';
import 'package:unicharge/models/booking_model.dart';
import 'package:unicharge/models/enums.dart';

class BookingNotification extends ConsumerStatefulWidget {
  const BookingNotification({super.key});

  @override
  ConsumerState<BookingNotification> createState() => _BookingNotificationState();
}

class _BookingNotificationState extends ConsumerState<BookingNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  BookingStatus? _previousStatus;
  bool _showNotification = false;
  String _notificationMessage = '';

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _checkBookingStatusChange(BookingModel? booking) {
    if (booking == null) return;

    // Check if status changed from reserved to active
    if (_previousStatus == BookingStatus.reserved && 
        booking.status == BookingStatus.active) {
      _showBookingActivatedNotification();
    }
    // Check if status changed from active to completed
    else if (_previousStatus == BookingStatus.active && 
             booking.status == BookingStatus.completed) {
      _showBookingCompletedNotification();
    }

    _previousStatus = booking.status;
  }

  void _showBookingActivatedNotification() {
    // Haptic feedback
    HapticFeedback.mediumImpact();
    
    setState(() {
      _showNotification = true;
      _notificationMessage = '🎉 Your booking has been activated!';
    });

    _slideController.forward();
    _fadeController.forward();

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _hideNotification();
      }
    });
  }

  void _showBookingCompletedNotification() {
    setState(() {
      _showNotification = true;
      _notificationMessage = '✅ Your session has ended';
    });

    _slideController.forward();
    _fadeController.forward();

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _hideNotification();
      }
    });
  }

  void _hideNotification() {
    _slideController.reverse();
    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showNotification = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    
    if (user == null) {
      return const SizedBox.shrink();
    }

    // Listen to user's active booking for real-time updates
    final activeBooking = ref.watch(activeBookingProvider(user.uid));

    return activeBooking.when(
      data: (booking) {
        if (booking != null) {
          // Check for status changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkBookingStatusChange(booking);
          });
        }
        return _buildNotification();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildNotification() {
    if (!_showNotification) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _notificationMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _hideNotification,
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
