plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
    // NUEVA LÍNEA: Agrega el plugin de Google Services aquí
    id "com.google.gms.google-services"
}

android {
    namespace = "com.example.msa"
    compileSdk = flutter.compileSdkVersion
    compileOptions {
        // Habilita el "traductor" (desugaring)
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.example.msa"
        minSdk flutter.minSdkVersion
        targetSdk flutter.targetSdkVersion
        versionCode 1
        versionName "1.0"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source "../.."
}

dependencies {
    // La dependencia del "traductor"
    coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.0.4"
    // NUEVA LÍNEA: Agrega la plataforma de Firebase
    implementation platform("com.google.firebase:firebase-bom:32.7.4")
    // NUEVA LÍNEA: Agrega las dependencias de Firebase
    implementation "com.google.firebase:firebase-analytics"
    implementation "com.google.firebase:firebase-messaging"
}