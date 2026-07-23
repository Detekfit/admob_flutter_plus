group = "io.admobflutterplus.admob_flutter_plus"
version = "1.0-SNAPSHOT"

buildscript {
    // Pin to the Flutter plugin ecosystem AGP (same as shared_preferences /
    // google_mobile_ads). Host apps keep their own AGP/Gradle; do not chase
    // bleeding-edge AGP here — mismatched classpaths break path/pub builds.
    val kotlinVersion = "2.3.0"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.13.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
}

android {
    namespace = "io.admobflutterplus.admob_flutter_plus"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        minSdk = 24
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()
                it.outputs.upToDateWhen { false }
                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

// Mediation is optional. Host apps that add `com.google.ads.mediation:*` should
// exclude legacy Play Services Ads modules in *their* app Gradle (see README).
// Do not apply those excludes here by default — they are only needed with adapters.

dependencies {
    // Google Mobile Ads Next-Gen SDK.
    // See CONTRIBUTING.md for the process to bump this after reading release notes.
    implementation("com.google.android.libraries.ads.mobile.sdk:ads-mobile-sdk:1.3.0")
    // User Messaging Platform (UMP) for consent.
    implementation("com.google.android.ump:user-messaging-platform:4.0.0")
    // Process-level lifecycle for app open ads.
    implementation("androidx.lifecycle:lifecycle-process:2.11.0")
    // Coroutines for off-main-thread initialization.
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.11.0")

    testImplementation("org.jetbrains.kotlin:kotlin-test")
    testImplementation("org.mockito:mockito-core:5.0.0")
}
