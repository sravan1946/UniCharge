import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicharge/providers/auth_provider.dart';
import 'package:unicharge/providers/booking_provider.dart';
import 'package:unicharge/models/booking_model.dart';
import 'package:unicharge/models/enums.dart';

class BookingStatusAnimation extends ConsumerStatefulWidget {
  final Widget child;
  final String? bookingId;

  const BookingStatusAnimation({
    super.key,
    required this.child,
    this.bookingId,
  });

  @override
  ConsumerState<BookingStatusAnimation> createState() => _BookingStatusAnimationState();
}

class _BookingStatusAnimationState extends ConsumerState<BookingStatusAnimation>
    with TickerProviderStateMixin {
  late AnimationController _successController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _pulseAnimation;

  BookingStatus? _previousStatus;
  bool _showSuccessAnimation = false;

  @override
  void initState() {
    super.initState();
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _successController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _checkBookingStatusChange(BookingModel? booking) {
    if (booking == null) return;

    // Check if status changed from reserved to active
    if (_previousStatus == BookingStatus.reserved && 
        booking.status == BookingStatus.active) {
      _triggerSuccessAnimation();
    }

    _previousStatus = booking.status;
  }

  void _triggerSuccessAnimation() {
    // Haptic feedback
    HapticFeedback.heavyImpact();
    
    setState(() {
      _showSuccessAnimation = true;
    });

    _successController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() {
            _showSuccessAnimation = false;
          });
          _successController.reset();
        }
      });
    });

    // Start pulse animation
    _pulseController.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _pulseController.stop();
        _pulseController.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider).value;
    
    if (user == null) {
      return widget.child;
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
        return _buildWithAnimation(booking);
      },
      loading: () => widget.child,
      error: (_, __) => widget.child,
    );
  }

  Widget _buildWithAnimation(BookingModel? booking) {
    return Stack(
      children: [
        widget.child,
        if (_showSuccessAnimation) _buildSuccessOverlay(),
        if (booking?.status == BookingStatus.active) _buildActiveIndicator(booking!),
      ],
    );
  }

  Widget _buildSuccessOverlay() {
    return AnimatedBuilder(
      animation: _successController,
      builder: (context, child) {
        return Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success icon with pulse animation
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.green.withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Booking Activated!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your booking is now active',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveIndicator(BookingModel booking) {
    // Position at top-right corner as a subtle floating badge
    final appBarHeight = kToolbarHeight;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    
    return Positioned(
      top: appBarHeight + statusBarHeight + 12,
      right: 12,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Pulsing dot indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Active',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
