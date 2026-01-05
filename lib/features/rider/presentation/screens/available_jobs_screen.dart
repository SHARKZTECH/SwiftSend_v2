import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';

// Mock data provider for available jobs
final availableJobsProvider = StateProvider<List<AvailableJob>>((ref) {
  return [
    AvailableJob(
      id: '1',
      pickupAddress: 'Westlands Mall, Waiyaki Way',
      pickupArea: 'Westlands',
      dropoffAddress: 'Garden City Mall, Thika Road',
      dropoffArea: 'Roysambu',
      distance: 8.5,
      estimatedPrice: 350,
      packageSize: 'Medium',
      senderName: 'John Kamau',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      isUrgent: false,
    ),
    AvailableJob(
      id: '2',
      pickupAddress: 'Kenyatta Avenue, CBD',
      pickupArea: 'CBD',
      dropoffAddress: 'Karen Shopping Centre',
      dropoffArea: 'Karen',
      distance: 15.2,
      estimatedPrice: 550,
      packageSize: 'Small',
      senderName: 'Mary Wanjiku',
      createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      isUrgent: true,
    ),
    AvailableJob(
      id: '3',
      pickupAddress: 'Sarit Centre, Westlands',
      pickupArea: 'Westlands',
      dropoffAddress: 'Two Rivers Mall, Limuru Road',
      dropoffArea: 'Runda',
      distance: 6.3,
      estimatedPrice: 280,
      packageSize: 'Large',
      senderName: 'Peter Omondi',
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      isUrgent: false,
    ),
    AvailableJob(
      id: '4',
      pickupAddress: 'Village Market, Limuru Road',
      pickupArea: 'Gigiri',
      dropoffAddress: 'JKIA, Airport Road',
      dropoffArea: 'Embakasi',
      distance: 22.0,
      estimatedPrice: 750,
      packageSize: 'Small',
      senderName: 'Grace Muthoni',
      createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      isUrgent: true,
    ),
  ];
});

class AvailableJobsScreen extends ConsumerStatefulWidget {
  const AvailableJobsScreen({super.key});

  @override
  ConsumerState<AvailableJobsScreen> createState() => _AvailableJobsScreenState();
}

class _AvailableJobsScreenState extends ConsumerState<AvailableJobsScreen> {
  String _selectedFilter = 'all';
  bool _sortByPrice = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobs = ref.watch(availableJobsProvider);
    
    // Filter and sort jobs
    var filteredJobs = jobs.where((job) {
      if (_selectedFilter == 'urgent') return job.isUrgent;
      if (_selectedFilter == 'nearby') return job.distance < 10;
      return true;
    }).toList();
    
    if (_sortByPrice) {
      filteredJobs.sort((a, b) => b.estimatedPrice.compareTo(a.estimatedPrice));
    } else {
      filteredJobs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Jobs'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_sortByPrice ? Icons.attach_money : Icons.access_time),
            tooltip: _sortByPrice ? 'Sort by time' : 'Sort by price',
            onPressed: () {
              setState(() => _sortByPrice = !_sortByPrice);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip(
                  theme: theme,
                  label: 'All Jobs',
                  value: 'all',
                  icon: Icons.list,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  theme: theme,
                  label: 'Urgent',
                  value: 'urgent',
                  icon: Icons.bolt,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  theme: theme,
                  label: 'Nearby',
                  value: 'nearby',
                  icon: Icons.near_me,
                ),
              ],
            ),
          ),
          
          // Stats bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  '${filteredJobs.length} jobs available',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  _sortByPrice ? 'Highest price first' : 'Newest first',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Job list
          Expanded(
            child: filteredJobs.isEmpty
                ? _buildEmptyState(theme)
                : RefreshIndicator(
                    onRefresh: () async {
                      await Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredJobs.length,
                      itemBuilder: (context, index) {
                        return _buildJobCard(theme, filteredJobs[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required ThemeData theme,
    required String label,
    required String value,
    required IconData icon,
  }) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No jobs available',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new delivery requests',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(ThemeData theme, AvailableJob job) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showJobDetails(context, job),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with price and urgency
              Row(
                children: [
                  if (job.isUrgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'URGENT',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const Spacer(),
                  Text(
                    'KES ${job.estimatedPrice.toStringAsFixed(0)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Pickup location
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.shade700, width: 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.pickupArea,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          job.pickupAddress,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Connector line
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Container(
                  width: 2,
                  height: 20,
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              
              // Dropoff location
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.shade700, width: 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.dropoffArea,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          job.dropoffAddress,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              // Footer with details
              Row(
                children: [
                  _buildInfoChip(theme, Icons.straighten, '${job.distance} km'),
                  const SizedBox(width: 12),
                  _buildInfoChip(theme, Icons.inventory_2_outlined, job.packageSize),
                  const Spacer(),
                  Text(
                    _formatTime(job.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
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

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  void _showJobDetails(BuildContext context, AvailableJob job) {
    context.push(AppConstants.routeJobDetails, extra: job);
  }
}

class AvailableJob {
  final String id;
  final String pickupAddress;
  final String pickupArea;
  final String dropoffAddress;
  final String dropoffArea;
  final double distance;
  final double estimatedPrice;
  final String packageSize;
  final String senderName;
  final DateTime createdAt;
  final bool isUrgent;

  AvailableJob({
    required this.id,
    required this.pickupAddress,
    required this.pickupArea,
    required this.dropoffAddress,
    required this.dropoffArea,
    required this.distance,
    required this.estimatedPrice,
    required this.packageSize,
    required this.senderName,
    required this.createdAt,
    required this.isUrgent,
  });
}
