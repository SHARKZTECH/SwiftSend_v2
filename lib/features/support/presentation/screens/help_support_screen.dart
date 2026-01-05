import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends ConsumerStatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  ConsumerState<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends ConsumerState<HelpSupportScreen> {
  final List<FAQItem> _faqs = [
    FAQItem(
      question: 'How do I create a delivery?',
      answer: 'To create a delivery, tap the "+" button on the home screen or use the "Send Package" quick action. Fill in the pickup and delivery addresses, package details, and confirm your order.',
    ),
    FAQItem(
      question: 'How can I track my delivery?',
      answer: 'Once your delivery is accepted by a rider, you can track it in real-time from the Deliveries tab or by tapping "Track Live" on your delivery details page.',
    ),
    FAQItem(
      question: 'What payment methods are accepted?',
      answer: 'We accept M-Pesa, credit/debit cards, and cash on delivery (for eligible deliveries). You can select your preferred payment method during checkout.',
    ),
    FAQItem(
      question: 'How are delivery prices calculated?',
      answer: 'Delivery prices are based on distance, package size, delivery urgency, and current demand. You\'ll see the exact price before confirming your delivery.',
    ),
    FAQItem(
      question: 'Can I cancel my delivery?',
      answer: 'You can cancel your delivery before it\'s picked up by the rider. Once picked up, cancellation may incur charges. Contact support for assistance.',
    ),
    FAQItem(
      question: 'How do I become a rider?',
      answer: 'To become a rider, create an account with the "Rider" type, provide your vehicle details, and complete the verification process. You\'ll need a valid driving license and vehicle registration.',
    ),
    FAQItem(
      question: 'What if my package is damaged or lost?',
      answer: 'We provide insurance for all deliveries. If your package is damaged or lost, contact support immediately with your order details and we\'ll investigate and compensate accordingly.',
    ),
    FAQItem(
      question: 'How do I update my profile information?',
      answer: 'Go to your Profile tab and tap the edit icon (three dots) in the top right corner, then select "Edit Profile" to update your information.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quick Actions
            _buildQuickActions(theme),
            
            const SizedBox(height: 24),
            
            // FAQ Section
            _buildFAQSection(theme),
            
            const SizedBox(height: 24),
            
            // Contact Support
            _buildContactSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  theme,
                  'Call Support',
                  Icons.phone,
                  Colors.green,
                  () => _callSupport(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  theme,
                  'WhatsApp',
                  Icons.message,
                  Colors.green[600]!,
                  () => _openWhatsApp(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  theme,
                  'Email Us',
                  Icons.email,
                  Colors.blue,
                  () => _sendEmail(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    ThemeData theme,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Frequently Asked Questions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqs.length,
            itemBuilder: (context, index) {
              return _buildFAQItem(theme, _faqs[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(ThemeData theme, FAQItem faq) {
    return ExpansionTile(
      title: Text(
        faq.question,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            faq.answer,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                'Contact Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildContactInfo(
            theme,
            Icons.phone,
            'Phone Support',
            '+254 700 123 456',
            'Available 24/7',
          ),
          const SizedBox(height: 12),
          
          _buildContactInfo(
            theme,
            Icons.email,
            'Email Support',
            'support@swiftsend.co.ke',
            'Response within 24 hours',
          ),
          const SizedBox(height: 12),
          
          _buildContactInfo(
            theme,
            Icons.location_on,
            'Office Address',
            'Westlands, Nairobi, Kenya',
            'Mon-Fri 9AM-5PM',
          ),
          const SizedBox(height: 12),
          
          _buildContactInfo(
            theme,
            Icons.message,
            'WhatsApp Support',
            '+254 700 123 456',
            'Quick responses',
          ),
          
          const SizedBox(height: 24),
          
          // Additional Resources
          Text(
            'Additional Resources',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildResourceLink(
            theme,
            'Terms of Service',
            Icons.description,
            () => _showTermsOfService(context),
          ),
          
          _buildResourceLink(
            theme,
            'Privacy Policy',
            Icons.privacy_tip,
            () => _showPrivacyPolicy(context),
          ),
          
          _buildResourceLink(
            theme,
            'User Guide',
            Icons.menu_book,
            () => _showUserGuide(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(
    ThemeData theme,
    IconData icon,
    String title,
    String value,
    String subtitle,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResourceLink(
    ThemeData theme,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: onTap,
    );
  }

  void _callSupport() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+254700123456');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone app')),
        );
      }
    }
  }

  void _openWhatsApp() async {
    final Uri whatsappUri = Uri.parse('https://wa.me/254700123456');
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open WhatsApp')),
        );
      }
    }
  }

  void _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@swiftsend.co.ke',
      query: 'subject=Support Request&body=Hello SwiftSend Team,\n\n',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email app')),
        );
      }
    }
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'SwiftSend Terms of Service\n\n'
            '1. Acceptance of Terms\n'
            'By using SwiftSend, you agree to these terms and conditions.\n\n'
            '2. Service Description\n'
            'SwiftSend provides on-demand delivery services connecting users with riders.\n\n'
            '3. User Responsibilities\n'
            'Users must provide accurate information and comply with all applicable laws.\n\n'
            '4. Payment Terms\n'
            'Payment is due upon service completion through approved methods.\n\n'
            '5. Limitation of Liability\n'
            'SwiftSend\'s liability is limited to the value of the service provided.\n\n'
            '6. Termination\n'
            'Either party may terminate this agreement at any time.',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'SwiftSend Privacy Policy\n\n'
            '1. Information Collection\n'
            'We collect information necessary to provide our delivery services.\n\n'
            '2. Data Usage\n'
            'Your data is used to process deliveries and improve our services.\n\n'
            '3. Data Protection\n'
            'We implement security measures to protect your personal information.\n\n'
            '4. Third Party Sharing\n'
            'We do not sell your data to third parties.\n\n'
            '5. Your Rights\n'
            'You have the right to access, update, or delete your personal data.\n\n'
            '6. Contact\n'
            'Contact us at privacy@swiftsend.co.ke for privacy concerns.',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUserGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Guide'),
        content: const SingleChildScrollView(
          child: Text(
            'SwiftSend User Guide\n\n'
            'Getting Started:\n'
            '1. Create an account with your user type\n'
            '2. Verify your phone number and email\n'
            '3. Complete your profile information\n\n'
            'Creating a Delivery:\n'
            '1. Tap the "+" button or "Send Package"\n'
            '2. Enter pickup and delivery addresses\n'
            '3. Add package details and special instructions\n'
            '4. Choose payment method and confirm\n\n'
            'Tracking Your Delivery:\n'
            '1. Go to the Deliveries tab\n'
            '2. Tap on your active delivery\n'
            '3. Use "Track Live" for real-time updates\n\n'
            'For Riders:\n'
            '1. Go online to receive delivery requests\n'
            '2. Accept deliveries that match your availability\n'
            '3. Follow pickup and delivery instructions\n'
            '4. Confirm delivery completion',
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;

  FAQItem({
    required this.question,
    required this.answer,
  });
}