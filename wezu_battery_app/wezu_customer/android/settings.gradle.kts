pluginManagement {
    val flutterSdkPath =
        run {
            val propertiesFile = file("local.properties")
            if (!propertiesFile.exists()) {
              throw GradleException("local.properties not found. Please run 'flutter pub get' in the project root.")
            }
            val path = propertiesFile.readLines()
                .map { it.trim() }
                .find { it.startsWith("flutter.sdk=") }
                ?.substringAfter("=")
                ?.trim()
            if (path == null) {
              throw GradleException("flutter.sdk not set in local.properties")
            }
            path
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.0" apply false
    id("org.jetbrains.kotlin.android") version "2.3.10" apply false
}

include(":app")
