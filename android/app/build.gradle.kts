plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.app_final_class"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.app_final_class"
        minSdk = 23
        targetSdk = 28
        multiDexEnabled = true
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("com.android.support:multidex:1.0.3")
    implementation(platform("com.google.firebase:firebase-bom:33.10.0"))
    // TODO: เพิ่ม dependencies อื่นๆ ของ Firebase ที่คุณต้องการ
}

// ไม่จำเป็นต้องมี apply plugin เนื่องจากใส่ไว้ใน plugins แล้ว