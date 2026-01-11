import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _locationTrackingEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preferences section
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Dark mode toggle
            _buildSettingTile(
              context,
              'Dark Mode',
              'Switch between light and dark themes',
              Icons.dark_mode,
              Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                  // TODO: Implement theme switching
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Notifications toggle
            _buildSettingTile(
              context,
              'Notifications',
              'Receive booking updates and reminders',
              Icons.notifications,
              Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                  // TODO: Implement notification settings
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Location tracking toggle
            _buildSettingTile(
              context,
              'Location Tracking',
              'Allow app to track your location for better recommendations',
              Icons.location_on,
              Switch(
                value: _locationTrackingEnabled,
                onChanged: (value) {
                  setState(() {
                    _locationTrackingEnabled = value;
                  });
                  // TODO: Implement location tracking settings
                },
              ),
            ),
            const SizedBox(height: 32),
            
            // Account section
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionTile(
              context,
              'Edit Profile',
              'Update your personal information',
              Icons.edit,
              () {
                // TODO: Navigate to edit profile
              },
            ),
            const SizedBox(height: 12),
            
            _buildActionTile(
              context,
              'Payment Methods',
              'Manage your payment options',
              Icons.payment,
              () {
                // TODO: Navigate to payment methods
              },
            ),
            const SizedBox(height: 12),
            
            _buildActionTile(
              context,
              'Saved Addresses',
              'Manage your saved locations',
              Icons.location_city,
              () {
                // TODO: Navigate to saved addresses
              },
            ),
            const SizedBox(height: 32),
            
            // Legal section
            Text(
              'Legal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildActionTile(
              context,
              'Privacy Policy',
              'View our privacy policy',
              Icons.privacy_tip,
              () {
                // TODO: Show privacy policy
              },
            ),
            const SizedBox(height: 12),
            
            _buildActionTile(
              context,
              'Terms of Service',
              'View our terms of service',
              Icons.description,
              () {
                // TODO: Show terms of service
              },
            ),
            const SizedBox(height: 12),
            
            _buildActionTile(
              context,
              'About',
              'Version and app information',
              Icons.info,
              () {
                // TODO: Show about dialog
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Widget trailing,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

