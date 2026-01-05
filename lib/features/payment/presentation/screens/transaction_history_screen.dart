import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'wallet_screen.dart';

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  String _selectedFilter = 'all';
  DateTimeRange? _dateRange;

  // Extended mock transactions
  final List<WalletTransaction> _allTransactions = [
    WalletTransaction(
      id: '1',
      type: TransactionType.earning,
      amount: 350,
      description: 'Delivery to Karen Shopping Centre',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      status: TransactionStatus.completed,
    ),
    WalletTransaction(
      id: '2',
      type: TransactionType.earning,
      amount: 550,
      description: 'Delivery to Westlands Mall',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      status: TransactionStatus.completed,
    ),
    WalletTransaction(
      id: '3',
      type: TransactionType.withdrawal,
      amount: 5000,
      description: 'M-Pesa Withdrawal to 0712***456',
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
      description: 'Weekend Bonus - 10 deliveries completed',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      status: TransactionStatus.completed,
    ),
    WalletTransaction(
      id: '6',
      type: TransactionType.earning,
      amount: 420,
      description: 'Delivery to Kilimani',
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
      status: TransactionStatus.completed,
    ),
    WalletTransaction(
      id: '7',
      type: TransactionType.withdrawal,
      amount: 3000,
      description: 'M-Pesa Withdrawal to 0712***456',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      status: TransactionStatus.completed,
    ),
    WalletTransaction(
      id: '8',
      type: TransactionType.earning,
      amount: 380,
      description: 'Delivery to Lavington',
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      status: TransactionStatus.completed,
    ),
    WalletTransaction(
      id: '9',
      type: TransactionType.refund,
      amount: 150,
      description: 'Cancelled order refund',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      status: TransactionStatus.completed,
    ),
    WalletTransaction(
      id: '10',
      type: TransactionType.bonus,
      amount: 1000,
      description: 'New Rider Bonus',
      timestamp: DateTime.now().subtract(const Duration(days: 7)),
      status: TransactionStatus.completed,
    ),
  ];

  List<WalletTransaction> get _filteredTransactions {
    var transactions = _allTransactions;

    // Filter by type
    if (_selectedFilter != 'all') {
      transactions = transactions.where((t) {
        switch (_selectedFilter) {
          case 'earnings':
            return t.type == TransactionType.earning;
          case 'withdrawals':
            return t.type == TransactionType.withdrawal;
          case 'bonuses':
            return t.type == TransactionType.bonus;
          default:
            return true;
        }
      }).toList();
    }

    // Filter by date range
    if (_dateRange != null) {
      transactions = transactions.where((t) {
        return t.timestamp.isAfter(_dateRange!.start) &&
               t.timestamp.isBefore(_dateRange!.end.add(const Duration(days: 1)));
      }).toList();
    }

    return transactions;
  }

  double get _totalEarnings {
    return _filteredTransactions
        .where((t) => t.type == TransactionType.earning || t.type == TransactionType.bonus)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get _totalWithdrawals {
    return _filteredTransactions
        .where((t) => t.type == TransactionType.withdrawal)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );

    if (picked != null) {
      setState(() => _dateRange = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = _filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Statement download coming soon')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Summary cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    theme,
                    'Earnings',
                    'KES ${_totalEarnings.toStringAsFixed(0)}',
                    Colors.green,
                    Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    theme,
                    'Withdrawals',
                    'KES ${_totalWithdrawals.toStringAsFixed(0)}',
                    Colors.red,
                    Icons.arrow_upward,
                  ),
                ),
              ],
            ),
          ),

          // Date range indicator
          if (_dateRange != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.date_range,
                    size: 16,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatDate(_dateRange!.start)} - ${_formatDate(_dateRange!.end)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _dateRange = null),
                    child: Icon(
                      Icons.close,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip(theme, 'All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip(theme, 'Earnings', 'earnings'),
                const SizedBox(width: 8),
                _buildFilterChip(theme, 'Withdrawals', 'withdrawals'),
                const SizedBox(width: 8),
                _buildFilterChip(theme, 'Bonuses', 'bonuses'),
              ],
            ),
          ),

          // Transaction count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${transactions.length} transactions',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Transaction list
          Expanded(
            child: transactions.isEmpty
                ? _buildEmptyState(theme)
                : ListView.builder(
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

  Widget _buildSummaryCard(
    ThemeData theme,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ThemeData theme, String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
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
            Icons.receipt_long,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(ThemeData theme, WalletTransaction transaction) {
    final isEarning = transaction.type == TransactionType.earning ||
                      transaction.type == TransactionType.bonus ||
                      transaction.type == TransactionType.refund;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isEarning ? Colors.green : Colors.red).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.type.icon,
              color: isEarning ? Colors.green : Colors.red,
              size: 22,
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
                const SizedBox(height: 2),
                Text(
                  _formatDateTime(transaction.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isEarning ? '+' : '-'}KES ${transaction.amount.toStringAsFixed(0)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isEarning ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Completed',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inDays == 0) {
      return 'Today at ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Yesterday at ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return _formatDate(time);
    }
  }
}
