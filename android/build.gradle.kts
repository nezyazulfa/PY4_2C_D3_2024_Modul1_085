allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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

// Menyuntikkan library ke semua plugin Android secara aman (tanpa afterEvaluate)
subprojects {
    plugins.withId("com.android.library") {
        dependencies {
            add("implementation", "androidx.concurrent:concurrent-futures:1.1.0")
            add("implementation", "com.google.guava:guava:31.1-android")
        }
    }
}