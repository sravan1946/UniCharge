import 'package:flutter/material.dart';

class DebugHotReloadWidget extends StatefulWidget {
  const DebugHotReloadWidget({super.key});

  @override
  State<DebugHotReloadWidget> createState() => _DebugHotReloadWidgetState();
}

class _DebugHotReloadWidgetState extends State<DebugHotReloadWidget> {
  int _reloadCount = 0;

  @override
  void initState() {
    super.initState();
    _reloadCount++;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bug_report, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            'Hot Reload Test - Reload #$_reloadCount',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Timestamp: ${DateTime.now().millisecondsSinceEpoch}',
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            '✅ Hot reload is working! Change this widget to test.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
