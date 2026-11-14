/// Where people get the app. Every screen that links or encodes a QR code
/// reads from here, so a store URL changes in one place.
class StoreLinks {
  StoreLinks._();

  static const appStore =
      'https://apps.apple.com/us/app/nanosolve-hive/id6760934677';
  static const playStore =
      'https://play.google.com/store/apps/details?id=org.nanosolve.hive';
  static const githubLatestRelease =
      'https://github.com/glmcz/nanoplastics_frontend/releases/latest';
  static const githubRepo = 'https://github.com/glmcz/nanoplastics_frontend';
  static const website = 'https://web.nanosolve.org';
  static const privacy = '$website/privacy';
}
