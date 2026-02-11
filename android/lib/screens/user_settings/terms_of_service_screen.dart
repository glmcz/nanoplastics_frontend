import 'package:flutter/material.dart';
import 'dart:ui';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../widgets/header_back_button.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.pastelLavender.withValues(alpha: 0.05),
              AppColors.pastelMint.withValues(alpha: 0.05),
              const Color(0xFF0A0A12),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.space24),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeaderBackButton(
                  label: 'Back',
                  color: AppColors.pastelLavender,
                ),
                Icon(Icons.description_outlined,
                    size: AppConstants.iconMedium,
                    color: AppColors.pastelLavender),
              ],
            ),
            const SizedBox(height: AppConstants.space16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TERMS OF SERVICE',
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            context,
            '1. Acceptance of Terms',
            [
              'By accessing and using the NanoSolve Hive App, you accept and agree to be bound by the terms and provision of this agreement.',
            ],
          ),
          _buildSection(
            context,
            '2. License Grant',
            [
              'We grant you a limited, non-exclusive, non-transferable license to use this App for personal, non-commercial purposes only.',
              'You may not reproduce, distribute, or transmit the App or its content without our prior written permission.',
            ],
          ),
          _buildSection(
            context,
            '3. User Responsibilities',
            [
              '• You agree to use the App lawfully and responsibly',
              '• You will not engage in harassment, abuse, or defamatory conduct',
              '• You will not attempt to hack, reverse engineer, or compromise App security',
              '• You are responsible for maintaining the confidentiality of your account',
            ],
          ),
          _buildSection(
            context,
            '4. Intellectual Property Rights',
            [
              '• All content, features, and functionality are owned by NanoSolve Hive',
              '• Open source components retain their respective licenses',
              '• User-generated content remains your property, but you grant us a license to use it',
            ],
          ),
          _buildSection(
            context,
            '5. Content Disclaimer',
            [
              '• The App provides information for educational purposes only',
              '• We do not guarantee the accuracy or completeness of the information',
              '• Always consult qualified professionals before making decisions based on App content',
            ],
          ),
          _buildSection(
            context,
            '6. Limitation of Liability',
            [
              'To the fullest extent permitted by law, we shall not be liable for:',
              '• Indirect, incidental, or consequential damages',
              '• Loss of data, profits, or business opportunities',
              '• Use or inability to use the App',
            ],
          ),
          _buildSection(
            context,
            '7. Community Guidelines',
            [
              '• Respect other users and their contributions',
              '• No spam, advertising, or commercial promotion',
              '• Do not share inappropriate, offensive, or illegal content',
              '• Report violations to support@nanoslve.app',
            ],
          ),
          _buildSection(
            context,
            '8. Modifications to Terms',
            [
              'We reserve the right to modify these terms at any time. Continued use of the App indicates acceptance of updated terms.',
            ],
          ),
          _buildSection(
            context,
            '9. Termination',
            [
              'We may terminate or suspend your access immediately, without prior notice, for violations of these terms or applicable laws.',
            ],
          ),
          _buildSection(
            context,
            '10. Governing Law',
            [
              'These terms are governed by and construed in accordance with applicable law.',
            ],
          ),
          _buildSection(
            context,
            '11. Contact Information',
            [
              'For questions about these terms, please contact us through the App settings.',
            ],
          ),
          const SizedBox(height: AppConstants.space20),
          Text(
            'Last Updated: January 2026',
            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.space40),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String title, List<String> content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppConstants.space8),
          ...content.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.space8),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: AppColors.textMuted,
                        height: 1.6,
                      ),
                ),
              )),
        ],
      ),
    );
  }
}
