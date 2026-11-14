// Reads Roboto from the Flutter SDK with dart:io, which Chrome can't: CI runs
// this file on the VM in its own step of flutter-release.yaml.
@TestOn('vm')
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoplastics_app/l10n/app_localizations.dart';
import 'package:nanoplastics_app/models/category_detail_data.dart';
import 'package:nanoplastics_app/models/digest_paper.dart';
import 'package:nanoplastics_app/screens/category_detail_new_screen.dart';
import 'package:nanoplastics_app/screens/category_evidence_screen.dart';
import 'package:nanoplastics_app/screens/digest_settings_screen.dart';
import 'package:nanoplastics_app/screens/main_screen.dart';
import 'package:nanoplastics_app/screens/onboarding_screen.dart';
import 'package:nanoplastics_app/screens/paper_detail_screen.dart';
import 'package:nanoplastics_app/screens/solver_ideas_screen.dart';
import 'package:nanoplastics_app/screens/solvers_leaderboard_screen.dart';
import 'package:nanoplastics_app/screens/sources_screen.dart';
import 'package:nanoplastics_app/screens/user_settings/about_screen.dart';
import 'package:nanoplastics_app/screens/user_settings/language_screen.dart';
import 'package:nanoplastics_app/screens/user_settings/privacy_policy_screen.dart';
import 'package:nanoplastics_app/screens/user_settings/privacy_security_screen.dart';
import 'package:nanoplastics_app/screens/user_settings/terms_of_service_screen.dart';
import 'package:nanoplastics_app/screens/user_settings/user_profile.dart';
import 'package:nanoplastics_app/screens/user_settings/user_settings_screen.dart';
import 'package:nanoplastics_app/screens/vault_screen.dart';
import 'package:nanoplastics_app/services/digest_service.dart';
import '../helpers/fake_digest_service.dart';
import '../helpers/real_fonts.dart';
import '../helpers/responsive_test_helper.dart';
import '../helpers/settings_test_helper.dart';
import '../helpers/test_app.dart';

// Android lets users raise the system font size to 200%. Every screen must lay
// out at that size in every language, measured with the font a phone draws.
// A Text inside a Row without Flexible is what breaks: Russian did at 130%.

const _paper = DigestPaper(
  id: 'p1',
  title: 'Surface charge governs the uptake of polystyrene nanoplastics by '
      'human intestinal epithelial cells',
  perex: 'Negatively charged 50 nm particles crossed the barrier three times '
      'faster than neutral ones in a Caco-2 model.',
  category: 'Human Health',
  subcategory: 'Central systems',
  labels: ['nanoplastics', 'surface charge', 'uptake'],
  matchedKeywords: ['nanoplastics', 'zeta potential'],
  sourceUrl: 'https://doi.org/10.1000/example',
  publishedDate: '2026-10-02',
  doi: '10.1000/example',
  authors: 'A. Novak, B. Svoboda, C. Dvorak',
  journal: 'Environmental Science & Technology',
  source: 'pubmed',
);

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    await loadRealFonts();
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  // CategoryDetail runs a repeating animation and never settles: one frame is
  // enough for an overflow to show.
  final screens = <String, ({Widget Function() build, bool settles})>{
    'Main': (build: () => const MainScreen(), settles: true),
    'Onboarding': (build: () => const OnboardingScreen(), settles: true),
    'CategoryDetail': (
      build: () => CategoryDetailNewScreen(
          categoryData: CategoryDetailDataFactory.centralSystems(l10n)),
      settles: false
    ),
    'Evidence': (
      build: () => CategoryEvidenceScreen(
          categoryData: CategoryDetailDataFactory.worldOcean(l10n)),
      settles: false
    ),
    'Vault': (build: () => const VaultScreen(), settles: true),
    'PaperDetail': (
      build: () => const PaperDetailScreen(paper: _paper),
      settles: true
    ),
    'DigestSettings': (
      build: () => const DigestSettingsScreen(),
      settles: true
    ),
    'Sources': (build: () => const SourcesScreen(), settles: true),
    'Leaderboard': (
      build: () => const SolversLeaderboardScreen(),
      settles: true
    ),
    'SolverIdeas': (
      build: () => const SolverIdeasScreen(solverName: 'Marie Curie', rank: 2),
      settles: true
    ),
    'UserSettings': (build: () => const UserSettingsScreen(), settles: true),
    'UserProfile': (build: () => const UserProfileScreen(), settles: true),
    'PrivacySecurity': (
      build: () => const PrivacySecurityScreen(),
      settles: true
    ),
    'About': (build: () => const AboutScreen(), settles: true),
    'Language': (build: () => const LanguageScreen(), settles: true),
    'PrivacyPolicy': (build: () => const PrivacyPolicyScreen(), settles: true),
    'Terms': (build: () => const TermsOfServiceScreen(), settles: true),
  };

  for (final MapEntry(key: name, value: screen) in screens.entries) {
    group(name, () {
      for (final device in [kSmallBoundary, kMotoG32]) {
        for (final locale in AppLocalizations.supportedLocales) {
          for (final scale in [1.0, 2.0]) {
            testWidgets('fits $device, $locale, text ${scale}x',
                (tester) async {
              await setupServiceLocator({
                'email': 'test@example.com',
                'onboarding_shown': name != 'Onboarding',
              });
              DigestService.overrideForTesting(FakeDigestService());
              addTearDown(() => DigestService.overrideForTesting(null));
              setScreenSize(tester, device);

              await tester.pumpWidget(buildTestableWidget(screen.build(),
                  locale: locale, textScaleFactor: scale));
              if (screen.settles) {
                await tester.pumpAndSettle();
              } else {
                await tester.pump();
              }
            });
          }
        }
      }
    });
  }
}
