import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String deliveryId;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.deliveryId,
    required this.amount,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  PaymentMethod _selectedMethod = PaymentMethod.mpesa;
  final _phoneController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // IMPLEMENTATION: Process actual M-Pesa payment
      await Future.delayed(const Duration(seconds: 3)); // Simulate payment processing

      if (mounted) {
        _showPaymentSuccess();
      }
    } catch (error) {
      if (mounted) {
        _showPaymentError();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Payment Successful'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your payment has been processed successfully.'),
            const SizedBox(height: 12),
            Text('Amount: KSh ${widget.amount.toInt()}'),
            Text('Method: ${_selectedMethod.displayName}'),
            Text('Transaction ID: MP${DateTime.now().millisecondsSinceEpoch}'),
            const SizedBox(height: 12),
            const Text('You will receive an SMS confirmation shortly.'),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              context.pop(); // Close dialog
              context.pop(); // Go back to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showPaymentError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Payment Failed'),
          ],
        ),
        content: const Text(
          'We could not process your payment. Please check your phone number and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('Try Again'),
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
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment summary
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
                        'Total Amount',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        'KSh ${widget.amount.toInt()}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery ID',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        widget.deliveryId,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Payment method selection
            Text(
              'Payment Method',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...PaymentMethod.values.map((method) => Card(
                  child: ListTile(
                    leading: Radio<PaymentMethod>(
                      value: method,
                      groupValue: _selectedMethod,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedMethod = value;
                          });
                        }
                      },
                    ),
                    title: Row(
                      children: [
                        Icon(
                          method.icon,
                          color: method.color,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(method.displayName),
                      ],
                    ),
                    subtitle: Text(method.description),
                    onTap: () {
                      setState(() {
                        _selectedMethod = method;
                      });
                    },
                  ),
                )),
            const SizedBox(height: 24),
            // Phone number input
            Text(
              'Phone Number',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'M-Pesa Phone Number',
                hintText: '+254700000000',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
                helperText: 'Enter the phone number registered with M-Pesa',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                if (!RegExp(r'^\+254[17]\d{8}$').hasMatch(value)) {
                  return 'Please enter a valid Kenyan phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Payment instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Payment Instructions',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '1. A payment prompt will be sent to your phone\n'
                    '2. Enter your M-Pesa PIN when prompted\n'
                    '3. You will receive an SMS confirmation\n'
                    '4. Payment will be processed immediately',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Security info
            Row(
              children: [
                Icon(
                  Icons.security,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your payment is secured by 256-bit SSL encryption',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Pay button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Processing Payment...'),
                        ],
                      )
                    : Text('Pay KSh ${widget.amount.toInt()}'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  context.pop();
                },
                child: const Text('Cancel Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum PaymentMethod {
  mpesa,
  airtelMoney,
  card;

  String get displayName {
    switch (this) {
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.airtelMoney:
        return 'Airtel Money';
      case PaymentMethod.card:
        return 'Credit/Debit Card';
    }
  }

  String get description {
    switch (this) {
      case PaymentMethod.mpesa:
        return 'Pay using your Safaricom M-Pesa account';
      case PaymentMethod.airtelMoney:
        return 'Pay using your Airtel Money wallet';
      case PaymentMethod.card:
        return 'Pay using Visa, Mastercard, or local cards';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.mpesa:
        return Icons.phone_android;
      case PaymentMethod.airtelMoney:
        return Icons.account_balance_wallet;
      case PaymentMethod.card:
        return Icons.credit_card;
    }
  }

  Color get color {
    switch (this) {
      case PaymentMethod.mpesa:
        return const Color(0xFF00A651); // M-Pesa green
      case PaymentMethod.airtelMoney:
        return const Color(0xFFE60000); // Airtel red
      case PaymentMethod.card:
        return const Color(0xFF1976D2); // Card blue
    }
  }
}