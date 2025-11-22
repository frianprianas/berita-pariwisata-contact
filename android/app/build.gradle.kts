plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "id.smkbaknus666.wartawisata"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        // Keep applicationId stable and consistent with other platform bundle IDs.
        // If you prefer a different id, change it here. We align it with the iOS bundle id by default.
        applicationId = "id.smkbaknus666.beritapariwisata"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Signing config reads secure values from `android/gradle.properties` (not committed to VCS).
    // Add the following properties to `android/gradle.properties` on your machine or CI:
    // KEYSTORE_FILE=/absolute/or/relative/path/to/keystore.jks
    // KEYSTORE_PASSWORD=your_store_password
    // KEY_ALIAS=your_key_alias
    // KEY_PASSWORD=your_key_password
    signingConfigs {
        create("release") {
            val ksFileProp = project.findProperty("KEYSTORE_FILE")?.toString()
            val ksPasswordProp = project.findProperty("KEYSTORE_PASSWORD")?.toString()
            val keyAliasProp = project.findProperty("KEY_ALIAS")?.toString()
            val keyPasswordProp = project.findProperty("KEY_PASSWORD")?.toString()

            if (!ksFileProp.isNullOrEmpty()) {
                storeFile = file(ksFileProp)
            }
            if (!ksPasswordProp.isNullOrEmpty()) {
                storePassword = ksPasswordProp
            }
            if (!keyAliasProp.isNullOrEmpty()) {
                keyAlias = keyAliasProp
            }
            if (!keyPasswordProp.isNullOrEmpty()) {
                keyPassword = keyPasswordProp
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            isShrinkResources = false
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
