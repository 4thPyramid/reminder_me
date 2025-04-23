plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin") // يجب أن يكون بعد android و kotlin
}

android {
    namespace = "com.example.reminder_me" // تأكد من أنه هو نفس الـ package في AndroidManifest.xml
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // تم التعديل هنا حسب الخطأ اللي ظهر لك

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        // ✅ إضافة هذا السطر لتفعيل Java 8 features
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.reminder_me"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    // ✅ ضروري جداً لهذا الخطأ:
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
