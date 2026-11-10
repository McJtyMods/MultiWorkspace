# MultiWorkspace for Minecraft 1.21.1 / Fabric

This workspace contains five separate mod repositories on branch `1.21_fabric`:

| Directory | Mod |
| --- | --- |
| `McJtyLib` | McJtyLib |
| `TheOneProbe` | The One Probe |
| `ModHoloGui` | HoloGui |
| `Ariente` | Ariente |
| `ArienteWorld` | Ariente World |

Use Java 21, Gradle 8.14.2, and Fabric Loom 1.10.5. `co.sh` checks out these repositories once their Fabric branches are available remotely. Settings support nested checkouts, sibling `<Mod>_fabric` checkouts, and `-Pmod.<Name>=<path>` overrides.

## IntelliJ

Open the root `build.gradle` as a separate IntelliJ project. Set the Gradle JVM to Java 21 and **Gradle user home** to:

```
/data/Projects/Multi21_fabric/.gradle-user-home
```

Run `python3 tools/configure-gradle-home.py` to prepare the isolated home and its Minecraft/loader guard. The wrapper selects this home automatically; IntelliJ's Gradle user home field must be set in Settings > Build, Execution, Deployment > Build Tools > Gradle. IntelliJ stores that field outside the repository's Gradle configuration XML.

Reload Gradle to generate the combined `Client (:workspace)` and `Server (:workspace)` runs. `./gradlew :workspace:ideaSyncTask` generates them explicitly. Both runs use the included mods' class and resource directories. The aggregator has no dummy mod entrypoint. Its imported module is `1_21_fabric.workspace.main`.

## Build and run

```sh
./gradlew projects
./gradlew :McJtyLib:build :TheOneProbe:build :ModHoloGui:build :Ariente:build :ArienteWorld:build :workspace:classes
./gradlew :workspace:runClient
./gradlew :workspace:runServer
./gradlew :Ariente:runDatagen :ArienteWorld:runDatagen
./gradlew -PtransferTests :McJtyLib:runTransferTest
```

The transfer checks run inside Fabric and exit after checking native inventory slots, fluid units, transactions, and item energy storage. McJtyLib's normal build also runs its JUnit regression checks. Minecraft development requires Java 21; set `JAVA_HOME` when invoking the wrapper from a shell whose default JDK differs.

## Shared build driver and standalone builds

`gradletools.gradle` drives every mod's repositories, Minecraft/Fabric dependencies, access wideners, development runs, jar tasks, and publication settings. Included McJtyLib, TOP, HoloGui, and Ariente projects always take precedence over Maven artifacts. Loom's `namedElements` configurations supply the local development jars, and the combined runs load their source outputs directly.

Each individual `build.gradle` first looks for `-Pgradletools_path=<file>`, the integrated root script, a sibling `Multi_fabric/gradletools.gradle`, a parent script, and a standalone local copy. The final fallback is MultiWorkspace's remote `1.21_fabric/gradletools.gradle`. A local copy should remain excluded from Git.

Standalone settings also discover compatible local peer checkouts. With no peers, the same dependency helpers select Fabric artifacts from Jenkins/Maven. Their default revision suffixes are the expected first Jenkins builds; actual artifacts and the remote driver become available after publishing the branches and configuring Jenkins. Override the exact artifacts with `-Ptop_version=...`, `-Pmcjtylib_version=...`, `-Phologui_version=...`, and `-Pariente_version=...` as needed. McJtyLib preserves its `.BUILD_NUMBER` suffix; the other mods use `-BUILD_NUMBER`.

For example, from an individual checkout:

```sh
./gradlew --gradle-user-home ../.gradle-user-home -Pgradletools_path=../gradletools.gradle build
```

The initial Fabric port versions have no matching 1.21.1 Fabric releases on Modrinth. CurseForge publication checks returned HTTP 403, so that service remains unverified.

Forge Config API Port supplies the TOML config API on Fabric. Its `net.neoforged` config class names are intentional. No NeoForge loader is used. Team Reborn energy is included in the built mod jars. TOP plugins use Fabric entrypoints, and Patchouli integration is optional.

## Tutorial world

Generate and install ArienteWorld's playable visual test world into the combined client's saves:

```sh
python3 ArienteWorld/tools/create_tutorial.py --saves workspace/runs/client/saves
python3 ArienteWorld/tools/create_tutorial.py --verify
```

The authoring server validates real machine ticks, automation, displays, power, wireless controls, and vehicles before saving. Its world and logs are under `ArienteWorld/build/tutorial/server`. The installed save appears as **Tutorial** in `:workspace:runClient`. Use `--replace` only when deliberately regenerating an existing Tutorial save. The preview and sound/position checks operate on separate copies; see ArienteWorld's README.

Keep build caches, runtime data, and generated IDE metadata outside Git. Large temporary verification data belongs under `/var/tmp`.
