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

After adding or removing mods in the workspace run definitions, run
`./gradlew :workspace:genIntellijRuns` again with Java 17. Refreshing Gradle
alone does not regenerate the saved IntelliJ launch configurations' `MOD_CLASSES`
environment variable. Use `workspace runClient` for the generated application
configuration, or the Gradle task `:workspace:runClient`.

The combined workspace includes Embeddium 0.3.31 and Oculus 1.8.0 as runtime
dependencies for shader support on Forge 1.20.1. Reload the Gradle project in
IDEA after changing dependencies.

To use Complementary shaders:

1. Download either [Complementary Unbound or Reimagined](https://www.complementary.dev/shaders/).
2. Place the shader pack ZIP, without extracting it, in `workspace/run/shaderpacks/`.
3. Launch `workspace_runClient` in IDEA, or run `./gradlew :workspace:runClient` with Java 17.
4. Open Options → Video Settings → Shader Packs, select Complementary, and apply.

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
