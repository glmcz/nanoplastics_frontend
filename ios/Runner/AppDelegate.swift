import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    clearBadge()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  /// The app asks for badge authorization but nothing ever set the badge back
  /// to zero, so a count from any sender stayed on the icon indefinitely —
  /// including on a fresh install, where iOS restores it with the rest of the
  /// app's state. Clearing on launch and on every foreground is the missing
  /// half of that lifecycle.
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    clearBadge()
  }

  private func clearBadge() {
    if #available(iOS 16.0, *) {
      // applicationIconBadgeNumber is deprecated from iOS 16; this is the
      // supported path and it also works when the app is in the background.
      UNUserNotificationCenter.current().setBadgeCount(0)
    } else {
      UIApplication.shared.applicationIconBadgeNumber = 0
    }
  }
}
