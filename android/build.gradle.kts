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

// Workaround: set a default namespace for Android library modules (3rd-party plugins)
// This helps with older plugins that don't specify `namespace` in their build files
// and avoids AGP configuration failures during CI (e.g. install_plugin).
subprojects {
    plugins.withId("com.android.library") {
        try {
            val extObj = extensions.findByName("android")
            if (extObj != null) {
                try {
                    val clazz = extObj.javaClass
                    val getNs = try {
                        clazz.getMethod("getNamespace")
                    } catch (e: NoSuchMethodException) {
                        null
                    }
                    val currentNs = getNs?.invoke(extObj) as? String
                    if (currentNs.isNullOrEmpty()) {
                        val defaultNs = "com.example." + project.name.replace('-', '_')
                        try {
                            val setNs = clazz.getMethod("setNamespace", String::class.java)
                            setNs.invoke(extObj, defaultNs)
                        } catch (e: NoSuchMethodException) {
                            try {
                                val field = clazz.getDeclaredField("namespace")
                                field.isAccessible = true
                                field.set(extObj, defaultNs)
                            } catch (_: Throwable) {
                                // ignore - best effort
                            }
                        }
                    }
                } catch (_: Throwable) {
                    // ignore - best effort
                }
            }
        } catch (_: Throwable) {
            // ignore if Android plugin classes are not available during evaluation
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
