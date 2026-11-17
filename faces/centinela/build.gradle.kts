plugins {
    alias(libs.plugins.android.application)
}

android {
    // Watch Face Format bundles are resource-only: no Kotlin/Java code.
    enableKotlin = false
    namespace = "com.vidix.centinela"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.vidix.centinela"
        // WFF v4 requires Wear OS 6 (API 36).
        minSdk = 36
        targetSdk = 36
        versionCode = 1
        versionName = "1.0.0"
    }

    buildTypes {
        debug {
            isMinifyEnabled = true
        }
        release {
            isMinifyEnabled = true
            // Must stay false so WFF resources are not stripped.
            isShrinkResources = false
            // Personal use only: signed with the debug key.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}
