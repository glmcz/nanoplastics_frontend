// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'web_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class WebLocalizationsEn extends WebLocalizations {
  WebLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get privacyPageTitle => 'Privacy Policy';

  @override
  String get privacyLastUpdated => 'Last Updated: November 14, 2026';

  @override
  String get privacyS1Title => '1. Introduction';

  @override
  String get privacyS1P1 =>
      'NanoSolve Hive (\"App\", \"we\", \"our\", or \"us\") is committed to protecting your privacy. This Privacy Policy explains what information we collect, why, and who else handles it when you use the NanoSolve Hive app for iPhone and Android or the website web.nanosolve.org.';

  @override
  String get privacyS1P2 =>
      'By using NanoSolve Hive, you agree to this Privacy Policy. If you do not agree with our privacy practices, please do not use our application.';

  @override
  String get privacyS2Title => '2. Information We Collect';

  @override
  String get privacyS2DeviceTitle => 'Device Information';

  @override
  String get privacyS2DeviceItems =>
      'Device type, operating system and app version\nDevice language\nYour time zone, only when you save daily digest settings\nA push notification token from Apple or Google, only if you allow notifications';

  @override
  String get privacyS2UsageTitle => 'Usage Information';

  @override
  String get privacyS2UsageItems =>
      'Which screens you open and which buttons you press, so we can see where the app confuses people\nEach record carries a random installation number created on your device. It is not linked to you, your account, your email or your phone\nThese records are deleted after 180 days, and nothing is collected while usage statistics are turned off';

  @override
  String get privacyS2AnalyticsTitle => 'Crash Reports';

  @override
  String get privacyS2AnalyticsItems =>
      'When the app crashes, Firebase Crashlytics receives the error, the app version and the device\'s technical state at that moment\nCrash reports contain no email, nickname or ideas\nNo crash reports are sent while usage statistics are turned off';

  @override
  String get privacyS2UserTitle => 'Optional User-Provided Information';

  @override
  String get privacyS2UserItems =>
      'Display name/nickname (for the leaderboard)\nEmail address (for your profile, the daily digest and the emails you opt into)\nDaily digest preferences: keywords, delivery hour, time zone, and whether email and the monthly summary are on\nPapers you save to your Vault\nSolution ideas, attachments, and other contributions you submit';

  @override
  String get privacyS3Title => '3. Submitted Ideas — Open License';

  @override
  String get privacyS3HighlightLabel => 'Short version:';

  @override
  String get privacyS3Highlight =>
      'You keep the copyright to your idea. By submitting, you license it openly under CC BY 4.0 — so any scientist, NGO, or government can use it to fight nanoplastic pollution. We credit you. No one can lock the idea away.';

  @override
  String get privacyS3OwnerTitle => 'You retain ownership';

  @override
  String get privacyS3OwnerP =>
      'All ideas, texts, and attachments you submit remain your intellectual property. NanoSolve Hive makes no claim to ownership of your contributions.';

  @override
  String get privacyS3LicenseTitle => 'License you grant';

  @override
  String get privacyS3LicenseP =>
      'By submitting a Contribution, you grant NanoSolve Hive and the public a worldwide, royalty-free, irrevocable license under Creative Commons Attribution 4.0 International (CC BY 4.0) to use, share, adapt, and build upon your Contribution — including for scientific research, policy proposals, and environmental applications — provided attribution is given to your display name or nickname.';

  @override
  String get privacyS3LicenseLinkText => 'creativecommons.org/licenses/by/4.0/';

  @override
  String get privacyS3WhyTitle => 'Why open?';

  @override
  String get privacyS3WhyP =>
      'Nanoplastic pollution is a global problem with no time for legal barriers. Open licensing means a solution submitted in one country can be studied, implemented, and built upon anywhere — the same way open-source software accelerates technology. Your idea compounds in value the more freely it spreads.';

  @override
  String get privacyS3PatentsTitle => 'Defensive patents';

  @override
  String get privacyS3PatentsP =>
      'For high-impact ideas, NanoSolve Hive may — with the submitter\'s explicit written consent — pursue a defensive patent. The sole purpose is to prevent industry actors from patenting the solution and suppressing it. Any such patent remains royalty-free for research and public-benefit use.';

  @override
  String get privacyS3NeverTitle => 'What we will never do';

  @override
  String get privacyS3NeverItems =>
      'Sell your idea for private commercial profit without your explicit consent\nMisrepresent your idea as our own\nRemove your attribution after publishing';

  @override
  String get privacyS3AnonTitle => 'Anonymous submissions';

  @override
  String get privacyS3AnonP =>
      'If you submit without a name, the CC BY 4.0 license still applies but no attribution is required or possible. You will not be able to claim authorship after the fact for anonymous submissions.';

  @override
  String get privacyS3AiTitle => 'AI scoring';

  @override
  String get privacyS3AiP =>
      'An idea you submit is stored by NanoSolve and read by people working on the project. It is also sent to an AI service, which may be outside your country, to be scored, and the score comes back into the app. Your nickname and email are attached only if you choose. To delete a submission, contact us with the code shown when you send it.';

  @override
  String get privacyS4Title => '4. Daily Research Digest';

  @override
  String get privacyS4Items =>
      'The daily digest is off until you turn it on in the app under Settings → My Vault → Research Preferences. It needs your email address, which you confirm with a 6-digit code we send to it; the code also keeps anyone else from reading or changing your settings.\nTo deliver it we store your email, your keywords, the hour you chose, your time zone, whether digest email and the monthly summary are on, and your device\'s push token.\nWe also record which paper was sent to which profile, so you never get the same paper twice.\nPapers come from public scientific databases. Choosing one uses nothing about you except your keywords.\nPush notifications travel through Firebase Cloud Messaging (Google) and, on iPhone, the Apple Push Notification service. They receive the push token and the notification text (the paper\'s title and summary), not your email.\nDigest emails and the monthly summary are sent through Resend, an email delivery service, which receives your email address and the message.\nTo stop, switch the digest, email or monthly summary off in Research Preferences, or turn off notifications for NanoSolve Hive in your phone\'s settings.';

  @override
  String get privacyS5Title => '5. How We Use Your Information';

  @override
  String get privacyS5Items =>
      'Deliver the Daily Digest: Send the papers, notifications and emails you opted into, at the hour you chose\nImprove the App: Maintain and enhance application functionality and features\nAnalyze Usage: Understand usage patterns to improve user experience\nDiagnose Issues: Identify and fix technical problems and bugs\nComply with Law: Meet legal obligations and regulatory requirements\nCommunity Features: Display your nickname and ideas on the public leaderboard (with your consent)';

  @override
  String get privacyS6Title => '6. Data Storage and Security';

  @override
  String get privacyS6Items =>
      'We store only what the app needs: your profile (nickname and email), your digest preferences and Vault, and the ideas or attachments you submit.\nYour email is never shown publicly. Your nickname appears on the leaderboard only next to ideas you submit under it.\nData travels over encrypted HTTPS connections and is stored on our servers, with access limited to the people running NanoSolve.\nIdea content and associated metadata remain in anonymized form after removing personal identifiers.\nWe never sell personal data.';

  @override
  String get privacyS6HighlightLabel => 'Data Minimization:';

  @override
  String get privacyS6Highlight =>
      'We only collect information necessary to operate the application and provide the requested services. We do not collect information beyond what is needed.';

  @override
  String get privacyS7Title => '7. Third-Party Services';

  @override
  String get privacyS7Intro =>
      'Our application uses the following third-party services, each with their own privacy policies:';

  @override
  String get privacyS7FirebaseTitle => 'Firebase (Google)';

  @override
  String get privacyS7FirebaseItems =>
      'Purpose: Crash reporting (Crashlytics) and push notification delivery (Cloud Messaging)\nData: Crash reports as described in section 2; push tokens and notification text\nControl: Turn off usage statistics in Settings → Privacy & Security to stop crash reports; turn off notifications to stop pushes';

  @override
  String get privacyS7AppleTitle => 'Apple';

  @override
  String get privacyS7AppleP =>
      'Purpose: App Store distribution and push notification delivery on iPhone (Apple Push Notification service)';

  @override
  String get privacyS7PlayTitle => 'Google Play Services';

  @override
  String get privacyS7PlayP =>
      'Purpose: App distribution and updates on Android';

  @override
  String get privacyS7EmailTitle => 'Resend';

  @override
  String get privacyS7EmailP =>
      'Purpose: Sends the digest emails and monthly summary you opt into. Receives your email address and the message';

  @override
  String get privacyS7AiTitle => 'AI services';

  @override
  String get privacyS7AiP =>
      'Purpose: Scoring the ideas you submit (see section 3) and summarizing public research papers for the digest. Summarizing papers involves no personal data';

  @override
  String get privacyS7WebTitle => 'Cloudflare and content delivery';

  @override
  String get privacyS7WebP =>
      'Our servers sit behind Cloudflare, which shields them from attacks and sees your IP address. On the website, Cloudflare Turnstile checks that an idea is submitted by a person. The website also loads fonts and code from Google (gstatic.com) and jsDelivr, which receive your IP address when your browser fetches them';

  @override
  String get privacyS7Note =>
      'Each service receives only what it needs for the job listed above. We never sell personal data.';

  @override
  String get privacyS8Title => '8. Your Rights and Choices';

  @override
  String get privacyS8AccessTitle => 'Access Your Data';

  @override
  String get privacyS8AccessP =>
      'You have the right to request a copy of all personal data we hold about you.';

  @override
  String get privacyS8CorrectTitle => 'Correct Your Information';

  @override
  String get privacyS8CorrectP =>
      'You can update your profile information through the app\'s Settings → User Profile section at any time.';

  @override
  String get privacyS8DeleteTitle => 'Delete Your Data';

  @override
  String get privacyS8DeleteP =>
      'Settings → User Profile → Delete account erases your account from our servers (your email, digest preferences, push token and Vault) and then from this device. Ideas you submitted stay, without your name and email. If you have not confirmed your email on this device, the app first sends you a code, so nobody else can delete your account.';

  @override
  String get privacyS8OptoutTitle => 'Opt-Out of Analytics';

  @override
  String get privacyS8OptoutP =>
      'You can turn off usage statistics and crash reporting in Settings → Privacy & Security. This does not affect core app functionality.';

  @override
  String get privacyS8ManageTitle => 'Manage Communications';

  @override
  String get privacyS8ManageP =>
      'Turn the daily digest, digest email and monthly summary on or off at any time under Settings → My Vault → Research Preferences. You can also turn off notifications for NanoSolve Hive in your phone\'s settings.';

  @override
  String get privacyS9Title => '9. Children\'s Privacy';

  @override
  String get privacyS9P =>
      'NanoSolve Hive is not intended for users under 13 years old. We do not knowingly collect personal information from children under 13. If we become aware that a child under 13 has provided us with personal information, we will delete such information and terminate the child\'s account.';

  @override
  String get privacyS10Title => '10. Data Retention';

  @override
  String get privacyS10Items =>
      'Submitted Ideas: Retained indefinitely unless deleted by you\nUser Profile, digest preferences, push token and Vault: Retained while your profile exists; erased on request\nDigest delivery log: Retained while your profile exists, so the same paper is never sent twice\nUsage Statistics: Deleted after 180 days\nCrash Reports: Retained for 90 days by Firebase Crashlytics, then automatically deleted\nApp Settings: Stored locally on your device; deleted when you uninstall the app';

  @override
  String get privacyS11Title => '11. International Data Transfers';

  @override
  String get privacyS11P =>
      'Your data may be transferred, stored, and processed in countries other than your country of residence. These countries may have different data protection laws. By using NanoSolve Hive, you consent to such transfers and processing.';

  @override
  String get privacyS12Title => '12. Changes to This Privacy Policy';

  @override
  String get privacyS12P1 =>
      'We may update this Privacy Policy periodically to reflect changes in our practices, technology, legal requirements, or other factors. We will notify you of material changes by:';

  @override
  String get privacyS12Items =>
      'Posting the updated policy within the application\nUpdating the \"Last Updated\" date at the top of this page\nRequesting your consent if required by applicable law';

  @override
  String get privacyS12P2 =>
      'Your continued use of the application following the posting of revised Privacy Policy means that you accept and agree to the changes.';

  @override
  String get privacyS13Title => '13. California Privacy Rights (CCPA)';

  @override
  String get privacyS13P =>
      'If you are a California resident, you have additional rights under the California Consumer Privacy Act (CCPA), including the right to know, delete, and opt-out of sales of your personal information. To exercise these rights, please contact us using the information below.';

  @override
  String get privacyS14Title => '14. European Privacy Rights (GDPR)';

  @override
  String get privacyS14P =>
      'If you are in the European Union, you have rights under the General Data Protection Regulation (GDPR), including the right to access, rectification, erasure, and data portability. You also have the right to object to processing and the right to lodge a complaint with your local data protection authority.';

  @override
  String get privacyS15Title => '15. Contact Us';

  @override
  String get privacyS15P1 =>
      'If you have privacy concerns, questions about this policy, or wish to exercise any of your rights, please contact us:';

  @override
  String get privacyS15HighlightTeam => 'NanoSolve Hive Privacy Team';

  @override
  String get privacyS15HighlightEmail => 'Email: support@nanosolve.org';

  @override
  String get privacyS15HighlightContact =>
      'Or use the \"Contact Us\" option in the app Settings → About section';

  @override
  String get privacyS15P2 => 'We will respond to your request within 30 days.';

  @override
  String get privacyS15P3 =>
      'When you ask us to delete your personal data, we will remove any identifying information tied to your account, but accept that ideas, contributions, or other anonymized content you previously submitted may remain in the database as part of aggregated analytics, as those entries no longer contain personal identifiers.';

  @override
  String get privacyS16Title => '16. Additional Resources';

  @override
  String get privacyS16GithubLabel => 'GitHub Repository — Open source code';

  @override
  String get privacyS16FirebaseLabel => 'Firebase Privacy Policy';

  @override
  String get privacyS16GoogleLabel => 'Google Privacy Policy';

  @override
  String get privacyFooterCopyright =>
      '© 2026 Martin Durak. All rights reserved.';

  @override
  String get privacyFooterHome => 'Home';

  @override
  String get privacyFooterGithub => 'GitHub';
}
