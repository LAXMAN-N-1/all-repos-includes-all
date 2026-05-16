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
    namespace = "com.wezu.wezu_customer_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    configurations.all {
        resolutionStrategy {
            force("androidx.browser:browser:1.8.0")
            force("androidx.activity:activity:1.9.3")
            force("androidx.activity:activity-ktx:1.9.3")
            force("androidx.core:core:1.15.0")
            force("androidx.core:core-ktx:1.15.0")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.wezu.wezu_customer_app"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        manifestPlaceholders["GOOGLE_MAPS_API_KEY_ANDROID"] = googleMapsApiKey
        manifestPlaceholders["USES_CLEARTEXT_TRAFFIC"] = "false"
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
        debug {
            manifestPlaceholders["USES_CLEARTEXT_TRAFFIC"] = "true"
        }
        release {
            signingConfig = signingConfigs.getByName("release")
            manifestPlaceholders["USES_CLEARTEXT_TRAFFIC"] = "false"
        }
    }
}

flutter {
    source = "../.."
}
