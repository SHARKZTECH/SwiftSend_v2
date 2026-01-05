import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/delivery_model.dart';
import '../../../tracking/presentation/screens/delivery_tracking_screen.dart';

class DeliveryDetailsScreen extends ConsumerWidget {
  final DeliveryModel delivery;

  const DeliveryDetailsScreen({
    super.key,
    required this.delivery,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Delivery #${delivery.id.substring(0, 8).toUpperCase()}'),
        centerTitle: true,
        actions: [
          if (delivery.status == DeliveryStatus.inTransit ||
              delivery.status == DeliveryStatus.pickedUp)
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DeliveryTrackingScreen(deliveryId: delivery.id),
                  ),
                );
              },
              child: const Text('Track Live'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Status header
            _buildStatusHeader(theme),
            
            // Main details
            _buildMainDetails(theme),
            
            // Package information
            _buildPackageInfo(theme),
            
            // Locations
            _buildLocations(theme),
            
            // Payment info
            _buildPaymentInfo(theme),
            
            // Timeline
            _buildTimeline(theme),
            
            // Actions
            _buildActions(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _getStatusColor(delivery.status).withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getStatusColor(delivery.status),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              delivery.status.displayName,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _getStatusMessage(delivery.status),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          if (delivery.status == DeliveryStatus.inTransit) ...[
            const SizedBox(height: 12),
            Text(
              'Your rider is on the way!',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMainDetails(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            theme,
            'Order ID',
            delivery.id.substring(0, 8).toUpperCase(),
            Icons.receipt,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            theme,
            'Created',
            _formatDateTime(delivery.createdAt),
            Icons.access_time,
          ),
          if (delivery.acceptedAt != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              'Accepted',
              _formatDateTime(delivery.acceptedAt!),
              Icons.check_circle,
            ),
          ],
          if (delivery.deliveredAt != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              'Delivered',
              _formatDateTime(delivery.deliveredAt!),
              Icons.done_all,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPackageInfo(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            'Package Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            theme,
            'Description',
            delivery.packageInfo.description,
            Icons.inventory,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            theme,
            'Size',
            delivery.packageInfo.size.displayName,
            Icons.straighten,
          ),
          if (delivery.packageInfo.isFragile) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              'Special Handling',
              'Fragile Package',
              Icons.warning,
              valueColor: Colors.orange,
            ),
          ],
          if (delivery.packageInfo.requiresSignature) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              'Signature',
              'Required',
              Icons.edit,
              valueColor: Colors.blue,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocations(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            'Delivery Route',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildLocationCard(
            theme,
            'Pickup Location',
            delivery.pickupAddress,
            Icons.my_location,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildLocationCard(
            theme,
            'Delivery Location',
            delivery.dropoffAddress,
            Icons.location_on,
            Colors.green,
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            theme,
            'Receiver',
            '${delivery.receiverName} (${delivery.receiverPhone})',
            Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            'Payment Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'KSh ${delivery.finalPrice?.toInt() ?? delivery.estimatedPrice.toInt()}',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (delivery.paymentInfo != null) ...[
            const SizedBox(height: 12),
            _buildDetailRow(
              theme,
              'Payment Method',
              delivery.paymentInfo!.method.displayName,
              Icons.payment,
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              theme,
              'Payment Status',
              delivery.paymentInfo!.status.displayName,
              Icons.check_circle,
              valueColor: delivery.paymentInfo!.status == PaymentStatus.completed
                  ? Colors.green
                  : Colors.orange,
            ),
            if (delivery.paymentInfo!.transactionId.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow(
                theme,
                'Transaction ID',
                delivery.paymentInfo!.transactionId,
                Icons.receipt_long,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTimeline(ThemeData theme) {
    final events = <TimelineEvent>[
      TimelineEvent(
        title: 'Order Placed',
        time: delivery.createdAt,
        icon: Icons.add_circle,
        isCompleted: true,
      ),
      if (delivery.acceptedAt != null)
        TimelineEvent(
          title: 'Rider Assigned',
          time: delivery.acceptedAt!,
          icon: Icons.motorcycle,
          isCompleted: true,
        ),
      if (delivery.pickedUpAt != null)
        TimelineEvent(
          title: 'Package Picked Up',
          time: delivery.pickedUpAt!,
          icon: Icons.local_shipping,
          isCompleted: true,
        ),
      if (delivery.deliveredAt != null)
        TimelineEvent(
          title: 'Delivered',
          time: delivery.deliveredAt!,
          icon: Icons.done_all,
          isCompleted: true,
        )
      else if (delivery.status != DeliveryStatus.cancelled)
        TimelineEvent(
          title: delivery.status == DeliveryStatus.pending 
              ? 'Waiting for Rider'
              : 'In Transit',
          time: DateTime.now(),
          icon: delivery.status == DeliveryStatus.pending 
              ? Icons.hourglass_empty 
              : Icons.local_shipping,
          isCompleted: false,
          isActive: true,
        ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
            'Delivery Timeline',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...events.asMap().entries.map((entry) {
            final index = entry.key;
            final event = entry.value;
            final isLast = index == events.length - 1;
            
            return _buildTimelineItem(theme, event, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (delivery.status == DeliveryStatus.pending) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showCancelDialog(context);
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Cancel Delivery'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
          if (delivery.status == DeliveryStatus.inTransit ||
              delivery.status == DeliveryStatus.pickedUp) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DeliveryTrackingScreen(deliveryId: delivery.id),
                    ),
                  );
                },
                icon: const Icon(Icons.location_on),
                label: const Text('Track Live Location'),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (delivery.status == DeliveryStatus.delivered) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Rate delivery
                  _showRatingDialog(context);
                },
                icon: const Icon(Icons.star),
                label: const Text('Rate This Delivery'),
              ),
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // Contact support
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contact support feature coming soon')),
                );
              },
              icon: const Icon(Icons.support_agent),
              label: const Text('Contact Support'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(
    ThemeData theme,
    String title,
    String address,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  address,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(ThemeData theme, TimelineEvent event, bool isLast) {
    final color = event.isActive
        ? theme.colorScheme.primary
        : event.isCompleted
            ? Colors.green
            : theme.colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: event.isCompleted ? color : Colors.transparent,
                border: Border.all(color: color, width: 2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                event.icon,
                size: 16,
                color: event.isCompleted ? Colors.white : color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: event.isCompleted 
                    ? color.withValues(alpha: 0.3)
                    : theme.colorScheme.outline,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: event.isActive ? theme.colorScheme.primary : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateTime(event.time),
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
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Delivery'),
        content: const Text('Are you sure you want to cancel this delivery? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Keep Delivery'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle cancellation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delivery cancelled successfully')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Delivery'),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Your Delivery'),
        content: const Text('How was your delivery experience?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Rating feature coming soon')),
              );
            },
            child: const Text('Rate Now'),
          ),
        ],
      ),
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

  String _getStatusMessage(DeliveryStatus status) {
    switch (status) {
      case DeliveryStatus.pending:
        return 'Looking for an available rider near you...';
      case DeliveryStatus.accepted:
        return 'A rider has been assigned to your delivery';
      case DeliveryStatus.pickedUp:
        return 'Your package has been picked up';
      case DeliveryStatus.inTransit:
        return 'Your package is on its way to the destination';
      case DeliveryStatus.delivered:
        return 'Your package has been delivered successfully!';
      case DeliveryStatus.cancelled:
        return 'This delivery has been cancelled';
      case DeliveryStatus.failed:
        return 'Unfortunately, this delivery could not be completed';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}

class TimelineEvent {
  final String title;
  final DateTime time;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;

  TimelineEvent({
    required this.title,
    required this.time,
    required this.icon,
    required this.isCompleted,
    this.isActive = false,
  });
}