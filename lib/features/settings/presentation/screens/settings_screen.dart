import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _pushNotificationsEnabled = true;
  bool _emailNotificationsEnabled = true;
  bool _smsNotificationsEnabled = false;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Notifications Section
            _buildSettingsSection(
              theme,
              'Notifications',
              Icons.notifications,
              [
                _buildSwitchTile(
                  'Push Notifications',
                  'Receive real-time delivery updates',
                  _pushNotificationsEnabled,
                  (value) {
                    setState(() {
                      _pushNotificationsEnabled = value;
                    });
                  },
                  Icons.push_pin,
                ),
                _buildSwitchTile(
                  'Email Notifications',
                  'Get delivery updates via email',
                  _emailNotificationsEnabled,
                  (value) {
                    setState(() {
                      _emailNotificationsEnabled = value;
                    });
                  },
                  Icons.email,
                ),
                _buildSwitchTile(
                  'SMS Notifications',
                  'Receive SMS for important updates',
                  _smsNotificationsEnabled,
                  (value) {
                    setState(() {
                      _smsNotificationsEnabled = value;
                    });
                  },
                  Icons.sms,
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Privacy & Security Section
            _buildSettingsSection(
              theme,
              'Privacy & Security',
              Icons.security,
              [
                _buildSettingsTile(
                  'Change Password',
                  'Update your account password',
                  Icons.lock,
                  () {
                    _showChangePasswordDialog(context);
                  },
                ),
                _buildSettingsTile(
                  'Two-Factor Authentication',
                  'Add extra security to your account',
                  Icons.verified_user,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Two-factor authentication coming soon')),
                    );
                  },
                ),
                _buildSettingsTile(
                  'Privacy Policy',
                  'View our privacy policy',
                  Icons.privacy_tip,
                  () {
                    _showPrivacyPolicy(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // App Preferences Section
            _buildSettingsSection(
              theme,
              'App Preferences',
              Icons.tune,
              [
                _buildSwitchTile(
                  'Dark Mode',
                  'Use dark theme for the app',
                  _darkModeEnabled,
                  (value) {
                    setState(() {
                      _darkModeEnabled = value;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Theme change coming soon')),
                    );
                  },
                  Icons.dark_mode,
                ),
                _buildSettingsTile(
                  'Language',
                  'English',
                  Icons.language,
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Multiple languages coming soon')),
                    );
                  },
                ),
                _buildSettingsTile(
                  'App Version',
                  '1.0.0',
                  Icons.info,
                  () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Danger Zone
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: theme.colorScheme.error),
                      const SizedBox(width: 8),
                      Text(
                        'Danger Zone',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showDeleteAccountDialog(context);
                      },
                      icon: const Icon(Icons.delete_forever),
                      label: const Text('Delete Account'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    ThemeData theme,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password change feature coming soon')),
                );
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'SwiftSend Privacy Policy\n\n'
            '1. Information We Collect\n'
            'We collect information you provide directly to us, such as when you create an account, make a delivery request, or contact us for support.\n\n'
            '2. How We Use Your Information\n'
            'We use the information we collect to provide, maintain, and improve our services, process transactions, and communicate with you.\n\n'
            '3. Information Sharing\n'
            'We do not sell, trade, or otherwise transfer your personal information to third parties without your consent, except as described in this policy.\n\n'
            '4. Data Security\n'
            'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.\n\n'
            '5. Contact Us\n'
            'If you have any questions about this Privacy Policy, please contact us at privacy@swiftsend.co.ke',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'SwiftSend',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.local_shipping,
        size: 48,
        color: Theme.of(context).colorScheme.primary,
      ),
      children: [
        const Text(
          'SwiftSend is Kenya\'s premier delivery platform connecting customers, businesses, and boda boda riders for fast, reliable package delivery across Nairobi.',
        ),
      ],
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and will permanently remove all your data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion feature coming soon')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}