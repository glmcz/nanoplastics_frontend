import 'package:flutter/material.dart';
import 'dart:ui';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/responsive_config.dart';
import '../widgets/nanosolve_logo.dart';
import '../l10n/app_localizations.dart';
import '../models/onboarding_slide.dart';
import '../services/settings_manager.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late final _GridPatternPainter _gridPatternPainter = _GridPatternPainter();
  late final _LightStreaksPainter _lightStreaksPainter = _LightStreaksPainter();

  List<OnboardingSlide> _getSlides(AppLocalizations l10n) {
    return [
      OnboardingSlide(
        imagePath: 'assets/onboarding/slide1_ocean_plastic.jpg',
        title: l10n.onboardingTitle1,
        titleHighlight: l10n.onboardingHighlight1,
        description: l10n.onboardingDescription1,
      ),
      OnboardingSlide(
        imagePath: 'assets/onboarding/slide2_missions.jpg',
        title: l10n.onboardingTitle2,
        titleHighlight: l10n.onboardingHighlight2,
        description: l10n.onboardingDescription2,
      ),
      OnboardingSlide(
        imagePath: 'assets/onboarding/slide3_collaboration.jpg',
        title: l10n.onboardingTitle3,
        titleHighlight: l10n.onboardingHighlight3,
        description: l10n.onboardingDescription3,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    final l10n = AppLocalizations.of(context)!;
    final slides = _getSlides(l10n);
    if (_currentPage < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _closeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _closeOnboarding() async {
    print('DEBUG: _closeOnboarding called');
    // Mark onboarding as shown
    await SettingsManager().setOnboardingShown(true);
    print('DEBUG: Onboarding marked as shown, navigating to MainScreen');

    _animationController.reverse().then((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Base animated gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topLeft,
                radius: 2.0,
                colors: [
                  Color(0xFF1A1F2E),
                  Color(0xFF0A0A12),
                  Color(0xFF050508),
                ],
              ),
            ),
          ),

          // Aurora-style gradient overlay
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.pastelAqua.withValues(alpha: 0.05),
                    Colors.transparent,
                    AppColors.pastelMint.withValues(alpha: 0.05),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Large top-left orb with gradient
          Positioned(
            top: -200,
            left: -200,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.pastelAqua.withValues(alpha: 0.25),
                    AppColors.pastelAqua.withValues(alpha: 0.15),
                    AppColors.pastelMint.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Bottom-right large orb
          Positioned(
            bottom: -250,
            right: -200,
            child: Container(
              width: 700,
              height: 700,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.pastelMint.withValues(alpha: 0.22),
                    AppColors.pastelAqua.withValues(alpha: 0.12),
                    AppColors.pastelMint.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Middle-left accent orb
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.pastelAqua.withValues(alpha: 0.18),
                    AppColors.pastelMint.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Top-right small accent
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            right: 80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.pastelMint.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Diagonal light streaks
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _lightStreaksPainter,
              ),
            ),
          ),

          // Refined grid pattern
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _gridPatternPainter,
              ),
            ),
          ),

          // Light blur for dreamy effect
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF0A0A12).withValues(alpha: 0.1),
                    Colors.transparent,
                    const Color(0xFF0A0A12).withValues(alpha: 0.15),
                  ],
                ),
              ),
            ),
          ),

          // Modal overlay
          FadeTransition(
            opacity: _fadeAnimation,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(AppConstants.space20),
                    constraints: const BoxConstraints(maxWidth: 550),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF141928).withValues(alpha: 0.75),
                          const Color(0xFF0F1419).withValues(alpha: 0.8),
                          const Color(0xFF141928).withValues(alpha: 0.75),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusXXL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.pastelAqua.withValues(alpha: 0.1),
                          blurRadius: 40,
                          spreadRadius: 0,
                          offset: const Offset(0, 20),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 30,
                          spreadRadius: 0,
                          offset: const Offset(0, 30),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusXXL),
                      child: Builder(
                        builder: (context) {
                          final responsive =
                              ResponsiveConfig.fromMediaQuery(context);
                          final config = responsive.getOnboardingSlideConfig();
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildModalHeader(),
                              SizedBox(height: config.sectionSpacing),
                              Flexible(child: _buildSlidesContainer()),
                              SizedBox(height: config.sectionSpacing),
                              _buildModalFooter(),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalHeader() {
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final config = responsive.getOnboardingSlideConfig();

    return Padding(
      padding: EdgeInsets.all(config.headerPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: NanosolveLogo(height: AppConstants.logoMedium),
            ),
          ),
          IconButton(
            onPressed: _closeOnboarding,
            icon: const Icon(Icons.close, size: 32),
            color: AppColors.textMuted,
            hoverColor: AppColors.pastelAqua,
          ),
        ],
      ),
    );
  }

  Widget _buildSlidesContainer() {
    final l10n = AppLocalizations.of(context)!;
    final slides = _getSlides(l10n);
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final config = responsive.getOnboardingSlideConfig();

    return LayoutBuilder(
      builder: (context, constraints) {
        final slideHeight = (constraints.maxHeight * config.slideHeightPercent)
            .clamp(config.minSlideHeight, config.maxSlideHeight);
        return SizedBox(
          height: slideHeight,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: slides.length,
            itemBuilder: (context, index) {
              return _buildSlide(slides[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final config = responsive.getOnboardingSlideConfig();

    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * config.imageHeightPercent;
    final iconContainerSize = imageHeight * config.iconRatio;
    final iconSize = iconContainerSize * config.iconSizeMultiplier;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.space12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Media - Image or Icon
          Flexible(
            flex: 2,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: imageHeight),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
                  child: slide.imagePath != null
                      ? Image.asset(
                          slide.imagePath!,
                          fit: BoxFit.cover,
                        )
                      : Center(
                          child: Container(
                            width: iconContainerSize,
                            height: iconContainerSize,
                            decoration: BoxDecoration(
                              color:
                                  AppColors.pastelAqua.withValues(alpha: 0.8),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.pastelAqua
                                      .withValues(alpha: 0.5),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: slide.icon != null
                                ? Icon(
                                    slide.icon,
                                    size: iconSize,
                                    color: const Color(0xFF0A0A12),
                                  )
                                : null,
                          ),
                        ),
                ),
              ),
            ),
          ),
          SizedBox(height: config.spacing * 1.5),

          // Title with highlight using ShaderMask
          Flexible(
            flex: 2,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.pastelAqua, AppColors.pastelMint],
              ).createShader(bounds),
              child: RichText(
                textAlign: TextAlign.center,
                maxLines: 4,
                text: TextSpan(
                  style: config.titleStyle,
                  children: [
                    TextSpan(
                      text: '${slide.title} ',
                      style: const TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: slide.titleHighlight,
                      style: const TextStyle(color: Colors.white),
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

  Widget _buildModalFooter() {
    final l10n = AppLocalizations.of(context)!;
    final slides = _getSlides(l10n);
    final responsive = ResponsiveConfig.fromMediaQuery(context);
    final config = responsive.getOnboardingSlideConfig();

    return Padding(
      padding: EdgeInsets.all(config.footerPadding),
      child: Column(
        children: [
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin:
                    const EdgeInsets.symmetric(horizontal: AppConstants.space4),
                width: _currentPage == index ? 25.0 : 10.0,
                height: 10.0,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.pastelAqua
                      : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.space20),

          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 80,
                child: _currentPage > 0
                    ? TextButton(
                        onPressed: _previousPage,
                        child: Text(
                          l10n.onboardingBack,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.transparent,
                  shadowColor: AppColors.pastelAqua.withValues(alpha: 0.5),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.pastelAqua, AppColors.pastelMint],
                    ),
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMedium),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.space24,
                      vertical: AppConstants.space12,
                    ),
                    child: Text(
                      _currentPage == slides.length - 1
                          ? l10n.onboardingStart
                          : l10n.onboardingNext,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0A0A12),
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom painter for subtle grid pattern
class _GridPatternPainter extends CustomPainter {
  final Paint _paint = Paint()
    ..color = Colors.white.withValues(alpha: 0.02)
    ..strokeWidth = 0.5
    ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    const spacing = 100.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        _paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(_GridPatternPainter oldDelegate) => false;
}

// Custom painter for diagonal light streaks
class _LightStreaksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.0),
          Colors.white.withValues(alpha: 0.03),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw diagonal streaks
    final streakCount = 4;
    final spacing = size.width / streakCount;

    for (int i = 0; i < streakCount; i++) {
      final x = i * spacing;
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x + size.height * 0.3, size.height);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LightStreaksPainter oldDelegate) => false;
}
