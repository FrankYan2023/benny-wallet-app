import java.io.File
import java.io.FileInputStream
import java.util.Properties
import org.gradle.api.GradleException

fun loadPropertiesFrom(filePath: File): Properties {
    return Properties().apply {
        if (filePath.exists()) {
            FileInputStream(filePath).use { load(it) }
        }
    }
}

fun resolvePath(projectRoot: File, pathValue: String?): File? {
    if (pathValue.isNullOrBlank()) {
        return null
    }

    val candidate = File(pathValue)
    return if (candidate.isAbsolute) candidate else projectRoot.resolve(pathValue)
}

val localProperties = loadPropertiesFrom(rootProject.file("local.properties"))
val keyProperties = loadPropertiesFrom(rootProject.file("key.properties"))

val releaseStoreFile = resolvePath(
    rootProject.projectDir,
    System.getenv("BENNY_RELEASE_STORE_FILE")
        ?: keyProperties.getProperty("storeFile")
        ?: localProperties.getProperty("KEYSTORE_PATH"),
)
val releaseStorePassword =
    System.getenv("BENNY_RELEASE_STORE_PASSWORD")
        ?: keyProperties.getProperty("storePassword")
        ?: localProperties.getProperty("KEYSTORE_PASSWORD")
val releaseKeyAlias =
    System.getenv("BENNY_RELEASE_KEY_ALIAS")
        ?: keyProperties.getProperty("keyAlias")
        ?: localProperties.getProperty("KEY_ALIAS")
val releaseKeyPassword =
    System.getenv("BENNY_RELEASE_KEY_PASSWORD")
        ?: keyProperties.getProperty("keyPassword")
        ?: localProperties.getProperty("KEY_PASSWORD")

val hasReleaseSigning =
    releaseStoreFile?.exists() == true &&
        !releaseStorePassword.isNullOrBlank() &&
        !releaseKeyAlias.isNullOrBlank() &&
        !releaseKeyPassword.isNullOrBlank()

val liteSeekerApplicationId =
    System.getenv("BENNY_LITE_SEEKER_APPLICATION_ID")
        ?: localProperties.getProperty("LITE_SEEKER_APPLICATION_ID")
        ?: "com.benny.wallet.lite.seeker"

val requestedTasks = gradle.startParameter.taskNames.joinToString(" ")
val buildingRelease = requestedTasks.contains("Release", ignoreCase = true)

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.benny.wallet"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    flavorDimensions += "distribution"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    // 🔐 Modern Gradle syntax for compiler options
    kotlin {
        jvmToolchain(17)
    }

    signingConfigs {
        create("release") {
            if (hasReleaseSigning) {
                storeFile = releaseStoreFile
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
                enableV1Signing = true
                enableV2Signing = true
                logger.lifecycle("[SIGNING] Release signing configured: ${releaseStoreFile!!.absolutePath}")
            } else {
                logger.warn(
                    "[SIGNING] Release signing not configured. Add android/key.properties " +
                        "or export BENNY_RELEASE_STORE_FILE / BENNY_RELEASE_STORE_PASSWORD / " +
                        "BENNY_RELEASE_KEY_ALIAS / BENNY_RELEASE_KEY_PASSWORD.",
                )
            }
        }
    }

    defaultConfig {
        applicationId = "com.benny.wallet"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    productFlavors {
        // Lite and full variants share the same Flutter codebase while using
        // separate package identifiers.
        create("liteStore") {
            dimension = "distribution"
            applicationId = "com.benny.wallet.lite"
            resValue("string", "app_name", "Benny Wallet Lite")
        }
        create("liteSeeker") {
            dimension = "distribution"
            applicationId = liteSeekerApplicationId
            resValue("string", "app_name", "Benny Wallet Lite Seeker")
        }
        create("full") {
            dimension = "distribution"
            applicationId = "com.benny.wallet"
            resValue("string", "app_name", "Benny Wallet Full")
        }
    }

    buildTypes {
        release {
            if (buildingRelease && !hasReleaseSigning) {
                throw GradleException(
                    "Release signing is not configured. Add apps/wallet_client_flutter/android/key.properties " +
                        "with storeFile/storePassword/keyAlias/keyPassword, or export the BENNY_RELEASE_* environment variables.",
                )
            }
            if (hasReleaseSigning) {
                signingConfig = signingConfigs.getByName("release")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
        debug {
            // Debug uses default debug keystore
            isDebuggable = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
    implementation("androidx.core:core-splashscreen:1.0.1")
    implementation("com.solanamobile:mobile-wallet-adapter-clientlib-ktx:2.1.0")
    implementation("com.solanamobile:seedvault-wallet-sdk:0.4.0")
}
