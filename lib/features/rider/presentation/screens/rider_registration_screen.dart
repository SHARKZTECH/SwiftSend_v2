import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../../core/constants/app_constants.dart';

class RiderRegistrationScreen extends ConsumerStatefulWidget {
  const RiderRegistrationScreen({super.key});

  @override
  ConsumerState<RiderRegistrationScreen> createState() => _RiderRegistrationScreenState();
}

class _RiderRegistrationScreenState extends ConsumerState<RiderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nationalIdController = TextEditingController();
  final _drivingLicenseController = TextEditingController();
  final _ntsaPermitController = TextEditingController();
  final _vehicleRegController = TextEditingController();
  final _vehicleTypeController = TextEditingController();
  
  int _currentStep = 0;
  bool _isSubmitting = false;
  
  // Mock file paths for uploaded documents
  String? _nationalIdPhoto;
  String? _drivingLicensePhoto;
  String? _vehiclePhoto;
  String? _insurancePhoto;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nationalIdController.dispose();
    _drivingLicenseController.dispose();
    _ntsaPermitController.dispose();
    _vehicleRegController.dispose();
    _vehicleTypeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String documentType) async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    
    if (image != null) {
      setState(() {
        switch (documentType) {
          case 'national_id':
            _nationalIdPhoto = image.path;
            break;
          case 'driving_license':
            _drivingLicensePhoto = image.path;
            break;
          case 'vehicle':
            _vehiclePhoto = image.path;
            break;
          case 'insurance':
            _insurancePhoto = image.path;
            break;
        }
      });
    }
  }

  void _submitRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSubmitting = true);
    
    // Mock API call delay
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isSubmitting = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration submitted! Awaiting verification.'),
          backgroundColor: Colors.green,
        ),
      );
      context.go(AppConstants.routeHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Registration'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _submitRegistration();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (_currentStep < 2)
                    FilledButton(
                      onPressed: details.onStepContinue,
                      child: const Text('Continue'),
                    )
                  else
                    FilledButton(
                      onPressed: _isSubmitting ? null : details.onStepContinue,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Submit'),
                    ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                ],
              ),
            );
          },
          steps: [
            // Step 1: Personal Documents
            Step(
              title: const Text('Personal Documents'),
              subtitle: const Text('ID and License'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nationalIdController,
                    decoration: const InputDecoration(
                      labelText: 'National ID Number',
                      prefixIcon: Icon(Icons.badge_outlined),
                      hintText: 'Enter your ID number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your National ID number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentUpload(
                    theme: theme,
                    title: 'National ID Photo',
                    subtitle: 'Upload front side of your ID',
                    imagePath: _nationalIdPhoto,
                    onTap: () => _pickImage('national_id'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _drivingLicenseController,
                    decoration: const InputDecoration(
                      labelText: 'Driving License Number',
                      prefixIcon: Icon(Icons.card_membership_outlined),
                      hintText: 'Enter your license number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your Driving License number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentUpload(
                    theme: theme,
                    title: 'Driving License Photo',
                    subtitle: 'Upload your driving license',
                    imagePath: _drivingLicensePhoto,
                    onTap: () => _pickImage('driving_license'),
                  ),
                ],
              ),
            ),
            
            // Step 2: Vehicle Details
            Step(
              title: const Text('Vehicle Details'),
              subtitle: const Text('Motorcycle information'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _vehicleRegController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Registration',
                      prefixIcon: Icon(Icons.motorcycle_outlined),
                      hintText: 'e.g., KMXX 123X',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter vehicle registration';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _vehicleTypeController.text.isEmpty 
                        ? null 
                        : _vehicleTypeController.text,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Type',
                      prefixIcon: Icon(Icons.two_wheeler_outlined),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'motorcycle', child: Text('Motorcycle')),
                      DropdownMenuItem(value: 'scooter', child: Text('Scooter')),
                      DropdownMenuItem(value: 'electric', child: Text('Electric Bike')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _vehicleTypeController.text = value ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select vehicle type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _ntsaPermitController,
                    decoration: const InputDecoration(
                      labelText: 'NTSA Permit Number',
                      prefixIcon: Icon(Icons.verified_outlined),
                      hintText: 'Enter NTSA permit number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter NTSA permit number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentUpload(
                    theme: theme,
                    title: 'Vehicle Photo',
                    subtitle: 'Upload photo of your motorcycle',
                    imagePath: _vehiclePhoto,
                    onTap: () => _pickImage('vehicle'),
                  ),
                ],
              ),
            ),
            
            // Step 3: Insurance
            Step(
              title: const Text('Insurance'),
              subtitle: const Text('Vehicle insurance document'),
              isActive: _currentStep >= 2,
              state: _currentStep > 2 ? StepState.complete : StepState.indexed,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDocumentUpload(
                    theme: theme,
                    title: 'Insurance Document',
                    subtitle: 'Upload your vehicle insurance',
                    imagePath: _insurancePhoto,
                    onTap: () => _pickImage('insurance'),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
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
                              'Verification Process',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your documents will be verified within 24-48 hours. '
                          'You will receive a notification once approved.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentUpload({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: imagePath != null 
                ? theme.colorScheme.primary 
                : theme.colorScheme.outline,
            width: imagePath != null ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: imagePath != null 
              ? theme.colorScheme.primaryContainer.withOpacity(0.1) 
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(imagePath),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.add_a_photo_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (imagePath != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Uploaded',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
