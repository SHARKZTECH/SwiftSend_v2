import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../payment/presentation/screens/payment_screen.dart';

class CreateDeliveryScreen extends ConsumerStatefulWidget {
  const CreateDeliveryScreen({super.key});

  @override
  ConsumerState<CreateDeliveryScreen> createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends ConsumerState<CreateDeliveryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _pickupAddressController = TextEditingController();
  final _dropoffAddressController = TextEditingController();
  final _packageDescriptionController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  
  // Package details
  PackageSize _packageSize = PackageSize.small;
  bool _isFragile = false;
  bool _requiresSignature = false;
  double _estimatedPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _calculatePrice();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _pickupAddressController.dispose();
    _dropoffAddressController.dispose();
    _packageDescriptionController.dispose();
    _specialInstructionsController.dispose();
    super.dispose();
  }

  void _calculatePrice() {
    // IMPLEMENTATION: Replace with actual price calculation algorithm
    double basePrice = 200.0;
    switch (_packageSize) {
      case PackageSize.small:
        basePrice = 200.0;
        break;
      case PackageSize.medium:
        basePrice = 350.0;
        break;
      case PackageSize.large:
        basePrice = 500.0;
        break;
      case PackageSize.extraLarge:
        basePrice = 750.0;
        break;
    }
    
    if (_isFragile) basePrice += 100.0;
    if (_requiresSignature) basePrice += 50.0;
    
    setState(() {
      _estimatedPrice = basePrice;
    });
  }

  void _createDelivery() async {
    if (!_formKey.currentState!.validate()) return;

    // Navigate to payment screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          deliveryId: 'SW${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          amount: _estimatedPrice,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Delivery'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details', icon: Icon(Icons.info_outline)),
            Tab(text: 'Locations', icon: Icon(Icons.location_on_outlined)),
            Tab(text: 'Review', icon: Icon(Icons.check_circle_outline)),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(theme),
            _buildLocationsTab(theme),
            _buildReviewTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Package Details',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Package size selector
          Text('Package Size', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: PackageSize.values.map((size) {
              return ChoiceChip(
                label: Text(size.displayName),
                selected: _packageSize == size,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _packageSize = size;
                    });
                    _calculatePrice();
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          // Package description
          TextFormField(
            controller: _packageDescriptionController,
            decoration: const InputDecoration(
              labelText: 'Package Description',
              hintText: 'Electronics, documents, food, etc.',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.inventory),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please describe your package';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Receiver details
          Text('Receiver Details', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          TextFormField(
            controller: _receiverNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Receiver Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter receiver name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _receiverPhoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Receiver Phone',
              hintText: '+254700000000',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter receiver phone number';
              }
              if (!RegExp(r'^\+254[17]\d{8}$').hasMatch(value)) {
                return 'Please enter a valid Kenyan phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          // Special options
          Text('Special Requirements', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Fragile Package'),
            subtitle: const Text('Handle with extra care (+KSh 100)'),
            value: _isFragile,
            onChanged: (value) {
              setState(() {
                _isFragile = value;
              });
              _calculatePrice();
            },
          ),
          SwitchListTile(
            title: const Text('Require Signature'),
            subtitle: const Text('Receiver must sign for delivery (+KSh 50)'),
            value: _requiresSignature,
            onChanged: (value) {
              setState(() {
                _requiresSignature = value;
              });
              _calculatePrice();
            },
          ),
          const SizedBox(height: 24),
          // Special instructions
          TextFormField(
            controller: _specialInstructionsController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Special Instructions',
              hintText: 'Any special delivery instructions...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
          ),
          const SizedBox(height: 32),
          // Price display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Estimated Price',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'KSh ${_estimatedPrice.toInt()}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Continue button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                _tabController.animateTo(1);
              },
              child: const Text('Continue to Locations'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup & Delivery Locations',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Pickup location
          TextFormField(
            controller: _pickupAddressController,
            decoration: InputDecoration(
              labelText: 'Pickup Location',
              hintText: 'Enter pickup address',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.my_location),
              suffixIcon: IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  // IMPLEMENTATION: Open map to select location
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Map selection coming soon')),
                  );
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter pickup location';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Use current location button
          OutlinedButton.icon(
            onPressed: () {
              // IMPLEMENTATION: Get current location
              _pickupAddressController.text = 'Current Location (GPS)';
            },
            icon: const Icon(Icons.gps_fixed),
            label: const Text('Use Current Location'),
          ),
          const SizedBox(height: 32),
          // Dropoff location
          TextFormField(
            controller: _dropoffAddressController,
            decoration: InputDecoration(
              labelText: 'Delivery Location',
              hintText: 'Enter delivery address',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.location_on),
              suffixIcon: IconButton(
                icon: const Icon(Icons.map),
                onPressed: () {
                  // IMPLEMENTATION: Open map to select location
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Map selection coming soon')),
                  );
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter delivery location';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          // Map preview placeholder
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.map,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  'Map Preview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Route and distance will be shown here',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    if (_pickupAddressController.text.isNotEmpty &&
                        _dropoffAddressController.text.isNotEmpty) {
                      _tabController.animateTo(2);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill in both locations'),
                        ),
                      );
                    }
                  },
                  child: const Text('Review'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review Delivery',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          // Summary cards
          _buildSummaryCard(
            theme,
            'Package Details',
            [
              'Description: ${_packageDescriptionController.text}',
              'Size: ${_packageSize.displayName}',
              if (_isFragile) 'Fragile package',
              if (_requiresSignature) 'Signature required',
            ],
            Icons.inventory,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            theme,
            'Receiver',
            [
              'Name: ${_receiverNameController.text}',
              'Phone: ${_receiverPhoneController.text}',
            ],
            Icons.person,
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(
            theme,
            'Locations',
            [
              'Pickup: ${_pickupAddressController.text}',
              'Delivery: ${_dropoffAddressController.text}',
            ],
            Icons.location_on,
          ),
          if (_specialInstructionsController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSummaryCard(
              theme,
              'Special Instructions',
              [_specialInstructionsController.text],
              Icons.note,
            ),
          ],
          const SizedBox(height: 32),
          // Price breakdown
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Price',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'KSh ${_estimatedPrice.toInt()}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Final price may vary based on actual distance and rider availability',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _tabController.animateTo(1);
                  },
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: _createDelivery,
                  child: const Text('Create Delivery'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    String title,
    List<String> details,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...details.map((detail) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    detail,
                    style: theme.textTheme.bodyMedium,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

enum PackageSize {
  small,
  medium,
  large,
  extraLarge;

  String get displayName {
    switch (this) {
      case PackageSize.small:
        return 'Small';
      case PackageSize.medium:
        return 'Medium';
      case PackageSize.large:
        return 'Large';
      case PackageSize.extraLarge:
        return 'Extra Large';
    }
  }
}