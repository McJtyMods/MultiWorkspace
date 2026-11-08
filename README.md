# MultiWorkspace
Setup for a multi-mod workspace

Individual mods should be 'git cloned' inside subfolders of this project.
Modify settings.gradle as well as workspace/build.gradle for all your mods.
Inside the mods/build.gradle you should have the following construct to make sure the mods are still compilable standalone as well as inside the multi-project:

    if (findProject(':McJtyLib') != null) {
        implementation project(':McJtyLib')
    } else {
        implementation("com.github.mcjty:mcjtylib:${mcjtylib_version}") {
            transitive = false
        }
    }

To setup this project, just open the root (empty) build.gradle as a project in IDEA. Run genIntellijRuns and select the one for the 'workspace' module


This branch targets Minecraft 1.21.1 / NeoForge with Java 21. HoloGui (`ModHoloGui`), Ariente and ArienteWorld are included in the workspace client/server and use local McJtyLib and The One Probe sources.

Focused checks:

```sh
./gradlew :ModHoloGui:build :Ariente:build :ArienteWorld:build
./gradlew :Ariente:runData :ArienteWorld:runData
./gradlew :ArienteWorld:runGameTestServer
```

Individual development runs use isolated `build/verification/<run>` directories. The integrated workspace continues to use its usual run directory. See `ArienteWorld/PORT_1_21.md` for verification scope and the optional client fixture.
