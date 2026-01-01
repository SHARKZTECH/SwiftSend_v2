import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/providers/supabase_auth_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(supabaseAuthNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              final authNotifier = ref.read(supabaseAuthNotifierProvider.notifier);
              
              switch (value) {
                case 'edit':
                  if (authState.value != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: authState.value!),
                      ),
                    );
                  }
                  break;
                case 'logout':
                  final result = await authNotifier.signOut();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.message)),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Text('Edit Profile'),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Text('Sign Out'),
              ),
            ],
          ),
        ],
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Not signed in'));
          }
          return _buildProfileContent(context, theme, user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ThemeData theme, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile header
          _buildProfileHeader(theme, user),
          const SizedBox(height: 32),
          
          // User stats (for riders)
          if (user.userType == UserType.rider) ...[
            _buildRiderStats(theme, user),
            const SizedBox(height: 24),
          ],
          
          // Business info (for business users)
          if (user.userType == UserType.business) ...[
            _buildBusinessInfo(theme, user),
            const SizedBox(height: 24),
          ],
          
          // Profile sections
          _buildProfileSection(
            theme,
            'Personal Information',
            [
              _buildInfoTile(Icons.email, 'Email', user.email),
              _buildInfoTile(Icons.phone, 'Phone', user.phoneNumber),
              if (user.profile?.address != null)
                _buildInfoTile(Icons.location_on, 'Address', user.profile!.address!),
              if (user.profile?.city != null)
                _buildInfoTile(Icons.location_city, 'City', user.profile!.city!),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Account settings
          _buildProfileSection(
            theme,
            'Account',
            [
              _buildInfoTile(Icons.person, 'User Type', user.userType.displayName),
              _buildInfoTile(
                user.isVerified ? Icons.verified : Icons.warning,
                'Verification Status',
                user.isVerified ? 'Verified' : 'Not Verified',
                trailing: user.isVerified
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.warning, color: Colors.orange),
              ),
              _buildInfoTile(
                Icons.calendar_today,
                'Member Since',
                _formatDate(user.createdAt),
              ),
            ],
          ),
          
          if (user.userType == UserType.rider) ...[
            const SizedBox(height: 24),
            _buildRiderDetails(theme, user),
          ],
          
          const SizedBox(height: 32),
          
          // Action buttons
          _buildActionButtons(context, theme),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, UserModel user) {
    return Column(
      children: [
        // Profile picture
        CircleAvatar(
          radius: 60,
          backgroundColor: theme.colorScheme.primaryContainer,
          backgroundImage: user.profileImageUrl != null
              ? NetworkImage(user.profileImageUrl!)
              : null,
          child: user.profileImageUrl == null
              ? Text(
                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),
        
        // Name and type
        Text(
          user.fullName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            user.userType.displayName,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        if (user.profile?.bio != null) ...[
          const SizedBox(height: 16),
          Text(
            user.profile!.bio!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildRiderStats(ThemeData theme, UserModel user) {
    final profile = user.profile;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Rider Statistics',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Rating',
                  profile?.rating?.toStringAsFixed(1) ?? '0.0',
                  Icons.star,
                  Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Deliveries',
                  profile?.completedDeliveries?.toString() ?? '0',
                  Icons.local_shipping,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Earnings',
                  'KSh ${profile?.totalEarnings?.toInt() ?? 0}',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfo(ThemeData theme, UserModel user) {
    final businessInfo = user.profile?.businessInfo;
    if (businessInfo == null) return const SizedBox();

    return _buildProfileSection(
      theme,
      'Business Information',
      [
        _buildInfoTile(Icons.business, 'Business Name', businessInfo.businessName),
        _buildInfoTile(Icons.category, 'Business Type', businessInfo.businessType),
        if (businessInfo.businessRegistrationNumber != null)
          _buildInfoTile(Icons.numbers, 'Registration Number', businessInfo.businessRegistrationNumber!),
        if (businessInfo.website != null)
          _buildInfoTile(Icons.web, 'Website', businessInfo.website!),
        if (businessInfo.description != null)
          _buildInfoTile(Icons.description, 'Description', businessInfo.description!),
      ],
    );
  }

  Widget _buildRiderDetails(ThemeData theme, UserModel user) {
    final profile = user.profile;
    if (profile == null) return const SizedBox();

    return _buildProfileSection(
      theme,
      'Vehicle Information',
      [
        if (profile.vehicleType != null)
          _buildInfoTile(Icons.motorcycle, 'Vehicle Type', profile.vehicleType!),
        if (profile.plateNumber != null)
          _buildInfoTile(Icons.confirmation_number, 'Plate Number', profile.plateNumber!),
        if (profile.licenseNumber != null)
          _buildInfoTile(Icons.card_membership, 'License Number', profile.licenseNumber!),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(ThemeData theme, String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String label, String value, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate to settings
            },
            icon: const Icon(Icons.settings),
            label: const Text('Settings'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Navigate to help/support
            },
            icon: const Icon(Icons.help_outline),
            label: const Text('Help & Support'),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}