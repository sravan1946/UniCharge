import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicharge/features/dashboard/screens/dashboard_screen.dart';
import 'package:unicharge/features/map/screens/map_screen.dart';
import 'package:unicharge/features/stations/screens/stations_list_screen.dart';
import 'package:unicharge/features/profile/screens/profile_screen.dart';
import 'package:unicharge/providers/permission_provider.dart';
import 'package:unicharge/providers/location_provider.dart';
import 'package:unicharge/shared/widgets/permission_dialog.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key});

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  int _currentIndex = 0;
  bool _hasShownPermissionDialog = false;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const MapScreen(),
    const StationsListScreen(),
    const ProfileScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
      'label': 'Dashboard',
    },
    {
      'icon': Icons.map_outlined,
      'activeIcon': Icons.map,
      'label': 'Map',
    },
    {
      'icon': Icons.list_outlined,
      'activeIcon': Icons.list,
      'label': 'Stations',
    },
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Profile',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Watch permission state
    final permissionState = ref.watch(permissionStateProvider);
    
    // Show permission dialog if needed
    permissionState.whenData((status) {
      if (!_hasShownPermissionDialog && 
          (status == PermissionStatus.denied || status == PermissionStatus.deniedForever)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && !_hasShownPermissionDialog) {
            _hasShownPermissionDialog = true;
            _showPermissionDialog(context);
          }
        });
      }
    });

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_navItems.length, (index) {
                final isSelected = _currentIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.1 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSelected
                                ? _navItems[index]['activeIcon'] as IconData
                                : _navItems[index]['icon'] as IconData,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          child: Text(_navItems[index]['label'] as String),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionDialog(
        onDismiss: () {
          // Refresh location state after permission is granted
          ref.invalidate(locationStateProvider);
        },
        isDismissible: false,
      ),
    );
  }
}
