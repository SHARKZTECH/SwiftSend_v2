import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';

class RatingScreen extends ConsumerStatefulWidget {
  final String? deliveryId;
  final bool isRatingCustomer; // true for rider rating customer, false for customer rating rider

  const RatingScreen({
    super.key,
    this.deliveryId,
    this.isRatingCustomer = false,
  });

  @override
  ConsumerState<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends ConsumerState<RatingScreen> {
  int _rating = 0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;
  final List<String> _selectedTags = [];

  // Common rating tags
  final List<String> _positiveTags = [
    'Friendly',
    'Professional',
    'On Time',
    'Great Communication',
    'Careful with Package',
    'Fast Delivery',
  ];

  final List<String> _negativeTags = [
    'Late',
    'Rude',
    'Poor Communication',
    'Careless Handling',
    'Wrong Location',
  ];

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  List<String> get _availableTags {
    if (_rating >= 4) return _positiveTags;
    if (_rating <= 2 && _rating > 0) return _negativeTags;
    return [];
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    // Mock API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    if (mounted) {
      _showThankYouDialog();
    }
  }

  void _showThankYouDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.star,
            color: Colors.amber,
            size: 48,
          ),
        ),
        title: const Text('Thank You!'),
        content: const Text(
          'Your feedback helps us improve our service and recognize great riders.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppConstants.routeHome);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ratingTarget = widget.isRatingCustomer ? 'Customer' : 'Rider';

    return Scaffold(
      appBar: AppBar(
        title: Text('Rate Your $ratingTarget'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Avatar
            CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Text(
                'J',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Name
            Text(
              widget.isRatingCustomer ? 'Mary Wanjiku' : 'John Mwangi',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.isRatingCustomer 
                  ? 'Customer'
                  : 'Honda CB150R • KCA 123A',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Rating prompt
            Text(
              'How was your experience?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Star rating
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starNumber = index + 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = starNumber;
                      _selectedTags.clear();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: AnimatedScale(
                      scale: _rating >= starNumber ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        _rating >= starNumber ? Icons.star : Icons.star_border,
                        size: 48,
                        color: _rating >= starNumber 
                            ? Colors.amber 
                            : theme.colorScheme.outline,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),

            // Rating text
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _getRatingText(),
                key: ValueKey(_rating),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _getRatingColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick tags
            if (_availableTags.isNotEmpty) ...[
              Text(
                'What went well?',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: _availableTags.map((tag) {
                  final isSelected = _selectedTags.contains(tag);
                  return FilterChip(
                    selected: isSelected,
                    label: Text(tag),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Review text field
            TextField(
              controller: _reviewController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: 'Write a review (optional)',
                hintText: 'Tell us more about your experience...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            FilledButton(
              onPressed: _isSubmitting ? null : _submitRating,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Rating'),
            ),
            const SizedBox(height: 12),

            // Skip button
            TextButton(
              onPressed: () => context.go(AppConstants.routeHome),
              child: const Text('Skip for now'),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText() {
    switch (_rating) {
      case 1:
        return 'Very Poor';
      case 2:
        return 'Poor';
      case 3:
        return 'Average';
      case 4:
        return 'Good';
      case 5:
        return 'Excellent!';
      default:
        return 'Tap to rate';
    }
  }

  Color _getRatingColor() {
    switch (_rating) {
      case 1:
      case 2:
        return Colors.red;
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
