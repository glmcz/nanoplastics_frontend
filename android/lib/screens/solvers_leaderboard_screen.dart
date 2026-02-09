import 'package:flutter/material.dart';
import 'dart:ui';
import '../l10n/app_localizations.dart';
import '../config/app_colors.dart';
import '../config/app_constants.dart';
import '../utils/responsive_config.dart';
import '../widgets/nanosolve_logo.dart';
import '../widgets/header_back_button.dart';
import '../services/settings_manager.dart';
import '../services/api_service.dart';
import '../models/solver.dart';
import 'user_settings/profile_registration_dialog.dart';

class SolversLeaderboardScreen extends StatefulWidget {
  const SolversLeaderboardScreen({super.key});

  @override
  State<SolversLeaderboardScreen> createState() =>
      _SolversLeaderboardScreenState();
}

class _SolversLeaderboardScreenState extends State<SolversLeaderboardScreen> {
  late bool _userIsRegistered;
  late bool _userHasEmailAndBio;
  final _settingsManager = SettingsManager();
  Future<List<Solver>>? _solversFuture;

  @override
  void initState() {
    super.initState();
    _checkUserRegistration();
    _loadSolvers();
  }

  void _loadSolvers() {
    setState(() {
      _solversFuture = ApiService.getTopSolvers();
    });
  }

  void _checkUserRegistration() {
    _userIsRegistered = _settingsManager.isProfileRegistered;
    final displayName = _settingsManager.displayName.trim();
    final email = _settingsManager.email.trim();
    _userHasEmailAndBio = displayName.isNotEmpty && email.isNotEmpty;
  }

  void _showRegistrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ProfileRegistrationDialog(
        onProfileShared: () {
          setState(() {
            _checkUserRegistration();
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [
              AppColors.pastelMint.withValues(alpha: 0.08),
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
              Expanded(
                child: _buildLeaderboard(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppConstants.space24),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.9),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                HeaderBackButton(
                  label: l10n.resultsBackButton,
                  color: AppColors.pastelMint,
                  showArrow: true,
                ),
                const Icon(
                  Icons.emoji_events,
                  size: AppConstants.iconMedium,
                  color: AppColors.pastelMint,
                ),
              ],
            ),
            const SizedBox(height: AppConstants.space16),
            NanosolveLogo(
              height: ResponsiveConfig.fromMediaQuery(context)
                  .getSecondaryHeaderConfig()
                  .logoHeight,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Check if user has access to leaderboard
    if (!_userIsRegistered || !_userHasEmailAndBio) {
      return _buildRestrictedAccessView(context, l10n);
    }

    return RefreshIndicator(
      color: AppColors.pastelMint,
      backgroundColor: const Color(0xFF1A1F2E),
      onRefresh: () async {
        _loadSolvers();
        await _solversFuture;
      },
      child: FutureBuilder<List<Solver>>(
        future: _solversFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.pastelMint,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.space24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: AppConstants.iconLarge,
                      color: AppColors.pastelMint.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppConstants.space16),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.space24),
                    ElevatedButton.icon(
                      onPressed: _loadSolvers,
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.resultsBackButton),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pastelMint,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          final solvers = snapshot.data ?? [];

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.space24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(context),
                const SizedBox(height: AppConstants.space24),
                ...solvers.map((solver) => _buildSolverCard(solver)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestrictedAccessView(
      BuildContext context, AppLocalizations l10n) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleSection(context),
          const SizedBox(height: AppConstants.space40),
          // Locked icon
          Center(
            child: Container(
              width: AppConstants.avatarMedium,
              height: AppConstants.avatarMedium,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.pastelMint.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.lock,
                size: AppConstants.iconLarge,
                color: AppColors.pastelMint,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.space30),
          // Main message
          Center(
            child: Text(
              'Leaderboard Access Restricted',
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppConstants.space12),
          // Description
          Center(
            child: Text(
              'Register with your email and name to view the top 10 leaderboard and be recognized for your solutions.',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: AppColors.textMuted,
                  ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: AppConstants.space40),
          // CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _showRegistrationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.pastelMint,
                padding:
                    const EdgeInsets.symmetric(vertical: AppConstants.space16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMedium),
                ),
              ),
              icon: const Icon(
                Icons.app_registration,
                color: Colors.black,
              ),
              label: Text(
                'Register Now',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: Colors.black,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [AppColors.pastelMint, AppColors.pastelAqua],
          ).createShader(bounds),
          child: Text(
            l10n.leaderboardTitle,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          l10n.leaderboardSubtitle,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSolverCard(Solver solver) {
    final int rank = solver.rank;
    final bool isTopThree = rank <= 3;

    Color getRankColor() {
      if (rank == 1) return const Color(0xFFFFD700); // Gold
      if (rank == 2) return const Color(0xFFC0C0C0); // Silver
      if (rank == 3) return const Color(0xFFCD7F32); // Bronze
      return AppColors.pastelMint;
    }

    // Generate avatar emoji based on specialty
    String getAvatar() {
      const avatars = [
        '🧪',
        '🔬',
        '🧬',
        '⚗️',
        '🔭',
        '🧫',
        '🌊',
        '⚛️',
        '🔍',
        '🌱'
      ];
      return avatars[rank - 1];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.space12),
      padding: const EdgeInsets.all(AppConstants.space16),
      decoration: BoxDecoration(
        color: const Color(0xFF141928).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: isTopThree
              ? getRankColor().withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: isTopThree ? 2 : 1,
        ),
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: getRankColor().withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: AppConstants.avatarXS,
            height: AppConstants.avatarXS,
            decoration: BoxDecoration(
              color: getRankColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              border: Border.all(
                color: getRankColor().withValues(alpha: 0.5),
              ),
            ),
            child: Center(
              child: Text(
                '#$rank',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w900,
                      color: getRankColor(),
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.space16),
          // Avatar
          Container(
            width: AppConstants.avatarXS,
            height: AppConstants.avatarXS,
            decoration: BoxDecoration(
              color: AppColors.pastelLavender.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
            child: Center(
              child: Text(
                getAvatar(),
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.space16),
          // Name and contributions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        solver.name,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                            ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.space4),
                Row(
                  children: [
                    const Icon(
                      Icons.verified_outlined,
                      size: AppConstants.iconSmall,
                      color: AppColors.pastelAqua,
                    ),
                    const SizedBox(width: AppConstants.space4),
                    Expanded(
                      child: Text(
                        '${solver.solutionsCount} realized solutions',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.space4),
                Text(
                  solver.specialty,
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: AppColors.pastelMint.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Trophy for top 3
          if (isTopThree)
            Icon(
              Icons.emoji_events,
              size: AppConstants.iconMedium,
              color: getRankColor(),
            ),
        ],
      ),
    );
  }
}
