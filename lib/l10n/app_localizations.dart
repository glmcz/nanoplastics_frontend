import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_cs.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('cs'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NANOSOLVE'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'SCIENCE, SOCIETY, FUTURE'**
  String get appSubtitle;

  /// No description provided for @tabHuman.
  ///
  /// In en, this message translates to:
  /// **'HUMANS'**
  String get tabHuman;

  /// No description provided for @tabPlanet.
  ///
  /// In en, this message translates to:
  /// **'PLANET'**
  String get tabPlanet;

  /// No description provided for @navSources.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get navSources;

  /// No description provided for @navResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get navResults;

  /// No description provided for @humanCategoryCentralSystems.
  ///
  /// In en, this message translates to:
  /// **'Central Systems'**
  String get humanCategoryCentralSystems;

  /// No description provided for @humanCategoryCentralSystemsDesc.
  ///
  /// In en, this message translates to:
  /// **'Nervous, circulatory'**
  String get humanCategoryCentralSystemsDesc;

  /// No description provided for @humanCategoryFiltrationDetox.
  ///
  /// In en, this message translates to:
  /// **'Filtration & Detox'**
  String get humanCategoryFiltrationDetox;

  /// No description provided for @humanCategoryFiltrationDetoxDesc.
  ///
  /// In en, this message translates to:
  /// **'Kidneys, liver, lymph'**
  String get humanCategoryFiltrationDetoxDesc;

  /// No description provided for @humanCategoryVitalityTissue.
  ///
  /// In en, this message translates to:
  /// **'Vitality & Tissue'**
  String get humanCategoryVitalityTissue;

  /// No description provided for @humanCategoryVitalityTissueDesc.
  ///
  /// In en, this message translates to:
  /// **'Lungs, skin'**
  String get humanCategoryVitalityTissueDesc;

  /// No description provided for @humanCategoryReproduction.
  ///
  /// In en, this message translates to:
  /// **'Reproduction'**
  String get humanCategoryReproduction;

  /// No description provided for @humanCategoryReproductionDesc.
  ///
  /// In en, this message translates to:
  /// **'Hormones, cells'**
  String get humanCategoryReproductionDesc;

  /// No description provided for @humanCategoryEntryGates.
  ///
  /// In en, this message translates to:
  /// **'Entry Gates'**
  String get humanCategoryEntryGates;

  /// No description provided for @humanCategoryEntryGatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Skin, breathing, diet'**
  String get humanCategoryEntryGatesDesc;

  /// No description provided for @humanCategoryWaysOfDesctruction.
  ///
  /// In en, this message translates to:
  /// **'Ways of Destruction'**
  String get humanCategoryWaysOfDesctruction;

  /// No description provided for @humanCategoryWaysOfDesctructionDesc.
  ///
  /// In en, this message translates to:
  /// **'Known forms of destruction'**
  String get humanCategoryWaysOfDesctructionDesc;

  /// No description provided for @planetCategoryWorldOcean.
  ///
  /// In en, this message translates to:
  /// **'Hydrosphere'**
  String get planetCategoryWorldOcean;

  /// No description provided for @planetCategoryWorldOceanDesc.
  ///
  /// In en, this message translates to:
  /// **'Marine life, water'**
  String get planetCategoryWorldOceanDesc;

  /// No description provided for @planetCategoryAtmosphere.
  ///
  /// In en, this message translates to:
  /// **'Atmosphere'**
  String get planetCategoryAtmosphere;

  /// No description provided for @planetCategoryAtmosphereDesc.
  ///
  /// In en, this message translates to:
  /// **'Air, climate'**
  String get planetCategoryAtmosphereDesc;

  /// No description provided for @planetCategoryFloraFauna.
  ///
  /// In en, this message translates to:
  /// **'Flora & Fauna'**
  String get planetCategoryFloraFauna;

  /// No description provided for @planetCategoryFloraFaunaDesc.
  ///
  /// In en, this message translates to:
  /// **'Plants, animals'**
  String get planetCategoryFloraFaunaDesc;

  /// No description provided for @planetCategoryMagneticField.
  ///
  /// In en, this message translates to:
  /// **'Magnetic Field and Earth core'**
  String get planetCategoryMagneticField;

  /// No description provided for @planetCategoryMagneticFieldDesc.
  ///
  /// In en, this message translates to:
  /// **'Core abnormalities'**
  String get planetCategoryMagneticFieldDesc;

  /// No description provided for @planetCategoryEntryGates.
  ///
  /// In en, this message translates to:
  /// **'Entry Gates'**
  String get planetCategoryEntryGates;

  /// No description provided for @planetCategoryEntryGatesDesc.
  ///
  /// In en, this message translates to:
  /// **'Industry, waste'**
  String get planetCategoryEntryGatesDesc;

  /// No description provided for @planetCategoryPhysicalProperties.
  ///
  /// In en, this message translates to:
  /// **'Physical Properties'**
  String get planetCategoryPhysicalProperties;

  /// No description provided for @planetCategoryPhysicalPropertiesDesc.
  ///
  /// In en, this message translates to:
  /// **'Soil, water, air'**
  String get planetCategoryPhysicalPropertiesDesc;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'This is reality. We want to change it. But we need your brain.'**
  String get onboardingTitle1;

  /// No description provided for @onboardingHighlight1.
  ///
  /// In en, this message translates to:
  /// **''**
  String get onboardingHighlight1;

  /// No description provided for @onboardingDescription1.
  ///
  /// In en, this message translates to:
  /// **''**
  String get onboardingDescription1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Choose one of the battlefields, join in, and find a solution.'**
  String get onboardingTitle2;

  /// No description provided for @onboardingHighlight2.
  ///
  /// In en, this message translates to:
  /// **''**
  String get onboardingHighlight2;

  /// No description provided for @onboardingDescription2.
  ///
  /// In en, this message translates to:
  /// **''**
  String get onboardingDescription2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Be one of us, and inspire others.'**
  String get onboardingTitle3;

  /// No description provided for @onboardingHighlight3.
  ///
  /// In en, this message translates to:
  /// **''**
  String get onboardingHighlight3;

  /// No description provided for @onboardingDescription3.
  ///
  /// In en, this message translates to:
  /// **''**
  String get onboardingDescription3;

  /// No description provided for @onboardingNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardingNext;

  /// No description provided for @onboardingPrevious.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingPrevious;

  /// No description provided for @onboardingStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get onboardingStart;

  /// No description provided for @onboardingSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardingSkip;

  /// No description provided for @onboardingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get onboardingBack;

  /// No description provided for @categoryDetailBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get categoryDetailBack;

  /// No description provided for @categoryDetailBackToOverview.
  ///
  /// In en, this message translates to:
  /// **'BACK'**
  String get categoryDetailBackToOverview;

  /// No description provided for @categoryDetailBrainstorm.
  ///
  /// In en, this message translates to:
  /// **'Brainstorm'**
  String get categoryDetailBrainstorm;

  /// No description provided for @categoryDetailLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get categoryDetailLibrary;

  /// No description provided for @categoryDetailIdeas.
  ///
  /// In en, this message translates to:
  /// **'Ideas'**
  String get categoryDetailIdeas;

  /// No description provided for @categoryDetailResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get categoryDetailResults;

  /// No description provided for @categoryDetailBrainstormTitle.
  ///
  /// In en, this message translates to:
  /// **'Your idea for this topic'**
  String get categoryDetailBrainstormTitle;

  /// No description provided for @categoryDetailBrainstormUser.
  ///
  /// In en, this message translates to:
  /// **'@NanoSolver'**
  String get categoryDetailBrainstormUser;

  /// No description provided for @categoryDetailBrainstormPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Describe your idea, hypothesis or observation here...'**
  String get categoryDetailBrainstormPlaceholder;

  /// No description provided for @categoryDetailBrainstormSubmit.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT FOR EVALUATION'**
  String get categoryDetailBrainstormSubmit;

  /// No description provided for @categoryDetailBrainstormSuccess.
  ///
  /// In en, this message translates to:
  /// **'Idea submitted for evaluation!'**
  String get categoryDetailBrainstormSuccess;

  /// No description provided for @categoryDetailBrainstormError.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit (due to internet issue). Your idea has been saved as a draft.'**
  String get categoryDetailBrainstormError;

  /// No description provided for @categoryDetailBrainstormEditUsername.
  ///
  /// In en, this message translates to:
  /// **'Edit username'**
  String get categoryDetailBrainstormEditUsername;

  /// No description provided for @categoryDetailBrainstormUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get categoryDetailBrainstormUsernameHint;

  /// No description provided for @categoryDetailBrainstormCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get categoryDetailBrainstormCancel;

  /// No description provided for @categoryDetailBrainstormSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get categoryDetailBrainstormSave;

  /// No description provided for @categoryDetailBrainstormMinLength.
  ///
  /// In en, this message translates to:
  /// **'Please write at least 10 characters.'**
  String get categoryDetailBrainstormMinLength;

  /// No description provided for @categoryDetailSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Related Sources'**
  String get categoryDetailSourcesTitle;

  /// No description provided for @categoryDetailSourcesCount.
  ///
  /// In en, this message translates to:
  /// **'sources'**
  String get categoryDetailSourcesCount;

  /// No description provided for @sourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Sources'**
  String get sourcesTitle;

  /// No description provided for @sourcesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Library and educational materials'**
  String get sourcesSubtitle;

  /// No description provided for @resultsTitle.
  ///
  /// In en, this message translates to:
  /// **'ANALYSIS RESULTS'**
  String get resultsTitle;

  /// No description provided for @resultsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Mathematical evaluation of ideas and solutions'**
  String get resultsSubtitle;

  /// No description provided for @sourcesMainReportLabel.
  ///
  /// In en, this message translates to:
  /// **'⭐ MAIN REPORT (2025)'**
  String get sourcesMainReportLabel;

  /// No description provided for @sourcesMainReportTitle.
  ///
  /// In en, this message translates to:
  /// **'NANOPLASTICS IN THE BIOSPHERE, FROM MOLECULAR IMPACT TO PLANETARY CRISIS'**
  String get sourcesMainReportTitle;

  /// No description provided for @sourcesMainReportUrl.
  ///
  /// In en, this message translates to:
  /// **'https://allatra.org/storage/app/media/reports/en/Nanoplastics_in_the_Biosphere_Report.pdf'**
  String get sourcesMainReportUrl;

  /// No description provided for @sourcesBack.
  ///
  /// In en, this message translates to:
  /// **'← BACK'**
  String get sourcesBack;

  /// No description provided for @sourcesTabWeb.
  ///
  /// In en, this message translates to:
  /// **'A. WEB LINKS'**
  String get sourcesTabWeb;

  /// No description provided for @sourcesTabVideo.
  ///
  /// In en, this message translates to:
  /// **'B. VIDEO LINKS'**
  String get sourcesTabVideo;

  /// No description provided for @sourcesSectionHumanHealth.
  ///
  /// In en, this message translates to:
  /// **'I: Nanoplastics & Human Health'**
  String get sourcesSectionHumanHealth;

  /// No description provided for @sourcesSectionEarthPollution.
  ///
  /// In en, this message translates to:
  /// **'II: Earth & Plastic Pollution'**
  String get sourcesSectionEarthPollution;

  /// No description provided for @sourcesSectionWaterAbilities.
  ///
  /// In en, this message translates to:
  /// **'III: Specific Water Abilities'**
  String get sourcesSectionWaterAbilities;

  /// No description provided for @sourcesSectionVideoContent.
  ///
  /// In en, this message translates to:
  /// **'B. Documentary & Expert Content'**
  String get sourcesSectionVideoContent;

  /// No description provided for @videoLink1Title.
  ///
  /// In en, this message translates to:
  /// **'Nanoplastics. Threat to Life | ALLATRA Documentary'**
  String get videoLink1Title;

  /// No description provided for @videoLink1Source.
  ///
  /// In en, this message translates to:
  /// **'ALLATRA Documentary'**
  String get videoLink1Source;

  /// No description provided for @videoLink1Url.
  ///
  /// In en, this message translates to:
  /// **'https://youtu.be/BVap0MdbCZg?list=PL4b5lQBqqnUGsIhduDunOHm0gcSnrr8AT'**
  String get videoLink1Url;

  /// No description provided for @videoLink2Title.
  ///
  /// In en, this message translates to:
  /// **'Trap for Humanity | Popular Science Film'**
  String get videoLink2Title;

  /// No description provided for @videoLink2Source.
  ///
  /// In en, this message translates to:
  /// **'Popular Science Film'**
  String get videoLink2Source;

  /// No description provided for @videoLink2Url.
  ///
  /// In en, this message translates to:
  /// **'https://youtu.be/NBbbqRzzQGY?list=PL4b5lQBqqnUGsIhduDunOHm0gcSnrr8AT'**
  String get videoLink2Url;

  /// No description provided for @videoLink3Title.
  ///
  /// In en, this message translates to:
  /// **'Anthropogenic Factor in the Ocean\'s Demise | Popular Science Film'**
  String get videoLink3Title;

  /// No description provided for @videoLink3Source.
  ///
  /// In en, this message translates to:
  /// **'Popular Science Film'**
  String get videoLink3Source;

  /// No description provided for @videoLink3Url.
  ///
  /// In en, this message translates to:
  /// **'https://youtu.be/CDWrsgX4syc?list=PL4b5lQBqqnUGsIhduDunOHm0gcSnrr8AT'**
  String get videoLink3Url;

  /// No description provided for @videoLink4Title.
  ///
  /// In en, this message translates to:
  /// **'What Destroys You on a Quantum Level?'**
  String get videoLink4Title;

  /// No description provided for @videoLink4Source.
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get videoLink4Source;

  /// No description provided for @videoLink4Url.
  ///
  /// In en, this message translates to:
  /// **'https://youtu.be/0CBfe7w8oUU'**
  String get videoLink4Url;

  /// No description provided for @videoLink5Title.
  ///
  /// In en, this message translates to:
  /// **'Nanoplastics. The Last Generation Has Already Been Born'**
  String get videoLink5Title;

  /// No description provided for @videoLink5Source.
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get videoLink5Source;

  /// No description provided for @videoLink5Url.
  ///
  /// In en, this message translates to:
  /// **'https://youtu.be/qsarcxl1jls'**
  String get videoLink5Url;

  /// No description provided for @videoLink6Title.
  ///
  /// In en, this message translates to:
  /// **'ALLATRA at UN Summit COP16 | Climate Crisis and Ocean Pollution Documentary'**
  String get videoLink6Title;

  /// No description provided for @videoLink6Source.
  ///
  /// In en, this message translates to:
  /// **'Climate Crisis Documentary'**
  String get videoLink6Source;

  /// No description provided for @videoLink6Url.
  ///
  /// In en, this message translates to:
  /// **'https://youtu.be/0DNempKykno?list=PL4b5lQBqqnUGsIhduDunOHm0gcSnrr8AT'**
  String get videoLink6Url;

  /// No description provided for @detailCentralSystemsTitle.
  ///
  /// In en, this message translates to:
  /// **'Central Systems (Blood, Brain)'**
  String get detailCentralSystemsTitle;

  /// No description provided for @detailCentralSystemsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Trojan horse in the body: barrier penetration, inflammation'**
  String get detailCentralSystemsSubtitle;

  /// No description provided for @detailCentralSystemsEntry1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Aggressiveness: within 2 hours'**
  String get detailCentralSystemsEntry1Highlight;

  /// No description provided for @detailCentralSystemsEntry1Desc.
  ///
  /// In en, this message translates to:
  /// **'Inhaled nanoplastics quickly enter the bloodstream, carry an electrostatic charge and become coated with biomolecules (cholesterol, proteins) in the blood, forming a so-called bio-corona.'**
  String get detailCentralSystemsEntry1Desc;

  /// No description provided for @detailCentralSystemsEntry1Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Trojan horse effect - particle masking'**
  String get detailCentralSystemsEntry1Bullet1;

  /// No description provided for @detailCentralSystemsEntry1Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Blood-brain barrier penetration'**
  String get detailCentralSystemsEntry1Bullet2;

  /// No description provided for @detailCentralSystemsEntry1Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Disruption of neuron function and nerve signals'**
  String get detailCentralSystemsEntry1Bullet3;

  /// No description provided for @detailCentralSystemsEntry2Highlight.
  ///
  /// In en, this message translates to:
  /// **'Brain penetration'**
  String get detailCentralSystemsEntry2Highlight;

  /// No description provided for @detailCentralSystemsEntry2Desc.
  ///
  /// In en, this message translates to:
  /// **'Research shows they cross the blood-brain barrier, penetrate the brain and disrupt neuron function.'**
  String get detailCentralSystemsEntry2Desc;

  /// No description provided for @detailFiltrationDetoxTitle.
  ///
  /// In en, this message translates to:
  /// **'Filtration & Detox (Liver, Kidneys)'**
  String get detailFiltrationDetoxTitle;

  /// No description provided for @detailFiltrationDetoxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Filter overload & metabolic collapse'**
  String get detailFiltrationDetoxSubtitle;

  /// No description provided for @detailFiltrationDetoxEntry1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Aggressiveness: immediately after ingestion'**
  String get detailFiltrationDetoxEntry1Highlight;

  /// No description provided for @detailFiltrationDetoxEntry1Desc.
  ///
  /// In en, this message translates to:
  /// **'70% of the immune system is located in the intestines. After ingestion, nanoplastics disrupt the intestinal barrier and cause leaky gut syndrome.'**
  String get detailFiltrationDetoxEntry1Desc;

  /// No description provided for @detailFiltrationDetoxEntry1Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Penetration of toxins and pathogens into blood'**
  String get detailFiltrationDetoxEntry1Bullet1;

  /// No description provided for @detailFiltrationDetoxEntry1Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Weakening of the immune system'**
  String get detailFiltrationDetoxEntry1Bullet2;

  /// No description provided for @detailFiltrationDetoxEntry1Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Systemic inflammation'**
  String get detailFiltrationDetoxEntry1Bullet3;

  /// No description provided for @detailFiltrationDetoxEntry2Highlight.
  ///
  /// In en, this message translates to:
  /// **'Organ accumulation'**
  String get detailFiltrationDetoxEntry2Highlight;

  /// No description provided for @detailFiltrationDetoxEntry2Desc.
  ///
  /// In en, this message translates to:
  /// **'Particles accumulate in the liver and kidneys, where they disrupt metabolic processes and detoxification functions.'**
  String get detailFiltrationDetoxEntry2Desc;

  /// No description provided for @detailVitalityTissuesTitle.
  ///
  /// In en, this message translates to:
  /// **'Vitality & Tissues (Heart, Muscles)'**
  String get detailVitalityTissuesTitle;

  /// No description provided for @detailVitalityTissuesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Electric noise and cellular aging'**
  String get detailVitalityTissuesSubtitle;

  /// No description provided for @detailVitalityTissuesEntry1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Mitochondrial dysfunction'**
  String get detailVitalityTissuesEntry1Highlight;

  /// No description provided for @detailVitalityTissuesEntry1Desc.
  ///
  /// In en, this message translates to:
  /// **'Nanoplastics carry an electrostatic charge that is continuously renewed in the body (triboelectric effect).'**
  String get detailVitalityTissuesEntry1Desc;

  /// No description provided for @detailVitalityTissuesEntry1Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Electric noise deforms cellular proteins'**
  String get detailVitalityTissuesEntry1Bullet1;

  /// No description provided for @detailVitalityTissuesEntry1Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Mitochondrial damage'**
  String get detailVitalityTissuesEntry1Bullet2;

  /// No description provided for @detailVitalityTissuesEntry1Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Decreased ATP (cellular energy) production'**
  String get detailVitalityTissuesEntry1Bullet3;

  /// No description provided for @detailVitalityTissuesEntry1Bullet4.
  ///
  /// In en, this message translates to:
  /// **'Premature aging and tissue death'**
  String get detailVitalityTissuesEntry1Bullet4;

  /// No description provided for @detailReproductionTitle.
  ///
  /// In en, this message translates to:
  /// **'Origin & Protection (Reproduction)'**
  String get detailReproductionTitle;

  /// No description provided for @detailReproductionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Genetic damage to future generations'**
  String get detailReproductionSubtitle;

  /// No description provided for @detailReproductionEntry1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Reproductive & genetic damage'**
  String get detailReproductionEntry1Highlight;

  /// No description provided for @detailReproductionEntry1Desc.
  ///
  /// In en, this message translates to:
  /// **'Nanoplastics can penetrate the placental barrier and enter breast milk. They cause DNA damage and mutations in cells.'**
  String get detailReproductionEntry1Desc;

  /// No description provided for @detailReproductionEntry1Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Decreased fertility'**
  String get detailReproductionEntry1Bullet1;

  /// No description provided for @detailReproductionEntry1Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Increased developmental defects'**
  String get detailReproductionEntry1Bullet2;

  /// No description provided for @detailReproductionEntry1Bullet3.
  ///
  /// In en, this message translates to:
  /// **'Thymus disruption in newborns'**
  String get detailReproductionEntry1Bullet3;

  /// No description provided for @detailReproductionEntry1Bullet4.
  ///
  /// In en, this message translates to:
  /// **'Transmission between generations during cell division'**
  String get detailReproductionEntry1Bullet4;

  /// No description provided for @detailEntryGatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Entry Gates (Inhalation, Ingestion)'**
  String get detailEntryGatesTitle;

  /// No description provided for @detailEntryGatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Contamination pathways: air, water, food'**
  String get detailEntryGatesSubtitle;

  /// No description provided for @detailEntryGatesEntry1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Inhalation (breathing)'**
  String get detailEntryGatesEntry1Highlight;

  /// No description provided for @detailEntryGatesEntry1Desc.
  ///
  /// In en, this message translates to:
  /// **'The fastest route – penetration through the lungs directly into the bloodstream.'**
  String get detailEntryGatesEntry1Desc;

  /// No description provided for @detailEntryGatesEntry2Highlight.
  ///
  /// In en, this message translates to:
  /// **'Ingestion (swallowing)'**
  String get detailEntryGatesEntry2Highlight;

  /// No description provided for @detailEntryGatesEntry2Desc.
  ///
  /// In en, this message translates to:
  /// **'Entry through contaminated water, food and beverages.'**
  String get detailEntryGatesEntry2Desc;

  /// No description provided for @detailEntryGatesEntry3Highlight.
  ///
  /// In en, this message translates to:
  /// **'Absorption (skin)'**
  String get detailEntryGatesEntry3Highlight;

  /// No description provided for @detailEntryGatesEntry3Desc.
  ///
  /// In en, this message translates to:
  /// **'Penetration through skin pores upon contact with water or air.'**
  String get detailEntryGatesEntry3Desc;

  /// No description provided for @detailPhysicalAttackTitle.
  ///
  /// In en, this message translates to:
  /// **'Known Ways of Destruction'**
  String get detailPhysicalAttackTitle;

  /// No description provided for @detailPhysicalAttackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Comprehensive overview of negative effects on the organism'**
  String get detailPhysicalAttackSubtitle;

  /// No description provided for @detailPhysicalAttackEntry1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Electrostatic charge'**
  String get detailPhysicalAttackEntry1Highlight;

  /// No description provided for @detailPhysicalAttackEntry1Desc.
  ///
  /// In en, this message translates to:
  /// **'Particles carry a permanent charge that promotes their adhesion to cellular structures.'**
  String get detailPhysicalAttackEntry1Desc;

  /// No description provided for @detailPhysicalAttackEntry2Highlight.
  ///
  /// In en, this message translates to:
  /// **'Electrical interference'**
  String get detailPhysicalAttackEntry2Highlight;

  /// No description provided for @detailPhysicalAttackEntry2Desc.
  ///
  /// In en, this message translates to:
  /// **'The charge can disrupt bioelectric signals and nerve impulses.'**
  String get detailPhysicalAttackEntry2Desc;

  /// No description provided for @detailPhysicalAttackEntry3Highlight.
  ///
  /// In en, this message translates to:
  /// **'Structural deformation'**
  String get detailPhysicalAttackEntry3Highlight;

  /// No description provided for @detailPhysicalAttackEntry3Desc.
  ///
  /// In en, this message translates to:
  /// **'Interaction with proteins can disrupt their spatial structure and hydrogen bonds.'**
  String get detailPhysicalAttackEntry3Desc;

  /// No description provided for @detailWorldOceanTitle.
  ///
  /// In en, this message translates to:
  /// **'World Ocean and Hydrosphere'**
  String get detailWorldOceanTitle;

  /// No description provided for @detailWorldOceanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Physicochemical sabotage & heat accumulation'**
  String get detailWorldOceanSubtitle;

  /// No description provided for @detailWorldOceanEntry1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Disruption of water hydrogen bonds'**
  String get detailWorldOceanEntry1Highlight;

  /// No description provided for @detailWorldOceanEntry1Desc.
  ///
  /// In en, this message translates to:
  /// **'Nanoplastics bind to water molecules & create hydration shells that \'immobilize\' large volumes of water.'**
  String get detailWorldOceanEntry1Desc;

  /// No description provided for @detailWorldOceanEntry1Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Sharp decline in oceans\' ability to dissipate heat'**
  String get detailWorldOceanEntry1Bullet1;

  /// No description provided for @detailWorldOceanEntry1Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Changes in physical properties of seawater'**
  String get detailWorldOceanEntry1Bullet2;

  /// No description provided for @detailAtmosphereTitle.
  ///
  /// In en, this message translates to:
  /// **'Atmosphere & Global Water Cycle'**
  String get detailAtmosphereTitle;

  /// No description provided for @detailAtmosphereSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Atmospheric & hydrological disruption'**
  String get detailAtmosphereSubtitle;

  /// No description provided for @detailAtmosphereEntry1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Low & \'heavy\' clouds'**
  String get detailAtmosphereEntry1Highlight;

  /// No description provided for @detailAtmosphereEntry1Desc.
  ///
  /// In en, this message translates to:
  /// **'Nanoplastics act as aggressive condensation nuclei → formation of low, dense clouds that trap heat and destabilize climate.'**
  String get detailAtmosphereEntry1Desc;

  /// No description provided for @detailFloraFaunaTitle.
  ///
  /// In en, this message translates to:
  /// **'Flora, Fauna & Soil Biota'**
  String get detailFloraFaunaTitle;

  /// No description provided for @detailFloraFaunaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Biological & food chain ecosystem collapse'**
  String get detailFloraFaunaSubtitle;

  /// No description provided for @detailFloraFaunaEntry1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Disruption of bioelectric signals'**
  String get detailFloraFaunaEntry1Highlight;

  /// No description provided for @detailFloraFaunaEntry1Desc.
  ///
  /// In en, this message translates to:
  /// **'Electrostatically charged nanoplastics create \'noise\' that disrupts plant communication (root networks) and insects.'**
  String get detailFloraFaunaEntry1Desc;

  /// No description provided for @detailFloraFaunaEntry1Bullet1.
  ///
  /// In en, this message translates to:
  /// **'Loss of ecosystem adaptation'**
  String get detailFloraFaunaEntry1Bullet1;

  /// No description provided for @detailFloraFaunaEntry1Bullet2.
  ///
  /// In en, this message translates to:
  /// **'Disruption of food chains'**
  String get detailFloraFaunaEntry1Bullet2;

  /// No description provided for @detailFloraFaunaEntry2Highlight.
  ///
  /// In en, this message translates to:
  /// **'Photosynthesis damage'**
  String get detailFloraFaunaEntry2Highlight;

  /// No description provided for @detailFloraFaunaEntry2Desc.
  ///
  /// In en, this message translates to:
  /// **'Nanoplastics physically damage chloroplasts → decreased energy and oxygen production, weakening of primary producers.'**
  String get detailFloraFaunaEntry2Desc;

  /// No description provided for @detailMagneticFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Magnetic Field & Earth\'s Core'**
  String get detailMagneticFieldTitle;

  /// No description provided for @detailMagneticFieldSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Geodynamic & magnetic destabilization'**
  String get detailMagneticFieldSubtitle;

  /// No description provided for @detailMagneticFieldEntry1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Magnetic field destabilization'**
  String get detailMagneticFieldEntry1Highlight;

  /// No description provided for @detailMagneticFieldEntry1Desc.
  ///
  /// In en, this message translates to:
  /// **'Penetration of nanoplastics into geological structures may affect geodynamic processes and Earth\'s magnetic field.'**
  String get detailMagneticFieldEntry1Desc;

  /// No description provided for @detailPlanetEntryGatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Crisis Entry Gates'**
  String get detailPlanetEntryGatesTitle;

  /// No description provided for @detailPlanetEntryGatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Plastic system failure, landfills, water'**
  String get detailPlanetEntryGatesSubtitle;

  /// No description provided for @detailPlanetEntryGatesEntry1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Plastic system failure'**
  String get detailPlanetEntryGatesEntry1Highlight;

  /// No description provided for @detailPlanetEntryGatesEntry1Desc.
  ///
  /// In en, this message translates to:
  /// **'Landfills, oceans and waterways as main sources of nanoplastic contamination.'**
  String get detailPlanetEntryGatesEntry1Desc;

  /// No description provided for @detailPhysicalPropertiesTitle.
  ///
  /// In en, this message translates to:
  /// **'Physical Properties'**
  String get detailPhysicalPropertiesTitle;

  /// No description provided for @detailPhysicalPropertiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Key collapse mechanisms (bonds, signals)'**
  String get detailPhysicalPropertiesSubtitle;

  /// No description provided for @detailPhysicalPropertiesEntry1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Disruption of water hydrogen bonds'**
  String get detailPhysicalPropertiesEntry1Highlight;

  /// No description provided for @detailPhysicalPropertiesEntry1Desc.
  ///
  /// In en, this message translates to:
  /// **'Nanoplastics bind to water molecules and create hydration shells that \'immobilize\' large volumes of water → sharp decline in oceans\' ability to dissipate heat.'**
  String get detailPhysicalPropertiesEntry1Desc;

  /// No description provided for @detailPhysicalPropertiesEntry2Highlight.
  ///
  /// In en, this message translates to:
  /// **'Low and \'heavy\' clouds'**
  String get detailPhysicalPropertiesEntry2Highlight;

  /// No description provided for @detailPhysicalPropertiesEntry2Desc.
  ///
  /// In en, this message translates to:
  /// **'Nanoplastics act as aggressive condensation nuclei → formation of low, dense clouds that trap heat and destabilize climate.'**
  String get detailPhysicalPropertiesEntry2Desc;

  /// No description provided for @detailPhysicalPropertiesEntry3Highlight.
  ///
  /// In en, this message translates to:
  /// **'Disruption of bioelectric signals'**
  String get detailPhysicalPropertiesEntry3Highlight;

  /// No description provided for @detailPhysicalPropertiesEntry3Desc.
  ///
  /// In en, this message translates to:
  /// **'Electrostatically charged nanoplastics create \'noise\' that disrupts plant communication (root networks) and insects → loss of ecosystem adaptation.'**
  String get detailPhysicalPropertiesEntry3Desc;

  /// No description provided for @detailPhysicalPropertiesEntry4Highlight.
  ///
  /// In en, this message translates to:
  /// **'Photosynthesis damage'**
  String get detailPhysicalPropertiesEntry4Highlight;

  /// No description provided for @detailPhysicalPropertiesEntry4Desc.
  ///
  /// In en, this message translates to:
  /// **'Nanoplastics physically damage chloroplasts → decreased energy and oxygen production, weakening of primary producers.'**
  String get detailPhysicalPropertiesEntry4Desc;

  /// No description provided for @sourceBioaccumulationBrain.
  ///
  /// In en, this message translates to:
  /// **'Bioaccumulation in the human brain'**
  String get sourceBioaccumulationBrain;

  /// No description provided for @sourceAutismSpectrumBPA.
  ///
  /// In en, this message translates to:
  /// **'Autism Spectrum Disorders and BPA'**
  String get sourceAutismSpectrumBPA;

  /// No description provided for @sourceCrossingBloodBrainBarrier.
  ///
  /// In en, this message translates to:
  /// **'Crossing the blood-brain barrier'**
  String get sourceCrossingBloodBrainBarrier;

  /// No description provided for @sourceReductionMNPBoilingWater.
  ///
  /// In en, this message translates to:
  /// **'Reduction of MNP intake by boiling water'**
  String get sourceReductionMNPBoilingWater;

  /// No description provided for @sourceContaminationDairyProducts.
  ///
  /// In en, this message translates to:
  /// **'Contamination of dairy products'**
  String get sourceContaminationDairyProducts;

  /// No description provided for @sourceQuantumEffectsProtonTransfer.
  ///
  /// In en, this message translates to:
  /// **'Quantum effects and proton transfer in cells'**
  String get sourceQuantumEffectsProtonTransfer;

  /// No description provided for @sourceCardiovascularRisksAtheromas.
  ///
  /// In en, this message translates to:
  /// **'Cardiovascular risks (Atheromas)'**
  String get sourceCardiovascularRisksAtheromas;

  /// No description provided for @sourcePlasticsInMaleSemen.
  ///
  /// In en, this message translates to:
  /// **'Plastics in male semen'**
  String get sourcePlasticsInMaleSemen;

  /// No description provided for @sourcePlasticsInFemaleFollicularFluid.
  ///
  /// In en, this message translates to:
  /// **'Plastics in female follicular fluid'**
  String get sourcePlasticsInFemaleFollicularFluid;

  /// No description provided for @sourceAdverseBirthOutcomesUSAPhthalates.
  ///
  /// In en, this message translates to:
  /// **'Adverse birth outcomes in the USA (phthalates)'**
  String get sourceAdverseBirthOutcomesUSAPhthalates;

  /// No description provided for @sourcePhthalateExposureCancerChildren.
  ///
  /// In en, this message translates to:
  /// **'Phthalate exposure and cancer in children'**
  String get sourcePhthalateExposureCancerChildren;

  /// No description provided for @sourceEmissionPlasticsOceanToAtmosphere.
  ///
  /// In en, this message translates to:
  /// **'Emission of plastics from ocean to atmosphere'**
  String get sourceEmissionPlasticsOceanToAtmosphere;

  /// No description provided for @sourceOceanAcidificationPlasticDegradation.
  ///
  /// In en, this message translates to:
  /// **'Ocean acidification from plastic degradation'**
  String get sourceOceanAcidificationPlasticDegradation;

  /// No description provided for @sourceContaminationDeepestOcean.
  ///
  /// In en, this message translates to:
  /// **'Contamination of the deepest parts of the ocean'**
  String get sourceContaminationDeepestOcean;

  /// No description provided for @sourceCoralReefCollapse.
  ///
  /// In en, this message translates to:
  /// **'Coral reef collapse'**
  String get sourceCoralReefCollapse;

  /// No description provided for @sourceIceFormationAtmosphereMNP.
  ///
  /// In en, this message translates to:
  /// **'Ice formation in atmosphere with MNP'**
  String get sourceIceFormationAtmosphereMNP;

  /// No description provided for @sourceMNPCloudsImpactPrecipitation.
  ///
  /// In en, this message translates to:
  /// **'MNP in clouds and impact on precipitation'**
  String get sourceMNPCloudsImpactPrecipitation;

  /// No description provided for @sourceGlobalPhotosynthesisLosses.
  ///
  /// In en, this message translates to:
  /// **'Global photosynthesis losses'**
  String get sourceGlobalPhotosynthesisLosses;

  /// No description provided for @sourceFragmentGrowthPacificGarbagePatch.
  ///
  /// In en, this message translates to:
  /// **'Fragment growth in the Pacific garbage patch'**
  String get sourceFragmentGrowthPacificGarbagePatch;

  /// No description provided for @sourceGeophysicalBreak1995.
  ///
  /// In en, this message translates to:
  /// **'Geophysical break in 1995'**
  String get sourceGeophysicalBreak1995;

  /// No description provided for @resultsBackButton.
  ///
  /// In en, this message translates to:
  /// **'← BACK'**
  String get resultsBackButton;

  /// No description provided for @resultsStatsTotalIdeas.
  ///
  /// In en, this message translates to:
  /// **'Total number of ideas'**
  String get resultsStatsTotalIdeas;

  /// No description provided for @resultsStatsAnalyzedCategories.
  ///
  /// In en, this message translates to:
  /// **'Analyzed categories'**
  String get resultsStatsAnalyzedCategories;

  /// No description provided for @resultsStatsActiveSolvers.
  ///
  /// In en, this message translates to:
  /// **'Active solvers'**
  String get resultsStatsActiveSolvers;

  /// No description provided for @resultsEvaluationSystemTitle.
  ///
  /// In en, this message translates to:
  /// **'ABOUT THE EVALUATION SYSTEM'**
  String get resultsEvaluationSystemTitle;

  /// No description provided for @resultsEvaluationSystemDesc1.
  ///
  /// In en, this message translates to:
  /// **'Your ideas are collected and mathematically analyzed using advanced algorithms. The system evaluates feasibility, impact, and innovation of each solution.'**
  String get resultsEvaluationSystemDesc1;

  /// No description provided for @resultsEvaluationSystemDesc2.
  ///
  /// In en, this message translates to:
  /// **'The most promising solutions will be presented to scientists and policymakers for practical implementation.'**
  String get resultsEvaluationSystemDesc2;

  /// No description provided for @leaderboardTitle.
  ///
  /// In en, this message translates to:
  /// **'TOP 10 SOLVERS'**
  String get leaderboardTitle;

  /// No description provided for @leaderboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Leading contributors to nanoplastic solutions'**
  String get leaderboardSubtitle;

  /// No description provided for @leaderboardAccessRestricted.
  ///
  /// In en, this message translates to:
  /// **'Leaderboard Access Restricted'**
  String get leaderboardAccessRestricted;

  /// No description provided for @leaderboardAccessDescription.
  ///
  /// In en, this message translates to:
  /// **'Register with your email and name to view the top 10 leaderboard and be recognized for your solutions.'**
  String get leaderboardAccessDescription;

  /// No description provided for @leaderboardRegisterNow.
  ///
  /// In en, this message translates to:
  /// **'Register Now'**
  String get leaderboardRegisterNow;

  /// No description provided for @settingsBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get settingsBack;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your preferences'**
  String get settingsSubtitle;

  /// No description provided for @settingsProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settingsProfile;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsPrivacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get settingsPrivacySecurity;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your profile and preferences'**
  String get profileSubtitle;

  /// No description provided for @profilePersonalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get profilePersonalInfo;

  /// No description provided for @profileDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get profileDisplayName;

  /// No description provided for @profileDisplayNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name or nickname'**
  String get profileDisplayNameHint;

  /// No description provided for @profileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profileEmail;

  /// No description provided for @profileEmailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get profileEmailHint;

  /// No description provided for @profileBio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get profileBio;

  /// No description provided for @profileBioHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get profileBioHint;

  /// No description provided for @profileAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get profileAppearance;

  /// No description provided for @profileDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get profileDarkMode;

  /// No description provided for @profileDarkModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Use dark theme throughout the app'**
  String get profileDarkModeDesc;

  /// No description provided for @profileNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get profileNotifications;

  /// No description provided for @profilePushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get profilePushNotifications;

  /// No description provided for @profilePushNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications on your device'**
  String get profilePushNotificationsDesc;

  /// No description provided for @profileEmailNotifications.
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get profileEmailNotifications;

  /// No description provided for @profileEmailNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive updates via email'**
  String get profileEmailNotificationsDesc;

  /// No description provided for @profilePrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get profilePrivacy;

  /// No description provided for @profileAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get profileAnalytics;

  /// No description provided for @profileAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Help us improve by sharing usage data'**
  String get profileAnalyticsDesc;

  /// No description provided for @profileDangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get profileDangerZone;

  /// No description provided for @profileDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// No description provided for @profileDeleteAccountDesc.
  ///
  /// In en, this message translates to:
  /// **'Permanently remove your account and data'**
  String get profileDeleteAccountDesc;

  /// No description provided for @profileChangeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Change Avatar'**
  String get profileChangeAvatar;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get languageSubtitle;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed to'**
  String get languageChanged;

  /// No description provided for @languageInfoMessage.
  ///
  /// In en, this message translates to:
  /// **'The app will update to your selected language. Some content may require an app restart.'**
  String get languageInfoMessage;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyTitle;

  /// No description provided for @privacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your privacy preferences'**
  String get privacySubtitle;

  /// No description provided for @privacyDataAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Data & Analytics'**
  String get privacyDataAnalytics;

  /// No description provided for @privacyAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get privacyAnalytics;

  /// No description provided for @privacyAnalyticsDesc.
  ///
  /// In en, this message translates to:
  /// **'Help us improve by sharing anonymous usage data'**
  String get privacyAnalyticsDesc;

  /// No description provided for @privacySecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get privacySecurity;

  /// No description provided for @privacyDataEncryption.
  ///
  /// In en, this message translates to:
  /// **'Data Encryption'**
  String get privacyDataEncryption;

  /// No description provided for @privacyDataEncryptionDesc.
  ///
  /// In en, this message translates to:
  /// **'All your data is encrypted in transit and at rest'**
  String get privacyDataEncryptionDesc;

  /// No description provided for @privacyLocalStorage.
  ///
  /// In en, this message translates to:
  /// **'Local Storage'**
  String get privacyLocalStorage;

  /// No description provided for @privacyLocalStorageDesc.
  ///
  /// In en, this message translates to:
  /// **'Your preferences are stored securely on your device'**
  String get privacyLocalStorageDesc;

  /// No description provided for @privacyLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get privacyLegal;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @privacyTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get privacyTermsOfService;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutAppName.
  ///
  /// In en, this message translates to:
  /// **'NanoSolve Hive'**
  String get aboutAppName;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get aboutVersion;

  /// No description provided for @aboutSection.
  ///
  /// In en, this message translates to:
  /// **'About NanoSolve'**
  String get aboutSection;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'NanoSolve Hive is your gateway to understanding nanoplastics and their impact on human health and the environment. We provide science-backed information to help you make informed decisions.'**
  String get aboutDescription;

  /// No description provided for @aboutConnect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get aboutConnect;

  /// No description provided for @aboutWebsite.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get aboutWebsite;

  /// No description provided for @aboutWebsiteUrl.
  ///
  /// In en, this message translates to:
  /// **'nanosolve.io'**
  String get aboutWebsiteUrl;

  /// No description provided for @aboutContactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get aboutContactUs;

  /// No description provided for @aboutContactUsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with our team'**
  String get aboutContactUsDesc;

  /// No description provided for @aboutLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get aboutLegal;

  /// No description provided for @aboutPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get aboutPrivacyPolicy;

  /// No description provided for @aboutPrivacyPolicyDesc.
  ///
  /// In en, this message translates to:
  /// **'How we handle your data'**
  String get aboutPrivacyPolicyDesc;

  /// No description provided for @aboutTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get aboutTermsOfService;

  /// No description provided for @aboutTermsOfServiceDesc.
  ///
  /// In en, this message translates to:
  /// **'Terms and conditions'**
  String get aboutTermsOfServiceDesc;

  /// No description provided for @aboutOpenSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get aboutOpenSourceLicenses;

  /// No description provided for @aboutOpenSourceLicensesDesc.
  ///
  /// In en, this message translates to:
  /// **'Third-party libraries we use'**
  String get aboutOpenSourceLicensesDesc;

  /// No description provided for @aboutShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get aboutShare;

  /// No description provided for @aboutShareTitle.
  ///
  /// In en, this message translates to:
  /// **'Share NanoSolve'**
  String get aboutShareTitle;

  /// No description provided for @aboutShareDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code to download \nthe app'**
  String get aboutShareDesc;

  /// No description provided for @aboutShareAppLink.
  ///
  /// In en, this message translates to:
  /// **'App Download Link'**
  String get aboutShareAppLink;

  /// No description provided for @aboutFooterMessage.
  ///
  /// In en, this message translates to:
  /// **'Made with care for a cleaner planet'**
  String get aboutFooterMessage;

  /// No description provided for @aboutCopyright.
  ///
  /// In en, this message translates to:
  /// **'2024 NanoSolve. All rights reserved.'**
  String get aboutCopyright;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['cs', 'en', 'es', 'fr', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'cs':
      return AppLocalizationsCs();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
