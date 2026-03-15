import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../config/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final data = context.watch<DataProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        // No leading button needed if it's pushed from Dashboard header
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _sectionHeader('ACCOUNT'),
          _settingsTile(
            icon: Icons.person,
            title: 'NetID',
            subtitle: auth.user?.netID ?? 'Not signed in',
            isDark: isDark,
          ),
          _settingsTile(
            icon: Icons.badge,
            title: 'Name',
            subtitle: auth.user?.name ?? 'Unknown',
            isDark: isDark,
          ),

          _sectionHeader('DATA MANAGEMENT'),
          _settingsTile(
            icon: Icons.sync,
            title: 'Refresh Data',
            subtitle: data.isLoading ? 'Syncing...' : 'Last synced: Just now',
            isDark: isDark,
            onTap: () => data.refreshAll(),
          ),
          _settingsTile(
            icon: Icons.delete_sweep,
            title: 'Clear Local Cache',
            subtitle: 'Removes local copies of attendance & marks',
            isDark: isDark,
            onTap: () {
              // TODO: Implement clear cache
            },
          ),

          _sectionHeader('APPEARANCE'),
          _settingsSwitchTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            value: isDark,
            onChanged: (v) {
              // TODO: Implement theme switching in a ThemeProvider
            },
            isDark: isDark,
          ),

          _sectionHeader('ABOUT'),
          _settingsTile(
            icon: Icons.info,
            title: 'Version',
            subtitle: '1.0.0 (Beta)',
            isDark: isDark,
          ),
          _settingsTile(
            icon: Icons.security,
            title: 'Privacy & Security',
            subtitle: 'All data is processed locally on this device.',
            isDark: isDark,
          ),

          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FilledButton(
              onPressed: () {
                auth.logout();
                Navigator.of(context).pop(); // Go back from settings if possible
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, size: 20),
                  SizedBox(width: 8),
                  Text('Logout'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextButton(
              onPressed: () {
                auth.hardLogout();
                Navigator.of(context).pop(); // Go back from settings if possible
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red.shade400,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Remove Saved Credentials & Logout'),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'UNOFFICIAL SRM ACADEMIA CLIENT',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10,
                color: AppTheme.slate400,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
            letterSpacing: 1.2),
      ),
    );
  }

  Widget _settingsTile(
      {required IconData icon,
      required String title,
      String? subtitle,
      Widget? trailing,
      required bool isDark,
      VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate900 : Colors.white,
        border: const Border(
            bottom: BorderSide(color: AppTheme.slate100, width: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        subtitle: subtitle != null
            ? Text(subtitle,
                style: TextStyle(fontSize: 13, color: AppTheme.slate500))
            : null,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _settingsSwitchTile(
      {required IconData icon,
      required String title,
      required bool value,
      required ValueChanged<bool> onChanged,
      required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.slate900 : Colors.white,
        border: const Border(
            bottom: BorderSide(color: AppTheme.slate100, width: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
        ),
        title: Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppTheme.primaryBlue,
        ),
      ),
    );
  }
}
