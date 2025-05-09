allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

allprojects {
    plugins.withId("com.android.library") {
        configure<com.android.build.gradle.LibraryExtension> {
            buildFeatures {
                buildConfig = true
            }
        }
    }
    plugins.withId("com.android.application") {
        configure<com.android.build.gradle.internal.dsl.BaseAppModuleExtension> {
            buildFeatures {
                buildConfig = true
            }
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
