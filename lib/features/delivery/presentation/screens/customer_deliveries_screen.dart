import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/delivery_model.dart';
import '../../../../core/providers/supabase_auth_provider.dart';
import '../../../../core/services/delivery_service.dart';
import 'delivery_details_screen.dart';

class CustomerDeliveriesScreen extends ConsumerStatefulWidget {
  const CustomerDeliveriesScreen({super.key});

  @override
  ConsumerState<CustomerDeliveriesScreen> createState() => _CustomerDeliveriesScreenState();
}

class _CustomerDeliveriesScreenState extends ConsumerState<CustomerDeliveriesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<DeliveryModel> _allDeliveries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDeliveries();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveries() async {
    final user = ref.read(currentUserProvider);
    
    setState(() {
      _isLoading = true;
    });

    if (user == null) {
      // User not logged in - show empty state instead of spinning forever
      if (mounted) {
        setState(() {
          _allDeliveries = [];
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final deliveryService = ref.read(deliveryServiceProvider);
      final deliveries = await deliveryService.getUserDeliveries(user.id);
      
      if (mounted) {
        setState(() {
          _allDeliveries = deliveries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<DeliveryModel> get _activeDeliveries {
    return _allDeliveries.where((delivery) =>
      delivery.status != DeliveryStatus.delivered &&
      delivery.status != DeliveryStatus.cancelled
    ).toList();
  }

  List<DeliveryModel> get _completedDeliveries {
    return _allDeliveries.where((delivery) =>
      delivery.status == DeliveryStatus.delivered
    ).toList();
  }

  List<DeliveryModel> get _cancelledDeliveries {
    return _allDeliveries.where((delivery) =>
      delivery.status == DeliveryStatus.cancelled
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Deliveries'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeliveries,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Active (${_activeDeliveries.length})',
              icon: const Icon(Icons.local_shipping),
            ),
            Tab(
              text: 'Completed (${_completedDeliveries.length})',
              icon: const Icon(Icons.check_circle),
            ),
            Tab(
              text: 'Cancelled (${_cancelledDeliveries.length})',
              icon: const Icon(Icons.cancel),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDeliveries,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildDeliveryList(_activeDeliveries, 'active'),
                  _buildDeliveryList(_completedDeliveries, 'completed'),
                  _buildDeliveryList(_cancelledDeliveries, 'cancelled'),
                ],
              ),
      ),
    );
  }

  Widget _buildDeliveryList(List<DeliveryModel> deliveries, String type) {
    if (deliveries.isEmpty) {
      return _buildEmptyState(type);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deliveries.length,
      itemBuilder: (context, index) {
        final delivery = deliveries[index];
        return _buildDeliveryCard(delivery);
      },
    );
  }

  Widget _buildEmptyState(String type) {
    String message;
    IconData icon;

    switch (type) {
      case 'active':
        message = 'No active deliveries.\nCreate a new delivery to get started!';
        icon = Icons.local_shipping_outlined;
        break;
      case 'completed':
        message = 'No completed deliveries yet.\nYour delivery history will appear here.';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        message = 'No cancelled deliveries.\nHopefully it stays that way!';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'No deliveries found.';
        icon = Icons.inbox_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (type == 'active') ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Navigate to create delivery
                Navigator.of(context).pop();
                // The parent will handle navigation to create delivery
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Delivery'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(DeliveryModel delivery) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DeliveryDetailsScreen(delivery: delivery),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(delivery.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      delivery.status.displayName,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getStatusColor(delivery.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    delivery.id.substring(0, 8).toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Locations
              _buildLocationRow(
                theme,
                Icons.my_location,
                'From',
                delivery.pickupAddress,
                Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildLocationRow(
                theme,
                Icons.location_on,
                'To',
                delivery.dropoffAddress,
                Colors.green,
              ),
              const SizedBox(height: 12),
              
              // Package info
              Row(
                children: [
                  Icon(Icons.inventory, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${delivery.packageInfo.size.displayName} package - ${delivery.packageInfo.description}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Bottom row
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(delivery.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'KSh ${delivery.finalPrice?.toInt() ?? delivery.estimatedPrice.toInt()}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              // Rider info (if assigned)
              if (delivery.riderId != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.motorcycle, size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Rider assigned',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, size: 16),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationRow(
    ThemeData theme,
    IconData icon,
    String label,
    String location,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                location,
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return Colors.orange;
      case DeliveryStatus.accepted:
        return Colors.blue;
      case DeliveryStatus.pickedUp:
      case DeliveryStatus.inTransit:
        return Colors.purple;
      case DeliveryStatus.delivered:
        return Colors.green;
      case DeliveryStatus.cancelled:
      case DeliveryStatus.failed:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}