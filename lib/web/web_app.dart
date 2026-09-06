@Deprecated('Use web_app_shell.dart directly for new code.')
export 'web_app_shell.dart' show NanoSolveWebApp;

// ignore: unused_element
const _legacyWebAppSource = r'''

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_colors.dart';
import '../l10n/app_localizations.dart';
import '../mixins/language_selection_mixin.dart';
import '../models/category_detail_data.dart';
import '../services/service_locator.dart';
import '../utils/platform_adaptive.dart';
import 'sections/explore_section.dart';
import 'sections/ideas_section.dart';
import 'sections/leaderboard_section.dart';
import 'sections/sources_section.dart';
import 'web_state.dart';
import 'web_theme.dart';
import 'widgets/ai_chat_panel.dart';
import 'widgets/web_background.dart';
import 'widgets/web_sidebar.dart';
import 'widgets/web_topbar.dart';

/*

enum WebSection { explore, sources, ideas, leaderboard }

enum WebDomain { human, planet }

class NanoSolveWebApp extends StatefulWidget {
  const NanoSolveWebApp({super.key});
export 'web_app_shell.dart' show NanoSolveWebApp;

  @override
  State<NanoSolveWebApp> createState() => _NanoSolveWebAppState();
}


class NanoSolveWebApp extends StatefulWidget {
  const NanoSolveWebApp({super.key});

  @override
  State<NanoSolveWebApp> createState() => _NanoSolveWebAppState();
}

class _NanoSolveWebAppState extends State<NanoSolveWebApp>
    with LanguageSelectionMixin<NanoSolveWebApp> {
  WebSection _section = WebSection.explore;
  WebDomain _domain = WebDomain.human;
  String _sourcesQuery = '';
  CategoryDetailData? _selectedCategory;

  bool _isChatOpen = false;
  double _chatPanelHeight = WebTheme.chatPanelHeightDefault;
  bool _isSidebarHovered = false;
  bool _searchExpanded = false;

  @override
  void initState() {
    super.initState();
    initLanguageSelection();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final categories = CategoryDetailDataFactory.all(l10n);
    final domainCategories = categories
        .where((c) => _domain == WebDomain.human
            ? c.categoryKey.startsWith('human_')
            : c.categoryKey.startsWith('planet_'))
        .toList(growable: false);

    if (_selectedCategory != null &&
        !domainCategories
            .any((c) => c.categoryKey == _selectedCategory!.categoryKey)) {
      _selectedCategory = null;
    }

    final width = MediaQuery.sizeOf(context).width;
    final compactSidebar = width < 1200;
    final expandedSidebar = compactSidebar ? false : _isSidebarHovered;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        if (event.logicalKey == LogicalKeyboardKey.slash) {
          setState(() => _searchExpanded = true);
          return KeyEventResult.handled;
        }

        if (event.logicalKey == LogicalKeyboardKey.escape) {
          setState(() {
            if (_searchExpanded) {
              _searchExpanded = false;
              _sourcesQuery = '';
            } else if (_isChatOpen) {
              _isChatOpen = false;
            } else if (_selectedCategory != null &&
                _section == WebSection.explore) {
              _selectedCategory = null;
            }
          });
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: WebBackground(domain: _domain)),
            Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _domainAccent.withValues(alpha: 0.07),
                      Colors.transparent,
                      _domainAccentSoft.withValues(alpha: 0.04),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: PlatformAdaptive.contentMaxWidth(
                      context,
                      mobile: 900,
                      tablet: 1280,
                      desktop: 1700,
                    ),
                  ),
                  child: Row(
                    children: [
                      MouseRegion(
                        onEnter: (_) =>
                            setState(() => _isSidebarHovered = true),
                        onExit: (_) =>
                            setState(() => _isSidebarHovered = false),
                        child: AnimatedContainer(
                          width: expandedSidebar
                              ? WebTheme.sidebarExpanded
                              : WebTheme.sidebarCollapsed,
                          duration: WebTheme.slow,
                          curve: WebTheme.sidebarCurve,
                          child: WebSidebar(
                            l10n: l10n,
                            expanded: expandedSidebar,
                            compactMode: compactSidebar,
                            domain: _domain,
                            section: _section,
                            isChatOpen: _isChatOpen,
                            selectedLanguage: selectedLanguage,
                            onDomainChanged: _setDomain,
                            onSectionChanged: (section) =>
                                setState(() => _section = section),
                            onToggleChat: () =>
                                setState(() => _isChatOpen = !_isChatOpen),
                            onSelectLanguage: selectLanguage,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 14, 20, 20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: WebTheme.surfacePanel(context),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Column(
                                children: [
                                  WebTopBar(
                                    l10n: l10n,
                                    section: _section,
                                    domain: _domain,
                                    selectedCategoryTitle:
                                        _selectedCategory?.title,
                                    searchExpanded: _searchExpanded,
                                    searchQuery: _sourcesQuery,
                                    onToggleSearch: () =>
                                        setState(() => _searchExpanded = true),
                                    onSearchChanged: (value) =>
                                        setState(() => _sourcesQuery = value),
                                    onSearchClear: () {
                                      setState(() {
                                        _searchExpanded = false;
                                        _sourcesQuery = '';
                                      });
                                    },
                                    onDomainChanged: _setDomain,
                                  ),
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        AnimatedSwitcher(
                                          duration: WebTheme.normal,
                                          switchInCurve: WebTheme.switchCurve,
                                          switchOutCurve: WebTheme.switchCurve,
                                          child: _buildSection(
                                            l10n: l10n,
                                            domainCategories: domainCategories,
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: _ChatResizableContainer(
                                            isOpen: _isChatOpen,
                                            height: _chatPanelHeight,
                                            onResize: (delta) {
                                              final viewportH =
                                                  MediaQuery.sizeOf(context)
                                                      .height;
                                              final maxHeight = viewportH * 0.8;
                                              setState(() {
                                                _chatPanelHeight =
                                                    (_chatPanelHeight + delta)
                                                        .clamp(
                                                  WebTheme.chatPanelHeightMin,
                                                  maxHeight,
                                                );
                                              });
                                            },
                                            child: AiChatPanel(
                                              l10n: l10n,
                                              onClose: () => setState(
                                                  () => _isChatOpen = false),
                                              onMinimize: () => setState(
                                                  () => _isChatOpen = false),
                                              onOpenLibrary: () {
                                                setState(() {
                                                  _section = WebSection.sources;
                                                  _isChatOpen = false;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required AppLocalizations l10n,
    required List<CategoryDetailData> domainCategories,
  }) {
    return switch (_section) {
      WebSection.explore => ExploreSection(
          key: const ValueKey('explore-section'),
          l10n: l10n,
          isHumanDomain: _domain == WebDomain.human,
          categories: domainCategories,
          selectedCategory: _selectedCategory,
          onSelectCategory: (category) =>
              setState(() => _selectedCategory = category),
          onClearSelection: () => setState(() => _selectedCategory = null),
          onOpenSources: (category) => setState(() {
            _selectedCategory = category;
            _section = WebSection.sources;
          }),
          onPostIdea: (category) => setState(() {
            _selectedCategory = category;
            _section = WebSection.ideas;
          }),
        ),
      WebSection.sources => SourcesSection(
          key: const ValueKey('sources-section'),
          l10n: l10n,
          domain: _domain,
          categories: domainCategories,
          query: _sourcesQuery,
          onQueryChanged: (value) => setState(() => _sourcesQuery = value),
          activeLanguageCode: _activeLanguageCode(),
          onOpenInNewTab: _openSourceInNewPanel,
        ),
      WebSection.ideas => IdeasSection(
          key: const ValueKey('ideas-section'),
          l10n: l10n,
          categories: domainCategories,
          initialCategory: _selectedCategory,
        ),
      WebSection.leaderboard => LeaderboardSection(
          key: const ValueKey('leaderboard-section'),
          l10n: l10n,
          onPostIdea: () => setState(() => _section = WebSection.ideas),
        ),
    };
  }

  Future<void> _openSourceInNewPanel(String rawUrl) async {
    final normalized = rawUrl.trim();
    if (normalized.isEmpty) {
      _showSnack('Invalid source link.');
      return;
    }

    Uri? uri = Uri.tryParse(normalized);
    uri ??= Uri.tryParse(Uri.encodeFull(normalized));
    if (uri == null || !(uri.hasScheme && uri.host.isNotEmpty)) {
      _showSnack('Invalid source link.');
      return;
    }

    final opened = await PlatformAdaptive.launchExternalUri(uri);
    if (!opened && mounted) {
      _showSnack('Could not open source link in a new tab.');
    }
  }

  String _activeLanguageCode() {
    final settingsLang =
        ServiceLocator().settingsManager.userLanguage.toLowerCase();
    const supported = {'en', 'cs', 'es', 'fr', 'ru'};
    if (supported.contains(settingsLang)) {
      return settingsLang;
    }

    final localeLang =
        Localizations.localeOf(context).languageCode.toLowerCase();
    return supported.contains(localeLang) ? localeLang : 'en';
  }

  void _setDomain(WebDomain domain) {
    setState(() {
      _domain = domain;
      _selectedCategory = null;
    });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Color get _domainAccent =>
      _domain == WebDomain.human ? AppColors.neonCyan : AppColors.neonOcean;

  Color get _domainAccentSoft =>
      _domain == WebDomain.human ? AppColors.pastelAqua : AppColors.pastelMint;
}

class _ChatResizableContainer extends StatelessWidget {
  final bool isOpen;
  final double height;
  final Widget child;
  final ValueChanged<double> onResize;

  const _ChatResizableContainer({
    required this.isOpen,
    required this.height,
    required this.child,
    required this.onResize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      height: isOpen ? height : 0,
      duration: WebTheme.slow,
      curve: WebTheme.chatCurve,
      child: isOpen
          ? Column(
              children: [
                GestureDetector(
                  onVerticalDragUpdate: (d) => onResize(-d.delta.dy),
                  child: Container(
                    height: 6,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                Expanded(child: child),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}

/*

class _NanoSolveWebAppState extends State<NanoSolveWebApp>
    with LanguageSelectionMixin<NanoSolveWebApp> {
  static const int _maxAttachments = 10;
  static const int _maxAttachmentSizeBytes = 95 * 1024 * 1024;

  WebSection _section = WebSection.explore;
  WebDomain _domain = WebDomain.human;
  String _sourcesQuery = '';
  CategoryDetailData? _selectedCategory;
  Future<List<Solver>>? _solversFuture;
  final TextEditingController _sourcesSearchController =
      TextEditingController();
  final FocusNode _sourcesSearchFocusNode = FocusNode();
  final TextEditingController _ideaController = TextEditingController();
  final List<IdeaAttachment> _ideaAttachments = [];
  bool _isSubmittingIdea = false;

  @override
  void initState() {
    super.initState();
    initLanguageSelection();
    _solversFuture = ServiceLocator().apiService.getTopSolvers();
  }

  @override
  void dispose() {
    _sourcesSearchController.dispose();
    _sourcesSearchFocusNode.dispose();
    _ideaController.dispose();
    super.dispose();
  }

  _DomainTheme _themeFor(WebDomain domain) {
    if (domain == WebDomain.human) {
      return const _DomainTheme(
        background: [Color(0xFF081424), Color(0xFF123055), Color(0xFF081424)],
        accent: AppColors.neonCyan,
        accentSoft: AppColors.pastelAqua,
      );
    }

    return const _DomainTheme(
      background: [Color(0xFF071A17), Color(0xFF12473B), Color(0xFF071A17)],
      accent: AppColors.neonOcean,
      accentSoft: AppColors.pastelMint,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final domainTheme = _themeFor(_domain);
    final categories = CategoryDetailDataFactory.all(l10n);
    final domainCategories = categories
        .where((c) => _domain == WebDomain.human
            ? c.categoryKey.startsWith('human_')
            : c.categoryKey.startsWith('planet_'))
        .toList(growable: false);

    final filteredCategories = domainCategories;

    if (_selectedCategory != null &&
        !filteredCategories
            .any((c) => c.categoryKey == _selectedCategory!.categoryKey)) {
      _selectedCategory = null; // domain switched — back to showcase
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── Animated space background ────────────────────────────────────
          Positioned.fill(child: _AnimatedBackground(domain: _domain)),
          // ── Subtle domain-colour tint that shifts with domain switch ─────
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    domainTheme.accent.withValues(alpha: 0.07),
                    Colors.transparent,
                    domainTheme.accentSoft.withValues(alpha: 0.04),
                  ],
                ),
              ),
            ),
          ),
          // ── App UI ───────────────────────────────────────────────────────
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: PlatformAdaptive.contentMaxWidth(
                    context,
                    mobile: 900,
                    tablet: 1280,
                    desktop: 1700,
                  ),
                ),
                child: Row(
                  children: [
                    _buildSideNav(l10n, domainTheme),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              child: switch (_section) {
                                WebSection.explore => _buildExplore(
                                    l10n,
                                    filteredCategories,
                                    _selectedCategory,
                                  ),
                                WebSection.sources =>
                                  _buildSources(l10n, domainCategories),
                                WebSection.ideas =>
                                  _buildIdeas(l10n, domainCategories),
                                WebSection.leaderboard =>
                                  _buildLeaderboard(l10n),
                              },
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
        ],
      ),
    );
  }

  Widget _buildSideNav(AppLocalizations l10n, _DomainTheme theme) {
    return Container(
      width: 290,
      padding: const EdgeInsets.fromLTRB(18, 18, 10, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const NanosolveLogo(height: 44),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _DomainChip(
                  title: l10n.tabHuman,
                  subtitle: 'Human health',
                  icon: Icons.health_and_safety_outlined,
                  active: _domain == WebDomain.human,
                  color: AppColors.neonCyan,
                  onTap: () => setState(() => _domain = WebDomain.human),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _DomainChip(
                  title: l10n.tabPlanet,
                  subtitle: 'Earth systems',
                  icon: Icons.public,
                  active: _domain == WebDomain.planet,
                  color: AppColors.neonOcean,
                  onTap: () => setState(() => _domain = WebDomain.planet),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _NavItem(
            title: l10n.navExplore,
            icon: Icons.explore_outlined,
            selected: _section == WebSection.explore,
            onTap: () => setState(() => _section = WebSection.explore),
          ),
          _NavItem(
            title: l10n.navSources,
            icon: Icons.menu_book_outlined,
            selected: _section == WebSection.sources,
            onTap: () => setState(() => _section = WebSection.sources),
          ),
          _NavItem(
            title: l10n.categoryDetailIdeas,
            icon: Icons.lightbulb_outline,
            selected: _section == WebSection.ideas,
            onTap: () => setState(() => _section = WebSection.ideas),
          ),
          _NavItem(
            title: l10n.navResults,
            icon: Icons.leaderboard_outlined,
            selected: _section == WebSection.leaderboard,
            onTap: () async {
              if (await _requireRegistration()) {
                setState(() => _section = WebSection.leaderboard);
              }
            },
          ),
          const Spacer(),
          // ── Language selector ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 10),
            child: Row(
              children: [
                Text(
                  'Lang',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 8),
                ...LanguageSelectionMixin.supportedLanguages.map((lang) {
                  final code = lang['code']!;
                  final flag = lang['flag']!;
                  final active = selectedLanguage == code;
                  return Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Tooltip(
                      message: lang['name']!,
                      child: InkWell(
                        onTap: () => selectLanguage(code),
                        borderRadius: BorderRadius.circular(6),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 3),
                          decoration: BoxDecoration(
                            color: active
                                ? theme.accent.withValues(alpha: 0.22)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: active
                                  ? theme.accent.withValues(alpha: 0.65)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Text(
                            flag,
                            style: TextStyle(
                              fontSize: active ? 18 : 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExplore(
    AppLocalizations l10n,
    List<CategoryDetailData> categories,
    CategoryDetailData? selected,
  ) {
    if (selected == null) {
      return _buildCategoryShowcase(l10n, categories);
    }
    return Row(
      key: const ValueKey('explore-split'),
      children: [
        SizedBox(
          width: 220,
          child: _buildCategoryList(categories, selected),
        ),
        Expanded(
          child: _CategoryPanel(
            data: selected,
            onGoToSources: () =>
                setState(() => _section = WebSection.sources),
            onPostIdea: () => _openIdeasForCategory(selected),
            onOpenEntryPdf: (page) {
              final url = _buildAllatraPageUrl(page);
              if (url != null) _openSourceInNewPanel(url);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryShowcase(
      AppLocalizations l10n, List<CategoryDetailData> categories) {
    final isHuman = _domain == WebDomain.human;
    return CustomScrollView(
      key: const ValueKey('explore-showcase'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(32, 36, 32, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'RESEARCH DOMAINS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isHuman ? 'Human Health Impact' : 'Earth Systems Impact',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  isHuman
                      ? 'Six critical pathways through which nanoplastic pollution disrupts human biology — from the central nervous system to hormonal regulation.'
                      : 'Six planetary systems under accelerating threat from nanoplastic contamination — from oceanic food chains to atmospheric chemistry.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(32, 0, 32, 36),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 310,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.42,
            ),
            itemCount: categories.length,
            itemBuilder: (_, i) => _buildShowcaseCard(categories[i], i),
          ),
        ),
      ],
    );
  }

  Widget _buildShowcaseCard(CategoryDetailData category, int index) {
    return Semantics(
      button: true,
      label: category.title,
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = category),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      category.themeColor.withValues(alpha: 0.38),
                      category.themeColor.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Icon(category.icon, color: category.themeColor, size: 24),
                    const Spacer(),
                    Text(
                      '0${index + 1}',
                      style: TextStyle(
                        color: category.themeColor.withValues(alpha: 0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Text(
                          category.subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 12,
                            height: 1.45,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Explore',
                            style: TextStyle(
                              color: category.themeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.arrow_forward,
                              color: category.themeColor, size: 11),
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
    );
  }

  Widget _buildCategoryList(
      List<CategoryDetailData> categories, CategoryDetailData selected) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _selectedCategory = null),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Icon(Icons.arrow_back,
                      size: 13, color: Colors.white.withValues(alpha: 0.45)),
                  const SizedBox(width: 6),
                  Text(
                    'All domains',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: categories.length,
              itemBuilder: (_, i) {
                final cat = categories[i];
                final active = selected.categoryKey == cat.categoryKey;
                return Semantics(
                  button: true,
                  selected: active,
                  label: cat.title,
                  child: InkWell(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 120),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 9),
                      decoration: BoxDecoration(
                        color: active
                            ? cat.themeColor.withValues(alpha: 0.14)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: active
                              ? cat.themeColor.withValues(alpha: 0.5)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(cat.icon, color: cat.themeColor, size: 17),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              cat.title,
                              style: TextStyle(
                                color: active
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.6),
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                fontSize: 12.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSources(
      AppLocalizations l10n, List<CategoryDetailData> categories) {
    final query = _sourcesQuery.trim().toLowerCase();
    final categoryBlocks = categories.map((category) {
      final allatraSources = _allatraSourcesForCategory(category);
      return (category: category, allatraSources: allatraSources);
    }).where((block) {
      if (query.isEmpty) return true;

      final category = block.category;
      if (category.title.toLowerCase().contains(query) ||
          category.subtitle.toLowerCase().contains(query)) {
        return true;
      }

      for (final section in category.evidenceSections) {
        if (section.title.toLowerCase().contains(query)) {
          return true;
        }
        for (final study in section.studies) {
          if (study.title.toLowerCase().contains(query) ||
              study.journal.toLowerCase().contains(query) ||
              study.year.toString().contains(query)) {
            return true;
          }
        }
      }

      for (final source in block.allatraSources) {
        if (source.title.toLowerCase().contains(query) ||
            source.description.toLowerCase().contains(query) ||
            source.getPageRangeDisplay().toLowerCase().contains(query)) {
          return true;
        }
      }

      return false;
    }).toList(growable: false);

    return Column(
      key: const ValueKey('sources-view'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
          child: Text(
            '${l10n.navSources} • ${_domain == WebDomain.human ? l10n.tabHuman : l10n.tabPlanet}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
          child: Text(
            'Libraries are grouped by category and section headline for faster research flow.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 12,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
          child: RawAutocomplete<_SourceSearchSuggestion>(
            textEditingController: _sourcesSearchController,
            focusNode: _sourcesSearchFocusNode,
            displayStringForOption: (option) => option.query,
            optionsBuilder: (textEditingValue) => _buildSourceSearchSuggestions(
                categories, textEditingValue.text),
            onSelected: (option) => _setSourcesQuery(option.query),
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: _setSourcesQuery,
                onSubmitted: (_) => onSubmitted(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search sources…',
                  hintStyle:
                      TextStyle(color: Colors.white.withValues(alpha: 0.55)),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: _sourcesQuery.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _sourcesSearchController.clear();
                            _setSourcesQuery('');
                          },
                          icon: const Icon(Icons.close, color: Colors.white70),
                        ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              final items = options.toList(growable: false);
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: const Color(0xFF0B2035),
                  elevation: 8,
                  borderRadius: BorderRadius.circular(14),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 720,
                      maxHeight: 320,
                    ),
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                      itemBuilder: (_, index) {
                        final option = items[index];
                        return InkWell(
                          onTap: () => onSelected(option),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  option.icon,
                                  size: 16,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        option.kindLabel,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withValues(alpha: 0.62),
                                          fontSize: 11,
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
                ),
              );
            },
          ),
        ),
        Expanded(
          child: categoryBlocks.isEmpty
              ? Center(
                  child: Text(
                    'No matching sources.',
                    style:
                        TextStyle(color: Colors.white.withValues(alpha: 0.72)),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  itemCount: categoryBlocks.length,
                  itemBuilder: (_, i) {
                    final category = categoryBlocks[i].category;
                    final allatraSources = categoryBlocks[i].allatraSources;
                    final categoryHeadlineUrl =
                        _headlinePdfUrlForCategory(category, allatraSources);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(category.icon, color: category.themeColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: categoryHeadlineUrl == null
                                      ? null
                                      : () => _openSourceInNewPanel(
                                          categoryHeadlineUrl),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            category.title,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                        if (categoryHeadlineUrl != null) ...[
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.picture_as_pdf_outlined,
                                            size: 15,
                                            color: AppColors.pastelMint,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '${category.evidenceStudyCount + allatraSources.length} refs',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...category.evidenceSections.asMap().entries.map(
                            (sectionEntry) {
                              final sectionIndex = sectionEntry.key;
                              final section = sectionEntry.value;
                              final sectionHeadlineUrl =
                                  _headlinePdfUrlForSection(
                                category,
                                section,
                                sectionIndex,
                                allatraSources,
                              );
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    InkWell(
                                      onTap: sectionHeadlineUrl == null
                                          ? null
                                          : () => _openSourceInNewPanel(
                                              sectionHeadlineUrl),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                          horizontal: 2,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                section.title,
                                                style: TextStyle(
                                                  color: category.themeColor,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                            if (sectionHeadlineUrl != null) ...[
                                              const SizedBox(width: 6),
                                              const Icon(
                                                Icons.open_in_new,
                                                size: 14,
                                                color: AppColors.pastelAqua,
                                              ),
                                              const SizedBox(width: 6),
                                              _openInPanelButton(
                                                  sectionHeadlineUrl),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    ...section.studies.map(
                                      (study) => InkWell(
                                        onTap: () =>
                                            _openSourceInNewPanel(study.url),
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          width: double.infinity,
                                          margin:
                                              const EdgeInsets.only(bottom: 6),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 9,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.black
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: Colors.white
                                                  .withValues(alpha: 0.08),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.open_in_new,
                                                size: 16,
                                                color: AppColors.pastelAqua,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      study.title,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      '${study.journal} • ${study.year}',
                                                      style: TextStyle(
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.7),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              _openInPanelButton(study.url),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          if (allatraSources.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Allatra report PDFs',
                              style: TextStyle(
                                color: category.themeColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ...allatraSources.map(
                              (source) => InkWell(
                                onTap: () => _openSourceInNewPanel(source.url!),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 9,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.picture_as_pdf_outlined,
                                        size: 16,
                                        color: AppColors.pastelMint,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              source.title,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              source.getPageRangeDisplay(),
                                              style: TextStyle(
                                                color: Colors.white.withValues(
                                                  alpha: 0.7,
                                                ),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _openInPanelButton(source.url!),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildIdeas(
      AppLocalizations l10n, List<CategoryDetailData> categories) {
    return Row(
      key: const ValueKey('ideas-view'),
      children: [
        SizedBox(
          width: 340,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Post new idea',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Attach documents, images, videos, or audio notes. All attachments are sent with your submission.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.76),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: _isSubmittingIdea ? null : _pickWebAttachments,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Add attachments'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Max $_maxAttachments files, each up to 95 MB.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _ideaAttachments.isEmpty
                      ? Center(
                          child: Text(
                            'No attachments yet',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.52),
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _ideaAttachments.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 6),
                          itemBuilder: (_, i) {
                            final att = _ideaAttachments[i];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _iconForAttachmentType(att.type),
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      att.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  IconButton(
                                    iconSize: 18,
                                    visualDensity: VisualDensity.compact,
                                    onPressed: _isSubmittingIdea
                                        ? null
                                        : () => setState(
                                              () =>
                                                  _ideaAttachments.removeAt(i),
                                            ),
                                    icon: const Icon(Icons.close,
                                        color: Colors.white70),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 18, 18, 18),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Submission form',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory?.categoryKey,
                    decoration: _formDecoration('Category'),
                    dropdownColor: const Color(0xFF0B2035),
                    iconEnabledColor: Colors.white70,
                    items: categories
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: c.categoryKey,
                            child: Text(c.title),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: _isSubmittingIdea
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(
                              () => _selectedCategory = categories
                                  .firstWhere((c) => c.categoryKey == value),
                            );
                          },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: _ideaController,
                      enabled: !_isSubmittingIdea,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: _formDecoration(
                              l10n.categoryDetailBrainstormPlaceholder)
                          .copyWith(alignLabelWithHint: true),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isSubmittingIdea
                              ? null
                              : () => _submitIdeaWeb(l10n),
                          icon: _isSubmittingIdea
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send_outlined),
                          label: Text(
                            _isSubmittingIdea
                                ? 'Submitting...'
                                : l10n.categoryDetailBrainstormSubmit,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _formDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.pastelAqua, width: 1.2),
      ),
    );
  }

  void _openIdeasForCategory(CategoryDetailData category) {
    if (!mounted) return;
    setState(() {
      _selectedCategory = category;
      _section = WebSection.ideas;
    });

    final template =
        'Category: ${category.title}\n\nProblem:\n\nProposed solution:\n';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _ideaController.value = TextEditingValue(
        text: template,
        selection: TextSelection.collapsed(offset: template.length),
      );
    });
  }

  Future<void> _openSourceInNewPanel(String rawUrl) async {
    final normalized = rawUrl.trim();
    if (normalized.isEmpty) {
      _showSnack('Invalid source link.');
      return;
    }

    Uri? uri = Uri.tryParse(normalized);
    uri ??= Uri.tryParse(Uri.encodeFull(normalized));
    if (uri == null || !(uri.hasScheme && uri.host.isNotEmpty)) {
      _showSnack('Invalid source link.');
      return;
    }

    final opened = await PlatformAdaptive.launchExternalUri(uri);
    if (!opened && mounted) {
      _showSnack('Could not open source link in a new panel.');
    }
  }

  Widget _openInPanelButton(String url) {
    return Tooltip(
      message: 'Open in new panel',
      child: TextButton.icon(
        onPressed: () => _openSourceInNewPanel(url),
        icon: const Icon(Icons.open_in_new, size: 14),
        label: const Text('New panel'),
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          foregroundColor: AppColors.pastelAqua,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }

  List<PDFSource> _allatraSourcesForCategory(CategoryDetailData category) {
    final lang = _activeLanguageCode();

    final categoryPool = [
      if (_domain == WebDomain.human) ...humanHealthSources,
      if (_domain == WebDomain.planet) ...earthPollutionSources,
      if (_domain == WebDomain.planet) ...waterAbilitiesSources,
    ]
        .where((s) => s.language == lang && s.url != null && s.url!.isNotEmpty)
        .toList();

    final globalReports = earthPollutionSources
        .where((s) => s.language == lang && s.url != null && s.url!.isNotEmpty)
        .where(_isFullAllatraReport)
        .toList(growable: false);

    final keywords = _categoryKeywords(category.categoryKey);
    final matched = categoryPool.where((source) {
      final haystack = '${source.title} ${source.description}'.toLowerCase();
      return keywords.any(haystack.contains);
    }).toList(growable: false);

    final unique = <String>{};
    final ordered = <PDFSource>[];
    for (final source in [...globalReports, ...matched]) {
      final id = '${source.title}|${source.url}';
      if (unique.add(id)) ordered.add(source);
    }
    return ordered;
  }

  String? _headlinePdfUrlForCategory(
    CategoryDetailData category,
    List<PDFSource> allatraSources,
  ) {
    final pageFromCategory = _pageForCategoryHeadline(category);
    final exactCategoryUrl = _buildAllatraPageUrl(pageFromCategory);
    if (exactCategoryUrl != null) return exactCategoryUrl;

    final specific =
        allatraSources.where((s) => !_isFullAllatraReport(s)).firstWhere(
              (_) => true,
              orElse: () => allatraSources.isNotEmpty
                  ? allatraSources.first
                  : _emptyPdfSource,
            );

    if (specific.url != null && specific.url!.isNotEmpty) {
      return specific.url;
    }
    return allatraSources.isNotEmpty ? allatraSources.first.url : null;
  }

  String? _headlinePdfUrlForSection(
    CategoryDetailData category,
    EvidenceSection section,
    int sectionIndex,
    List<PDFSource> allatraSources,
  ) {
    final sectionTitle = section.title;
    final pageFromSection = _pageForSectionHeadline(category, sectionTitle);
    final exactSectionUrl = _buildAllatraPageUrl(pageFromSection);
    if (exactSectionUrl != null) return exactSectionUrl;

    if (sectionIndex >= 0 && sectionIndex < category.entries.length) {
      final indexedEntry = category.entries[sectionIndex];
      final indexedUrl = _buildAllatraPageUrl(indexedEntry.pdfStartPage);
      if (indexedUrl != null) return indexedUrl;
    }

    final sectionTokens = sectionTitle
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3)
        .toSet();

    final ranked = allatraSources
        .where((s) => !_isFullAllatraReport(s))
        .map((s) {
          final haystack = '${s.title} ${s.description}'.toLowerCase();
          final score = sectionTokens.where(haystack.contains).length;
          return (source: s, score: score);
        })
        .where((it) => it.score > 0)
        .toList(growable: false)
      ..sort((a, b) => b.score.compareTo(a.score));

    if (ranked.isNotEmpty && ranked.first.source.url != null) {
      return ranked.first.source.url;
    }

    return _headlinePdfUrlForCategory(category, allatraSources);
  }

  static final PDFSource _emptyPdfSource = PDFSource(
    title: '',
    startPage: 1,
    endPage: 1,
    description: '',
    language: 'en',
    url: '',
  );

  int? _pageForCategoryHeadline(CategoryDetailData category) {
    for (final entry in category.entries) {
      if (entry.pdfStartPage != null && entry.pdfStartPage! > 0) {
        return entry.pdfStartPage;
      }
    }
    for (final source in category.sourceLinks ?? const <SourceLink>[]) {
      if (source.pdfStartPage != null && source.pdfStartPage! > 0) {
        return source.pdfStartPage;
      }
    }
    return null;
  }

  int? _pageForSectionHeadline(
      CategoryDetailData category, String sectionTitle) {
    final normalizedSection = _normalizeHeadline(sectionTitle);
    if (normalizedSection.isEmpty) return null;

    final exact = category.entries.where((e) {
      final h = _normalizeHeadline(e.highlight);
      return h == normalizedSection;
    });
    for (final entry in exact) {
      if (entry.pdfStartPage != null && entry.pdfStartPage! > 0) {
        return entry.pdfStartPage;
      }
    }

    final partial = category.entries.where((e) {
      final h = _normalizeHeadline(e.highlight);
      return h.contains(normalizedSection) || normalizedSection.contains(h);
    });
    for (final entry in partial) {
      if (entry.pdfStartPage != null && entry.pdfStartPage! > 0) {
        return entry.pdfStartPage;
      }
    }

    return null;
  }

  String _normalizeHeadline(String value) {
    return value
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _buildAllatraPageUrl(int? page) {
    if (page == null || page <= 0) return null;
    final base = _allatraBaseUrlForLanguage();
    if (base == null || base.isEmpty) return null;
    return '$base#page=$page';
  }

  String? _allatraBaseUrlForLanguage() {
    final lang = _activeLanguageCode();
    const baseUrls = <String, String>{
      'en':
          'https://allatra.org/storage/app/media/reports/en/Nanoplastics_in_the_Biosphere_Report.pdf',
      'cs':
          'https://allatra.org/storage/app/media/reports/cs/Nanoplastics_in_the_Biosphere_Report_CS.pdf',
      'es':
          'https://allatra.org/storage/app/media/reports/es/Nanoplasticos_en_la_Biosfera_Informe_ES.pdf',
      'fr':
          'https://allatra.org/storage/app/media/reports/fr/Nanoplastics_in_the_Biosphere_Report_FR.pdf',
      'ru':
          'https://allatra.org/storage/app/media/reports/ru/Nanoplastics_in_the_Biosphere_Report_RU.pdf',
    };
    return baseUrls[lang] ?? baseUrls['en'];
  }

  bool _isFullAllatraReport(PDFSource source) {
    final text = '${source.title} ${source.description}'.toLowerCase();
    return source.endPage == PDFSource.endPageSentinel ||
        text.contains('report') ||
        text.contains('zpráva') ||
        text.contains('raport') ||
        text.contains('отч') ||
        text.contains('informe');
  }

  List<String> _categoryKeywords(String categoryKey) {
    switch (categoryKey) {
      // Human domain — keys match CategoryDetailDataFactory actual categoryKey values
      case 'human_central':
        return ['central', 'centrální', 'centrales', 'централь', 'cerveau'];
      case 'human_detox':
        return ['filtration', 'detox', 'filtrace', 'détox', 'детокс'];
      case 'human_vitality':
        return ['vitality', 'tissues', 'vitalita', 'vitalité', 'tkan'];
      case 'human_reproduction':
        return ['reproduction', 'vývoj', 'fertility', 'fœtus', 'развит'];
      case 'human_entry':
        return ['entry gates', 'vstupní brány', 'portes d\'entrée', 'вход'];
      case 'human_ways_of_destruction':
        return [
          'physical attack',
          'fyzický útok',
          'attaque physique',
          'физичес',
        ];
      // Planet domain — keys match CategoryDetailDataFactory actual categoryKey values
      case 'planet_ocean':
        return ['world ocean', 'océan mondial', 'oceán', 'мировой океан'];
      case 'planet_atmosphere':
        return ['atmosphere', 'atmosféra', 'atmosphère', 'атмосфера'];
      case 'planet_bio':
        return ['flora', 'fauna', 'biota', 'flore', 'флора'];
      case 'planet_magnetic':
        return [
          'magnetic field',
          'magnetické pole',
          'champ magnétique',
          'магнит',
        ];
      case 'planet_entry':
        return ['entry', 'source', 'zdroj', 'porte', 'источ'];
      case 'planet_physical':
        return [
          'physical properties',
          'fyzické',
          'propriétés physiques',
          'физические',
        ];
      default:
        return const [];
    }
  }

  String _activeLanguageCode() {
    final settingsLang =
        ServiceLocator().settingsManager.userLanguage.toLowerCase();
    const supported = {'en', 'cs', 'es', 'fr', 'ru'};
    if (supported.contains(settingsLang)) {
      return settingsLang;
    }

    final localeLang =
        Localizations.localeOf(context).languageCode.toLowerCase();
    return supported.contains(localeLang) ? localeLang : 'en';
  }

  void _setSourcesQuery(String value) {
    final normalized = value.trimLeft();
    if (_sourcesQuery == normalized) {
      return;
    }

    setState(() => _sourcesQuery = normalized);
  }

  List<_SourceSearchSuggestion> _buildSourceSearchSuggestions(
    List<CategoryDetailData> categories,
    String input,
  ) {
    final query = input.trim().toLowerCase();
    final suggestions = <_SourceSearchSuggestion>[];
    final seen = <String>{};

    void addSuggestion(_SourceSearchSuggestion suggestion) {
      final key = '${suggestion.kindLabel}|${suggestion.query.toLowerCase()}';
      if (seen.add(key)) {
        suggestions.add(suggestion);
      }
    }

    for (final category in categories) {
      addSuggestion(
        _SourceSearchSuggestion(
          label: category.title,
          query: category.title,
          kindLabel: 'Category',
          icon: category.icon,
        ),
      );

      for (final section in category.evidenceSections) {
        addSuggestion(
          _SourceSearchSuggestion(
            label: section.title,
            query: section.title,
            kindLabel: 'Headline',
            icon: Icons.topic_outlined,
          ),
        );

        for (final study in section.studies) {
          addSuggestion(
            _SourceSearchSuggestion(
              label: study.title,
              query: study.title,
              kindLabel: 'Study',
              icon: Icons.article_outlined,
            ),
          );
        }
      }

      for (final source in _allatraSourcesForCategory(category)) {
        addSuggestion(
          _SourceSearchSuggestion(
            label: source.title,
            query: source.title,
            kindLabel: 'Allatra PDF',
            icon: Icons.picture_as_pdf_outlined,
          ),
        );
      }
    }

    if (query.isEmpty) {
      return suggestions.take(8).toList(growable: false);
    }

    final ranked = suggestions.where((suggestion) {
      final haystack =
          '${suggestion.label} ${suggestion.kindLabel}'.toLowerCase();
      return haystack.contains(query);
    }).toList(growable: false)
      ..sort((a, b) {
        final aStarts = a.label.toLowerCase().startsWith(query) ? 0 : 1;
        final bStarts = b.label.toLowerCase().startsWith(query) ? 0 : 1;
        if (aStarts != bStarts) return aStarts.compareTo(bStarts);
        return a.label.compareTo(b.label);
      });

    return ranked.take(10).toList(growable: false);
  }

  Future<void> _pickWebAttachments() async {
    if (_ideaAttachments.length >= _maxAttachments) {
      _showSnack('Maximum $_maxAttachments attachments allowed.');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: const [
        'jpg',
        'jpeg',
        'png',
        'gif',
        'webp',
        'mp4',
        'mov',
        'pdf',
        'txt',
        'csv',
        'doc',
        'docx',
        'm4a',
        'mp3',
        'wav',
        'ogg',
        'aac',
      ],
    );

    if (result == null || result.files.isEmpty || !mounted) return;

    final incoming = <IdeaAttachment>[];
    for (final file in result.files) {
      final safePath = kIsWeb ? '' : (file.path ?? '');
      final ext =
          (file.extension ?? p.extension(file.name).replaceFirst('.', ''))
              .toLowerCase();

      final bytes = file.bytes;
      final size = file.size;
      if (size > _maxAttachmentSizeBytes) {
        _showSnack('${file.name} is too large (max 95 MB).');
        continue;
      }

      incoming.add(
        IdeaAttachment(
          path: safePath,
          name: file.name,
          mimeType: mimeFromExtension(ext),
          type: attachmentTypeFromExtension(ext),
          bytes: bytes,
          sizeBytes: size,
        ),
      );
    }

    setState(() {
      final availableSlots = _maxAttachments - _ideaAttachments.length;
      _ideaAttachments.addAll(incoming.take(availableSlots));
    });
  }

  /// Returns true if the user already has a registered email, or successfully
  /// registers via the dialog. Returns false if they skip/dismiss.
  Future<bool> _requireRegistration() async {
    final settings = ServiceLocator().settingsManager;
    if (settings.email.isNotEmpty) return true;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ProfileRegistrationDialog(
        onProfileShared: () => Navigator.of(ctx).pop(),
      ),
    );

    if (!mounted) return false;
    if (settings.email.isEmpty) {
      _showSnack('An email is required to continue.');
      return false;
    }
    return true;
  }

  Future<void> _submitIdeaWeb(AppLocalizations l10n) async {
    final text = _ideaController.text.trim();
    if (text.length < 10 && _ideaAttachments.isEmpty) {
      _showSnack(l10n.categoryDetailBrainstormMinLength);
      return;
    }

    if (_selectedCategory == null) {
      _showSnack('Please select a category first.');
      return;
    }

    if (!await _requireRegistration()) return;

    setState(() => _isSubmittingIdea = true);
    try {
      final result = await ServiceLocator().apiService.submitIdea(
            description: text,
            category: _selectedCategory!.categoryKey,
            attachments: List<IdeaAttachment>.from(_ideaAttachments),
          );

      if (!mounted) return;
      if (result['success'] == true) {
        _ideaController.clear();
        setState(() => _ideaAttachments.clear());
        _showSnack('${l10n.categoryDetailBrainstormSuccess} 🚀');
      } else {
        _showSnack(result['message']?.toString() ??
            l10n.categoryDetailBrainstormError);
      }
    } catch (_) {
      if (mounted) _showSnack(l10n.categoryDetailBrainstormError);
    } finally {
      if (mounted) setState(() => _isSubmittingIdea = false);
    }
  }

  IconData _iconForAttachmentType(AttachmentType type) {
    switch (type) {
      case AttachmentType.image:
        return Icons.image_outlined;
      case AttachmentType.video:
        return Icons.videocam_outlined;
      case AttachmentType.audio:
        return Icons.mic_outlined;
      case AttachmentType.document:
        return Icons.description_outlined;
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildLeaderboard(AppLocalizations l10n) {
    return FutureBuilder<List<Solver>>(
      key: const ValueKey('leaderboard-view'),
      future: _solversFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.pastelMint),
          );
        }

        final solvers = snapshot.data ?? const <Solver>[];
        if (solvers.isEmpty) {
          return Center(
            child: Text(
              'No data yet',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Text(
                l10n.leaderboardTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                itemCount: solvers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final s = solvers[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.pastelMint.withValues(alpha: 0.2),
                          ),
                          child: Text(
                            '${s.rank}',
                            style: const TextStyle(
                              color: AppColors.pastelMint,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${s.solutionsCount} contributions • ${s.specialty}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          s.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.pastelAqua,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

''';

