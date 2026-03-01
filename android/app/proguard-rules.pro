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

# Google Play Core — this app does not use Dart deferred components / dynamic feature delivery.
# Flutter's engine references PlayStoreDeferredComponentManager which pulls in split-install APIs,
# but those classes are never exercised at runtime. Suppress R8 missing-class errors.
-dontwarn com.google.android.play.core.**
