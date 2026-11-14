import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'web_localizations_ar.dart';
import 'web_localizations_cs.dart';
import 'web_localizations_en.dart';
import 'web_localizations_es.dart';
import 'web_localizations_fr.dart';
import 'web_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of WebLocalizations
/// returned by `WebLocalizations.of(context)`.
///
/// Applications need to include `WebLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n_web/web_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: WebLocalizations.localizationsDelegates,
///   supportedLocales: WebLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the WebLocalizations.supportedLocales
/// property.
abstract class WebLocalizations {
  WebLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static WebLocalizations? of(BuildContext context) {
    return Localizations.of<WebLocalizations>(context, WebLocalizations);
  }

  static const LocalizationsDelegate<WebLocalizations> delegate =
      _WebLocalizationsDelegate();

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
    Locale('ar'),
    Locale('en'),
    Locale('cs'),
    Locale('es'),
    Locale('fr'),
    Locale('ru')
  ];

  /// No description provided for @privacyPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPageTitle;

  /// No description provided for @privacyLastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated: November 14, 2026'**
  String get privacyLastUpdated;

  /// No description provided for @privacyS1Title.
  ///
  /// In en, this message translates to:
  /// **'1. Introduction'**
  String get privacyS1Title;

  /// No description provided for @privacyS1P1.
  ///
  /// In en, this message translates to:
  /// **'NanoSolve Hive (\"App\", \"we\", \"our\", or \"us\") is committed to protecting your privacy. This Privacy Policy explains what information we collect, why, and who else handles it when you use the NanoSolve Hive app for iPhone and Android or the website web.nanosolve.org.'**
  String get privacyS1P1;

  /// No description provided for @privacyS1P2.
  ///
  /// In en, this message translates to:
  /// **'By using NanoSolve Hive, you agree to this Privacy Policy. If you do not agree with our privacy practices, please do not use our application.'**
  String get privacyS1P2;

  /// No description provided for @privacyS2Title.
  ///
  /// In en, this message translates to:
  /// **'2. Information We Collect'**
  String get privacyS2Title;

  /// No description provided for @privacyS2DeviceTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Information'**
  String get privacyS2DeviceTitle;

  /// No description provided for @privacyS2DeviceItems.
  ///
  /// In en, this message translates to:
  /// **'Device type, operating system and app version\nDevice language\nYour time zone, only when you save daily digest settings\nA push notification token from Apple or Google, only if you allow notifications'**
  String get privacyS2DeviceItems;

  /// No description provided for @privacyS2UsageTitle.
  ///
  /// In en, this message translates to:
  /// **'Usage Information'**
  String get privacyS2UsageTitle;

  /// No description provided for @privacyS2UsageItems.
  ///
  /// In en, this message translates to:
  /// **'Which screens you open and which buttons you press, so we can see where the app confuses people\nEach record carries a random installation number created on your device. It is not linked to you, your account, your email or your phone\nThese records are deleted after 180 days, and nothing is collected while usage statistics are turned off'**
  String get privacyS2UsageItems;

  /// No description provided for @privacyS2AnalyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Crash Reports'**
  String get privacyS2AnalyticsTitle;

  /// No description provided for @privacyS2AnalyticsItems.
  ///
  /// In en, this message translates to:
  /// **'When the app crashes, Firebase Crashlytics receives the error, the app version and the device\'s technical state at that moment\nCrash reports contain no email, nickname or ideas\nNo crash reports are sent while usage statistics are turned off'**
  String get privacyS2AnalyticsItems;

  /// No description provided for @privacyS2UserTitle.
  ///
  /// In en, this message translates to:
  /// **'Optional User-Provided Information'**
  String get privacyS2UserTitle;

  /// No description provided for @privacyS2UserItems.
  ///
  /// In en, this message translates to:
  /// **'Display name/nickname (for the leaderboard)\nEmail address (for your profile, the daily digest and the emails you opt into)\nDaily digest preferences: keywords, delivery hour, time zone, and whether email and the monthly summary are on\nPapers you save to your Vault\nSolution ideas, attachments, and other contributions you submit'**
  String get privacyS2UserItems;

  /// No description provided for @privacyS3Title.
  ///
  /// In en, this message translates to:
  /// **'3. Submitted Ideas — Open License'**
  String get privacyS3Title;

  /// No description provided for @privacyS3HighlightLabel.
  ///
  /// In en, this message translates to:
  /// **'Short version:'**
  String get privacyS3HighlightLabel;

  /// No description provided for @privacyS3Highlight.
  ///
  /// In en, this message translates to:
  /// **'You keep the copyright to your idea. By submitting, you license it openly under CC BY 4.0 — so any scientist, NGO, or government can use it to fight nanoplastic pollution. We credit you. No one can lock the idea away.'**
  String get privacyS3Highlight;

  /// No description provided for @privacyS3OwnerTitle.
  ///
  /// In en, this message translates to:
  /// **'You retain ownership'**
  String get privacyS3OwnerTitle;

  /// No description provided for @privacyS3OwnerP.
  ///
  /// In en, this message translates to:
  /// **'All ideas, texts, and attachments you submit remain your intellectual property. NanoSolve Hive makes no claim to ownership of your contributions.'**
  String get privacyS3OwnerP;

  /// No description provided for @privacyS3LicenseTitle.
  ///
  /// In en, this message translates to:
  /// **'License you grant'**
  String get privacyS3LicenseTitle;

  /// No description provided for @privacyS3LicenseP.
  ///
  /// In en, this message translates to:
  /// **'By submitting a Contribution, you grant NanoSolve Hive and the public a worldwide, royalty-free, irrevocable license under Creative Commons Attribution 4.0 International (CC BY 4.0) to use, share, adapt, and build upon your Contribution — including for scientific research, policy proposals, and environmental applications — provided attribution is given to your display name or nickname.'**
  String get privacyS3LicenseP;

  /// No description provided for @privacyS3LicenseLinkText.
  ///
  /// In en, this message translates to:
  /// **'creativecommons.org/licenses/by/4.0/'**
  String get privacyS3LicenseLinkText;

  /// No description provided for @privacyS3WhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why open?'**
  String get privacyS3WhyTitle;

  /// No description provided for @privacyS3WhyP.
  ///
  /// In en, this message translates to:
  /// **'Nanoplastic pollution is a global problem with no time for legal barriers. Open licensing means a solution submitted in one country can be studied, implemented, and built upon anywhere — the same way open-source software accelerates technology. Your idea compounds in value the more freely it spreads.'**
  String get privacyS3WhyP;

  /// No description provided for @privacyS3PatentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Defensive patents'**
  String get privacyS3PatentsTitle;

  /// No description provided for @privacyS3PatentsP.
  ///
  /// In en, this message translates to:
  /// **'For high-impact ideas, NanoSolve Hive may — with the submitter\'s explicit written consent — pursue a defensive patent. The sole purpose is to prevent industry actors from patenting the solution and suppressing it. Any such patent remains royalty-free for research and public-benefit use.'**
  String get privacyS3PatentsP;

  /// No description provided for @privacyS3NeverTitle.
  ///
  /// In en, this message translates to:
  /// **'What we will never do'**
  String get privacyS3NeverTitle;

  /// No description provided for @privacyS3NeverItems.
  ///
  /// In en, this message translates to:
  /// **'Sell your idea for private commercial profit without your explicit consent\nMisrepresent your idea as our own\nRemove your attribution after publishing'**
  String get privacyS3NeverItems;

  /// No description provided for @privacyS3AnonTitle.
  ///
  /// In en, this message translates to:
  /// **'Anonymous submissions'**
  String get privacyS3AnonTitle;

  /// No description provided for @privacyS3AnonP.
  ///
  /// In en, this message translates to:
  /// **'If you submit without a name, the CC BY 4.0 license still applies but no attribution is required or possible. You will not be able to claim authorship after the fact for anonymous submissions.'**
  String get privacyS3AnonP;

  /// No description provided for @privacyS3AiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI scoring'**
  String get privacyS3AiTitle;

  /// No description provided for @privacyS3AiP.
  ///
  /// In en, this message translates to:
  /// **'An idea you submit is stored by NanoSolve and read by people working on the project. It is also sent to an AI service, which may be outside your country, to be scored, and the score comes back into the app. Your nickname and email are attached only if you choose. To delete a submission, contact us with the code shown when you send it.'**
  String get privacyS3AiP;

  /// No description provided for @privacyS4Title.
  ///
  /// In en, this message translates to:
  /// **'4. Daily Research Digest'**
  String get privacyS4Title;

  /// No description provided for @privacyS4Items.
  ///
  /// In en, this message translates to:
  /// **'The daily digest is off until you turn it on in the app under Settings → My Vault → Research Preferences. It needs your email address, which you confirm with a 6-digit code we send to it; the code also keeps anyone else from reading or changing your settings.\nTo deliver it we store your email, your keywords, the hour you chose, your time zone, whether digest email and the monthly summary are on, and your device\'s push token.\nWe also record which paper was sent to which profile, so you never get the same paper twice.\nPapers come from public scientific databases. Choosing one uses nothing about you except your keywords.\nPush notifications travel through Firebase Cloud Messaging (Google) and, on iPhone, the Apple Push Notification service. They receive the push token and the notification text (the paper\'s title and summary), not your email.\nDigest emails and the monthly summary are sent through Resend, an email delivery service, which receives your email address and the message.\nTo stop, switch the digest, email or monthly summary off in Research Preferences, or turn off notifications for NanoSolve Hive in your phone\'s settings.'**
  String get privacyS4Items;

  /// No description provided for @privacyS5Title.
  ///
  /// In en, this message translates to:
  /// **'5. How We Use Your Information'**
  String get privacyS5Title;

  /// No description provided for @privacyS5Items.
  ///
  /// In en, this message translates to:
  /// **'Deliver the Daily Digest: Send the papers, notifications and emails you opted into, at the hour you chose\nImprove the App: Maintain and enhance application functionality and features\nAnalyze Usage: Understand usage patterns to improve user experience\nDiagnose Issues: Identify and fix technical problems and bugs\nComply with Law: Meet legal obligations and regulatory requirements\nCommunity Features: Display your nickname and ideas on the public leaderboard (with your consent)'**
  String get privacyS5Items;

  /// No description provided for @privacyS6Title.
  ///
  /// In en, this message translates to:
  /// **'6. Data Storage and Security'**
  String get privacyS6Title;

  /// No description provided for @privacyS6Items.
  ///
  /// In en, this message translates to:
  /// **'We store only what the app needs: your profile (nickname and email), your digest preferences and Vault, and the ideas or attachments you submit.\nYour email is never shown publicly. Your nickname appears on the leaderboard only next to ideas you submit under it.\nData travels over encrypted HTTPS connections and is stored on our servers, with access limited to the people running NanoSolve.\nIdea content and associated metadata remain in anonymized form after removing personal identifiers.\nWe never sell personal data.'**
  String get privacyS6Items;

  /// No description provided for @privacyS6HighlightLabel.
  ///
  /// In en, this message translates to:
  /// **'Data Minimization:'**
  String get privacyS6HighlightLabel;

  /// No description provided for @privacyS6Highlight.
  ///
  /// In en, this message translates to:
  /// **'We only collect information necessary to operate the application and provide the requested services. We do not collect information beyond what is needed.'**
  String get privacyS6Highlight;

  /// No description provided for @privacyS7Title.
  ///
  /// In en, this message translates to:
  /// **'7. Third-Party Services'**
  String get privacyS7Title;

  /// No description provided for @privacyS7Intro.
  ///
  /// In en, this message translates to:
  /// **'Our application uses the following third-party services, each with their own privacy policies:'**
  String get privacyS7Intro;

  /// No description provided for @privacyS7FirebaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Firebase (Google)'**
  String get privacyS7FirebaseTitle;

  /// No description provided for @privacyS7FirebaseItems.
  ///
  /// In en, this message translates to:
  /// **'Purpose: Crash reporting (Crashlytics) and push notification delivery (Cloud Messaging)\nData: Crash reports as described in section 2; push tokens and notification text\nControl: Turn off usage statistics in Settings → Privacy & Security to stop crash reports; turn off notifications to stop pushes'**
  String get privacyS7FirebaseItems;

  /// No description provided for @privacyS7AppleTitle.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get privacyS7AppleTitle;

  /// No description provided for @privacyS7AppleP.
  ///
  /// In en, this message translates to:
  /// **'Purpose: App Store distribution and push notification delivery on iPhone (Apple Push Notification service)'**
  String get privacyS7AppleP;

  /// No description provided for @privacyS7PlayTitle.
  ///
  /// In en, this message translates to:
  /// **'Google Play Services'**
  String get privacyS7PlayTitle;

  /// No description provided for @privacyS7PlayP.
  ///
  /// In en, this message translates to:
  /// **'Purpose: App distribution and updates on Android'**
  String get privacyS7PlayP;

  /// No description provided for @privacyS7EmailTitle.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get privacyS7EmailTitle;

  /// No description provided for @privacyS7EmailP.
  ///
  /// In en, this message translates to:
  /// **'Purpose: Sends the digest emails and monthly summary you opt into. Receives your email address and the message'**
  String get privacyS7EmailP;

  /// No description provided for @privacyS7AiTitle.
  ///
  /// In en, this message translates to:
  /// **'AI services'**
  String get privacyS7AiTitle;

  /// No description provided for @privacyS7AiP.
  ///
  /// In en, this message translates to:
  /// **'Purpose: Scoring the ideas you submit (see section 3) and summarizing public research papers for the digest. Summarizing papers involves no personal data'**
  String get privacyS7AiP;

  /// No description provided for @privacyS7WebTitle.
  ///
  /// In en, this message translates to:
  /// **'Cloudflare and content delivery'**
  String get privacyS7WebTitle;

  /// No description provided for @privacyS7WebP.
  ///
  /// In en, this message translates to:
  /// **'Our servers sit behind Cloudflare, which shields them from attacks and sees your IP address. On the website, Cloudflare Turnstile checks that an idea is submitted by a person. The website also loads fonts and code from Google (gstatic.com) and jsDelivr, which receive your IP address when your browser fetches them'**
  String get privacyS7WebP;

  /// No description provided for @privacyS7Note.
  ///
  /// In en, this message translates to:
  /// **'Each service receives only what it needs for the job listed above. We never sell personal data.'**
  String get privacyS7Note;

  /// No description provided for @privacyS8Title.
  ///
  /// In en, this message translates to:
  /// **'8. Your Rights and Choices'**
  String get privacyS8Title;

  /// No description provided for @privacyS8AccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Access Your Data'**
  String get privacyS8AccessTitle;

  /// No description provided for @privacyS8AccessP.
  ///
  /// In en, this message translates to:
  /// **'You have the right to request a copy of all personal data we hold about you.'**
  String get privacyS8AccessP;

  /// No description provided for @privacyS8CorrectTitle.
  ///
  /// In en, this message translates to:
  /// **'Correct Your Information'**
  String get privacyS8CorrectTitle;

  /// No description provided for @privacyS8CorrectP.
  ///
  /// In en, this message translates to:
  /// **'You can update your profile information through the app\'s Settings → User Profile section at any time.'**
  String get privacyS8CorrectP;

  /// No description provided for @privacyS8DeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Your Data'**
  String get privacyS8DeleteTitle;

  /// No description provided for @privacyS8DeleteP.
  ///
  /// In en, this message translates to:
  /// **'Settings → User Profile → Delete account erases your account from our servers (your email, digest preferences, push token and Vault) and then from this device. Ideas you submitted stay, without your name and email. If you have not confirmed your email on this device, the app first sends you a code, so nobody else can delete your account.'**
  String get privacyS8DeleteP;

  /// No description provided for @privacyS8OptoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Opt-Out of Analytics'**
  String get privacyS8OptoutTitle;

  /// No description provided for @privacyS8OptoutP.
  ///
  /// In en, this message translates to:
  /// **'You can turn off usage statistics and crash reporting in Settings → Privacy & Security. This does not affect core app functionality.'**
  String get privacyS8OptoutP;

  /// No description provided for @privacyS8ManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Communications'**
  String get privacyS8ManageTitle;

  /// No description provided for @privacyS8ManageP.
  ///
  /// In en, this message translates to:
  /// **'Turn the daily digest, digest email and monthly summary on or off at any time under Settings → My Vault → Research Preferences. You can also turn off notifications for NanoSolve Hive in your phone\'s settings.'**
  String get privacyS8ManageP;

  /// No description provided for @privacyS9Title.
  ///
  /// In en, this message translates to:
  /// **'9. Children\'s Privacy'**
  String get privacyS9Title;

  /// No description provided for @privacyS9P.
  ///
  /// In en, this message translates to:
  /// **'NanoSolve Hive is not intended for users under 13 years old. We do not knowingly collect personal information from children under 13. If we become aware that a child under 13 has provided us with personal information, we will delete such information and terminate the child\'s account.'**
  String get privacyS9P;

  /// No description provided for @privacyS10Title.
  ///
  /// In en, this message translates to:
  /// **'10. Data Retention'**
  String get privacyS10Title;

  /// No description provided for @privacyS10Items.
  ///
  /// In en, this message translates to:
  /// **'Submitted Ideas: Retained indefinitely unless deleted by you\nUser Profile, digest preferences, push token and Vault: Retained while your profile exists; erased on request\nDigest delivery log: Retained while your profile exists, so the same paper is never sent twice\nUsage Statistics: Deleted after 180 days\nCrash Reports: Retained for 90 days by Firebase Crashlytics, then automatically deleted\nApp Settings: Stored locally on your device; deleted when you uninstall the app'**
  String get privacyS10Items;

  /// No description provided for @privacyS11Title.
  ///
  /// In en, this message translates to:
  /// **'11. International Data Transfers'**
  String get privacyS11Title;

  /// No description provided for @privacyS11P.
  ///
  /// In en, this message translates to:
  /// **'Your data may be transferred, stored, and processed in countries other than your country of residence. These countries may have different data protection laws. By using NanoSolve Hive, you consent to such transfers and processing.'**
  String get privacyS11P;

  /// No description provided for @privacyS12Title.
  ///
  /// In en, this message translates to:
  /// **'12. Changes to This Privacy Policy'**
  String get privacyS12Title;

  /// No description provided for @privacyS12P1.
  ///
  /// In en, this message translates to:
  /// **'We may update this Privacy Policy periodically to reflect changes in our practices, technology, legal requirements, or other factors. We will notify you of material changes by:'**
  String get privacyS12P1;

  /// No description provided for @privacyS12Items.
  ///
  /// In en, this message translates to:
  /// **'Posting the updated policy within the application\nUpdating the \"Last Updated\" date at the top of this page\nRequesting your consent if required by applicable law'**
  String get privacyS12Items;

  /// No description provided for @privacyS12P2.
  ///
  /// In en, this message translates to:
  /// **'Your continued use of the application following the posting of revised Privacy Policy means that you accept and agree to the changes.'**
  String get privacyS12P2;

  /// No description provided for @privacyS13Title.
  ///
  /// In en, this message translates to:
  /// **'13. California Privacy Rights (CCPA)'**
  String get privacyS13Title;

  /// No description provided for @privacyS13P.
  ///
  /// In en, this message translates to:
  /// **'If you are a California resident, you have additional rights under the California Consumer Privacy Act (CCPA), including the right to know, delete, and opt-out of sales of your personal information. To exercise these rights, please contact us using the information below.'**
  String get privacyS13P;

  /// No description provided for @privacyS14Title.
  ///
  /// In en, this message translates to:
  /// **'14. European Privacy Rights (GDPR)'**
  String get privacyS14Title;

  /// No description provided for @privacyS14P.
  ///
  /// In en, this message translates to:
  /// **'If you are in the European Union, you have rights under the General Data Protection Regulation (GDPR), including the right to access, rectification, erasure, and data portability. You also have the right to object to processing and the right to lodge a complaint with your local data protection authority.'**
  String get privacyS14P;

  /// No description provided for @privacyS15Title.
  ///
  /// In en, this message translates to:
  /// **'15. Contact Us'**
  String get privacyS15Title;

  /// No description provided for @privacyS15P1.
  ///
  /// In en, this message translates to:
  /// **'If you have privacy concerns, questions about this policy, or wish to exercise any of your rights, please contact us:'**
  String get privacyS15P1;

  /// No description provided for @privacyS15HighlightTeam.
  ///
  /// In en, this message translates to:
  /// **'NanoSolve Hive Privacy Team'**
  String get privacyS15HighlightTeam;

  /// No description provided for @privacyS15HighlightEmail.
  ///
  /// In en, this message translates to:
  /// **'Email: support@nanosolve.org'**
  String get privacyS15HighlightEmail;

  /// No description provided for @privacyS15HighlightContact.
  ///
  /// In en, this message translates to:
  /// **'Or use the \"Contact Us\" option in the app Settings → About section'**
  String get privacyS15HighlightContact;

  /// No description provided for @privacyS15P2.
  ///
  /// In en, this message translates to:
  /// **'We will respond to your request within 30 days.'**
  String get privacyS15P2;

  /// No description provided for @privacyS15P3.
  ///
  /// In en, this message translates to:
  /// **'When you ask us to delete your personal data, we will remove any identifying information tied to your account, but accept that ideas, contributions, or other anonymized content you previously submitted may remain in the database as part of aggregated analytics, as those entries no longer contain personal identifiers.'**
  String get privacyS15P3;

  /// No description provided for @privacyS16Title.
  ///
  /// In en, this message translates to:
  /// **'16. Additional Resources'**
  String get privacyS16Title;

  /// No description provided for @privacyS16GithubLabel.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repository — Open source code'**
  String get privacyS16GithubLabel;

  /// No description provided for @privacyS16FirebaseLabel.
  ///
  /// In en, this message translates to:
  /// **'Firebase Privacy Policy'**
  String get privacyS16FirebaseLabel;

  /// No description provided for @privacyS16GoogleLabel.
  ///
  /// In en, this message translates to:
  /// **'Google Privacy Policy'**
  String get privacyS16GoogleLabel;

  /// No description provided for @privacyFooterCopyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Martin Durak. All rights reserved.'**
  String get privacyFooterCopyright;

  /// No description provided for @privacyFooterHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get privacyFooterHome;

  /// No description provided for @privacyFooterGithub.
  ///
  /// In en, this message translates to:
  /// **'GitHub'**
  String get privacyFooterGithub;
}

class _WebLocalizationsDelegate
    extends LocalizationsDelegate<WebLocalizations> {
  const _WebLocalizationsDelegate();

  @override
  Future<WebLocalizations> load(Locale locale) {
    return SynchronousFuture<WebLocalizations>(lookupWebLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'cs',
        'en',
        'es',
        'fr',
        'ru'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_WebLocalizationsDelegate old) => false;
}

WebLocalizations lookupWebLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return WebLocalizationsAr();
    case 'cs':
      return WebLocalizationsCs();
    case 'en':
      return WebLocalizationsEn();
    case 'es':
      return WebLocalizationsEs();
    case 'fr':
      return WebLocalizationsFr();
    case 'ru':
      return WebLocalizationsRu();
  }

  throw FlutterError(
      'WebLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