/*

class _CategoryPanel extends StatelessWidget {
  final CategoryDetailData data;
  final VoidCallback onGoToSources;
  final VoidCallback onPostIdea;
  final void Function(int page)? onOpenEntryPdf;

  const _CategoryPanel({
    required this.data,
    required this.onGoToSources,
    required this.onPostIdea,
    this.onOpenEntryPdf,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.themeColor.withValues(alpha: 0.18),
                    border: Border.all(
                        color: data.themeColor.withValues(alpha: 0.5)),
                  ),
                  child: Icon(data.icon, color: data.themeColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.subtitle,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: onPostIdea,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Post idea'),
                ),
                OutlinedButton.icon(
                  onPressed: onGoToSources,
                  icon: const Icon(Icons.menu_book_outlined),
                  label: const Text('Open grouped sources'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Evidence libraries were moved to the Sources workspace and are now ordered by category and headline.',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
            ),
            const SizedBox(height: 14),
            ...data.entries.take(5).map(
              (e) {
                final hasPage = e.pdfStartPage != null && e.pdfStartPage! > 0;
                final canOpen = hasPage && onOpenEntryPdf != null;
                return InkWell(
                  onTap:
                      canOpen ? () => onOpenEntryPdf!(e.pdfStartPage!) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: canOpen
                            ? data.themeColor.withValues(alpha: 0.22)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                e.highlight,
                                style: TextStyle(
                                  color: data.themeColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (canOpen) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.picture_as_pdf_outlined,
                                size: 14,
                                color: data.themeColor.withValues(alpha: 0.65),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e.description,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(right: 12, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.pastelAqua.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.pastelAqua.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.pastelAqua : Colors.white70),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.82),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DomainChip extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _DomainChip({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        decoration: BoxDecoration(
          gradient: active
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.28),
                    color.withValues(alpha: 0.1),
                  ],
                )
              : null,
          color: active ? null : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: active ? color : Colors.white70, size: 16),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.75),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DomainTheme {
  final List<Color> background;
  final Color accent;
  final Color accentSoft;

  const _DomainTheme({
    required this.background,
    required this.accent,
    required this.accentSoft,
  });
}

class _SourceSearchSuggestion {
  final String label;
  final String query;
  final String kindLabel;
  final IconData icon;

  const _SourceSearchSuggestion({
    required this.label,
    required this.query,
    required this.kindLabel,
    required this.icon,
  });
}

// ═══════════════════════════════════════════════════════════════════════════════
// Animated space background  –  stars · meteors · Earth night-side with city
// lights slowly rotating.
// ═══════════════════════════════════════════════════════════════════════════════

class _AnimatedBackground extends StatefulWidget {
  const _AnimatedBackground({required this.domain});
  final WebDomain domain;

  @override
  State<_AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<_AnimatedBackground>
    with SingleTickerProviderStateMixin {
  // One continuous looping controller drives everything.
  late final AnimationController _ctrl;

  // Fixed-seed RNG so the star layout is deterministic across rebuilds.
  final _rng = math.Random(42);

  late final List<_BgStar> _stars;
  late final List<_CityDot> _cityDots;
  final List<_Meteor> _meteors = [];

  // Track time to compute Δt between listener calls.
  double _prevSeconds = 0;

  static const double _cycleSec = 60.0; // controller period

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _cycleSec ~/ 1),
    )..repeat();

    _stars = List.generate(210, (_) => _BgStar(_rng));
    _cityDots = List.generate(88, (_) => _CityDot(_rng));

    _ctrl.addListener(_onTick);
  }

  void _onTick() {
    final t = _ctrl.value * _cycleSec;
    double dt = t - _prevSeconds;
    if (dt < 0) dt += _cycleSec; // loop wrap-around
    _prevSeconds = t;

    // Advance existing meteors and retire finished ones.
    for (final m in _meteors) {
      m.elapsed += dt;
    }
    _meteors.removeWhere((m) => m.elapsed >= m.lifetime);

    // Spawn rate differs: Human is more energetic (more streaks, shorter pauses).
    final isHuman = widget.domain == WebDomain.human;
    final maxM = isHuman ? 9 : 6;
    final rate = isHuman ? 0.55 : 0.35;
    if (_meteors.length < maxM && _rng.nextDouble() < dt * rate) {
      _meteors.add(_Meteor(_rng));
    }
    // Occasionally send a double burst.
    if (_meteors.length < maxM - 1 &&
        _rng.nextDouble() < dt * (isHuman ? 0.16 : 0.08)) {
      _meteors.add(_Meteor(_rng));
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onTick);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => CustomPaint(
        painter: _BackgroundPainter(
          t: _ctrl.value,
          stars: _stars,
          meteors: _meteors,
          cityDots: _cityDots,
          domain: widget.domain,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ── Data objects ──────────────────────────────────────────────────────────────

class _BgStar {
  final double x; // 0-1 normalised
  final double y; // 0-1 (restricted to top ~83 % — above the Earth arc)
  final double radius;
  final double twinkleSpeed; // cycles per _cycleSec seconds
  final double twinklePhase;
  final double baseOpacity;

  _BgStar(math.Random rng)
      : x = rng.nextDouble(),
        y = rng.nextDouble() * 0.83,
        radius = 0.3 + rng.nextDouble() * 1.7,
        twinkleSpeed = 0.3 + rng.nextDouble() * 2.0,
        twinklePhase = rng.nextDouble() * math.pi * 2,
        baseOpacity = 0.40 + rng.nextDouble() * 0.60;
}

class _Meteor {
  final double startX; // 0-1
  final double startY; // 0-1
  final double angle; // radians, downward-right direction
  final double speed; // normalised units / second
  final double trailLength; // normalised
  final double maxOpacity;
  final double lifetime; // seconds
  double elapsed = 0;

  _Meteor(math.Random rng)
      : startX = 0.05 + rng.nextDouble() * 0.80,
        startY = 0.01 + rng.nextDouble() * 0.50,
        angle = (22 + rng.nextDouble() * 32) * math.pi / 180,
        speed = 0.10 + rng.nextDouble() * 0.24,
        trailLength = 0.05 + rng.nextDouble() * 0.15,
        maxOpacity = 0.55 + rng.nextDouble() * 0.45,
        lifetime = 1.6 + rng.nextDouble() * 2.8;
}

class _CityDot {
  final double relX; // 0-1 horizontal seed used for scrolling
  final double arcFraction; // 0-1: vertical spread across visible Earth arc
  final double size;
  final Color color;
  final double flickerSpeed;
  final double flickerPhase;

  static const _c1 = Color(0xFFFF9030); // warm orange
  static const _c2 = Color(0xFFFFE566); // pale yellow
  static const _c3 = Color(0xFFFFF5E0); // near-white

  _CityDot(math.Random rng)
      : relX = rng.nextDouble(),
        arcFraction = rng.nextDouble(),
        size = 0.8 + rng.nextDouble() * 2.8,
        color = [_c1, _c2, _c3][rng.nextInt(3)],
        flickerSpeed = 0.25 + rng.nextDouble() * 1.1,
        flickerPhase = rng.nextDouble() * math.pi * 2;
}

// ── Custom painter ────────────────────────────────────────────────────────────

class _BackgroundPainter extends CustomPainter {
  final double t; // 0-1 controller value
  final List<_BgStar> stars;
  final List<_Meteor> meteors;
  final List<_CityDot> cityDots;
  final WebDomain domain;

  const _BackgroundPainter({
    required this.t,
    required this.stars,
    required this.meteors,
    required this.cityDots,
    required this.domain,
  });

  static const _cycleSec = 60.0;
  double get _sec => t * _cycleSec;
  bool get _isHuman => domain == WebDomain.human;

  @override
  bool shouldRepaint(_BackgroundPainter old) =>
      old.t != t || old.domain != domain;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintNebula(canvas, size);
    _paintStars(canvas, size);
    _paintMeteors(canvas, size);
    if (_isHuman) {
      _paintOrganicArc(canvas, size);
    } else {
      _paintEarth(canvas, size);
    }
    _paintAtmosphere(canvas, size);
  }

  // ── Deep-space gradient ────────────────────────────────────────────────────

  void _paintBackground(Canvas canvas, Size size) {
    final colors = _isHuman
        ? const [
            Color(0xFF0C0A02),
            Color(0xFF130F03),
            Color(0xFF1A1405),
            Color(0xFF201807)
          ]
        : const [
            Color(0xFF020810),
            Color(0xFF030E1E),
            Color(0xFF04142C),
            Color(0xFF06193A)
          ];
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
          stops: const [0.0, 0.35, 0.70, 1.0],
        ).createShader(Offset.zero & size),
    );
  }

  // ── Very faint nebula / cloud hints ───────────────────────────────────────

  void _paintNebula(Canvas canvas, Size size) {
    // Three slow-breathing blobs – warm golden for Human, cool navy for Planet.
    final blobs = _isHuman
        ? const [
            (rx: 0.22, ry: 0.14, rr: 0.40, hue: Color(0xFF4A3200), a: 0.11),
            (rx: 0.75, ry: 0.28, rr: 0.34, hue: Color(0xFF3A2500), a: 0.09),
            (rx: 0.50, ry: 0.56, rr: 0.30, hue: Color(0xFF5A3D00), a: 0.08),
          ]
        : const [
            (rx: 0.22, ry: 0.14, rr: 0.40, hue: Color(0xFF0B2D65), a: 0.10),
            (rx: 0.75, ry: 0.28, rr: 0.34, hue: Color(0xFF0E1F52), a: 0.08),
            (rx: 0.50, ry: 0.56, rr: 0.30, hue: Color(0xFF091D48), a: 0.07),
          ];
    // Same slow breath rate for both domains – no rapid blinking.
    const breathRate = 0.09;
    for (final b in blobs) {
      final cx = b.rx * size.width;
      final cy = b.ry * size.height;
      final r = b.rr * size.width;
      final breath = 0.88 + 0.12 * math.sin(_sec * breathRate + b.rx * 4);
      canvas.drawCircle(
        Offset(cx, cy),
        r * breath,
        Paint()
          ..color = b.hue.withValues(alpha: b.a)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.65),
      );
    }
  }

  // ── Twinkling stars ────────────────────────────────────────────────────────

  void _paintStars(Canvas canvas, Size size) {
    for (final s in stars) {
      final twinkle = 0.5 +
          0.5 *
              math.sin(
                _sec * s.twinkleSpeed * math.pi * 2 + s.twinklePhase,
              );
      final opacity = s.baseOpacity * (0.35 + 0.65 * twinkle);
      final r = s.radius * (0.88 + 0.12 * twinkle);
      final x = s.x * size.width;
      final y = s.y * size.height;

      // Soft halo on larger stars – warm amber for Human, cool blue for Planet.
      if (s.radius > 1.15) {
        final haloColor =
            _isHuman ? const Color(0xFFFFD080) : const Color(0xFFB0D0FF);
        canvas.drawCircle(
          Offset(x, y),
          r * 2.8,
          Paint()
            ..color = haloColor.withValues(alpha: opacity * 0.15)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.5),
        );
      }
      // Star core.
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = Colors.white.withValues(alpha: opacity),
      );
    }
  }

  // ── Shooting meteors ───────────────────────────────────────────────────────

  void _paintMeteors(Canvas canvas, Size size) {
    for (final m in meteors) {
      if (m.elapsed <= 0) continue;
      final progress = (m.elapsed / m.lifetime).clamp(0.0, 1.0);
      // Quick rise (15 %), long fade out.
      final opacity =
          progress < 0.15 ? progress / 0.15 : 1.0 - (progress - 0.15) / 0.85;

      final dist = m.elapsed * m.speed;
      final cosA = math.cos(m.angle);
      final sinA = math.sin(m.angle);
      final headX = (m.startX + dist * cosA) * size.width;
      final headY = (m.startY + dist * sinA) * size.height;
      final trailPx = m.trailLength * size.width;
      final tailX = headX - trailPx * cosA;
      final tailY = headY - trailPx * sinA;

      // Skip meteors fully off-screen.
      if (headX < -trailPx || headX > size.width + trailPx) continue;
      if (headY < -trailPx || headY > size.height + trailPx) continue;

      final alpha = (opacity * m.maxOpacity).clamp(0.0, 1.0);

      // Gradient trail: transparent → faint → bright head.
      // Human: warm amber streak; Planet: cool white streak.
      final streakColor = _isHuman ? const Color(0xFFFFB060) : Colors.white;
      canvas.drawLine(
        Offset(tailX, tailY),
        Offset(headX, headY),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4 + m.trailLength * 3.5
          ..strokeCap = StrokeCap.round
          ..shader = ui.Gradient.linear(
            Offset(tailX, tailY),
            Offset(headX, headY),
            [
              Colors.transparent,
              streakColor.withValues(alpha: alpha * 0.22),
              streakColor.withValues(alpha: alpha),
            ],
            [0.0, 0.55, 1.0],
          ),
      );

      // Bright flaring head.
      canvas.drawCircle(
        Offset(headX, headY),
        1.6,
        Paint()
          ..color = streakColor.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );
    }
  }

  // ── Earth – night side with slowly drifting city lights ───────────────────

  void _paintEarth(Canvas canvas, Size size) {
    // A very large circle centred well below the viewport bottom edge so
    // only the curved limb is visible as a glowing arc.
    final r = size.width * 1.10;
    final cx = size.width / 2;
    final cy = size.height + r * 0.695;
    final centre = Offset(cx, cy);
    final earthRect = Rect.fromCircle(center: centre, radius: r);

    // Clip everything inside the globe.
    canvas.save();
    canvas.clipPath(Path()..addOval(earthRect));

    // Dark ocean/surface base.
    canvas.drawPaint(Paint()..color = const Color(0xFF010A16));

    // Very subtle lighter patches hinting at continents.
    canvas.drawCircle(
      Offset(cx * 0.65, cy - r * 0.78),
      r * 0.28,
      Paint()
        ..color = const Color(0xFF041424).withValues(alpha: 0.9)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
    );
    canvas.drawCircle(
      Offset(cx * 1.35, cy - r * 0.74),
      r * 0.22,
      Paint()
        ..color = const Color(0xFF041424).withValues(alpha: 0.85)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.10),
    );

    // City lights — scrolling left slowly (simulated Earth rotation).
    // Belt width in which lights appear (normalised Earth radii from centre).
    final scrollX = (_sec / _cycleSec) * r * 0.80;
    final beltW = r * 1.90; // total horizontal belt (wider than screen)

    for (final dot in cityDots) {
      // Wrap the dot position within the repeating belt.
      final rawX = dot.relX * beltW;
      final dotX = cx - r * 0.95 + ((rawX - scrollX) % beltW);

      // Vertical position: spread across the visible arc.
      final arcDist = (0.695 + dot.arcFraction * 0.245) * r;
      final dotY = cy - arcDist;

      // Reject dots outside the viewport or the circle.
      if (dotX < -8 || dotX > size.width + 8) continue;
      if (dotY < -8 || dotY > size.height + 8) continue;
      final dx = dotX - cx;
      final dy = dotY - cy;
      if (dx * dx + dy * dy > r * r * 0.998) continue;

      final flicker = 0.55 +
          0.45 *
              math.sin(
                _sec * dot.flickerSpeed * math.pi * 2 + dot.flickerPhase,
              );

      // Soft outer glow.
      canvas.drawCircle(
        Offset(dotX, dotY),
        dot.size * 2.0,
        Paint()
          ..color = dot.color.withValues(alpha: 0.16 * flicker)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, dot.size * 1.8),
      );
      // Bright core.
      canvas.drawCircle(
        Offset(dotX, dotY),
        dot.size * 0.48,
        Paint()..color = dot.color.withValues(alpha: 0.80 * flicker),
      );
    }

    canvas.restore();
  }

  // ── Organic arc – Human domain ───────────────────────────────────────────
  // Replaces the Earth globe: a calm golden arc with gently drifting
  // warm light clusters. No blinking, no pulsing.

  void _paintOrganicArc(Canvas canvas, Size size) {
    final r = size.width * 1.10;
    final cx = size.width / 2;
    final cy = size.height + r * 0.695;
    final centre = Offset(cx, cy);
    final earthRect = Rect.fromCircle(center: centre, radius: r);

    canvas.save();
    canvas.clipPath(Path()..addOval(earthRect));

    // Deep warm-dark base (near-black with a golden hint).
    canvas.drawPaint(Paint()..color = const Color(0xFF0A0800));

    // Soft inner golden warmth – static, no pulsing.
    canvas.drawCircle(
      Offset(cx, cy - r * 0.82),
      r * 0.50,
      Paint()
        ..color = const Color(0xFF3A2800).withValues(alpha: 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.22),
    );

    // Light clusters: golden, amber, warm white – no red at all.
    const bioColors = [
      Color(0xFFFFCC00), // bright gold
      Color(0xFFFFAA20), // amber
      Color(0xFFFFE080), // pale yellow
      Color(0xFFFFF5C0), // near-white warm
    ];
    // Slow drift (same organic flow feel).
    final scrollX = (_sec / _cycleSec) * r * 0.30;
    final beltW = r * 1.90;

    for (final dot in cityDots) {
      final rawX = dot.relX * beltW;
      final dotX = cx - r * 0.95 + ((rawX - scrollX) % beltW);
      final arcDist = (0.695 + dot.arcFraction * 0.245) * r;
      final dotY = cy - arcDist;

      if (dotX < -8 || dotX > size.width + 8) continue;
      if (dotY < -8 || dotY > size.height + 8) continue;
      final dx = dotX - cx;
      final dy = dotY - cy;
      if (dx * dx + dy * dy > r * r * 0.998) continue;

      // Very gentle, slow sway – not a sharp flicker.
      final sway = 0.70 +
          0.30 * math.sin(_sec * dot.flickerSpeed * 0.25 + dot.flickerPhase);
      final colorIndex =
          (dot.relX * bioColors.length).floor().clamp(0, bioColors.length - 1);
      final bioColor = bioColors[colorIndex];

      // Soft golden glow.
      canvas.drawCircle(
        Offset(dotX, dotY),
        dot.size * 2.2,
        Paint()
          ..color = bioColor.withValues(alpha: 0.16 * sway)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, dot.size * 2.0),
      );
      // Warm core.
      canvas.drawCircle(
        Offset(dotX, dotY),
        dot.size * 0.48,
        Paint()..color = bioColor.withValues(alpha: 0.75 * sway),
      );
    }

    canvas.restore();

    // Steady golden rim – no pulsing width or opacity change.
    canvas.drawCircle(
      centre,
      r * 1.018,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF8A6000).withValues(alpha: 0.0),
            const Color(0xFFB88000).withValues(alpha: 0.12),
            const Color(0xFFFFCC30).withValues(alpha: 0.28),
            const Color(0xFFFFE080).withValues(alpha: 0.10),
            Colors.transparent,
          ],
          stops: const [0.0, 0.88, 0.93, 0.970, 0.988, 1.0],
        ).createShader(
          Rect.fromCircle(center: centre, radius: r * 1.018),
        ),
    );

    // Thin steady rim stroke.
    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0xFFCC9920).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0),
    );
  }

  // ── Atmospheric rim glow (Planet) / vignette (Human) ─────────────────────

  void _paintAtmosphere(Canvas canvas, Size size) {
    final r = size.width * 1.10;
    final cx = size.width / 2;
    final cy = size.height + r * 0.695;
    final centre = Offset(cx, cy);

    if (_isHuman) {
      // Warm golden vignette at the bottom to blend into the arc.
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              const Color(0xFF120E00).withValues(alpha: 0.65),
              Colors.transparent,
            ],
            stops: const [0.0, 0.30],
          ).createShader(Offset.zero & size),
      );
      return;
    }

    // Blue atmospheric halo just outside the globe edge.
    canvas.drawCircle(
      centre,
      r * 1.022,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.transparent,
            const Color(0xFF1A5CB8).withValues(alpha: 0.0),
            const Color(0xFF2B80F0).withValues(alpha: 0.16),
            const Color(0xFF60AAFF).withValues(alpha: 0.30),
            const Color(0xFF90CCFF).withValues(alpha: 0.12),
            Colors.transparent,
          ],
          stops: const [0.0, 0.91, 0.95, 0.975, 0.990, 1.0],
        ).createShader(
          Rect.fromCircle(center: centre, radius: r * 1.022),
        ),
    );

    // Thin glowing rim line at the limb edge.
    canvas.drawCircle(
      centre,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..color = const Color(0xFF4499DD).withValues(alpha: 0.40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5),
    );

    // Soft dark vignette rising from the very bottom of the screen so the
    // Earth/space transition feels seamless.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            const Color(0xFF050F22).withValues(alpha: 0.60),
            Colors.transparent,
          ],
          stops: const [0.0, 0.30],
        ).createShader(Offset.zero & size),
    );
  }
}

*/
