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

Available source checkouts are always included using the same rules for every mod. The dependency helpers use `project(':McJtyLib')` and `project(':RFToolsBase')` when those projects are present; otherwise they use the published Maven versions from `gradletools.gradle`: `26.1.2-10.0.0.1` and `26.1.2-7.0.0-1`. Standalone builds use the remote shared script. The minimum runtime mod dependencies remain `26.1.2-10.0.0` and `26.1.2-7.0.0`.

## Dependencies

The configured dependencies target Minecraft 26.1.2. The shared script defaults to NeoForge 26.1.2.94. The three RFTools/XNet ports and the workspace runtime override this to 26.1.2.99, which the configured JEI release requires.

| Helper | 26.1.2 configuration |
| --- | --- |
| `mc()` | NeoForge `26.1.2.94` |
| `top()` | Source project when included; otherwise `curse.maven:the-one-probe-245211:8797594` (TOP `26.1.2_neo-14.0.0`) |
| `jei()` | JEI common/NeoForge APIs and NeoForge runtime `29.43.0.106` |
| `curios()` | `15.0.0+26.1.2`, overridable with `-Pcurios_version` |
| `sereneseasons()` | Requires an explicit compatible `sereneseasons_version` |
| `mcjtylib()` | Source project when included; this workspace pins published artifact `26.1.2-10.0.0.1` |
| `rftoolsbase()` | Source project when included; default Maven artifact `26.1.2-7.0.0-1` |
| `lostcities()` | Source project, otherwise requires an explicit compatible version |
| `patchouli()`, `gamestages()` | Require explicit compatible versions |

Published artifacts can be checked on [TOP's 26.1.2 release](https://www.curseforge.com/minecraft/mc-mods/the-one-probe/files/8797594), [JEI's Maven](https://maven.blamejared.com/mezz/jei/jei-26.1.2-neoforge/), [Curios' Maven](https://maven.theillusivec4.top/top/theillusivec4/curios/curios-neoforge/15.0.0+26.1.2/), and [NeoForge's Maven](https://maven.neoforged.net/releases/net/neoforged/neoforge/26.1.2.94/). Old Forge/1.21 artifacts are never automatic fallbacks.

When another dependency becomes available, set the named version property explicitly or update this script after verifying its coordinates and API. `gamestages()` requires both `bookshelf_version` and `gamestages_version`.

## Validation

Run `./gradlew :RFToolsPower:build :ModXNet:build :workspace:classes` to check the ports and their regression tests. Generate resources with `:RFToolsPower:runClientData` and `:ModXNet:runClientData`. Use `:RFToolsBase:build` or `:RFToolsBase:runClientData` when that checkout is present.

Game testing should use `:workspace:runClient` and `:workspace:runServer`. The headless `:workspace:runGameTestServer` run checks integrated server startup, resource loading, and ticking. Source mod jars are filtered from workspace run classpaths so the runtime uses live classes rather than loading each mod twice. To work on the library itself, use `:McJtyLib:build` or `:McJtyLib:runClientData`.
