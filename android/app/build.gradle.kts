import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
} else {
    println("⚠️ key.properties not found. Release signing will fail unless you create it.")
}

android {
    namespace = "com.example.seller_loop" // TODO: set your final package
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.dealzyloop.partner" // TODO: set your final applicationId (must match Play listing)
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        vectorDrawables { useSupportLibrary = true }
    }

    // ---- SIGNING CONFIGS ----
    signingConfigs {
        create("release") {
            val store = keystoreProperties["storeFile"] as? String
            if (store != null) {
                storeFile = file(store)
            }
            storePassword = keystoreProperties["storePassword"] as? String
            keyAlias = keystoreProperties["keyAlias"] as? String
            keyPassword = keystoreProperties["keyPassword"] as? String
        }
    }

    // ---- BUILD TYPES ----
    buildTypes {
        getByName("debug") {
            // Debug keeps default debug signing
            isMinifyEnabled = false
            isShrinkResources = false
        }
        getByName("release") {
            // Use the real release keystore (not debug!)
            signingConfig = signingConfigs.getByName("release")

            // Optimize release builds
            isMinifyEnabled = true
            isShrinkResources = true

            // If you use reflection/JSON (e.g., Gson), keep rules here:
            // proguardFiles(
            //     getDefaultProguardFile("proguard-android-optimize.txt"),
            //     "proguard-rules.pro"
            // )
        }
    }

    buildFeatures {
        buildConfig = true
    }

    packaging {
        resources.excludes += setOf("META-INF/AL2.0", "META-INF/LGPL2.1")
    }
}

flutter {
    source = "../.."
}
