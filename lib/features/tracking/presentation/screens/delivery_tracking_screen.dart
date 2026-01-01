import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class DeliveryTrackingScreen extends ConsumerStatefulWidget {
  final String deliveryId;
  
  const DeliveryTrackingScreen({
    super.key,
    required this.deliveryId,
  });

  @override
  ConsumerState<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends ConsumerState<DeliveryTrackingScreen> {
  Timer? _locationTimer;
  final List<TrackingUpdate> _trackingUpdates = [
    TrackingUpdate(
      status: 'Order Confirmed',
      timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      description: 'Your delivery request has been confirmed',
      icon: Icons.check_circle,
    ),
    TrackingUpdate(
      status: 'Rider Assigned',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      description: 'John (Honda CB150R) has been assigned to your delivery',
      icon: Icons.motorcycle,
    ),
    TrackingUpdate(
      status: 'Package Picked Up',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      description: 'Package has been picked up from Westlands Mall',
      icon: Icons.local_shipping,
    ),
    TrackingUpdate(
      status: 'In Transit',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      description: 'Rider is on the way to delivery location',
      icon: Icons.location_on,
      isActive: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      // IMPLEMENTATION: Update rider location from real-time data
      setState(() {
        // Simulate location updates
      });
    });
  }

  void _callRider() {
    // IMPLEMENTATION: Make phone call to rider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calling rider...')),
    );
  }

  void _messageRider() {
    // IMPLEMENTATION: Open chat with rider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening chat with rider...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Track Order #${widget.deliveryId}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh tracking data
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map section
            _buildMapSection(theme),
            // Delivery info section
            _buildDeliveryInfo(theme),
            // Tracking timeline
            _buildTrackingTimeline(theme),
            // Rider info and actions
            _buildRiderSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection(ThemeData theme) {
    return Container(
      height: 250,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Stack(
        children: [
          // Map placeholder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Live Map Tracking',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rider location updates every 10 seconds',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // ETA overlay
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'ETA: 12 mins',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Distance overlay
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.straighten,
                    size: 16,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '2.3 km',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.local_shipping, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Small Package',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Electronics',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'In Transit',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLocationInfo(
                  theme,
                  'From',
                  'Westlands Mall',
                  'Shop 12, Ground Floor',
                  Icons.my_location,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: _buildLocationInfo(
                  theme,
                  'To',
                  'Karen Shopping Centre',
                  'Main Entrance',
                  Icons.location_on,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(
    ThemeData theme,
    String label,
    String address,
    String details,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          address,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          details,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingTimeline(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tracking Timeline',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _trackingUpdates.length,
            itemBuilder: (context, index) {
              final update = _trackingUpdates[index];
              final isLast = index == _trackingUpdates.length - 1;
              
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Timeline indicator
                  Column(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: update.isActive
                              ? theme.colorScheme.primary
                              : theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          update.icon,
                          size: 14,
                          color: update.isActive
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: theme.colorScheme.outline,
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Update details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            update.status,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: update.isActive
                                  ? theme.colorScheme.primary
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            update.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(update.timestamp),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRiderSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Rider',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  'J',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'John Mwangi',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Honda CB150R • KCA 123A',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '4.8 (127 reviews)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _callRider,
                  icon: const Icon(Icons.phone),
                  label: const Text('Call'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _messageRider,
                  icon: const Icon(Icons.message),
                  label: const Text('Message'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

class TrackingUpdate {
  final String status;
  final DateTime timestamp;
  final String description;
  final IconData icon;
  final bool isActive;

  TrackingUpdate({
    required this.status,
    required this.timestamp,
    required this.description,
    required this.icon,
    this.isActive = false,
  });
}