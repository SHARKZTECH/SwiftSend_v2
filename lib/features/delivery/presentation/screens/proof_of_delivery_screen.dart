import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../core/constants/app_constants.dart';
import '../widgets/signature_pad_widget.dart';

class ProofOfDeliveryScreen extends ConsumerStatefulWidget {
  final String? deliveryId;

  const ProofOfDeliveryScreen({super.key, this.deliveryId});

  @override
  ConsumerState<ProofOfDeliveryScreen> createState() => _ProofOfDeliveryScreenState();
}

class _ProofOfDeliveryScreenState extends ConsumerState<ProofOfDeliveryScreen> {
  final ImagePicker _picker = ImagePicker();
  final GlobalKey<SignaturePadWidgetState> _signatureKey = GlobalKey();
  
  String? _deliveryPhotoPath;
  bool _hasSignature = false;
  bool _isSubmitting = false;
  String _recipientName = '';
  final _recipientNameController = TextEditingController();

  @override
  void dispose() {
    _recipientNameController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _deliveryPhotoPath = photo.path;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _deliveryPhotoPath = photo.path;
      });
    }
  }

  void _onSignatureChanged(List<dynamic> points) {
    setState(() {
      _hasSignature = points.isNotEmpty;
    });
  }

  bool get _canSubmit {
    return _deliveryPhotoPath != null && 
           _hasSignature && 
           _recipientNameController.text.isNotEmpty;
  }

  Future<void> _submitProof() async {
    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);

    // Mock API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isSubmitting = false);

    if (mounted) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 48,
          ),
        ),
        title: const Text('Delivery Completed!'),
        content: const Text(
          'The proof of delivery has been submitted successfully. '
          'The customer will be notified.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go(AppConstants.routeRating);
            },
            child: const Text('Rate Customer'),
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
        title: const Text('Proof of Delivery'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Take a photo of the delivered package and collect the recipient\'s signature.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Photo section
            _buildSectionTitle(theme, 'Delivery Photo', Icons.camera_alt),
            const SizedBox(height: 12),
            _buildPhotoSection(theme),
            const SizedBox(height: 24),

            // Recipient name
            _buildSectionTitle(theme, 'Recipient Name', Icons.person),
            const SizedBox(height: 12),
            TextFormField(
              controller: _recipientNameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Who received the package?',
                hintText: 'Enter recipient name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: (value) {
                setState(() => _recipientName = value);
              },
            ),
            const SizedBox(height: 24),

            // Signature section
            _buildSectionTitle(theme, 'Recipient Signature', Icons.draw),
            const SizedBox(height: 12),
            SignaturePadWidget(
              key: _signatureKey,
              onSignatureChanged: _onSignatureChanged,
              height: 180,
            ),
            const SizedBox(height: 32),

            // Submit button
            FilledButton(
              onPressed: _canSubmit && !_isSubmitting ? _submitProof : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle),
                        SizedBox(width: 8),
                        Text('Complete Delivery'),
                      ],
                    ),
            ),
            const SizedBox(height: 16),

            // Missing items hint
            if (!_canSubmit)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Missing items:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_deliveryPhotoPath == null)
                      _buildMissingItem(theme, 'Delivery photo'),
                    if (_recipientNameController.text.isEmpty)
                      _buildMissingItem(theme, 'Recipient name'),
                    if (!_hasSignature)
                      _buildMissingItem(theme, 'Recipient signature'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoSection(ThemeData theme) {
    if (_deliveryPhotoPath != null) {
      return Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.primary, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(_deliveryPhotoPath!),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _buildPhotoActionButton(
                  theme,
                  Icons.refresh,
                  'Retake',
                  _takePhoto,
                ),
                const SizedBox(width: 8),
                _buildPhotoActionButton(
                  theme,
                  Icons.delete,
                  'Remove',
                  () => setState(() => _deliveryPhotoPath = null),
                  isDelete: true,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Photo captured',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: InkWell(
        onTap: _takePhoto,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'Take a photo of the delivered package',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Camera'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _pickFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoActionButton(
    ThemeData theme,
    IconData icon,
    String label,
    VoidCallback onPressed, {
    bool isDelete = false,
  }) {
    return Material(
      color: isDelete ? Colors.red : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isDelete ? Colors.white : theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: isDelete ? Colors.white : theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissingItem(ThemeData theme, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
