import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../config/app_colors.dart';
import '../../config/app_constants.dart';
import '../../utils/app_spacing.dart';
import '../../utils/app_sizing.dart';
import '../../utils/app_typography.dart';
import '../../widgets/nanosolve_logo.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.pastelAqua.withValues(alpha: 0.05),
              AppColors.pastelLavender.withValues(alpha: 0.05),
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

  Widget _buildHeader(context) {
    final l10n = AppLocalizations.of(context)!;
    final spacing = AppSpacing.of(context);
    final sizing = AppSizing.of(context);
    final typography = AppTypography.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.contentPaddingH,
        vertical: spacing.contentPaddingV),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: InkWell(
              onTap: () => Navigator.of(context).maybePop(),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.arrow_back_ios,
                      color: Colors.white, size: sizing.backIcon),
                  const SizedBox(width: AppConstants.space4),
                  Flexible(
                    child: Text(
                      l10n.categoryDetailBackToOverview,
                      style: typography.back.copyWith(
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.fade,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: spacing.headerSpacing),
          NanosolveLogo(height: sizing.logoHeightLg),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(context, '1. Introduction', [
            'This Privacy Policy explains how NanoSolve Hive ("App", "we", "our", or "us") collects, uses, discloses, and otherwise handles your information when you use our mobile application.',
          ]),
          _buildSection(context, '2. Information We Collect', [
            '• Device Information: Device type, operating system, unique identifiers, and mobile network information',
            '• Usage Information: Features accessed, interactions with content, and time spent in the App',
            '• Analytics Data: App performance metrics, crash reports, and error logs',
            '• Optional Information: Profile data you voluntarily provide for community features',
          ]),
          _buildSection(context, '3. How We Use Your Information', [
            '• Improve and maintain the App functionality',
            '• Analyze usage patterns to enhance user experience',
            '• Diagnose and fix technical issues',
            '• Send you important updates or notices',
            '• Comply with legal obligations',
          ]),
          _buildSection(context, '4. Data Storage and Security', [
            '• We implement industry-standard security measures',
            '• Data is stored securely on our servers',
            '• We never share personal data with third parties without consent',
            '• You can request data deletion at any time',
          ]),
          _buildSection(context, '5. Third-Party Services', [
            '• Firebase: Used for crash reporting and analytics',
            '• These services have their own privacy policies',
            '• We do not share personal identifiable information',
          ]),
          _buildSection(context, '6. Your Rights', [
            '• Access: Request a copy of your data',
            '• Correction: Update inaccurate information',
            '• Deletion: Request removal of your data',
            '• Opt-Out: Disable analytics in app settings',
          ]),
          _buildSection(context, '7. Children\'s Privacy', [
            'This App is not intended for users under 13 years old. We do not knowingly collect information from children.',
          ]),
          _buildSection(context, '8. Changes to This Policy', [
            'We may update this Privacy Policy periodically. Changes will be posted here with an updated date.',
          ]),
          _buildSection(context, '9. Contact Us', [
            'For privacy concerns or data requests, please contact us through the App settings or visit our website.',
          ]),
          const SizedBox(height: AppConstants.space20),
          Text(
            'Last Updated: January 2026',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
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
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: AppConstants.space8),
          ...content.map((text) => Padding(
                padding: const EdgeInsets.only(bottom: AppConstants.space8),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textMuted,
                        height: 1.6,
                        fontWeight: FontWeight.normal,
                      ),
                ),
              )),
        ],
      ),
    );
  }
}
