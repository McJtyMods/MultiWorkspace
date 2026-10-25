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

The `workspace` module adds every included mod as both `modSource` and `implementation`. It supplies client and dedicated server runs without an example mod. Individual repositories retain standalone builds. Additional mods can be added to the list in `settings.gradle`; the runtime aggregator follows that list automatically.

The aggregator disables NeoGradle's automatic inclusion of its own empty sources as a mod and configures its NeoForge runtime explicitly. This keeps mod discovery valid while resolving client assets and native libraries.

## Shared build script

`gradletools.gradle` owns Minecraft/NeoForge versions, repositories, dependency helpers, development runs, jars, and publishing. A module should apply the root workspace script, then an optional standalone local copy, then the remote `26.2_neo` script. McJtyLib implements this order.

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
| `mcjtylib()` | Source project when included; standalone version `26.2-10.0.0` once published |
| `rftoolsbase()`, `lostcities()` | Source project, otherwise require an explicit compatible version |
| `patchouli()`, `curios()`, `gamestages()` | No verified 26.2 release configured; requesting one fails with an explanation |

Published artifacts can be checked on [McJty's Maven](https://maven.k-4u.nl/mcjty/theoneprobe/theoneprobe/), [JEI's Maven](https://maven.blamejared.com/mezz/jei/), and [Serene Seasons' Maven](https://maven.minecraftforge.net/com/github/glitchfiend/SereneSeasons-neoforge/). [Patchouli's releases](https://github.com/VazkiiMods/Patchouli/releases) and [Curios' port PRs](https://github.com/TheIllusiveC4/Curios/pulls) do not establish a compatible 26.2 release. Old Forge/1.21 artifacts are never automatic fallbacks.

When another dependency becomes available, set the named version property explicitly or update this script after verifying its coordinates and API. `gamestages()` requires both `bookshelf_version` and `gamestages_version`.

## Validation

Run `./gradlew :McJtyLib:build :workspace:classes` to check the library, regression checks, and aggregator. Game testing should use `:workspace:runClient` and `:workspace:runServer`. Datagen uses `runClientData` on 26.2.
