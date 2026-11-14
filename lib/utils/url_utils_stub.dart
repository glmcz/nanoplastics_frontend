import 'package:url_launcher/url_launcher.dart';

/// Opens [url] outside the app on iOS and Android. Screens shared with the
/// website (the privacy policy) call this too, so it cannot be a no-op.
void openExternalUrl(String url) {
  launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
