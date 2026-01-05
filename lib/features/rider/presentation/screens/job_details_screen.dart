import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import 'available_jobs_screen.dart';

class JobDetailsScreen extends ConsumerStatefulWidget {
  final AvailableJob? job;
  
  const JobDetailsScreen({super.key, this.job});

  @override
  ConsumerState<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends ConsumerState<JobDetailsScreen> {
  bool _isAccepting = false;
  double _counterOfferPrice = 0;
  bool _showCounterOffer = false;

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      _counterOfferPrice = widget.job!.estimatedPrice;
    }
  }

  void _acceptJob() async {
    setState(() => _isAccepting = true);
    
    // Mock API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isAccepting = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job accepted! Navigate to pickup location.'),
          backgroundColor: Colors.green,
        ),
      );
      context.go(AppConstants.routeRiderDashboard);
    }
  }

  void _submitCounterOffer() async {
    setState(() => _isAccepting = true);
    
    // Mock API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isAccepting = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Counter offer of KES ${_counterOfferPrice.toStringAsFixed(0)} submitted!'),
          backgroundColor: Colors.orange,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final job = widget.job;
    
    if (job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: const Center(child: Text('Job not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Price header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Estimated Earnings',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'KES ${job.estimatedPrice.toStringAsFixed(0)}',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (job.isUrgent) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, size: 16, color: Colors.yellow),
                          SizedBox(width: 4),
                          Text(
                            'URGENT DELIVERY',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Route section
                  _buildSectionTitle(theme, 'Route Details'),
                  const SizedBox(height: 12),
                  _buildRouteCard(theme, job),
                  
                  const SizedBox(height: 24),
                  
                  // Package section
                  _buildSectionTitle(theme, 'Package Information'),
                  const SizedBox(height: 12),
                  _buildInfoCard(theme, [
                    _buildInfoRow(theme, Icons.inventory_2_outlined, 'Size', job.packageSize),
                    _buildInfoRow(theme, Icons.straighten, 'Distance', '${job.distance} km'),
                    _buildInfoRow(theme, Icons.timer_outlined, 'Est. Time', '${(job.distance * 3).toInt()} mins'),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  // Sender section
                  _buildSectionTitle(theme, 'Sender Information'),
                  const SizedBox(height: 12),
                  _buildInfoCard(theme, [
                    _buildInfoRow(theme, Icons.person_outline, 'Name', job.senderName),
                    _buildInfoRow(theme, Icons.star_outline, 'Rating', '4.8 ⭐'),
                    _buildInfoRow(theme, Icons.local_shipping_outlined, 'Past Orders', '23'),
                  ]),
                  
                  const SizedBox(height: 24),
                  
                  // Counter offer section
                  if (_showCounterOffer) ...[
                    _buildSectionTitle(theme, 'Your Counter Offer'),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'KES ${_counterOfferPrice.toStringAsFixed(0)}',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Slider(
                            value: _counterOfferPrice,
                            min: job.estimatedPrice * 0.8,
                            max: job.estimatedPrice * 1.5,
                            divisions: 20,
                            label: 'KES ${_counterOfferPrice.toStringAsFixed(0)}',
                            onChanged: (value) {
                              setState(() => _counterOfferPrice = value);
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Min: KES ${(job.estimatedPrice * 0.8).toStringAsFixed(0)}',
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                'Max: KES ${(job.estimatedPrice * 1.5).toStringAsFixed(0)}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_showCounterOffer)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _showCounterOffer = true);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Counter Offer'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _isAccepting ? null : _acceptJob,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: _isAccepting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Accept Job'),
                      ),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() => _showCounterOffer = false);
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _isAccepting ? null : _submitCounterOffer,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: Colors.orange,
                        ),
                        child: _isAccepting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Submit Offer'),
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

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildRouteCard(ThemeData theme, AvailableJob job) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Pickup
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green.shade700, width: 2),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 40,
                    color: theme.colorScheme.outlineVariant,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PICKUP',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.pickupAddress,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      job.pickupArea,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.navigation_outlined),
                onPressed: () {},
              ),
            ],
          ),
          
          // Dropoff
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 12,
                height: 12,
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
                      'DROPOFF',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      job.dropoffAddress,
                      style: theme.textTheme.bodyMedium,
                    ),
                    Text(
                      job.dropoffArea,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.navigation_outlined),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
