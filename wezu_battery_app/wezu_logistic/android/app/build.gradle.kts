plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.io.FileInputStream
import java.util.Properties

val localPropertiesFile = rootProject.file("local.properties")
val googleMapsApiKey = if (localPropertiesFile.exists()) {
    localPropertiesFile.readLines()
        .map { it.trim() }
        .find { it.startsWith("GOOGLE_MAPS_API_KEY_ANDROID=") }
        ?.substringAfter("=")
        ?.trim()
        ?.removeSurrounding("\"")
        ?.removeSurrounding("'") ?: ""
} else ""

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val hasReleaseSigning = keystorePropertiesFile.exists() &&
    keystoreProperties["storeFile"] != null &&
    keystoreProperties["storePassword"] != null &&
    keystoreProperties["keyAlias"] != null &&
    keystoreProperties["keyPassword"] != null

android {
    namespace = "com.wezu.wezu_logistic"
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
        applicationId = "com.wezu.wezu_logistic"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        manifestPlaceholders["GOOGLE_MAPS_API_KEY_ANDROID"] = googleMapsApiKey
    }

    signingConfigs {
        create("release") {
            if (!hasReleaseSigning) {
                throw GradleException(
                    "Missing Android release signing config. Provide android/key.properties " +
                    "with storeFile, storePassword, keyAlias, keyPassword.",
                )
            }
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}
