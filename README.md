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

NeoGradle's generated library lists contain absolute paths to the current
checkout. The shared `gradletools.gradle` includes the project directory in those
tasks' cache keys, preventing Jenkins jobs from restoring another job's paths
while retaining caching for repeated builds in the same checkout. Standalone
builds receive this configuration through their normal shared-script lookup.

Focused checks:

```sh
./gradlew :ModHoloGui:build :Ariente:build :ArienteWorld:build
./gradlew :Ariente:runData :ArienteWorld:runData
./gradlew :ArienteWorld:runGameTestServer
```

Individual development runs use isolated `build/verification/<run>` directories. The integrated workspace continues to use its usual run directory. See `ArienteWorld/PORT_1_21.md` for verification scope and the optional client fixture.

## Gradle cache isolation

The workspace wrappers default to `./.gradle-user-home`, keeping this Minecraft
version and loader's assets, NeoGradle/Loom caches, dependencies, and daemons
separate from other workspaces. An explicit `GRADLE_USER_HOME` or
`--gradle-user-home` is supported, but must belong to this same target. The
`.minecraft-target` marker rejects reuse by another version or loader, including
through symlinks. The shared `~/.gradle` home is rejected before project setup.
Keep private cache directories separate; do not symlink their mutable contents.
NeoGradle library-list cache keys include the home and checkout paths so moving
to a new home regenerates lists containing absolute dependency paths.

The asset files also need their version-specific index in
`caches/minecraft/assets/indexes`. `prepareVanillaAssets` downloads or restores
that index and checks every referenced asset. Both `runClient` and IntelliJ's
`ideBeforeRun` run this check, so a missing index cannot silently remove vanilla
sounds and menu backgrounds. Download cache keys include Mojang's index hash,
because an index can change without a new Minecraft version. After creating a
new home, run
`./gradlew :workspace:prepareVanillaAssets` online before launching a client.

Install the home guard for standalone builds after checkout or recreating the
private home:

```sh
python3 tools/configure-gradle-home.py
```

In each IntelliJ project, open **Settings > Build, Execution, Deployment >
Build Tools > Gradle** and set **Gradle user home** to the absolute
`.gradle-user-home` path printed by the helper. Click **Apply**, then reload all
Gradle projects to regenerate the Minecraft run configurations before launching.
The field sits above the per-Gradle-build settings and applies to all Gradle
builds linked in the current IntelliJ project/window. Open different Minecraft
workspaces as separate IntelliJ projects, each with its own home. IntelliJ stores
this value per IDE project, but also updates an application default that projects
without their own value can inherit. Set each workspace's home explicitly; the
target guard rejects an incorrectly inherited home. Setting
`serviceDirectoryPath` in `.idea/gradle.xml` is ignored
by current IntelliJ versions. The helper prepares the home and prints these
instructions. IntelliJ does not execute the `gradlew` shell script. Old
Application configurations still reference old absolute cache paths until
regenerated.

For standalone mod builds, use this workspace's wrapper with `-p /path/to/mod`,
or use the mod's wrapper with
`--gradle-user-home /path/to/workspace/.gradle-user-home`. The installed init
script also checks standalone and IDE builds using that home. CI should allocate
one Gradle user home per Minecraft version and loader (or per checkout). A fresh
home downloads its own dependencies; do not copy old NeoGradle execution caches
or generated absolute-path library lists into it. User-level `gradle.properties`
and credentials are not copied; supply any required settings separately.
When porting the workspace, update `minecraftTarget` in
`gradle/gradle-home.init.gradle` and use a fresh home for the new target.
Preserve the wrapper customizations when upgrading Gradle.
