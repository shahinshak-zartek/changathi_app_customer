import org.gradle.api.GradleException
import java.util.Properties
import java.io.FileInputStream
import java.util.zip.ZipFile
plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
    // The Flutter Gradle Plugin must be applied after the Android Gradle plugin.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}
val codemagicSigningValues = listOf(
    "CM_KEYSTORE_PATH",
    "CM_KEYSTORE_PASSWORD",
    "CM_KEY_ALIAS",
    "CM_KEY_PASSWORD",
).associateWith { System.getenv(it).orEmpty() }
val hasCodemagicSigning = codemagicSigningValues.values.all { it.isNotBlank() }

android {
    namespace = "com.nizhal.customer"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    signingConfigs {
        create("release") {
            if (hasCodemagicSigning) {
                keyAlias = codemagicSigningValues.getValue("CM_KEY_ALIAS")
                keyPassword = codemagicSigningValues.getValue("CM_KEY_PASSWORD")
                storeFile = file(codemagicSigningValues.getValue("CM_KEYSTORE_PATH"))
                storePassword = codemagicSigningValues.getValue("CM_KEYSTORE_PASSWORD")
            } else if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.nizhal.customer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            isMinifyEnabled = true
            isShrinkResources = true
            signingConfig = signingConfigs.getByName("release")
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

val requiredFlutterNativeLibraries = listOf(
    "base/lib/arm64-v8a/libflutter.so",
    "base/lib/armeabi-v7a/libflutter.so",
)

val validateReleaseNativeLibraries = tasks.register("validateReleaseNativeLibraries") {
    group = "verification"
    description = "Verifies the release AAB contains Flutter native libraries for required Android ABIs."

    doLast {
        val releaseBundle = layout.buildDirectory
            .file("outputs/bundle/release/app-release.aab")
            .get()
            .asFile

        if (!releaseBundle.exists()) {
            throw GradleException(
                "Release AAB not found at ${releaseBundle.absolutePath}. " +
                    "Build the Play app bundle with :app:bundleRelease before validation."
            )
        }

        val missingLibraries = ZipFile(releaseBundle).use { bundle ->
            requiredFlutterNativeLibraries.filter { bundle.getEntry(it) == null }
        }

        if (missingLibraries.isNotEmpty()) {
            throw GradleException(
                "Release AAB is missing required Flutter native libraries:\n" +
                    missingLibraries.joinToString(separator = "\n") { " - $it" } +
                    "\nBuild a Play AAB that includes arm64-v8a and armeabi-v7a. " +
                    "Do not use restricted --target-platform flags for production releases."
            )
        }

        logger.lifecycle(
            "Verified release AAB contains required Flutter native libraries: " +
                requiredFlutterNativeLibraries.joinToString()
        )
    }
}

tasks.matching { it.name == "bundleRelease" }.configureEach {
    finalizedBy(validateReleaseNativeLibraries)
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("androidx.multidex:multidex:2.0.1")

    configurations.all {
        resolutionStrategy {
            force("org.bouncycastle:bcprov-jdk18on:1.76")
        }
    }
}
