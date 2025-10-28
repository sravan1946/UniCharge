import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class RiveChargingWidget extends StatefulWidget {
  final int batteryLevel;
  final bool isCharging;
  final bool isSwapping;

  const RiveChargingWidget({
    super.key,
    required this.batteryLevel,
    this.isCharging = false,
    this.isSwapping = false,
  });

  @override
  State<RiveChargingWidget> createState() => _RiveChargingWidgetState();
}

class _RiveChargingWidgetState extends State<RiveChargingWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _spinController;
  late AnimationController _bounceController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _spinAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    // Pulse animation for the outer circle
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.5).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Spin animation for rotating effects
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    if (widget.isCharging) {
      _spinController.repeat();
    }

    _spinAnimation = Tween<double>(begin: 0, end: 1).animate(_spinController);

    // Bounce animation for the lightning icon
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void didUpdateWidget(RiveChargingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCharging) {
      _spinController.repeat();
    } else {
      _spinController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _spinController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  Color _getBatteryColor(int level) {
    if (level < 20) return AppColors.batteryEmpty;
    if (level < 50) return AppColors.batteryLow;
    if (level < 80) return AppColors.batteryMedium;
    return AppColors.batteryFull;
  }

  @override
  Widget build(BuildContext context) {
    final batteryColor = _getBatteryColor(widget.batteryLevel);
    
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing circle
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: PulsingCirclePainter(
                  color: batteryColor.withValues(alpha: 0.2),
                  scale: _pulseAnimation.value,
                ),
              );
            },
          ),
          
          // Main battery indicator
          CustomPaint(
            painter: ChargingPainter(
              batteryLevel: widget.batteryLevel,
              isCharging: widget.isCharging,
              batteryColor: batteryColor,
              spinProgress: _spinAnimation.value,
            ),
          ),
          
          // Animated lightning icon
          if (widget.isCharging)
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _bounceAnimation.value,
                  child: const Icon(
                    Icons.bolt,
                    color: Colors.white,
                    size: 40,
                  ),
                );
              },
            )
          else
            // Percentage text when not charging
            Text(
              '${widget.batteryLevel}%',
              style: TextStyle(
                color: batteryColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: batteryColor.withValues(alpha: 0.5),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PulsingCirclePainter extends CustomPainter {
  final Color color;
  final double scale;

  PulsingCirclePainter({required this.color, required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * scale;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(PulsingCirclePainter oldDelegate) {
    return oldDelegate.scale != scale;
  }
}

class ChargingPainter extends CustomPainter {
  final int batteryLevel;
  final bool isCharging;
  final Color batteryColor;
  final double spinProgress;

  ChargingPainter({
    required this.batteryLevel,
    required this.isCharging,
    required this.batteryColor,
    required this.spinProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;
    final fillPercentage = batteryLevel / 100.0;

    // Draw background circle
    final backgroundPaint = Paint()
      ..color = batteryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw battery ring outline
    final outlinePaint = Paint()
      ..color = batteryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, outlinePaint);

    // Draw filled arc
    final fillPaint = Paint()
      ..color = batteryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final sweepAngle = fillPercentage * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      fillPaint,
    );

    // Draw animated charging rings when charging
    if (isCharging) {
      // Outer rotating rings
      for (int i = 0; i < 3; i++) {
        final angle = (spinProgress * 2 * math.pi) + (i * 2 * math.pi / 3);
        final x = center.dx + math.cos(angle) * (radius + 15);
        final y = center.dy + math.sin(angle) * (radius + 15);
        
        final ringPaint = Paint()
          ..color = batteryColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(Offset(x, y), 8, ringPaint);
        
        // Glow effect
        final glowPaint = Paint()
          ..color = batteryColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        
        canvas.drawCircle(Offset(x, y), 32, glowPaint);
      }

      // Inner charging wave
      final waveAngle = -math.pi / 2 + (fillPercentage * 2 * math.pi);
      final wavePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 5),
        waveAngle - 0.3,
        0.6,
        false,
        wavePaint,
      );
    }

    // Draw center dot with glow
    final dotPaint = Paint()
      ..color = batteryColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 1, dotPaint);

    final glowPaint = Paint()
      ..color = batteryColor.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 32);

    canvas.drawCircle(center, 32, glowPaint);
  }

  @override
  bool shouldRepaint(ChargingPainter oldDelegate) {
    return oldDelegate.batteryLevel != batteryLevel ||
        oldDelegate.isCharging != isCharging ||
        oldDelegate.spinProgress != spinProgress;
  }
}
