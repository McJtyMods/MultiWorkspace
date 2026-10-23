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

The `workspace` module adds every included mod as both `modSource` and `implementation`. It provides client and dedicated server runs. McJtyLib's separate game-test source set is loaded only by its own `runGameTestServer` task. The historical `co.sh` and version-switch scripts predate this branch; use the layout above to provision current checkouts.

## Shared build settings

`gradletools.gradle` owns Minecraft/NeoForge versions, repositories, dependency helpers, runs, jars, and publishing. McJtyLib applies this script directly from the root in an integrated build, or from the sibling/parent workspace in a standalone build. Its remote fallback points to `MultiWorkspace/26.3_neo/gradletools.gradle`. Local script copies inside McJtyLib are unnecessary.

| Helper | 26.3 configuration |
| --- | --- |
| `mc()` | NeoForge `26.3.0.83` |
| `top()` | Source project when included; otherwise `mcjty.theoneprobe:theoneprobe:26.3_neo-16.0.0-1` |
| `jei()` | 26.3 common/NeoForge APIs and NeoForge runtime `31.12.0.65` |
| `sereneseasons()` | `26.3-26.1.2.0.7` |
| `mcjtylib()` | Source project when included; otherwise `26.3-11.0.0` once published |
| `rftoolsbase()`, `lostcities()` | Source project, otherwise require an explicit compatible version |
| `patchouli()`, `curios()`, `gamestages()` | Require explicit compatible versions |

JEI's pinned 26.3 release appears on [its Maven repository](https://maven.blamejared.com/mezz/jei/jei-26.3-neoforge/). TOP was available from the existing local 26.3 checkout/Maven installation during port validation. Until it is published, include the TOP checkout or publish it to Maven Local. Helpers never fall back automatically to old Forge/1.21 artifacts. `gamestages()` requires both `bookshelf_version` and `gamestages_version`.

Datagen runs are `runClientData` and `runServerData`; output goes to each mod's `src/generated/resources`. Only invoke them for mods that register data providers. Publishing credentials and destinations retain their existing configuration.

## Validation

McJtyLib's main sources compiled against cached 26.3 Minecraft/NeoForge artifacts. Four JUnit checks and eight NeoForge game tests passed, including a runtime load alongside TOP. The sandbox prevented Gradle startup because local networking was unavailable, and blocked dependency downloads. The configured 26.3 JEI artifacts were not cached; compile validation used the cached 26.2 API. Full standalone/workspace Gradle builds, JEI runtime, datagen, and interactive client validation remain to be checked outside that restriction.
