import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicharge/providers/permission_provider.dart';

class PermissionDialog extends ConsumerWidget {
  final VoidCallback onDismiss;
  final bool isDismissible;

  const PermissionDialog({
    super.key,
    required this.onDismiss,
    this.isDismissible = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionState = ref.watch(permissionStateProvider);

    return WillPopScope(
      onWillPop: () async => isDismissible,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Location Permission Required',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'ParkCharge needs your location to show nearby charging stations and help you navigate to them.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Benefits list
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildBenefitItem(context, Icons.map, 'Find nearby stations'),
                    const SizedBox(height: 8),
                    _buildBenefitItem(context, Icons.directions, 'Get directions'),
                    const SizedBox(height: 8),
                    _buildBenefitItem(context, Icons.route, 'Track your location'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Buttons
              permissionState.when(
                data: (status) {
                  if (status == PermissionStatus.deniedForever) {
                    return _buildDeniedForeverButtons(context, ref);
                  }
                  return _buildPermissionButtons(context, ref);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildPermissionButtons(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionButtons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              if (isDismissible) {
                Navigator.of(context).pop();
                onDismiss();
              }
            },
            child: const Text('Not Now'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => _requestPermissions(context, ref),
            child: const Text('Allow Access'),
          ),
        ),
      ],
    );
  }

  Widget _buildDeniedForeverButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Text(
          'Location permission was permanently denied. Please enable it in app settings.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (isDismissible) {
                    Navigator.of(context).pop();
                    onDismiss();
                  }
                },
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => _openSettings(context, ref),
                child: const Text('Open Settings'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _requestPermissions(BuildContext context, WidgetRef ref) async {
    final permissionService = ref.read(permissionServiceProvider);
    final status = await permissionService.requestLocationPermission();

    if (status == PermissionStatus.granted) {
      if (context.mounted) {
        Navigator.of(context).pop();
        onDismiss();
      }
    } else if (status == PermissionStatus.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied permanently. Please enable it in settings.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _openSettings(BuildContext context, WidgetRef ref) async {
    final permissionService = ref.read(permissionServiceProvider);
    await permissionService.openAppSettings();
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    onDismiss();
  }
}

