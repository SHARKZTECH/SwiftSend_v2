import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';

// Mock wallet data
final walletBalanceProvider = StateProvider<double>((ref) => 12450.00);
final recentTransactionsProvider = StateProvider<List<WalletTransaction>>((ref) => [
  WalletTransaction(
    id: '1',
    type: TransactionType.earning,
    amount: 350,
    description: 'Delivery to Karen',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    status: TransactionStatus.completed,
  ),
  WalletTransaction(
    id: '2',
    type: TransactionType.earning,
    amount: 550,
    description: 'Delivery to Westlands',
    timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    status: TransactionStatus.completed,
  ),
  WalletTransaction(
    id: '3',
    type: TransactionType.withdrawal,
    amount: 5000,
    description: 'M-Pesa Withdrawal',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    status: TransactionStatus.completed,
  ),
  WalletTransaction(
    id: '4',
    type: TransactionType.earning,
    amount: 280,
    description: 'Delivery to CBD',
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
    status: TransactionStatus.completed,
  ),
  WalletTransaction(
    id: '5',
    type: TransactionType.bonus,
    amount: 500,
    description: 'Weekend Bonus',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    status: TransactionStatus.completed,
  ),
]);

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  bool _isWithdrawing = false;

  void _showWithdrawDialog() {
    final amountController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Withdraw to M-Pesa',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Amount (KES)',
                prefixText: 'KES ',
                hintText: 'Enter amount',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum: KES 100 • Maximum: KES ${ref.read(walletBalanceProvider).toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // Quick amount buttons
            Wrap(
              spacing: 8,
              children: [500, 1000, 2000, 5000].map((amount) {
                return ActionChip(
                  label: Text('KES $amount'),
                  onPressed: () {
                    amountController.text = amount.toString();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() => _isWithdrawing = true);
                await Future.delayed(const Duration(seconds: 2));
                setState(() => _isWithdrawing = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Withdrawal request submitted! Check your M-Pesa.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Withdraw'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = ref.watch(walletBalanceProvider);
    final transactions = ref.watch(recentTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.push(AppConstants.routeTransactionHistory),
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance card
          Container(
            margin: const EdgeInsets.all(16),
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
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Available Balance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'KES ${balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isWithdrawing ? null : _showWithdrawDialog,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        icon: _isWithdrawing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.arrow_upward),
                        label: const Text('Withdraw'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white54),
                        ),
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Statement'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Today',
                    'KES 900',
                    Icons.today,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'This Week',
                    'KES 4,250',
                    Icons.calendar_view_week,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Deliveries',
                    '127',
                    Icons.local_shipping,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Recent transactions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Recent Transactions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push(AppConstants.routeTransactionHistory),
                  child: const Text('See All'),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                return _buildTransactionItem(theme, transaction);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(ThemeData theme, WalletTransaction transaction) {
    final isEarning = transaction.type == TransactionType.earning || 
                      transaction.type == TransactionType.bonus;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isEarning ? Colors.green : Colors.red).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.type.icon,
              color: isEarning ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _formatTime(transaction.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isEarning ? '+' : '-'}KES ${transaction.amount.toStringAsFixed(0)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: isEarning ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

enum TransactionType {
  earning,
  withdrawal,
  bonus,
  refund;

  IconData get icon {
    switch (this) {
      case TransactionType.earning:
        return Icons.local_shipping;
      case TransactionType.withdrawal:
        return Icons.arrow_upward;
      case TransactionType.bonus:
        return Icons.star;
      case TransactionType.refund:
        return Icons.refresh;
    }
  }
}

enum TransactionStatus { pending, completed, failed }

class WalletTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime timestamp;
  final TransactionStatus status;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.status,
  });
}
