import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../../main.dart';
import '../../l10n/app_localizations.dart';
import '../../mixins/language_selection_mixin.dart';
import '../../models/category_detail_data.dart';
import '../../services/settings_manager.dart';
import '../../utils/url_utils.dart';
import '../../config/app_colors.dart';
import '../../web/web_app_shell.dart';
import '../../widgets/nanosolve_logo.dart';

// ── Category descriptor (landing-page only) ───────────────────────────────────

class _Cat {
  final String key;
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final bool isHuman;

  const _Cat(
      this.key, this.title, this.desc, this.icon, this.color, this.isHuman);
}

const _human = [
  _Cat(
      'human_central',
      'Central Systems',
      'Blood–brain barrier penetration, neurological damage, and accumulation data.',
      Icons.psychology_outlined,
      AppColors.neonCyan,
      true),
  _Cat(
      'human_detox',
      'Filtration & Detox',
      'Liver and kidney overload, bioaccumulation in detox organs.',
      Icons.water_drop_outlined,
      AppColors.neonLime,
      true),
  _Cat(
      'human_vitality',
      'Vitality & Tissues',
      'Cardiovascular inflammation, mitochondrial disruption, muscle tissue damage.',
      Icons.favorite_outline,
      AppColors.neonCrimson,
      true),
  _Cat(
      'human_reproduction',
      'Origin & Protection',
      'Reproductive system effects, placental crossings, fertility impact.',
      Icons.people_outline,
      AppColors.neonViolet,
      true),
  _Cat(
      'human_entry',
      'Entry Gates',
      'Inhalation and ingestion pathways — how nanoplastics enter the body.',
      Icons.air,
      AppColors.neonOrange,
      true),
  _Cat(
      'human_ways_of_destruction',
      'Ways of Destruction',
      'Oxidative stress, epigenetic disruption, and cellular damage mechanisms.',
      Icons.science_outlined,
      AppColors.neonCrimson,
      true),
];

const _planet = [
  _Cat(
      'planet_ocean',
      'World Ocean',
      'Marine microplastic accumulation, deep-sea distribution, food chain impact.',
      Icons.waves,
      AppColors.neonOcean,
      false),
  _Cat(
      'planet_atmosphere',
      'Atmosphere',
      'Airborne nanoplastics, cloud formation disruption, global water cycle interference.',
      Icons.cloud_outlined,
      AppColors.neonAtmos,
      false),
  _Cat(
      'planet_bio',
      'Flora, Fauna & Soil',
      'Soil biota disruption, plant uptake, and wildlife exposure pathways.',
      Icons.eco,
      AppColors.neonBio,
      false),
  _Cat(
      'planet_magnetic',
      'Magnetic Field & Core',
      'Ferrofluid-like behavior and potential geological interference.',
      Icons.explore,
      AppColors.neonMagma,
      false),
  _Cat(
      'planet_entry',
      'Crisis Entry Gates',
      'How nanoplastics enter planetary systems — industrial, urban, and agricultural sources.',
      Icons.input,
      AppColors.neonSource,
      false),
  _Cat(
      'planet_physical',
      'Physical Properties',
      'Nanoplastic material science — charge, size distribution, surface interactions.',
      Icons.hub,
      AppColors.neonPhysics,
      false),
];

// ── Shared colors (mirroring HTML CSS variables) ─────────────────────────────

const _bgDeep = Color(0xFF021018);
const _bgOcean = Color(0xFF0A3A4A);
const _surfaceCard = Color(0xE0061E2C);
const _surfaceStrong = Color(0xCC071D2E);
const _surfaceSubtle = Color(0x40082838);
const _line = Color(0x367FEBD7);
const _lineBright = Color(0x5A7FEBD7);
const _textMain = Color(0xFFF0FDF9);
const _textSoft = Color(0xFFB9DCD4);
const _textMuted = Color(0xFF7EAAA0);
const _accent = Color(0xFF6DF5D8);
const _accentStrong = Color(0xFF2DD4BF);
const _githubLatestReleaseUrl =
    'https://github.com/glmcz/nanoplastics_frontend/releases/latest/';
const _githubRepoUrl = 'https://github.com/glmcz/nanoplastics_frontend';

void _openExternalUrl(String url) {
  openExternalUrl(url);
}

// ── Screen ────────────────────────────────────────────────────────────────────

class WebLandingScreen extends StatefulWidget {
  const WebLandingScreen({super.key});

  @override
  State<WebLandingScreen> createState() => _WebLandingScreenState();
}

class _WebLandingScreenState extends State<WebLandingScreen> {
  final GlobalKey _whySectionKey = GlobalKey();
  final GlobalKey _howSectionKey = GlobalKey();
  bool _isChangingLanguage = false;

