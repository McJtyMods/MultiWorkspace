# MultiWorkspace for Minecraft 26.3 / NeoForge

Use Java 25. The wrapper uses Gradle 9.2.1 with NeoGradle 7.1.39, targeting NeoForge 26.3.0.83.

Open this directory's `build.gradle` in IntelliJ. Available mods are included automatically from nested checkouts (`Multi_neo/McJtyLib`) or sibling checkouts (`../McJtyLib_neo`). Missing mods are skipped. Logical project names stay `:McJtyLib`, `:TheOneProbe`, etc., so dependency helpers resolve source projects consistently.

```sh
./gradlew projects
./gradlew :McJtyLib:build :McJtyLib:apiJar :workspace:classes
./gradlew :McJtyLib:portingRegression
./gradlew :McJtyLib:runGameTestServer
./gradlew :workspace:runClient
./gradlew :workspace:runServer
```

For checkouts elsewhere, pass `-Pmod.TheOneProbe=/path/to/TheOneProbe_neo` (or the corresponding logical mod name). Only include compatible 26.3 checkouts.

The `workspace` module loads every included mod, including McJtyLib, from its local main source outputs. It provides client and dedicated server runs. The coordinator itself is excluded from `MOD_CLASSES` because it has no mod descriptor. Its runtime classpath excludes jars for mods already loaded from source, so FML does not select a built jar over the source output during debugging. McJtyLib's separate game-test source set is loaded only by its own `runGameTestServer` task. The historical `co.sh` and version-switch scripts predate this branch; use the layout above to provision current checkouts.

The workspace SDK is configured before IDE launch arguments are captured. Asset index and directory arguments must contain resolved values, not literal `{asset_index}` or `{assets_root}` placeholders; unresolved values cause missing menu backgrounds, icons, and sounds. Reload the Gradle projects after changing this configuration to refresh the IntelliJ runs.

After changing workspace run settings, use **Reload All Gradle Projects** in IntelliJ, then run `./gradlew ideSync` from this directory and select **Workspace: Client**. Regenerate existing configurations so their `MOD_CLASSES` no longer contains `workspace%%...`. A launch that reports `workspace/build/resources/main is not a valid mod file` is still using the old configuration; subsequent scan cancellations are a consequence of the loader shutting down.

## Shared build settings

`gradletools.gradle` owns Minecraft/NeoForge versions, repositories, dependency helpers, runs, jars, and publishing. McJtyLib applies this script directly from the root in an integrated build, or from the sibling/parent workspace in a standalone build. Its remote fallback points to `MultiWorkspace/26.3_neo/gradletools.gradle`. Local script copies inside McJtyLib are unnecessary.

| Helper | 26.3 configuration |
| --- | --- |
| `mc()` | NeoForge `26.3.0.83` |
| `top()` | Source project when included; otherwise `mcjty.theoneprobe:theoneprobe:26.3_neo-16.0.0-1` |
| `jei()` | 26.3 common/NeoForge APIs and NeoForge runtime `31.12.0.65` |
| `sereneseasons()` | `26.3-26.1.2.0.7` |
| `mcjtylib()` | Local source project when included; otherwise the published artifact pinned in `gradletools.gradle` |
| `rftoolsbase()` | Source project when included; otherwise published artifact `26.3-9.0.0-1` |
| `lostcities()` | Source project, otherwise require an explicit compatible version |
| `patchouli()`, `curios()`, `gamestages()` | Require explicit compatible versions |

JEI's pinned 26.3 release appears on [its Maven repository](https://maven.blamejared.com/mezz/jei/jei-26.3-neoforge/). TOP was available from the existing local 26.3 checkout/Maven installation during port validation. Until it is published, include the TOP checkout or publish it to Maven Local. Helpers never fall back automatically to old Forge/1.21 artifacts. `gamestages()` requires both `bookshelf_version` and `gamestages_version`.

Datagen runs are `runClientData` and `runServerData`; output goes to each mod's `src/generated/resources`. Only invoke them for mods that register data providers. Publishing credentials and destinations retain their existing configuration.

## Validation

McJtyLib's main sources compiled against cached 26.3 Minecraft/NeoForge artifacts. Four JUnit checks and eight NeoForge game tests passed, including a runtime load alongside TOP. The sandbox prevented Gradle startup because local networking was unavailable, and blocked dependency downloads. The configured 26.3 JEI artifacts were not cached; compile validation used the cached 26.2 API. Full standalone/workspace Gradle builds, JEI runtime, datagen, and interactive client validation remain to be checked outside that restriction.

The workspace startup fix was checked by evaluating its run configuration and directly launching a headless NeoForge game-test server with all eight currently included source mods and Jenkins McJtyLib `26.3-11.0.1.4`. All seven XNet port regression tests passed. Interactive client startup and Gradle regeneration of IntelliJ run configurations still require verification in the desktop environment.

## HoloGui, Ariente and ArienteWorld

The 26.3 NeoForge workspace includes sibling `ModHoloGui_neo`, `Ariente_neo` and
`ArienteWorld_neo` checkouts. Their dependency chain uses the local McJtyLib,
The One Probe, HoloGui and Ariente source sets. The McJtyLib standalone fallback
is now `26.3-11.0.4`; publish that library and the updated shared script before
distributing standalone builds of these ports.

The verified Tutorial save is installed under `workspace/run/saves/Tutorial`.
Launch `:workspace:runClient` and select **Tutorial**. Creation, restart checks,
camera/tank pixel checks and standalone builds are described in the
[26.3 port report](../ArienteWorld_neo/PORT_26_3.md).

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
