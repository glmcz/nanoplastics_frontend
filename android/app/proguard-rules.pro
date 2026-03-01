# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep custom application classes
-keep class org.nanosolve.hive.** { *; }

# Google Play Core - Keep all classes to prevent R8 stripping
# Required by Flutter's PlayStoreDeferredComponentManager for dynamic feature delivery
-keep class com.google.android.play.core.** { *; }
-keep interface com.google.android.play.core.** { *; }

# Explicit Flutter deferred component classes
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.PlayStoreDeferredComponentManager$* { *; }

# Don't optimize these - they're needed for Play Store dynamic features
-keepclassmembers class com.google.android.play.core.splitinstall.SplitInstallManager { *; }
-keepclassmembers class com.google.android.play.core.splitinstall.SplitInstallException { *; }
-keepclassmembers class com.google.android.play.core.tasks.Task { *; }
-keepclassmembers class com.google.android.play.core.tasks.OnSuccessListener { *; }
-keepclassmembers class com.google.android.play.core.tasks.OnFailureListener { *; }
