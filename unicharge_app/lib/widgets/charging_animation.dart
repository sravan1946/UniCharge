import 'package:flutter/material.dart';

class ChargingAnimation extends StatefulWidget {
  final bool isCharging;
  final double progress;
  final double size;

  const ChargingAnimation({
    super.key,
    required this.isCharging,
    this.progress = 0.0,
    this.size = 50.0,
  });

  @override
  State<ChargingAnimation> createState() => _ChargingAnimationState();
}

class _ChargingAnimationState extends State<ChargingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isCharging) {
      _pulseController.repeat(reverse: true);
    }
    
    _progressController.forward();
  }

  @override
  void didUpdateWidget(ChargingAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isCharging != oldWidget.isCharging) {
      if (widget.isCharging) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
    
    if (widget.progress != oldWidget.progress) {
      _progressController.animateTo(widget.progress);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[200],
            ),
          ),
          
          // Progress circle
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return SizedBox(
                width: widget.size,
                height: widget.size,
                child: CircularProgressIndicator(
                  value: _progressAnimation.value,
                  strokeWidth: 4,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.isCharging ? Colors.green : Colors.blue,
                  ),
                ),
              );
            },
          ),
          
          // Charging icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isCharging ? _pulseAnimation.value : 1.0,
                child: Icon(
                  widget.isCharging ? Icons.battery_charging_full : Icons.battery_full,
                  color: widget.isCharging ? Colors.green : Colors.blue,
                  size: widget.size * 0.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class BatterySwapAnimation extends StatefulWidget {
  final bool isSwapping;
  final double size;

  const BatterySwapAnimation({
    super.key,
    required this.isSwapping,
    this.size = 50.0,
  });

  @override
  State<BatterySwapAnimation> createState() => _BatterySwapAnimationState();
}

class _BatterySwapAnimationState extends State<BatterySwapAnimation>
    with TickerProviderStateMixin {
  late AnimationController _swapController;
  late Animation<double> _swapAnimation;

  @override
  void initState() {
    super.initState();
    
    _swapController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _swapAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _swapController,
      curve: Curves.easeInOut,
    ));
    
    if (widget.isSwapping) {
      _swapController.repeat();
    }
  }

  @override
  void didUpdateWidget(BatterySwapAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isSwapping != oldWidget.isSwapping) {
      if (widget.isSwapping) {
        _swapController.repeat();
      } else {
        _swapController.stop();
      }
    }
  }

  @override
  void dispose() {
    _swapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _swapAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Battery 1
              Transform.translate(
                offset: Offset(
                  -widget.size * 0.2 * (1 - _swapAnimation.value),
                  0,
                ),
                child: Icon(
                  Icons.battery_full,
                  color: Colors.green,
                  size: widget.size * 0.4,
                ),
              ),
              
              // Swap arrow
              Icon(
                Icons.swap_horiz,
                color: Colors.blue,
                size: widget.size * 0.3,
              ),
              
              // Battery 2
              Transform.translate(
                offset: Offset(
                  widget.size * 0.2 * _swapAnimation.value,
                  0,
                ),
                child: Icon(
                  Icons.battery_charging_full,
                  color: Colors.blue,
                  size: widget.size * 0.4,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
