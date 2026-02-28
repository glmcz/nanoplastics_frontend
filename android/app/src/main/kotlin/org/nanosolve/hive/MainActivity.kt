package org.nanosolve.hive

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
  private val CHANNEL = "org.nanosolve.hive/update"

  override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
      when (call.method) {
        "getSdkVersion" -> {
          result.success(Build.VERSION.SDK_INT)
        }
        "hasInstallPermission" -> {
          val hasPermission = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            // Android 12+: check REQUEST_INSTALL_PACKAGES permission
            packageManager.checkPermission(
              android.Manifest.permission.REQUEST_INSTALL_PACKAGES,
              packageName
            ) == PackageManager.PERMISSION_GRANTED
          } else {
            // Below Android 12: permission not required
            true
          }
          result.success(hasPermission)
        }
        else -> result.notImplemented()
      }
    }
  }
}