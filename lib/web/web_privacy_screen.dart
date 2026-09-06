import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../l10n_web/web_localizations.dart';
import '../utils/url_utils.dart';
import 'web_theme.dart';

class WebPrivacyScreen extends StatelessWidget {
  const WebPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = WebLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: WebTheme.bg,
      appBar: AppBar(
        backgroundColor: WebTheme.bg.withValues(alpha: 0.95),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: WebTheme.textPrimary),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          '🧬 NanoSolve Hive',
          style: TextStyle(color: WebTheme.accent, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: WebTheme.borderSubtle),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(context),
                  const SizedBox(height: 48),
                  // Section 1: Introduction
                  _Section(
                    title: l10n.privacyS1Title,
                    children: [
                      _P(l10n.privacyS1P1),
                      _P(l10n.privacyS1P2),
                    ],
                  ),
                  // Section 2: Information We Collect
                  _Section(
                    title: l10n.privacyS2Title,
                    children: [
                      _H3(l10n.privacyS2DeviceTitle),
                      _BulletList(l10n.privacyS2DeviceItems.split('\n')),
                      _H3(l10n.privacyS2UsageTitle),
                      _BulletList(l10n.privacyS2UsageItems.split('\n')),
                      _H3(l10n.privacyS2AnalyticsTitle),
                      _BulletList(l10n.privacyS2AnalyticsItems.split('\n')),
                      _H3(l10n.privacyS2UserTitle),
                      _BulletList(l10n.privacyS2UserItems.split('\n')),
                    ],
                  ),
                  // Section 3: Submitted Ideas
                  _Section(
                    title: l10n.privacyS3Title,
                    children: [
                      _Highlight(
                        child: _RichP(
                          spans: [
                            TextSpan(
                              text: '${l10n.privacyS3HighlightLabel} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: WebTheme.accent,
                              ),
                            ),
                            TextSpan(text: l10n.privacyS3Highlight),
                          ],
                        ),
                      ),
                      _H3(l10n.privacyS3OwnerTitle),
                      _P(l10n.privacyS3OwnerP),
                      _H3(l10n.privacyS3LicenseTitle),
                      _P(l10n.privacyS3LicenseP),
                      _LinkP(
                        text: 'Full license text: ',
                        url: 'https://creativecommons.org/licenses/by/4.0/',
                        label: l10n.privacyS3LicenseLinkText,
                      ),
                      _H3(l10n.privacyS3WhyTitle),
                      _P(l10n.privacyS3WhyP),
                      _H3(l10n.privacyS3PatentsTitle),
                      _P(l10n.privacyS3PatentsP),
                      _H3(l10n.privacyS3NeverTitle),
                      _BulletList(l10n.privacyS3NeverItems.split('\n')),
                      _H3(l10n.privacyS3AnonTitle),
                      _P(l10n.privacyS3AnonP),
                    ],
                  ),
                  // Section 5: How We Use Your Information
                  _Section(
                    title: l10n.privacyS5Title,
                    children: [
                      _BulletList(l10n.privacyS5Items.split('\n')),
                    ],
                  ),
                  // Section 6: Data Storage and Security
                  _Section(
                    title: l10n.privacyS6Title,
                    children: [
                      _BulletList(l10n.privacyS6Items.split('\n')),
                      _Highlight(
                        child: _RichP(
                          spans: [
                            TextSpan(
                              text: '${l10n.privacyS6HighlightLabel} ',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: WebTheme.accent,
                              ),
                            ),
                            TextSpan(text: l10n.privacyS6Highlight),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Section 7: Third-Party Services
                  _Section(
                    title: l10n.privacyS7Title,
                    children: [
                      _P(l10n.privacyS7Intro),
                      _H3(l10n.privacyS7FirebaseTitle),
                      _BulletList(l10n.privacyS7FirebaseItems.split('\n')),
                      _H3(l10n.privacyS7PlayTitle),
                      _P(l10n.privacyS7PlayP),
                      _P(l10n.privacyS7Note),
                    ],
                  ),
                  // Section 8: Your Rights and Choices
                  _Section(
                    title: l10n.privacyS8Title,
                    children: [
                      _H3(l10n.privacyS8AccessTitle),
                      _P(l10n.privacyS8AccessP),
                      _H3(l10n.privacyS8CorrectTitle),
                      _P(l10n.privacyS8CorrectP),
                      _H3(l10n.privacyS8DeleteTitle),
                      _P(l10n.privacyS8DeleteP),
                      _H3(l10n.privacyS8OptoutTitle),
                      _P(l10n.privacyS8OptoutP),
                      _H3(l10n.privacyS8ManageTitle),
                      _P(l10n.privacyS8ManageP),
                    ],
                  ),
                  // Section 9: Children's Privacy
                  _Section(
                    title: l10n.privacyS9Title,
                    children: [
                      _P(l10n.privacyS9P),
                    ],
                  ),
                  // Section 10: Data Retention
                  _Section(
                    title: l10n.privacyS10Title,
                    children: [
                      _BulletList(l10n.privacyS10Items.split('\n')),
                    ],
                  ),
                  // Section 11: International Data Transfers
                  _Section(
                    title: l10n.privacyS11Title,
                    children: [
                      _P(l10n.privacyS11P),
                    ],
                  ),
                  // Section 12: Changes to This Privacy Policy
                  _Section(
                    title: l10n.privacyS12Title,
                    children: [
                      _P(l10n.privacyS12P1),
                      _BulletList(l10n.privacyS12Items.split('\n')),
                      _P(l10n.privacyS12P2),
                    ],
                  ),
                  // Section 13: California Privacy Rights (CCPA)
                  _Section(
                    title: l10n.privacyS13Title,
                    children: [
                      _P(l10n.privacyS13P),
                    ],
                  ),
                  // Section 14: European Privacy Rights (GDPR)
                  _Section(
                    title: l10n.privacyS14Title,
                    children: [
                      _P(l10n.privacyS14P),
                    ],
                  ),
                  // Section 15: Contact Us
                  _Section(
                    title: l10n.privacyS15Title,
                    children: [
                      _P(l10n.privacyS15P1),
                      _Highlight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _RichP(
                              spans: [
                                TextSpan(
                                  text: l10n.privacyS15HighlightTeam,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                            _P(l10n.privacyS15HighlightEmail),
                            _P(l10n.privacyS15HighlightContact),
                          ],
                        ),
                      ),
                      _P(l10n.privacyS15P2),
                      _P(l10n.privacyS15P3),
                    ],
                  ),
                  // Section 16: Additional Resources
                  _Section(
                    title: l10n.privacyS16Title,
                    children: [
                      _LinkLine(
                        url: 'https://github.com/glmcz/nanoplastics_frontend',
                        label: l10n.privacyS16GithubLabel,
                      ),
                      _LinkLine(
                        url: 'https://firebase.google.com/support/privacy',
                        label: l10n.privacyS16FirebaseLabel,
                      ),
                      _LinkLine(
                        url: 'https://policies.google.com/privacy',
                        label: l10n.privacyS16GoogleLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),
                  _footer(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final l10n = WebLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.privacyPageTitle,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: WebTheme.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.privacyLastUpdated,
          style: const TextStyle(color: WebTheme.textMuted, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Container(height: 1, color: WebTheme.borderSubtle),
      ],
    );
  }

  Widget _footer(BuildContext context) {
    final l10n = WebLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(height: 1, color: WebTheme.borderSubtle),
        const SizedBox(height: 24),
        Text(
          l10n.privacyFooterCopyright,
          style: const TextStyle(color: WebTheme.textMuted, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.privacyFooterHome,
                style: const TextStyle(color: AppColors.neonCyan),
              ),
            ),
            const Text(' · ', style: TextStyle(color: WebTheme.textMuted)),
            GestureDetector(
              onTap: () => openExternalUrl(
                  'https://github.com/glmcz/nanoplastics_frontend'),
              child: Text(
                l10n.privacyFooterGithub,
                style: const TextStyle(color: AppColors.neonCyan),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Helper Widgets
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: WebTheme.accentDim,
            border: const Border(
              left: BorderSide(color: WebTheme.accent, width: 3),
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: WebTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 32),
      ],
    );
  }
}

class _H3 extends StatelessWidget {
  final String text;

  const _H3(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: WebTheme.textPrimary,
        ),
      ),
    );
  }
}

class _P extends StatelessWidget {
  final String text;

  const _P(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: WebTheme.textPrimary,
          height: 1.6,
        ),
      ),
    );
  }
}

class _RichP extends StatelessWidget {
  final List<TextSpan> spans;

  const _RichP({required this.spans});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: WebTheme.textPrimary,
            height: 1.6,
          ),
          children: spans,
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;

  const _BulletList(this.items);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(color: WebTheme.textPrimary, fontSize: 14),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 14,
                      color: WebTheme.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LinkP extends StatelessWidget {
  final String text;
  final String url;
  final String label;

  const _LinkP({
    required this.text,
    required this.url,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14,
            color: WebTheme.textPrimary,
            height: 1.6,
          ),
          children: [
            TextSpan(text: text),
            TextSpan(
              text: label,
              style: const TextStyle(
                color: AppColors.neonCyan,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => openExternalUrl(url),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkLine extends StatelessWidget {
  final String url;
  final String label;

  const _LinkLine({required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 16),
      child: GestureDetector(
        onTap: () => openExternalUrl(url),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.neonCyan,
            decoration: TextDecoration.underline,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

class _Highlight extends StatelessWidget {
  final Widget child;

  const _Highlight({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: WebTheme.accentDim,
          border: const Border(
            left: BorderSide(color: WebTheme.accent, width: 3),
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: child,
      ),
    );
  }
}
