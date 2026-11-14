import 'package:flutter/material.dart';

import '../../config/store_links.dart';
import '../../l10n/app_localizations.dart';
import '../../mixins/language_selection_mixin.dart';
import '../../utils/url_utils.dart';
import '../web_theme.dart';

const _supportEmail = 'support@nanosolve.org';

class SettingsSection extends StatelessWidget {
  final AppLocalizations l10n;
  final String selectedLanguage;
  final ValueChanged<String> onSelectLanguage;

  const SettingsSection({
    super.key,
    required this.l10n,
    required this.selectedLanguage,
    required this.onSelectLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(32, 36, 32, 28),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.webSettingsPreferences,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.settingsTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 32),
                _SettingsBlock(
                  title: l10n.webSettingsLanguageBlock,
                  children: [
                    _LanguageRow(
                      l10n: l10n,
                      selectedLanguage: selectedLanguage,
                      onSelectLanguage: onSelectLanguage,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsBlock(
                  title: l10n.webSettingsConnectBlock,
                  children: [
                    _LinkRow(
                      icon: Icons.language,
                      label: l10n.aboutWebsite,
                      subtitle: 'web.nanosolve.org',
                      onTap: () => openExternalUrl(StoreLinks.website),
                    ),
                    _LinkRow(
                      icon: Icons.email_outlined,
                      label: l10n.aboutContactUs,
                      subtitle: _supportEmail,
                      onTap: () => openExternalUrl('mailto:$_supportEmail'),
                    ),
                    _LinkRow(
                      icon: Icons.privacy_tip_outlined,
                      label: l10n.privacyTitle,
                      subtitle: 'web.nanosolve.org/privacy',
                      onTap: () => Navigator.pushNamed(context, '/privacy'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsBlock(
                  title: l10n.webSettingsDownloadBlock,
                  children: [
                    _LinkRow(
                      icon: Icons.android,
                      label: l10n.aboutPlatformPlayStore,
                      subtitle: 'play.google.com',
                      onTap: () => openExternalUrl(StoreLinks.playStore),
                    ),
                    _LinkRow(
                      icon: Icons.apple,
                      label: l10n.aboutPlatformIOS,
                      subtitle: 'apps.apple.com',
                      onTap: () => openExternalUrl(StoreLinks.appStore),
                    ),
                    _LinkRow(
                      icon: Icons.code,
                      label: l10n.aboutPlatformAndroidFull,
                      subtitle: 'github.com',
                      onTap: () =>
                          openExternalUrl(StoreLinks.githubLatestRelease),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsBlock(
                  title: l10n.webSettingsAboutBlock,
                  children: [
                    _InfoRow(
                        label: l10n.aboutAppName, value: l10n.aboutCopyright),
                    _DescRow(text: l10n.aboutDescription),
                    _InfoRow(label: '🌱', value: l10n.aboutFooterMessage),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SliverSafeArea(
          sliver: SliverToBoxAdapter(child: SizedBox(height: 32)),
        ),
      ],
    );
  }
}

// ── Settings block ────────────────────────────────────────────────────────────
class _SettingsBlock extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsBlock({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WebTheme.surfaceHover,
        border: Border.all(color: WebTheme.borderSubtle),
        borderRadius: BorderRadius.circular(WebTheme.itemRadius),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: WebTheme.borderSubtle)),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: WebTheme.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.08,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

// ── Language row ──────────────────────────────────────────────────────────────
class _LanguageRow extends StatelessWidget {
  final AppLocalizations l10n;
  final String selectedLanguage;
  final ValueChanged<String> onSelectLanguage;

  const _LanguageRow({
    required this.l10n,
    required this.selectedLanguage,
    required this.onSelectLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final current = LanguageSelectionMixin.supportedLanguages.firstWhere(
      (l) => l['code'] == selectedLanguage,
      orElse: () => LanguageSelectionMixin.supportedLanguages.first,
    );

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.language, size: 16, color: WebTheme.textMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsLanguage,
                  style: const TextStyle(
                    color: WebTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${current['flag']} ${current['name']}',
                  style: const TextStyle(
                    color: WebTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            offset: const Offset(0, 32),
            initialValue: selectedLanguage,
            onSelected: onSelectLanguage,
            itemBuilder: (context) =>
                LanguageSelectionMixin.supportedLanguages.map((lang) {
              return PopupMenuItem<String>(
                value: lang['code']!,
                child: Row(
                  children: [
                    Text(lang['flag']!),
                    const SizedBox(width: 8),
                    Text(lang['name']!),
                  ],
                ),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: WebTheme.borderSubtle),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedLanguage.toUpperCase(),
                    style: const TextStyle(
                      color: WebTheme.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down,
                      size: 16, color: WebTheme.textMuted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Link row ──────────────────────────────────────────────────────────────────
class _LinkRow extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _LinkRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_LinkRow> createState() => _LinkRowState();
}

class _LinkRowState extends State<_LinkRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: WebTheme.fast,
          decoration: BoxDecoration(
            color: _hovered ? WebTheme.surfaceHover : Colors.transparent,
            border: const Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(widget.icon, size: 16, color: WebTheme.textMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: WebTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: const TextStyle(
                        color: WebTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.open_in_new,
                  size: 14, color: WebTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Description row ───────────────────────────────────────────────────────────
class _DescRow extends StatelessWidget {
  final String text;
  const _DescRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          color: WebTheme.textSecondary,
          fontSize: 12,
          height: 1.55,
        ),
      ),
    );
  }
}

// ── Info row ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0x0DFFFFFF))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: WebTheme.textMuted,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: WebTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
