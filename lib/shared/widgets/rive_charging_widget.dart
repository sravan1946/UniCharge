import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
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

class _RiveChargingWidgetState extends State<RiveChargingWidget> {
  Artboard? _artboard;
  StateMachineController? _controller;
  SMIInput<double>? _batteryLevelInput;
  SMIBool? _isChargingInput;
  SMIBool? _isSwappingInput;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  void _loadRiveFile() {
    // For now, we'll create a simple animated widget
    // In a real implementation, you'd load a .riv file
    // rootBundle.load('assets/animations/charging_animation.riv').then(
    //   (data) async {
    //     final file = RiveFile.import(data);
    //     final artboard = file.mainArtboard;
    //     final controller = StateMachineController.fromArtboard(artboard, 'StateMachine');
    //     if (controller != null) {
    //       artboard.addController(controller);
    //       _batteryLevelInput = controller.findInput<double>('batteryLevel');
    //       _isChargingInput = controller.findInput<bool>('isCharging');
    //       _isSwappingInput = controller.findInput<bool>('isSwapping');
    //     }
    //     setState(() {
    //       _artboard = artboard;
    //       _controller = controller;
    //     });
    //   },
    // );
  }

  @override
  void didUpdateWidget(RiveChargingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.batteryLevel != widget.batteryLevel) {
      _batteryLevelInput?.value = widget.batteryLevel.toDouble();
    }
    if (oldWidget.isCharging != widget.isCharging) {
      _isChargingInput?.value = widget.isCharging;
    }
    if (oldWidget.isSwapping != widget.isSwapping) {
      _isSwappingInput?.value = widget.isSwapping;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_artboard != null) {
      return SizedBox(
        width: 200,
        height: 200,
        child: Rive(
          artboard: _artboard!,
          fit: BoxFit.contain,
        ),
      );
    }

    // Fallback widget when Rive file is not loaded
    return _buildFallbackWidget();
  }

  Widget _buildFallbackWidget() {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.chargingGradient,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Battery icon
          Icon(
            Icons.battery_charging_full,
            size: 80,
            color: Colors.white,
          ),
          
          // Battery level text
          Positioned(
            bottom: 40,
            child: Text(
              '${widget.batteryLevel}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Charging indicator
          if (widget.isCharging)
            Positioned(
              top: 20,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const AnimatedOpacity(
                  opacity: 0.5,
                  duration: Duration(milliseconds: 1000),
                  child: Icon(
                    Icons.electric_bolt,
                    size: 4,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          
          // Swapping indicator
          if (widget.isSwapping)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.swap_horiz,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
