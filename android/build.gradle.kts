allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// flutter_sms 等の古いプラグインで Java/Kotlin JVM ターゲットが混在する問題を解消する
subprojects {
    afterEvaluate {
        extensions.findByType<com.android.build.gradle.LibraryExtension>()?.compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
            kotlinOptions {
                jvmTarget = JavaVersion.VERSION_17.toString()
            }
        }
    }
}

// AGP 8.x は namespace を必須とするが、古い Flutter プラグイン（isar_flutter_libs 等）は
// build.gradle に namespace を持たない。
// afterEvaluate では AGP のチェック後になり遅すぎるため、plugins.withId でプラグイン適用直後にフックし、
// AndroidManifest.xml の package 属性から namespace を補完する。
subprojects {
    plugins.withId("com.android.library") {
        val android =
            extensions.findByType(
                com.android.build.gradle.LibraryExtension::class.java,
            )
        if (android != null && android.namespace == null) {
            val manifestFile = project.file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val match =
                    Regex("""package\s*=\s*"([^"]+)"""")
                        .find(manifestFile.readText())
                if (match != null) {
                    android.namespace = match.groupValues[1]
                }
            }
        }
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
