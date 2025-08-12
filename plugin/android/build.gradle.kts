buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10")
        classpath("com.android.tools.build:gradle:8.12.0")
        classpath("com.beust:klaxon:5.6")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // maven(url = "https:// some custom repo")
        val nativeDir = if (System.getProperty("os.name").lowercase().contains("windows")) {
            System.getenv("CORONA_ROOT")
        } else {
            "${System.getenv("HOME")}/Library/Application Support/Corona/Native/"
        }
        flatDir {
            dirs("$nativeDir/Corona/android/lib/gradle", "$nativeDir/Corona/android/lib/Corona/libs")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(layout.buildDirectory)
}
