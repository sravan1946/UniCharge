import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_state.dart';
import '../services/appwrite_service.dart';
import 'config_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'Manage your account information',
            onTap: () {
              // TODO: Navigate to profile screen
            },
          ),
          _buildSettingsTile(
            icon: Icons.history,
            title: 'Booking History',
            subtitle: 'View your past bookings',
            onTap: () {
              // TODO: Navigate to booking history
            },
          ),
          _buildSettingsTile(
            icon: Icons.stars,
            title: 'Loyalty Points',
            subtitle: 'Check your rewards and points',
            onTap: () {
              // TODO: Navigate to loyalty screen
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Preferences'),
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              // TODO: Navigate to notification settings
            },
          ),
          _buildSettingsTile(
            icon: Icons.location_on,
            title: 'Location Services',
            subtitle: 'Control location access',
            onTap: () {
              // TODO: Navigate to location settings
            },
          ),
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark themes',
            trailing: Switch(
              value: false, // TODO: Implement theme switching
              onChanged: (value) {
                // TODO: Toggle theme
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Support'),
          _buildSettingsTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () {
              // TODO: Navigate to help screen
            },
          ),
          _buildSettingsTile(
            icon: Icons.settings,
            title: 'Appwrite Configuration',
            subtitle: 'Configure backend settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConfigScreen(),
                ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Account Actions'),
          _buildSettingsTile(
            icon: Icons.logout,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: () {
              _showSignOutDialog(context);
            },
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: textColor),
        title: Text(
          title,
          style: TextStyle(color: textColor),
        ),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'UniCharge',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.electric_car,
        size: 48,
        color: Colors.blue,
      ),
      children: [
        const Text('Smart Parking & EV Charging Management Platform'),
        const SizedBox(height: 16),
        const Text('Built with Flutter and Appwrite'),
      ],
    );
  }

  Future<void> _showSignOutDialog(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      _signOut(context);
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final appwriteService = AppwriteService();
      await appwriteService.signOut();
      
      final authState = context.read<AuthState>();
      authState.signOut();
      
      // Navigation happens automatically via AppWrapper watching authState
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign out: $e')),
        );
      }
    }
  }
}
