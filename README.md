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

While this branch is unpublished, copy the script into a standalone McJtyLib checkout:

```sh
cp ../Multi_neo/gradletools.gradle gradletools.gradle
```

Run that command inside `McJtyLib_neo`. Keep the copy byte-for-byte identical and exclude `/gradletools.gradle` in that checkout's `.git/info/exclude`. The copy is a local build aid and must not be committed or pushed.

## Dependencies

The configured dependencies target Minecraft 26.1.2. NeoForge 26.1.2.94 matches the existing TOP port; these are pinned versions, not claims about the latest release.

| Helper | 26.1.2 configuration |
| --- | --- |
| `mc()` | NeoForge `26.1.2.94` |
| `top()` | Source project when included; otherwise `curse.maven:the-one-probe-245211:8797594` (TOP `26.1.2_neo-14.0.0`) |
| `jei()` | JEI common/NeoForge APIs and NeoForge runtime `29.43.0.106` |
| `curios()` | `15.0.0+26.1.2`, overridable with `-Pcurios_version` |
| `sereneseasons()` | Requires an explicit compatible `sereneseasons_version` |
| `mcjtylib()` | Source project when included; standalone version `26.1.2-10.0.0` once published, overridable with `-Pmcjtylib_version` |
| `rftoolsbase()`, `lostcities()` | Source project, otherwise require an explicit compatible version |
| `patchouli()`, `gamestages()` | Require explicit compatible versions |

Published artifacts can be checked on [TOP's 26.1.2 release](https://www.curseforge.com/minecraft/mc-mods/the-one-probe/files/8797594), [JEI's Maven](https://maven.blamejared.com/mezz/jei/jei-26.1.2-neoforge/), [Curios' Maven](https://maven.theillusivec4.top/top/theillusivec4/curios/curios-neoforge/15.0.0+26.1.2/), and [NeoForge's Maven](https://maven.neoforged.net/releases/net/neoforged/neoforge/26.1.2.94/). Old Forge/1.21 artifacts are never automatic fallbacks.

When another dependency becomes available, set the named version property explicitly or update this script after verifying its coordinates and API. `gamestages()` requires both `bookshelf_version` and `gamestages_version`.

## Validation

Run `./gradlew :McJtyLib:build :workspace:classes` to check the library, regression checks, and aggregator. Game testing should use `:workspace:runClient` and `:workspace:runServer`. Datagen uses `:McJtyLib:runClientData`.

During the backport, direct Java 25 compilation and all four existing JUnit regression tests passed using cached Minecraft 26.1.2 classes, NeoForge API dependencies, and TOP. The diagnostic classpath used the cached JEI 26.2 API; the used plugin/GUI signatures were also checked against JEI's `26.1` sources, and the build itself pins JEI 26.1.2. Full Gradle builds, dependency resolution, datagen, and game launches remain to be verified: the execution sandbox blocked Gradle's socket setup and shell network access.
