import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// <<< LA CORRECTION EST ICI >>>
// Le script lit maintenant "key.properties" au bon endroit.
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties") // Chemin Corrigé
if (keystorePropertiesFile.exists()) {
    keystorePropertiesFile.reader().use { reader ->
        keystoreProperties.load(reader)
    }
}
// >>> FIN DE LA CORRECTION

android {
    namespace = "com.example.landeroel25"
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
        applicationId = "fr.landerneau_boutiques.landernoel"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // Ce bloc crée la configuration "release"
    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }
        }
    }

    // Ce bloc dit au build "release" d'utiliser la configuration ci-dessus
    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}