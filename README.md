# MultiWorkspace for Minecraft 26.2 / NeoForge

Use Java 25. The wrapper runs Gradle 9.2.1 with NeoGradle 7.1.38.

Open this directory's `build.gradle` in IntelliJ. Available mods are included automatically from either nested checkouts (`Multi_neo/McJtyLib`) or sibling checkouts (`../McJtyLib_neo`). Missing mods are skipped. Logical project names stay `:McJtyLib`, `:TheOneProbe`, etc., so shared dependency helpers resolve source projects consistently.

For checkouts elsewhere, pass their location as a Gradle property:

```sh
./gradlew projects
./gradlew :workspace:runClient -Pmod.TheOneProbe=/path/to/Top26_2
./gradlew :workspace:runServer
./gradlew :McJtyLib:build
./gradlew :McJtyLib:runClientData
```

The `workspace` module adds every included mod as both `modSource` and `implementation`. It supplies client and dedicated server runs without an example mod. Individual repositories retain standalone builds. HoloGui (`:ModHoloGui`), Ariente and ArienteWorld are included when their checkouts exist. Additional mods can be added to the list in `settings.gradle`; the runtime aggregator follows that list automatically.

The aggregator disables NeoGradle's automatic inclusion of its own empty sources as a mod and configures its NeoForge runtime before IDE run configurations are finalized. Its primary source set supplies the runtime classpath without adding an empty mod to `MOD_CLASSES`. The shared script keeps client assets in a Minecraft-version-specific directory so preparing another workspace cannot remove them. Client asset index, asset directory, and native-library arguments must contain resolved values in both Gradle and IntelliJ launches; literal `{asset_index}` or `{assets_root}` values cause missing menu backgrounds, icons, and sounds. Reload the Gradle projects after changing this configuration to regenerate existing IntelliJ run arguments.

Both the IDE runtime classpath and Gradle runs exclude jars for mods already supplied through `modSource`. The shared script also selects class directories for included runtime projects and loads their transitive sources. This keeps development runs on the local classes instead of letting FML select a previously built jar. After changing this configuration, reload all Gradle projects in IntelliJ before launching the workspace again.

## Shared build script

`gradletools.gradle` owns Minecraft/NeoForge versions, repositories, dependency helpers, development runs, jars, and publishing. A module should apply the root workspace script, then an optional standalone local copy, then the remote `26.2_neo` script. McJtyLib and the Ariente-family mods also accept `-Pgradletools_path` and the sibling `../Multi_neo/gradletools.gradle` before a standalone local copy or the remote script.

While this branch is unpublished, copy the script into a standalone McJtyLib checkout:

```sh
cp ../Multi_neo/gradletools.gradle gradletools.gradle
```

Run that command inside `McJtyLib_neo`. Keep the copy byte-for-byte identical and exclude `/gradletools.gradle` in that checkout's `.git/info/exclude`. The copy is a local build aid and must not be committed or pushed.

## Dependencies

The configured versions below are actual 26.2 artifacts verified in the local Maven/Gradle caches; they are pinned versions, not claims about the latest release.

| Helper | 26.2 configuration |
| --- | --- |
| `mc()` | NeoForge `26.2.0.75` |
| `top()` | `mcjty.theoneprobe:theoneprobe:26.2_neo-15.0.1-2` |
| `jei()` | JEI common/NeoForge APIs and NeoForge runtime `30.30.0.204` |
| `sereneseasons()` | `26.2-26.1.2.0.6` |
| `mcjtylib()` | Source project when included; standalone version `26.2-10.0.3` once published |
| `rftoolsbase()` | Source project when included; standalone artifact `26.2-8.0.0-1` (runtime mod version `26.2-8.0.0`) |
| `lostcities()` | Source project, otherwise require an explicit compatible version |
| `patchouli()`, `curios()`, `gamestages()` | No verified 26.2 release configured; requesting one fails with an explanation |

Published artifacts can be checked on [McJty's Maven](https://maven.k-4u.nl/mcjty/theoneprobe/theoneprobe/), [JEI's Maven](https://maven.blamejared.com/mezz/jei/), and [Serene Seasons' Maven](https://maven.minecraftforge.net/com/github/glitchfiend/SereneSeasons-neoforge/). [Patchouli's releases](https://github.com/VazkiiMods/Patchouli/releases) and [Curios' port PRs](https://github.com/TheIllusiveC4/Curios/pulls) do not establish a compatible 26.2 release. Old Forge/1.21 artifacts are never automatic fallbacks.

When another dependency becomes available, set the named version property explicitly or update this script after verifying its coordinates and API. `gamestages()` requires both `bookshelf_version` and `gamestages_version`.

## Validation

Run `./gradlew :McJtyLib:build :workspace:classes` to check the library, regression checks, and aggregator. Game testing should use `:workspace:runClient` and `:workspace:runServer`. Datagen uses `runClientData` on 26.2.

The Ariente-family 26.2 port was also checked with all five targeted builds,
standalone dependency resolution, eleven library JUnit tests, ten native
GameTests, both data generators and an integrated client smoke. Camera/tank
pixel checks pass with Fancy and Fabulous. See
[ArienteWorld's port notes](../ArienteWorld_neo/README.md#minecraft-262-port).
The verified Tutorial save is available in `workspace/run/saves/Tutorial`.

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
