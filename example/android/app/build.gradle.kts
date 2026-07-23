plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "io.admobflutterplus.admob_flutter_plus_example"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "io.admobflutterplus.admob_flutter_plus_example"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        // admob_flutter_plus requires minSdk 24.
        minSdk = maxOf(24, flutter.minSdkVersion)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Mediation is optional. Only when you add `com.google.ads.mediation:*` (or a
// partner SDK), uncomment the excludes + adapter lines below. See README → Mediation.
//
// configurations.configureEach {
//     exclude(group = "com.google.android.gms", module = "play-services-ads")
//     exclude(group = "com.google.android.gms", module = "play-services-ads-lite")
// }
//
// dependencies {
//     implementation("com.unity3d.ads:unity-ads:4.19.0")
//     implementation("com.google.ads.mediation:unity:4.19.0.0")
// }
