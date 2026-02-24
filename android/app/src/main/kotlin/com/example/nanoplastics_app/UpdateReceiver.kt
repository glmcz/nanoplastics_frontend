package com.example.nanoplastics_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Relaunches the app automatically after a self-update APK install completes.
 * Android fires ACTION_MY_PACKAGE_REPLACED to the *new* version of the app
 * once the system installer finishes replacing the package.
 */
class UpdateReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_MY_PACKAGE_REPLACED) {
            val launchIntent = context.packageManager
                .getLaunchIntentForPackage(context.packageName)
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                context.startActivity(launchIntent)
            }
        }
    }
}
