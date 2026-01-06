import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';

class RiderDashboardScreen extends ConsumerStatefulWidget {
  const RiderDashboardScreen({super.key});

  @override
  ConsumerState<RiderDashboardScreen> createState() => _RiderDashboardScreenState();
}

class _RiderDashboardScreenState extends ConsumerState<RiderDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isOnline = false;
  
  // Mock data for available deliveries
  final List<DeliveryRequest> _availableDeliveries = [
    DeliveryRequest(
      id: 'SW001',
      pickupLocation: 'Westlands Shopping Mall',
      dropoffLocation: 'Karen Shopping Centre',
      distance: 8.5,
      estimatedTime: 25,
      amount: 350.0,
      packageSize: 'Medium',
      customerName: 'John Doe',
      customerPhone: '+254700000001',
      urgency: DeliveryUrgency.normal,
    ),
    DeliveryRequest(
      id: 'SW002',
      pickupLocation: 'CBD Post Office',
      dropoffLocation: 'Kilimani Estate',
      distance: 4.2,
      estimatedTime: 15,
      amount: 250.0,
      packageSize: 'Small',
      customerName: 'Jane Smith',
      customerPhone: '+254700000002',
      urgency: DeliveryUrgency.urgent,
    ),
    DeliveryRequest(
      id: 'SW003',
      pickupLocation: 'Junction Mall',
      dropoffLocation: 'Ngong Road',
      distance: 6.1,
      estimatedTime: 20,
      amount: 280.0,
      packageSize: 'Small',
      customerName: 'Peter Kamau',
      customerPhone: '+254700000003',
      urgency: DeliveryUrgency.normal,
    ),
  ];

  // Mock data for current delivery
  final DeliveryRequest _currentDelivery = DeliveryRequest(
    id: 'SW004',
    pickupLocation: 'Sarit Centre',
    dropoffLocation: 'Lavington Mall',
    distance: 3.8,
    estimatedTime: 12,
    amount: 220.0,
    packageSize: 'Small',
    customerName: 'Mary Wanjiku',
    customerPhone: '+254700000004',
    urgency: DeliveryUrgency.normal,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isOnline ? 'You are now online and available for deliveries' : 'You are now offline'),
        backgroundColor: _isOnline ? Colors.green : Colors.orange,
      ),
    );
  }

  void _acceptDelivery(DeliveryRequest delivery) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Delivery'),
        content: Text('Do you want to accept delivery ${delivery.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _availableDeliveries.remove(delivery);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Delivery ${delivery.id} accepted')),
              );
            },
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Dashboard'),
        centerTitle: true,
        actions: [
          // Online/Offline toggle
          Switch(
            value: _isOnline,
            onChanged: (_) => _toggleOnlineStatus(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Available', icon: Icon(Icons.local_shipping)),
            Tab(text: 'Current', icon: Icon(Icons.motorcycle)),
            Tab(text: 'Stats', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableDeliveries(theme),
          _buildCurrentDelivery(theme),
          _buildStats(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push(AppConstants.routeAvailableJobs);
        },
        icon: const Icon(Icons.search),
        label: const Text('Find Jobs'),
      ),
    );
  }

  Widget _buildAvailableDeliveries(ThemeData theme) {
    if (!_isOnline) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.power_off,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'You are offline',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Turn on the switch to see available deliveries',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _toggleOnlineStatus,
              icon: const Icon(Icons.power),
              label: const Text('Go Online'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // IMPLEMENTATION: Refresh available deliveries
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availableDeliveries.length,
        itemBuilder: (context, index) {
          final delivery = _availableDeliveries[index];
          return _buildDeliveryCard(theme, delivery, isAvailable: true);
        },
      ),
    );
  }

  Widget _buildCurrentDelivery(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDeliveryCard(theme, _currentDelivery, isCurrent: true),
          const SizedBox(height: 16),
          _buildDeliveryActions(theme),
        ],
      ),
    );
  }

  Widget _buildStats(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Summary',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Deliveries',
                  '12',
                  Icons.local_shipping,
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Earnings',
                  'KSh 2,850',
                  Icons.account_balance_wallet,
                  Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Distance',
                  '87 km',
                  Icons.straighten,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  theme,
                  'Rating',
                  '4.9 ⭐',
                  Icons.star,
                  Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Weekly Performance',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.show_chart,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Performance Chart',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Earnings and delivery trends',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildRecentEarnings(theme),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(
    ThemeData theme,
    DeliveryRequest delivery, {
    bool isAvailable = false,
    bool isCurrent = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: delivery.urgency.color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    delivery.urgency.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  delivery.id,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.my_location, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    delivery.pickupLocation,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    delivery.dropoffLocation,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildInfoChip(theme, '${delivery.distance} km', Icons.straighten),
                _buildInfoChip(theme, '${delivery.estimatedTime} min', Icons.access_time),
                _buildInfoChip(theme, delivery.packageSize, Icons.inventory),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'KSh ${delivery.amount.toInt()}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isAvailable)
                  FilledButton(
                    onPressed: () => _acceptDelivery(delivery),
                    child: const Text('Accept'),
                  ),
              ],
            ),
            if (isCurrent) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Call customer
                      },
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Call'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        context.push(AppConstants.routeTracking);
                      },
                      icon: const Icon(Icons.navigation, size: 18),
                      label: const Text('Navigate'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(ThemeData theme, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryActions(ThemeData theme) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Package marked as picked up!'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark Picked Up'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  context.push(AppConstants.routeTracking);
                },
                icon: const Icon(Icons.navigation),
                label: const Text('Start Navigation'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Redirecting to proof of delivery...'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 1),
                ),
              );
              context.push(AppConstants.routeProofOfDelivery, extra: 'SW004');
            },
            icon: const Icon(Icons.done_all),
            label: const Text('Mark as Delivered'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
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

  Widget _buildRecentEarnings(ThemeData theme) {
    return Container(
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
            'Recent Earnings',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(3, (index) {
            final earnings = [450, 380, 220];
            final times = ['2 hours ago', '4 hours ago', '6 hours ago'];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Delivery completed',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    '+KSh ${earnings[index]}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    times[index],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class DeliveryRequest {
  final String id;
  final String pickupLocation;
  final String dropoffLocation;
  final double distance;
  final int estimatedTime;
  final double amount;
  final String packageSize;
  final String customerName;
  final String customerPhone;
  final DeliveryUrgency urgency;

  DeliveryRequest({
    required this.id,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.distance,
    required this.estimatedTime,
    required this.amount,
    required this.packageSize,
    required this.customerName,
    required this.customerPhone,
    required this.urgency,
  });
}

enum DeliveryUrgency {
  normal,
  urgent,
  express;

  String get label {
    switch (this) {
      case DeliveryUrgency.normal:
        return 'Normal';
      case DeliveryUrgency.urgent:
        return 'Urgent';
      case DeliveryUrgency.express:
        return 'Express';
    }
  }

  Color get color {
    switch (this) {
      case DeliveryUrgency.normal:
        return Colors.blue;
      case DeliveryUrgency.urgent:
        return Colors.orange;
      case DeliveryUrgency.express:
        return Colors.red;
    }
  }
}