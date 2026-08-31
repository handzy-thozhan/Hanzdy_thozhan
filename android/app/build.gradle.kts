plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

configurations.all {
    resolutionStrategy {
        force("androidx.concurrent:concurrent-futures:1.2.0")
    }
}

android {
    namespace = "com.handzy.thozhan"

    compileSdk = 37

    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17

        // Required by flutter_local_notifications
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.handzy.thozhan"

        minSdk = flutter.minSdkVersion

        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode

        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig =
                signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget =
            org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
    
}

flutter {
    source = "../.."
}

dependencies {
    // Required by flutter_local_notifications
    coreLibraryDesugaring(
        "com.android.tools:desugar_jdk_libs:2.1.5"
    )
}