  Future<void> _scrollToSection(GlobalKey key) async {
    final sectionContext = key.currentContext;
    if (sectionContext == null) return;

    await Scrollable.ensureVisible(
      sectionContext,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  void _openWorkspace(BuildContext context, {String? categoryKey}) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => NanoSolveWebApp(initialCategoryKey: categoryKey),
    ));
  }

  Future<void> _selectLanguage(String code) async {
    final currentCode =
        Localizations.localeOf(context).languageCode.toLowerCase();
    if (_isChangingLanguage || currentCode == code) return;

    setState(() => _isChangingLanguage = true);
    await SettingsManager().setUserLanguage(code);
    if (!mounted) return;

    await NanoSolveHiveApp.changeLocale(context, Locale(code));
    if (!mounted) return;
    setState(() => _isChangingLanguage = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = CategoryDetailDataFactory.all(l10n);
    final selectedLanguage =
        Localizations.localeOf(context).languageCode.toLowerCase();

    return Scaffold(
      backgroundColor: _bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(-0.6, -0.8),
            radius: 1.4,
            colors: [
              Color(0x1A6DF5D8),
              Color(0x08818CF8),
              Colors.transparent,
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Column(
          children: [
            _LandingTopBar(
              l10n: l10n,
              selectedLanguage: selectedLanguage,
              onSelectLanguage: _selectLanguage,
              onLaunchWorkspace: () => _openWorkspace(context),
              onOpenWhy: () => _scrollToSection(_whySectionKey),
              onOpenHow: () => _scrollToSection(_howSectionKey),
              onOpenDownload: () {},
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _HeroSection(
                      l10n: l10n,
                      selectedLanguage: selectedLanguage,
                      onSelectLanguage: _selectLanguage,
                      onLaunchWorkspace: () => _openWorkspace(context),
                    ),
                    KeyedSubtree(
                      key: _whySectionKey,
                      child: _WhySection(l10n: l10n),
                    ),
                    KeyedSubtree(
                      key: _howSectionKey,
                      child: _HowItWorksSection(l10n: l10n),
                    ),
                    _CategoriesSection(
                      l10n: l10n,
                      categories: categories,
                      onOpenCategory: (key) =>
                          _openWorkspace(context, categoryKey: key),
                    ),
                    _Footer(
                      l10n: l10n,
                      onLaunchWorkspace: () => _openWorkspace(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _LandingTopBar extends StatelessWidget {
  final AppLocalizations l10n;
  final String selectedLanguage;
  final ValueChanged<String> onSelectLanguage;
  final VoidCallback onLaunchWorkspace;
  final VoidCallback onOpenWhy;
  final VoidCallback onOpenHow;
  // Kept for hot-reload field compatibility; intentionally unused.
  final VoidCallback? onOpenDownload;
  const _LandingTopBar({
    required this.l10n,
    required this.selectedLanguage,
    required this.onSelectLanguage,
    required this.onLaunchWorkspace,
    required this.onOpenWhy,
    required this.onOpenHow,
    this.onOpenDownload,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 980;
    final phone = width < 500;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE6021018),
        border: const Border(bottom: BorderSide(color: _line, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: _constrain(
          child: Row(
            children: [
              const NanosolveLogo(height: 50),
              const Spacer(),
              if (!compact) ...[
                _topLink(l10n.landingNavWhy, onTap: onOpenWhy),
                const SizedBox(width: 2),
                _topLink(l10n.landingNavHow, onTap: onOpenHow),
              ],
              if (!phone) ...[
                const SizedBox(width: 10),
                _PillButton(
                  label: l10n.landingLaunchWorkspace,
                  onTap: onLaunchWorkspace,
                  primary: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _topLink(String label, {required VoidCallback onTap}) {
    return _HoverUnderlineLink(
      label: label,
      onTap: onTap,
    );
  }
}

class _HoverUnderlineLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  const _HoverUnderlineLink({required this.label, required this.onTap});

  @override
  State<_HoverUnderlineLink> createState() => _HoverUnderlineLinkState();
}

class _HoverUnderlineLinkState extends State<_HoverUnderlineLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _hovered ? _surfaceSubtle : Colors.transparent,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: _hovered ? _accent : _textSoft,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  final AppLocalizations l10n;
  final String selectedLanguage;
  final ValueChanged<String> onSelectLanguage;
  final VoidCallback onLaunchWorkspace;
  const _HeroSection({
    required this.l10n,
    required this.selectedLanguage,
    required this.onSelectLanguage,
    required this.onLaunchWorkspace,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 48, bottom: 32),
      child: _constrain(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 920;
            final phone = constraints.maxWidth < 500;

            return _Card(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Subtle gradient overlay for depth
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _accent.withValues(alpha: 0.03),
                              Colors.transparent,
                              _bgDeep.withValues(alpha: 0.4),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(phone
                          ? 16
                          : compact
                              ? 24
                              : 40),
                      child: compact
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _heroText(compact: true, phone: phone),
                                SizedBox(height: phone ? 16 : 24),
                                _HeroSignalPanel(
                                  l10n: l10n,
                                  selectedLanguage: selectedLanguage,
                                  onSelectLanguage: onSelectLanguage,
                                  phone: phone,
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    flex: 13,
                                    child: _heroText(
                                        compact: false, phone: false)),
                                const SizedBox(width: 32),
                                Expanded(
                                  flex: 10,
                                  child: _HeroSignalPanel(
                                    l10n: l10n,
                                    selectedLanguage: selectedLanguage,
                                    onSelectLanguage: onSelectLanguage,
                                    phone: false,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _heroText({required bool compact, required bool phone}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
            border:
                Border.all(color: _accent.withValues(alpha: 0.2), width: 0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.landingBadgePlatforms,
                style: const TextStyle(
                  color: _accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: phone ? 16 : 24),
        // Main headline
        Text(
          l10n.landingHeroTitle,
          style: TextStyle(
            color: _textMain,
            fontSize: phone
                ? 24
                : compact
                    ? 32
                    : 42,
            fontWeight: FontWeight.w800,
            height: 1.08,
            letterSpacing: phone ? -0.5 : -1.0,
          ),
        ),
        const SizedBox(height: 16),
        // Subtitle
        Text(
          l10n.landingHeroSubtitle,
          style: const TextStyle(
            color: _textSoft,
            fontSize: 15.5,
            height: 1.65,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 28),
        // CTA buttons
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _PillButton(
              label: l10n.landingLaunchWorkspace,
              onTap: onLaunchWorkspace,
              primary: true,
              icon: Icons.rocket_launch_rounded,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Footnote
        Row(
          children: [
            const Icon(Icons.verified_outlined, size: 13, color: _textMuted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                l10n.landingHeroEvidenceNote,
                style: const TextStyle(
                  color: _textMuted,
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroSignalPanel extends StatelessWidget {
  final AppLocalizations l10n;
  final String selectedLanguage;
  final ValueChanged<String> onSelectLanguage;
  final bool phone;

  const _HeroSignalPanel({
    required this.l10n,
    required this.selectedLanguage,
    required this.onSelectLanguage,
    this.phone = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line, width: 0.5),
        color: _bgOcean.withValues(alpha: 0.35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(phone ? 12 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const NanosolveLogo(height: 26),
              const SizedBox(width: 10),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          _SignalChipRow(
            icon: Icons.public,
            title: l10n.landingGithubBuildCta,
            subtitle: 'github.com',
            onTap: () => _openExternalUrl(_githubRepoUrl),
          ),
          const SizedBox(height: 8),
          _SignalChipRow(
            icon: Icons.privacy_tip_outlined,
            title: l10n.landingFooterPrivacy,
            subtitle: '/privacy',
            onTap: () => Navigator.pushNamed(context, '/privacy'),
          ),
          const SizedBox(height: 8),
          PopupMenuButton<String>(
            tooltip: l10n.sidebarLang,
            onSelected: onSelectLanguage,
            itemBuilder: (context) => LanguageSelectionMixin.supportedLanguages
                .map(
                  (lang) => PopupMenuItem<String>(
                    value: lang['code']!,
                    child: Row(
                      children: [
                        Text(lang['flag']!),
                        const SizedBox(width: 8),
                        Text(lang['name']!),
                      ],
                    ),
                  ),
                )
                .toList(growable: false),
            child: _SignalChipRow(
              icon: Icons.language,
              title: l10n.sidebarLang,
              subtitle: selectedLanguage.toUpperCase(),
              interactive: true,
            ),
          ),
          const SizedBox(height: 16),
          // Highlighted feature row
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _accent.withValues(alpha: 0.08),
                  _surfaceStrong.withValues(alpha: 0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: _accent.withValues(alpha: 0.2), width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child:
                      const Icon(Icons.bolt_rounded, color: _accent, size: 16),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'All relevant sources in one place',
                    style: TextStyle(
                      color: _textMain,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalChipRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool interactive;

  const _SignalChipRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.interactive = false,
  });

  @override
  Widget build(BuildContext context) {
    final row = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _line.withValues(alpha: 0.5), width: 0.5),
        color: _surfaceStrong.withValues(alpha: 0.25),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 13, color: _accent),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: _textMain,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _surfaceSubtle,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: _textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          if (interactive) ...[
            const SizedBox(width: 6),
            const Icon(Icons.expand_more_rounded, size: 14, color: _textMuted),
          ],
        ],
      ),
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: row,
      ),
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  final AppLocalizations l10n;

  const _HowItWorksSection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: _constrain(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 1000;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  label: 'WORKFLOW',
                  title: l10n.landingNavHow,
                  subtitle: l10n.landingWhyFeatureActionableDesc,
                ),
                const SizedBox(height: 32),
                if (compact)
                  Column(
                    children: [
                      _StepCard(
                        index: 1,
                        title: l10n.navExplore,
                        desc: l10n.landingCategoriesSubtitle,
                      ),
                      const SizedBox(height: 12),
                      _StepCard(
                        index: 2,
                        title: l10n.sourcesTitle,
                        desc: l10n.sourcesSubtitle,
                      ),
                      const SizedBox(height: 12),
                      _StepCard(
                        index: 3,
                        title: l10n.categoryDetailIdeas,
                        desc: l10n.landingWhyFeatureActionableDesc,
                      ),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _StepCard(
                              index: 1,
                              title: l10n.navExplore,
                              desc: l10n.landingCategoriesSubtitle,
                            ),
                            const SizedBox(height: 12),
                            _StepCard(
                              index: 2,
                              title: l10n.sourcesTitle,
                              desc: l10n.sourcesSubtitle,
                            ),
                            const SizedBox(height: 12),
                            _StepCard(
                              index: 3,
                              title: l10n.categoryDetailIdeas,
                              desc: l10n.landingWhyFeatureActionableDesc,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 32),
                      const Expanded(
                        flex: 1,
                        child: _MobileQRMockup(),
                      ),
                    ],
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Mobile QR Mockup ──────────────────────────────────────────────────────────

class _MobileQRMockup extends StatelessWidget {
  const _MobileQRMockup();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 520,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Phone with 3D perspective tilt ──
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // perspective
                ..rotateY(0.05), // subtle Y rotation
              child: Container(
                width: 246,
                height: 506,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2D3748),
                      Color(0xFF111827),
                      Color(0xFF334155),
                    ],
                    stops: [0.0, 0.55, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(36),
                  border:
                      Border.all(color: const Color(0xFF475569), width: 1.1),
                  boxShadow: [
                    // Ambient accent glow
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.06),
                      blurRadius: 56,
                      spreadRadius: 5,
                    ),
                    // Main depth shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.48),
                      blurRadius: 36,
                      offset: const Offset(10, 20),
                    ),
                    // Secondary side shadow
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 18,
                      offset: const Offset(-5, 7),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF020617),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: const Color(0xFF0F172A),
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(29),
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              // Status bar
                              Container(
                                height: 34,
                                color: _surfaceStrong.withValues(alpha: 0.86),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '9:41',
                                      style: TextStyle(
                                        color: _textMain,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.signal_cellular_alt,
                                            size: 11, color: _textSoft),
                                        SizedBox(width: 3),
                                        Icon(Icons.battery_full,
                                            size: 11, color: _textSoft),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // App screenshot
                              Expanded(
                                child: Image.asset(
                                  'assets/images/app_screenshot.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                              // Home indicator
                              Container(
                                height: 16,
                                color: _surfaceStrong,
                                child: Center(
                                  child: Container(
                                    width: 100,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: _textSoft.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Dynamic-island style notch
                          Positioned(
                            top: 6,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 88,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF020617),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF111827),
                                    width: 0.6,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // ── QR card floating beside the phone ──
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(-0.08)
                ..translateByVector3(Vector3(0.0, 30.0, 0.0)),
              child: Container(
                width: 140,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.1),
                      blurRadius: 30,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 24,
                      offset: const Offset(4, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/images/nanosolve_qr.jpg',
                        width: 110,
                        height: 110,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Scan to Download',
                      style: TextStyle(
                        color: Color(0xFF0A3A4A),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A3A4A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.android,
                              size: 10, color: Color(0xFF6DF5D8)),
                          SizedBox(width: 4),
                          Text(
                            'Google Play',
                            style: TextStyle(
                              color: Color(0xFF6DF5D8),
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111827),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.apple, size: 10, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'iPhone App Store',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 7.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ].reversed.toList(),
        ),
      ),
    );
  }
}

class _StepCard extends StatefulWidget {
  final int index;
  final String title;
  final String desc;

  const _StepCard({
    required this.index,
    required this.title,
    required this.desc,
  });

  @override
  State<_StepCard> createState() => _StepCardState();
}

class _StepCardState extends State<_StepCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform:
            _hovered ? Matrix4.translationValues(0, -2, 0) : Matrix4.identity(),
        child: _Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _accent.withValues(alpha: 0.25),
                        _accent.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index}',
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: _textMain,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.desc,
                        style: const TextStyle(
                          color: _textSoft,
                          fontSize: 13,
                          height: 1.5,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Why Section ───────────────────────────────────────────────────────────────

class _WhySection extends StatelessWidget {
  final AppLocalizations l10n;

  const _WhySection({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: _constrain(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              label: 'WHY NANOSOLVE',
              title: l10n.landingWhyTitle,
              subtitle: l10n.landingWhySubtitle,
            ),
            const SizedBox(height: 24),
            _AdaptiveGrid(
              minChildWidth: 300,
              children: [
                _FeatureCard(
                  icon: Icons.hub_outlined,
                  accentColor: const Color(0xFF6DF5D8),
                  title: l10n.landingWhyFeatureStructuredTitle,
                  desc: l10n.landingWhyFeatureStructuredDesc,
                ),
                _FeatureCard(
                  icon: Icons.bolt_rounded,
                  accentColor: const Color(0xFFFBBF24),
                  title: l10n.landingWhyFeatureMetaGraphTitle,
                  desc: l10n.landingWhyFeatureMetaGraphDesc,
                ),
                _FeatureCard(
                  icon: Icons.verified_outlined,
                  accentColor: const Color(0xFF818CF8),
                  title: l10n.landingWhyFeatureTrustTitle,
                  desc: l10n.landingWhyFeatureTrustDesc,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── How Section ───────────────────────────────────────────────────────────────

// ── Categories Section (the main new addition) ────────────────────────────────

class _CategoriesSection extends StatelessWidget {
  final AppLocalizations l10n;
  final List<CategoryDetailData> categories;
  final ValueChanged<String> onOpenCategory;
  const _CategoriesSection({
    required this.l10n,
    required this.categories,
    required this.onOpenCategory,
  });

  @override
  Widget build(BuildContext context) {
    final categoryByKey = {
      for (final category in categories) category.categoryKey: category,
    };

    return _SectionWrap(
      title: l10n.landingCategoriesTitle,
      subtitle: l10n.landingCategoriesSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _domainLabel(l10n.exploreHumanTitle, isHuman: true),
          const SizedBox(height: 10),
          _CategoryGrid(
            children: _human
                .map((c) => _CategoryCard(
                      cat: c,
                      detailData: categoryByKey[c.key],
                      l10n: l10n,
                      onTap: () => onOpenCategory(c.key),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          _domainLabel(l10n.explorePlanetTitle, isHuman: false),
          const SizedBox(height: 10),
          _CategoryGrid(
            children: _planet
                .map((c) => _CategoryCard(
                      cat: c,
                      detailData: categoryByKey[c.key],
                      l10n: l10n,
                      onTap: () => onOpenCategory(c.key),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _domainLabel(String label, {required bool isHuman}) {
    final color = isHuman ? const Color(0xFF7DD3FC) : const Color(0xFF86EFAC);
    final bg = isHuman ? const Color(0x1F38BDF8) : const Color(0x1F4ADE80);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
          child: Text(label,
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8)),
        ),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: _line, height: 1)),
      ],
    );
  }
}

// ── Illustration Patterns ────────────────────────────────────────────────────

enum _IllustrationPattern {
  nodes,
  droplets,
  wave,
  orbit,
  stream,
  scatter,
  ocean,
  clouds,
  branches,
  fieldLines,
  flow,
  lattice,
}

const _patternFor = {
  'human_central': _IllustrationPattern.nodes,
  'human_detox': _IllustrationPattern.droplets,
  'human_vitality': _IllustrationPattern.wave,
  'human_reproduction': _IllustrationPattern.orbit,
  'human_entry': _IllustrationPattern.stream,
  'human_ways_of_destruction': _IllustrationPattern.scatter,
  'planet_ocean': _IllustrationPattern.ocean,
  'planet_atmosphere': _IllustrationPattern.clouds,
  'planet_bio': _IllustrationPattern.branches,
  'planet_magnetic': _IllustrationPattern.fieldLines,
  'planet_entry': _IllustrationPattern.flow,
  'planet_physical': _IllustrationPattern.lattice,
};

class _CategoryIllustrationPainter extends CustomPainter {
  final Color color;
  final _IllustrationPattern pattern;

  _CategoryIllustrationPainter({required this.color, required this.pattern});

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    final accentPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Draw category-specific thematic backgrounds
    switch (pattern) {
      case _IllustrationPattern.nodes:
        _drawNeuralNetwork(
            canvas, size, basePaint, accentPaint); // human_central
      case _IllustrationPattern.droplets:
        _drawFiltrationSystem(
            canvas, size, basePaint, accentPaint); // human_detox
      case _IllustrationPattern.wave:
        _drawPulsingEnergy(
            canvas, size, basePaint, accentPaint); // human_vitality
      case _IllustrationPattern.orbit:
        _drawDNAHelix(
            canvas, size, basePaint, accentPaint); // human_reproduction
      case _IllustrationPattern.stream:
        _drawParticleEntry(canvas, size, basePaint, accentPaint); // human_entry
      case _IllustrationPattern.scatter:
        _drawCellularDamage(
            canvas, size, basePaint, accentPaint); // human_ways_of_destruction
      case _IllustrationPattern.ocean:
        _drawOceanCurrents(
            canvas, size, basePaint, accentPaint); // planet_ocean
      case _IllustrationPattern.clouds:
        _drawAtmosphericLayers(
            canvas, size, basePaint, accentPaint); // planet_atmosphere
      case _IllustrationPattern.branches:
        _drawRootSystem(canvas, size, basePaint, accentPaint); // planet_bio
      case _IllustrationPattern.fieldLines:
        _drawMagneticField(
            canvas, size, basePaint, accentPaint); // planet_magnetic
      case _IllustrationPattern.flow:
        _drawIndustrialFlow(
            canvas, size, basePaint, accentPaint); // planet_entry
      case _IllustrationPattern.lattice:
        _drawParticleDistribution(
            canvas, size, basePaint, accentPaint); // planet_physical
    }
  }

  // HUMAN CATEGORIES
  void _drawNeuralNetwork(
      Canvas canvas, Size size, Paint basePaint, Paint accentPaint) {
    final random = Random(42);
    const nodeCount = 18;
    final nodes = <Offset>[];

    // Create nodes with clustering
    for (int i = 0; i < nodeCount; i++) {
      final angle = (i / nodeCount) * 2 * pi;
      final radius = 25 + random.nextDouble() * 35;
      final x = size.width / 2 + cos(angle) * radius;
      final y = size.height / 2 + sin(angle) * radius;
      nodes.add(Offset(x, y));
    }

    // Draw connections with varying opacity
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        if ((i + j) % 3 == 0) {
          final connectionPaint = Paint()
            ..color = color.withValues(alpha: 0.06)
            ..strokeWidth = 0.6;
          canvas.drawLine(nodes[i], nodes[j], connectionPaint);
        }
      }
    }

    // Draw glowing nodes
    for (final node in nodes) {
      canvas.drawCircle(node, 2.5, accentPaint);
      canvas.drawCircle(node, 1, Paint()..color = color.withValues(alpha: 0.3));
    }
  }

  void _drawFiltrationSystem(
      Canvas canvas, Size size, Paint basePaint, Paint accentPaint) {
    // Vertical channels for filtration
    for (int col = 0; col < 4; col++) {
      final x = (col + 1) * (size.width / 5);
      final channelPaint = Paint()
        ..color = color.withValues(alpha: 0.08)
        ..strokeWidth = 2;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), channelPaint);

      // Particles flowing down through channels
      for (int i = 0; i < 8; i++) {
        final y = (i / 8) * size.height;
        final particleX = x + sin(y * 0.02) * 8;
        canvas.drawCircle(Offset(particleX, y), 1.5, accentPaint);
      }
    }

    // Filter layers at bottom
    for (int i = 0; i < 6; i++) {
      final x = (i + 0.5) * (size.width / 6);
      canvas.drawCircle(Offset(x, size.height * 0.85), 2, accentPaint);
    }
  }

  void _drawPulsingEnergy(
      Canvas canvas, Size size, Paint basePaint, Paint accentPaint) {
    // Multiple pulsing sine waves
    for (int wave = 0; wave < 4; wave++) {
      const frequency = 0.015;
      final yOffset = size.height * (0.25 + wave * 0.15);
      const amplitude = 15.0;
      final wavePaint = Paint()
        ..color = color.withValues(alpha: 0.08 + (wave * 0.03))
        ..strokeWidth = 1 + (wave * 0.3);

      final path = Path();
      path.moveTo(0, yOffset);
      for (double x = 0; x <= size.width; x += 2) {
        final y = yOffset + sin((x + wave * 40) * frequency) * amplitude;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, wavePaint);
    }

    // Energy particles
    final random = Random(42);
    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.8;
      canvas.drawCircle(Offset(x, y), 1.2, accentPaint);
    }
  }

  void _drawDNAHelix(
      Canvas canvas, Size size, Paint basePaint, Paint accentPaint) {
    const frequency = 0.03;
    final centerX = size.width / 2;

    // Draw double helix strands
    for (int strand = 0; strand < 2; strand++) {
      final strandPaint = Paint()
        ..color = color.withValues(alpha: 0.1 + (strand * 0.08))
        ..strokeWidth = 1.5;

      final path = Path();
      path.moveTo(centerX + (strand == 0 ? -8 : 8), 0);
      for (double y = 0; y <= size.height; y += 2) {
        final x = centerX + (strand == 0 ? -8 : 8) + cos(y * frequency) * 15;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, strandPaint);
    }

    // Base pairs connecting strands
    for (double y = 0; y <= size.height; y += 12) {
      final x1 = centerX - 8 + cos(y * frequency) * 15;
      final x2 = centerX + 8 + cos(y * frequency) * 15;
      final connectionPaint = Paint()
        ..color = color.withValues(alpha: 0.06)
        ..strokeWidth = 0.8;
      canvas.drawLine(Offset(x1, y), Offset(x2, y), connectionPaint);
    }
  }

  void _drawParticleEntry(
      Canvas canvas, Size size, Paint basePaint, Paint accentPaint) {
    // Entry pathways from top
    final random = Random(42);
    for (int path = 0; path < 3; path++) {
      final startX = (path + 1) * (size.width / 4);
      final entryPaint = Paint()
        ..color = color.withValues(alpha: 0.08)
        ..strokeWidth = 1.5;

      var currentX = startX;
      var currentY = 0.0;

      while (currentY < size.height) {
        final nextY = currentY + 8;
        final drift = sin(currentY * 0.01) * 12;
        final nextX = startX + drift;
        canvas.drawLine(
          Offset(currentX, currentY),
          Offset(nextX, nextY),
          entryPaint,
        );
        currentX = nextX;
        currentY = nextY;
      }
    }

    // Particles along paths
    for (int i = 0; i < 20; i++) {
      final x = 100 + random.nextDouble() * (size.width - 200);
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 1.5, accentPaint);
    }
  }

  void _drawCellularDamage(
      Canvas canvas, Size size, Paint basePaint, Paint accentPaint) {
    final random = Random(42);
    const cellCount = 40;

    // Damaged/fractured cells scattered
    for (int i = 0; i < cellCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final cellSize = 3 + random.nextDouble() * 6;

      // Draw cell outline
      final cellPaint = Paint()
        ..color = color.withValues(alpha: 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawCircle(Offset(x, y), cellSize, cellPaint);

      // Random fracture lines inside cells
      if (random.nextDouble() > 0.4) {
        final fracturePaint = Paint()
          ..color = color.withValues(alpha: 0.06)
          ..strokeWidth = 0.3;
        for (int f = 0; f < 2; f++) {
          final angle = random.nextDouble() * pi;
          final fx1 = x + cos(angle) * cellSize;
          final fy1 = y + sin(angle) * cellSize;
          final fx2 = x - cos(angle) * cellSize;
          final fy2 = y - sin(angle) * cellSize;
          canvas.drawLine(Offset(fx1, fy1), Offset(fx2, fy2), fracturePaint);
        }
      }
    }
  }

  // PLANET CATEGORIES
  void _drawOceanCurrents(
      Canvas canvas, Size size, Paint basePaint, Paint accentPaint) {
    // Multiple flowing current layers
    for (int layer = 0; layer < 5; layer++) {
      const frequency = 0.012;
      final yOffset = size.height * (0.15 + layer * 0.15);
      const amplitude = 20.0;
      final currentPaint = Paint()
        ..color = color.withValues(alpha: 0.06 + (layer * 0.03))
        ..strokeWidth = 1.2 + (layer * 0.3);

      final path = Path();
      path.moveTo(0, yOffset);
      for (double x = 0; x <= size.width; x += 2) {
        final y = yOffset + sin((x + layer * 25) * frequency) * amplitude;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, currentPaint);
    }

    // Water particles
    final random = Random(42);
    for (int i = 0; i < 25; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.8, accentPaint);
    }
  }

  void _drawAtmosphericLayers(
      Canvas canvas, Size size, Paint basePaint, Paint accentPaint) {
    final random = Random(42);

    // Atmospheric pressure bands
    for (int band = 0; band < 6; band++) {
      final bandY = (band / 6) * size.height;
      final bandPaint = Paint()
        ..color = color.withValues(alpha: 0.04 + (band * 0.02))
        ..strokeWidth = size.height / 8;
      canvas.drawLine(
        Offset(0, bandY),
        Offset(size.width, bandY),
        bandPaint,
      );
    }

    // Cloud formations (cluster groups)
    for (int c = 0; c < 4; c++) {
      final cx = random.nextDouble() * size.width;
      final cy = random.nextDouble() * size.height * 0.8;

      for (int i = 0; i < 5; i++) {
        final x = cx + (i - 2) * 12;
        final r = 4 + random.nextDouble() * 3;
        canvas.drawCircle(
            Offset(x, cy),
            r,
            Paint()
              ..color = color.withValues(alpha: 0.08)
              ..style = PaintingStyle.fill);
      }
    }

    // Wind patterns
    for (int i = 0; i < 8; i++) {
      final y = (i / 8) * size.height;
      final windPaint = Paint()
        ..color = color.withValues(alpha: 0.05)
        ..strokeWidth = 0.8;
      final waveX = sin(y * 0.02) * 30;
      canvas.drawLine(
        Offset(0 + waveX, y),
        Offset(size.width + waveX, y),
        windPaint,
      );
    }
  }

  void _drawRootSystem(
      Canvas canvas, Size size, Paint basePaint, Paint accentPaint) {
    // Root system growing from bottom
    _drawRootRecursive(
      canvas,
      Offset(size.width / 2, size.height),
      -90.0,
      0,
      size,
      basePaint,
      accentPaint,
    );
  }

  void _drawRootRecursive(
    Canvas canvas,
    Offset start,
    double angle,
    int depth,
    Size size,
    Paint basePaint,
    Paint accentPaint,
  ) {
    if (depth > 5 || start.dx < 0 || start.dx > size.width || start.dy < 0) {
      return;
    }

    const length = 20.0;
    const angleChange = 20.0;

    final rad = angle * pi / 180;
    final end = Offset(
      start.dx + cos(rad) * length,
      start.dy + sin(rad) * length,
    );

    final rootPaint = Paint()
      ..color = color.withValues(alpha: 0.08 + (depth * 0.02))
      ..strokeWidth = 1.5 - (depth * 0.2)
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, rootPaint);

    // Root nodes/connections
    if (depth % 2 == 0) {
      canvas.drawCircle(end, 1.2, accentPaint);
    }

    _drawRootRecursive(canvas, end, angle - angleChange, depth + 1, size,
        basePaint, accentPaint);
    _drawRootRecursive(canvas, end, angle + angleChange, depth + 1, size,
        basePaint, accentPaint);
  }

  void _drawMagneticField(
      Canvas canvas, Size size, Paint basePaint, Paint accentPaint) {
    const count = 8;
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Concentric magnetic field arcs
    for (int i = 0; i < count; i++) {
      final radius = 20 + (i * 15.0);
      final arcPaint = Paint()
        ..color = color.withValues(alpha: 0.06 + (i * 0.01))
        ..strokeWidth = 0.8
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (double angle = 0; angle <= pi; angle += 0.15) {
        final x = centerX + cos(angle) * radius;
        final y = centerY + sin(angle) * radius;
        if (angle == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, arcPaint);
    }

    // Swirling field lines
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi;
      final fieldPaint = Paint()
        ..color = color.withValues(alpha: 0.08)
        ..strokeWidth = 0.8;

      final path = Path();
      path.moveTo(centerX + cos(angle) * 15, centerY + sin(angle) * 15);
      for (double r = 15; r < 120; r += 5) {
        final swirl = angle + (r * 0.02);
        final x = centerX + cos(swirl) * r;
        final y = centerY + sin(swirl) * r;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, fieldPaint);
    }
  }

  void _drawIndustrialFlow(
      Canvas canvas, Size size, Paint basePaint, Paint accentPaint) {
    final random = Random(42);

    // Industrial pathways - fragmented flows
    for (int path = 0; path < 4; path++) {
      final startX = (path + 1) * (size.width / 5);
      final pathPaint = Paint()
        ..color = color.withValues(alpha: 0.07)
        ..strokeWidth = 2;

      var currentX = startX;
      var currentY = 0.0;

      while (currentY < size.height) {
        const segment = 15.0;
        final nextY = currentY + segment;
        final deviation = (random.nextDouble() - 0.5) * 20;
        final nextX = startX + deviation;

        canvas.drawLine(
          Offset(currentX, currentY),
          Offset(nextX, nextY),
          pathPaint,
        );

        currentX = nextX;
        currentY = nextY;
      }
    }

    // Scattered particles (pollution)
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 1.5, accentPaint);
    }
  }

  void _drawParticleDistribution(
      Canvas canvas, Size size, Paint basePaint, Paint accentPaint) {
    final random = Random(42);
    const spacing = 18.0;

    // Base particle lattice
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(
            Offset(x, y),
            0.8,
            Paint()
              ..color = color.withValues(alpha: 0.06)
              ..style = PaintingStyle.fill);
      }
    }

    // Larger clusters showing distribution variance
    for (int cluster = 0; cluster < 8; cluster++) {
      final cx = random.nextDouble() * size.width;
      final cy = random.nextDouble() * size.height;

      for (int i = 0; i < 8; i++) {
        final angle = (i / 8) * 2 * pi;
        final r = 8 + random.nextDouble() * 8;
        final x = cx + cos(angle) * r;
        final y = cy + sin(angle) * r;
        canvas.drawCircle(Offset(x, y), 1.2, accentPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_CategoryIllustrationPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.pattern != pattern;
  }
}

// ── Category Grid (3 columns) ─────────────────────────────────────────────────

class _CategoryGrid extends StatelessWidget {
  final List<Widget> children;

  const _CategoryGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cols = w >= 980
            ? 3
            : w >= 600
                ? 2
                : 1;
        final ratio = cols == 1
            ? 2.2
            : cols == 2
                ? 1.6
                : 1.8;
        final gap = cols == 1 ? 12.0 : 20.0;
        return GridView.count(
          crossAxisCount: cols,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: gap,
          crossAxisSpacing: cols == 1 ? 0 : gap,
          childAspectRatio: ratio,
          children: children,
        );
      },
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final _Cat cat;
  final CategoryDetailData? detailData;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  const _CategoryCard({
    required this.cat,
    required this.detailData,
    required this.l10n,
    required this.onTap,
  });

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = widget.cat;
    final title = widget.detailData?.title ?? c.title;
    final desc = c.desc;
    final domainColor =
        c.isHuman ? const Color(0xFF7DD3FC) : const Color(0xFF86EFAC);
    final pattern = _patternFor[c.key] ?? _IllustrationPattern.scatter;

    return Semantics(
      button: true,
      label: c.title,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: _hovered
              ? Matrix4.translationValues(0, -3, 0)
              : Matrix4.identity(),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _hovered
                      ? c.color.withValues(alpha: 0.4)
                      : _line.withValues(alpha: 0.4),
                  width: 0.5,
                ),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: c.color.withValues(alpha: 0.1),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    CustomPaint(
                      painter: _CategoryIllustrationPainter(
                        color: c.color,
                        pattern: pattern,
                      ),
                      size: Size.infinite,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            _surfaceCard.withValues(alpha: 0.7),
                          ],
                          stops: const [0.0, 0.7],
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: c.color.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(c.icon, size: 16, color: c.color),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: c.isHuman
                                        ? const Color(0x1F38BDF8)
                                        : const Color(0x1F4ADE80),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    c.isHuman
                                        ? widget.l10n.tabHuman
                                        : widget.l10n.tabPlanet,
                                    style: TextStyle(
                                      color: domainColor,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              title,
                              style: const TextStyle(
                                color: _textMain,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                letterSpacing: -0.45,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              desc,
                              style: const TextStyle(
                                color: _textSoft,
                                fontSize: 12,
                                height: 1.35,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  widget.l10n.landingOpenWorkspace,
                                  style: TextStyle(
                                    color: c.color,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward,
                                    size: 12, color: c.color),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onLaunchWorkspace;

  const _Footer({required this.l10n, required this.onLaunchWorkspace});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: _line.withValues(alpha: 0.4), width: 0.5)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              _bgDeep.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          child: _constrain(
            child: Column(
              children: [
                // CTA banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _accent.withValues(alpha: 0.08),
                        _surfaceCard,
                      ],
                    ),
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.15),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        l10n.landingWhyFeatureTrustDesc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: _textSoft,
                          fontSize: 14,
                          height: 1.55,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _PillButton(
                        label: l10n.landingLaunchWorkspace,
                        onTap: onLaunchWorkspace,
                        primary: true,
                        icon: Icons.rocket_launch_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Footer links
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(
                        top: BorderSide(
                      color: _line.withValues(alpha: 0.3),
                      width: 0.5,
                    )),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final phone = constraints.maxWidth < 480;
                      final links = Wrap(
                        spacing: 20,
                        runSpacing: 8,
                        children: [
                          _footerLink(
                            l10n.landingFooterGithub,
                            onTap: () => _openExternalUrl(_githubRepoUrl),
                          ),
                          _footerLink(
                            l10n.landingFooterReleases,
                            onTap: () =>
                                _openExternalUrl(_githubLatestReleaseUrl),
                          ),
                          _footerLink(
                            l10n.landingFooterPrivacy,
                            onTap: () =>
                                Navigator.pushNamed(context, '/privacy'),
                          ),
                        ],
                      );
                      final copyright = Text(
                        l10n.landingFooterCopyright,
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 12,
                        ),
                      );
                      if (phone) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            links,
                            const SizedBox(height: 12),
                            copyright
                          ],
                        );
                      }
                      return Row(
                        children: [copyright, const Spacer(), links],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _footerLink(String label, {VoidCallback? onTap}) {
    return _HoverUnderlineLink(label: label, onTap: onTap ?? () {});
  }
}

// ── Reusable section wrapper ──────────────────────────────────────────────────

class _SectionWrap extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _SectionWrap(
      {required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: _constrain(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              title: title,
              subtitle: subtitle,
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }
}

/// Reusable section header with optional label badge, title, and subtitle.
class _SectionHeader extends StatelessWidget {
  final String? label;
  final String title;
  final String subtitle;

  const _SectionHeader({
    this.label,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _accent.withValues(alpha: 0.15),
                width: 0.5,
              ),
            ),
            child: Text(
              label!,
              style: const TextStyle(
                color: _accent,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final phone = constraints.maxWidth < 480;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: _textMain,
                    fontSize: phone ? 20 : 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: phone ? -0.2 : -0.5,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: _textSoft,
                    fontSize: phone ? 13 : 14.5,
                    height: 1.6,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

// ── Feature card ──────────────────────────────────────────────────────────────

class _FeatureCard extends StatefulWidget {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String desc;
  const _FeatureCard({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.desc,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform:
            _hovered ? Matrix4.translationValues(0, -3, 0) : Matrix4.identity(),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color:
              _hovered ? _surfaceCard : _surfaceStrong.withValues(alpha: 0.6),
          border: Border.all(
            color: _hovered
                ? widget.accentColor.withValues(alpha: 0.3)
                : _line.withValues(alpha: 0.5),
            width: 0.5,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.08),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.accentColor.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Icon(widget.icon, size: 22, color: widget.accentColor),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  color: _textMain,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.desc,
                style: const TextStyle(
                  color: _textSoft,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared micro-widgets ──────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _surfaceCard,
        border: Border.all(
          color: _line.withValues(alpha: 0.5),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PillButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final IconData? icon;
  const _PillButton({
    required this.label,
    required this.onTap,
    required this.primary,
    this.icon,
  });

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform:
            _hovered ? Matrix4.translationValues(0, -2, 0) : Matrix4.identity(),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: widget.primary
                  ? LinearGradient(
                      colors: _hovered
                          ? [_accent, const Color(0xFF34D4AA)]
                          : [_accent, _accentStrong],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: widget.primary
                  ? null
                  : _hovered
                      ? _surfaceSubtle
                      : Colors.transparent,
              border: widget.primary
                  ? null
                  : Border.all(
                      color: _hovered ? _lineBright : _line,
                      width: 0.5,
                    ),
              boxShadow: widget.primary && _hovered
                  ? [
                      BoxShadow(
                        color: _accent.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: 15,
                    color: widget.primary ? const Color(0xFF003228) : _textSoft,
                  ),
                  const SizedBox(width: 7),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.primary ? const Color(0xFF003228) : _textMain,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Responsive grid using Wrap so items reflow naturally.
class _AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minChildWidth;

  const _AdaptiveGrid({required this.children, required this.minChildWidth});

  @override
  Widget build(BuildContext context) {
    final available = MediaQuery.sizeOf(context).width - 40;
    final cols = (available / minChildWidth).floor().clamp(1, children.length);
    final itemWidth = (available - (cols - 1) * 12) / cols;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          children.map((c) => SizedBox(width: itemWidth, child: c)).toList(),
    );
  }
}

/// Centers content with max-width matching the HTML's --layout-max: 1140px.
Widget _constrain({required Widget child}) {
  return Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1140),
      child: child,
    ),
  );
}
