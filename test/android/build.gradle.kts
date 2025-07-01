buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath(kotlin("gradle-plugin", version = "1.3.70"))
        classpath("com.android.tools.build:gradle:8.8.2")
        classpath("com.beust:klaxon:5.5")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        // maven(url = "https:// some custom repo")
        val nativeDir = if (System.getProperty("os.name").toLowerCase().contains("windows")) {
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
    delete(rootProject.buildDir)
}
