plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}




def localProperties = new Properties()
def localPropertiesFile = rootProject.file('local.properties')
if (localPropertiesFile.exists()) {
    localPropertiesFile.withReader('UTF-8') { reader ->
        localProperties.load(reader)
    }
}

def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
if (flutterVersionCode == null) {
    flutterVersionCode = '1'
}

def flutterVersionName = localProperties.getProperty('flutter.versionName')
if (flutterVersionName == null) {
    flutterVersionName = '1.0'
}

def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}


android {
    namespace = "com.gambley1.spaxey"
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
        // Base applicationId (no .dev here, suffix handles that)
        applicationId = "com.gambley1.spaxey"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Define flavors
    flavorDimensions += "environment"

    productFlavors {
        create("development") {
            dimension = "environment"
            applicationIdSuffix = ".dev"        // → com.gambley1.spaxey.dev
            resValue("string", "app_name", "Spaxey Dev")
        }
        create("production") {
            dimension = "environment"
            // → com.gambley1.spaxey
            resValue("string", "app_name", "Spaxey")
        }
    }

    buildTypes {
        release {
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
