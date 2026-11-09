# MultiWorkspace for Minecraft 26.1.2 / NeoForge

Use Java 25. The wrapper runs Gradle 9.2.1 with NeoGradle 7.1.38.

Open this directory's `build.gradle` in IntelliJ. Available mods are included automatically from either nested checkouts (`Multi_neo/McJtyLib`) or sibling checkouts (`../McJtyLib_neo`). Missing mods are skipped. Logical project names stay `:McJtyLib`, `:TheOneProbe`, etc., so shared dependency helpers resolve source projects consistently.

For checkouts elsewhere, pass their location as a Gradle property:

```sh
./gradlew projects
./gradlew :workspace:runClient -Pmod.TheOneProbe=/path/to/Top26_1_2
./gradlew :workspace:runServer
./gradlew :McJtyLib:build
./gradlew :McJtyLib:runClientData
```

The `workspace` module adds every included mod as both `modSource` and `implementation`. It supplies client and dedicated server runs without an example mod. Individual repositories retain standalone builds. Additional mods can be added to the list in `settings.gradle`; the runtime aggregator follows that list automatically.

## Shared build script

`gradletools.gradle` owns Minecraft/NeoForge versions, repositories, dependency helpers, development runs, jars, and publishing. A module should apply the root workspace script, then an optional standalone local copy, then the remote [`26.1.2_neo` script](https://raw.githubusercontent.com/McJtyMods/MultiWorkspace/26.1.2_neo/gradletools.gradle). McJtyLib implements this order.

The shared script is now published. RFToolsBase, RFToolsPower, and XNet use it directly when built standalone; workspace builds apply the local workspace copy.

Available source checkouts are always included using the same rules for every mod. The dependency helpers use `project(':McJtyLib')` and `project(':RFToolsBase')` when those projects are present; otherwise they use the configured Maven versions from `gradletools.gradle`: `26.1.2-10.0.2.5` and `26.1.2-7.0.0-1`. Standalone builds use the remote shared script. HoloGui, Ariente and ArienteWorld require McJtyLib `26.1.2-10.0.2`; existing mods retain their declared minimums. Standalone builds can download the published McJtyLib `26.1.2-10.0.2.5` artifact without a version override; included source projects always take precedence.

## Dependencies

The configured dependencies target Minecraft 26.1.2. The shared script defaults to NeoForge 26.1.2.94. The RFTools/XNet and HoloGui/Ariente/ArienteWorld ports and the workspace runtime override this to 26.1.2.99, which the configured JEI release requires.

| Helper | 26.1.2 configuration |
| --- | --- |
| `mc()` | NeoForge `26.1.2.94` |
| `top()` | Source project when included; otherwise `curse.maven:the-one-probe-245211:8797594` (TOP `26.1.2_neo-14.0.0`) |
| `jei()` | JEI common/NeoForge APIs and NeoForge runtime `29.43.0.106` |
| `curios()` | `15.0.0+26.1.2`, overridable with `-Pcurios_version` |
| `sereneseasons()` | Requires an explicit compatible `sereneseasons_version` |
| `mcjtylib()` | Source project when included; default Maven artifact `26.1.2-10.0.2.5` |
| `rftoolsbase()` | Source project when included; default Maven artifact `26.1.2-7.0.0-1` |
| `lostcities()` | Source project, otherwise requires an explicit compatible version |
| `patchouli()` | Patchouli NeoForge API and development runtime `26.1-94`, overridable with `-Ppatchouli_version` |
| `gamestages()` | Requires explicit compatible versions |

Published artifacts can be checked on [TOP's 26.1.2 release](https://www.curseforge.com/minecraft/mc-mods/the-one-probe/files/8797594), [JEI's Maven](https://maven.blamejared.com/mezz/jei/jei-26.1.2-neoforge/), [Curios' Maven](https://maven.theillusivec4.top/top/theillusivec4/curios/curios-neoforge/15.0.0+26.1.2/), and [NeoForge's Maven](https://maven.neoforged.net/releases/net/neoforged/neoforge/26.1.2.94/). Old Forge/1.21 artifacts are never automatic fallbacks.

When another dependency becomes available, set the named version property explicitly or update this script after verifying its coordinates and API. `gamestages()` requires both `bookshelf_version` and `gamestages_version`.

## Validation

Run `./gradlew :RFToolsPower:build :ModXNet:build :workspace:classes` to check the ports and their regression tests. Generate resources with `:RFToolsPower:runClientData` and `:ModXNet:runClientData`. Use `:RFToolsBase:build` or `:RFToolsBase:runClientData` when that checkout is present.

Game testing should use `:workspace:runClient` and `:workspace:runServer`. The headless `:workspace:runGameTestServer` run checks integrated server startup, resource loading, and ticking. Source mod jars are filtered from workspace run classpaths so the runtime uses live classes rather than loading each mod twice. To work on the library itself, use `:McJtyLib:build` or `:McJtyLib:runClientData`.

## HoloGui, Ariente and ArienteWorld

The `26.1.2_neo` branches use sibling checkouts `../ModHoloGui_neo`,
`../Ariente_neo` and `../ArienteWorld_neo`. Build them with:

```sh
./gradlew :ModHoloGui:build :Ariente:build :ArienteWorld:build :workspace:classes
./gradlew :Ariente:runClientData :ArienteWorld:runClientData
./gradlew :ArienteWorld:runGameTestServer
```

With Java 25 selected, create and install the playable tutorial from ArienteWorld:

```sh
cd ../ArienteWorld_neo
python3 tools/create_tutorial.py
python3 tools/create_tutorial.py --verify --saves ../Multi_neo/workspace/run/saves
```

Launch `:workspace:runClient` and select **Tutorial**. Generation and verification
use an isolated dedicated server. See the [port report](../ArienteWorld_neo/PORT_26_1_2.md)
and [tutorial instructions](../ArienteWorld_neo/README.md#tutorial-save) for
repeatable render and sound checks using disposable copies.

## IntelliJ client assets and source dependencies

The shared script keeps a complete Minecraft-version-specific asset directory
under `$GRADLE_USER_HOME/caches/minecraft/assets/26.1.2`. Both client and client
datagen arguments use that directory and the `26.1.2` index. Asset download tasks
track the copied objects as outputs, so missing files invalidate preparation.
This avoids another Minecraft workspace replacing files needed by this version.

Runtime dependency resolution selects class directories for included projects.
Development runs also include their transitive local mod sources, including in
individual mod configurations. IntelliJ and Gradle therefore load live sources
without competing built jars. Published dependencies remain standalone fallbacks.
After changing build configuration, reload Gradle and use **Workspace: Client**.
The IntelliJ configuration was launched directly and reached the main menu with
14 mods, no startup errors and no duplicate source/jar selections. A missing
isolated asset was also removed for a regression check: the next preparation
detected the missing output and restored it automatically.

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
