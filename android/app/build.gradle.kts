plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.nanoplastics_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("KEYSTORE_PATH")
            val keystorePassword = System.getenv("KEYSTORE_PASSWORD")
            val keyAlias = System.getenv("KEY_ALIAS")
            val keyPassword = System.getenv("KEY_PASSWORD")
            
            if (!keystorePath.isNullOrEmpty() && !keystorePassword.isNullOrEmpty()) {
                storeFile = file(keystorePath)
                storePassword = keystorePassword
                keyAlias = keyAlias ?: "release-key"
                keyPassword = keyPassword ?: keystorePassword
            }
        }
    }

    tasks.withType<JavaCompile> {
        options.compilerArgs.add("-Xlint:-options")
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.nanoplastics_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "bundle"
    productFlavors {
        create("lite") {
            dimension = "bundle"
            // EN-only build — non-EN PDFs stripped at build time
        }
        create("full") {
            dimension = "bundle"
            // All language PDFs bundled
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}

// Strip non-EN PDF assets from lite flavor builds
android.applicationVariants.all variant@{
    val variantName = name
    if (variantName.startsWith("lite")) {
        mergeAssetsProvider.configure {
            doLast {
                val outputDir = outputDir.get().asFile
                outputDir.walkTopDown()
                    .filter { file -> file.isFile && file.name.endsWith(".pdf") }
                    .filter { file ->
                        val n = file.name
                        n.contains("_CS_") || n.contains("_ES_") ||
                        n.contains("_FR_") || n.contains("_RU_")
                    }
                    .forEach { file ->
                        println("Lite flavor: removing ${file.name}")
                        file.delete()
                    }
            }
        }
    }
}
