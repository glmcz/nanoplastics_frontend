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

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    signingConfigs {
        create("release") {
            val keystorePath = System.getenv("KEYSTORE_PATH")
            val keystorePassword = System.getenv("KEYSTORE_PASSWORD")
            val keyAliasEnv = System.getenv("KEY_ALIAS")
            val keyPasswordEnv = System.getenv("KEY_PASSWORD")
            
            if (!keystorePath.isNullOrEmpty() && !keystorePassword.isNullOrEmpty()) {
                storeFile = file(keystorePath)
                storePassword = keystorePassword
                keyAlias = keyAliasEnv ?: "release-key"
                keyPassword = keyPasswordEnv ?: keystorePassword
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
            val keystorePath = System.getenv("KEYSTORE_PATH")
            val keystorePassword = System.getenv("KEYSTORE_PASSWORD")
            
            // Only set signing config if environment variables are available (CI/CD)
            if (!keystorePath.isNullOrEmpty() && !keystorePassword.isNullOrEmpty()) {
                signingConfig = signingConfigs.getByName("release")
            }
            // Local builds will use debug signing
            
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    packaging {
        resources {
            // Exclude non-English PDFs from lite flavor
            // These are downloaded on-demand instead of being bundled
            excludes += "assets/docs/Nanoplastics_Report_CS_compressed.pdf"
            excludes += "assets/docs/Nanoplastics_Report_ES_compressed.pdf"
            excludes += "assets/docs/Nanoplastics_Report_FR_compressed.pdf"
            excludes += "assets/docs/Nanoplastics_Report_RU_compressed.pdf"
            excludes += "assets/docs/CS_WATER_compressed.pdf"
        }
    }
}

flutter {
    source = "../.."
}

// Flavor-specific packaging options for asset inclusion
android.applicationVariants.all variant@{
    val variantName = name
    if (variantName.startsWith("full")) {
        // Full flavor includes all language assets
        println("Building full flavor: including all language PDFs")
    } else if (variantName.startsWith("lite")) {
        // Lite flavor uses packagingOptions.exclude above
        println("Building lite flavor: excluding non-EN PDFs from assets")
    }
}
