import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    // END: FlutterFire Configuration
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    // Load keystore properties from repository root if available
    val keystorePropertiesFile = rootProject.file("../key.properties")
    val keystoreProperties = Properties()
    if (keystorePropertiesFile.exists()) {
        keystoreProperties.load(FileInputStream(keystorePropertiesFile))
    }

    namespace = "com.example.buang_yuk"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.buang_yuk"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
    
        signingConfigs {
            create("release") {
                // Load from key.properties when available
                if (keystoreProperties.isNotEmpty()) {
                    keyAlias = keystoreProperties.getProperty("keyAlias")
                    keyPassword = keystoreProperties.getProperty("keyPassword")
                    storeFile = file(keystoreProperties.getProperty("storeFile"))
                    storePassword = keystoreProperties.getProperty("storePassword")
                } else {
                    // fallback to environment variables or defaults
                    keyAlias = System.getenv("KEY_ALIAS") ?: "buangyuk"
                    keyPassword = System.getenv("KEY_PASSWORD") ?: "buangyukpass"
                    storeFile = file(System.getenv("KEYSTORE_PATH") ?: "keystore.jks")
                    storePassword = System.getenv("KEYSTORE_PASSWORD") ?: "buangyukstore"
                }
            }
        }

    buildTypes {
        release {
            // Use release signing config when available (loaded from key.properties)
                signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")
                isMinifyEnabled = true
                isShrinkResources = true
                proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
