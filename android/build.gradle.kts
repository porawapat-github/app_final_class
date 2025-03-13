buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.2.0")
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir = layout.buildDirectory.dir("../../build")

subprojects {
    project.layout.buildDirectory.set(newBuildDir.map { it.dir(project.name) })
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}