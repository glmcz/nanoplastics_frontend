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
          // Background simulation (blurred)
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.0,
                colors: [
                  AppColors.pastelAqua.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: const Color(0xFF0A0A12).withValues(alpha: 0.6),
              ),
            ),
          ),

          // Modal overlay
          FadeTransition(
            opacity: _fadeAnimation,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                color: const Color(0xFF0A0A12).withValues(alpha: 0.6),
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(AppConstants.space20),
                    constraints: const BoxConstraints(maxWidth: 550),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141928).withValues(alpha: 0.85),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 0,
                          offset: const Offset(0, 30),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusXXL),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildModalHeader(),
                          Flexible(child: _buildSlidesContainer()),
                          _buildModalFooter(),
                        ],
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
    return Padding(
      padding: const EdgeInsets.all(AppConstants.space30),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        const minHeight = 280.0;
        final slideHeight =
            (constraints.maxHeight * 0.5).clamp(minHeight, 450.0);
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
            flex: 3,
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
          SizedBox(height: config.spacing),

          // Title with highlight using ShaderMask
          Flexible(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppColors.pastelAqua, AppColors.pastelMint],
              ).createShader(bounds),
              child: RichText(
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
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
          SizedBox(height: config.spacing),

          // Description
          Flexible(
            child: Text(
              slide.description,
              textAlign: TextAlign.center,
              style: config.descStyle?.copyWith(
                color: AppColors.textRed,
              ),
              maxLines: screenHeight < 400 ? 3 : 5,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModalFooter() {
    final l10n = AppLocalizations.of(context)!;
    final slides = _getSlides(l10n);
    return Padding(
      padding: const EdgeInsets.all(AppConstants.space30),
      child: Column(
        children: [
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              slides.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.space4),
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
              if (_currentPage > 0)
                TextButton(
                  onPressed: _previousPage,
                  child: Text(
                    l10n.onboardingBack,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                )
              else
                const SizedBox(),
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
