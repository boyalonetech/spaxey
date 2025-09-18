plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("org.jetbrains.kotlin.android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = java.util.Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.reader(Charsets.UTF_8).use { reader ->
        localProperties.load(reader)
    }
}

val flutterVersionCode: String = localProperties.getProperty("flutter.versionCode") ?: "1"
val flutterVersionName: String = localProperties.getProperty("flutter.versionName") ?: "1.0"

val keystoreProperties = java.util.Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(java.io.FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.gambley1.spaxey"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        // Base applicationId (no .dev here, suffix handles that)
        applicationId = "com.gambley1.spaxey"
        minSdk = maxOf(flutter.minSdkVersion, 24) // ensure API 24+
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Define flavors
    flavorDimensions += "environment"

    productFlavors {
        create("development") {
            dimension = "environment"
            applicationIdSuffix = ".dev" // → com.gambley1.spaxey.dev
            resValue("string", "app_name", "Spaxey Dev")
        }
        create("production") {
            dimension = "environment"
            // → com.gambley1.spaxey
            resValue("string", "app_name", "Spaxey")
        }
    }

    buildTypes {
        getByName("release") {
            // TODO: Replace with your real release signing config
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    // Ensure flavor-specific google-services.json files are picked up
    sourceSets["development"].assets.srcDirs("src/development/assets")
    sourceSets["production"].assets.srcDirs("src/production/assets")
}

flutter {
    source = "../.."
}
