# MultiWorkspace
Setup for a multi-mod workspace

Individual mods should be 'git cloned' inside subfolders of this project.
Modify settings.gradle as well as workspace/build.gradle for all your mods.
Inside the mods/build.gradle you should have the following construct to make sure the mods are still compilable standalone as well as inside the multi-project:

    if (findProject(':McJtyLib') != null) {
        implementation project(':McJtyLib')
    } else {
        implementation fg.deobf (project.dependencies.create("com.github.mcjty:mcjtylib:${mcjtylib_version}") {
            transitive = false
        })
    }

To setup this project, just open the root (empty) build.gradle as a project in IDEA. Run genIntellijRuns and select the one for the 'workspace' module

The combined workspace includes Embeddium 0.3.31 and Oculus 1.8.0 as runtime
dependencies for shader support on Forge 1.20.1. Reload the Gradle project in
IDEA after changing dependencies.

To use Complementary shaders:

1. Download either [Complementary Unbound or Reimagined](https://www.complementary.dev/shaders/).
2. Place the shader pack ZIP, without extracting it, in `workspace/run/shaderpacks/`.
3. Launch `workspace_runClient` in IDEA, or run `./gradlew :workspace:runClient` with Java 17.
4. Open Options → Video Settings → Shader Packs, select Complementary, and apply.
