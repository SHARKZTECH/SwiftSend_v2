import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/providers/supabase_auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bioController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _vehicleTypeController;
  late final TextEditingController _plateNumberController;
  late final TextEditingController _licenseNumberController;
  late final TextEditingController _businessNameController;
  late final TextEditingController _businessTypeController;
  late final TextEditingController _businessRegistrationController;
  late final TextEditingController _websiteController;
  late final TextEditingController _businessDescriptionController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _phoneController = TextEditingController(text: widget.user.phoneNumber);
    _bioController = TextEditingController(text: widget.user.profile?.bio);
    _addressController = TextEditingController(text: widget.user.profile?.address);
    _cityController = TextEditingController(text: widget.user.profile?.city);
    _vehicleTypeController = TextEditingController(text: widget.user.profile?.vehicleType);
    _plateNumberController = TextEditingController(text: widget.user.profile?.plateNumber);
    _licenseNumberController = TextEditingController(text: widget.user.profile?.licenseNumber);
    _businessNameController = TextEditingController(text: widget.user.profile?.businessInfo?.businessName);
    _businessTypeController = TextEditingController(text: widget.user.profile?.businessInfo?.businessType);
    _businessRegistrationController = TextEditingController(text: widget.user.profile?.businessInfo?.businessRegistrationNumber);
    _websiteController = TextEditingController(text: widget.user.profile?.businessInfo?.website);
    _businessDescriptionController = TextEditingController(text: widget.user.profile?.businessInfo?.description);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _vehicleTypeController.dispose();
    _plateNumberController.dispose();
    _licenseNumberController.dispose();
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _businessRegistrationController.dispose();
    _websiteController.dispose();
    _businessDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated user profile
      UserProfile? updatedProfile;
      BusinessInfo? businessInfo;

      // Handle business info for business users
      if (widget.user.userType == UserType.business) {
        businessInfo = BusinessInfo(
          businessName: _businessNameController.text.trim(),
          businessType: _businessTypeController.text.trim(),
          businessRegistrationNumber: _businessRegistrationController.text.trim().isNotEmpty
              ? _businessRegistrationController.text.trim()
              : null,
          website: _websiteController.text.trim().isNotEmpty
              ? _websiteController.text.trim()
              : null,
          description: _businessDescriptionController.text.trim().isNotEmpty
              ? _businessDescriptionController.text.trim()
              : null,
        );
      }

      // Create updated profile
      updatedProfile = UserProfile(
        bio: _bioController.text.trim().isNotEmpty ? _bioController.text.trim() : null,
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
        country: widget.user.profile?.country ?? 'Kenya',
        idNumber: widget.user.profile?.idNumber,
        licenseNumber: widget.user.userType == UserType.rider
            ? (_licenseNumberController.text.trim().isNotEmpty ? _licenseNumberController.text.trim() : null)
            : widget.user.profile?.licenseNumber,
        vehicleType: widget.user.userType == UserType.rider
            ? (_vehicleTypeController.text.trim().isNotEmpty ? _vehicleTypeController.text.trim() : null)
            : widget.user.profile?.vehicleType,
        plateNumber: widget.user.userType == UserType.rider
            ? (_plateNumberController.text.trim().isNotEmpty ? _plateNumberController.text.trim() : null)
            : widget.user.profile?.plateNumber,
        rating: widget.user.profile?.rating,
        completedDeliveries: widget.user.profile?.completedDeliveries,
        totalEarnings: widget.user.profile?.totalEarnings,
        businessInfo: businessInfo ?? widget.user.profile?.businessInfo,
      );

      // Create updated user model
      final updatedUser = widget.user.copyWith(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        profile: updatedProfile,
        updatedAt: DateTime.now(),
      );

      // Update profile
      final authNotifier = ref.read(supabaseAuthNotifierProvider.notifier);
      final result = await authNotifier.updateProfile(updatedUser);

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture section
              _buildProfilePictureSection(theme),
              const SizedBox(height: 32),

              // Basic information
              _buildSectionHeader('Basic Information'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _fullNameController,
                label: 'Full Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!RegExp(r'^\+254[17]\d{8}$').hasMatch(value.trim())) {
                    return 'Please enter a valid Kenyan phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _bioController,
                label: 'Bio (Optional)',
                icon: Icons.description,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Location information
              _buildSectionHeader('Location'),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _addressController,
                label: 'Address (Optional)',
                icon: Icons.location_on,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _cityController,
                label: 'City (Optional)',
                icon: Icons.location_city,
              ),
              const SizedBox(height: 32),

              // Rider-specific fields
              if (widget.user.userType == UserType.rider) ...[
                _buildSectionHeader('Vehicle Information'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _vehicleTypeController,
                  label: 'Vehicle Type (Optional)',
                  icon: Icons.motorcycle,
                  hint: 'e.g., Honda CB150R',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _plateNumberController,
                  label: 'Plate Number (Optional)',
                  icon: Icons.confirmation_number,
                  hint: 'e.g., KCA 123A',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _licenseNumberController,
                  label: 'License Number (Optional)',
                  icon: Icons.card_membership,
                ),
                const SizedBox(height: 32),
              ],

              // Business-specific fields
              if (widget.user.userType == UserType.business) ...[
                _buildSectionHeader('Business Information'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _businessNameController,
                  label: 'Business Name',
                  icon: Icons.business,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your business name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _businessTypeController,
                  label: 'Business Type',
                  icon: Icons.category,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your business type';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _businessRegistrationController,
                  label: 'Registration Number (Optional)',
                  icon: Icons.numbers,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _websiteController,
                  label: 'Website (Optional)',
                  icon: Icons.web,
                  hint: 'https://example.com',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _businessDescriptionController,
                  label: 'Business Description (Optional)',
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
              ],

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: theme.colorScheme.primaryContainer,
                backgroundImage: widget.user.profileImageUrl != null
                    ? NetworkImage(widget.user.profileImageUrl!)
                    : null,
                child: widget.user.profileImageUrl == null
                    ? Text(
                        widget.user.fullName.isNotEmpty ? widget.user.fullName[0].toUpperCase() : 'U',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () {
                      // Handle image upload
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Image upload coming soon')),
                      );
                    },
                    icon: Icon(
                      Icons.camera_alt,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to change photo',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }
}