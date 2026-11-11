# MultiWorkSpace for Minecraft 26.2 / Fabric

Use Java 25. The wrapper uses Gradle 9.5.1 and the build uses Fabric Loom 1.17.17.

Open the root `build.gradle` in IntelliJ. `settings.gradle` includes available nested checkouts such as `Multi_fabric/McJtyLib`, or sibling checkouts such as `../McJtyLib_fabric`. Missing mods are skipped. Logical names remain `:McJtyLib`, `:TheOneProbe`, etc. Only include Fabric ports in this workspace.

IntelliJ Gradle sync generates the combined `Client` and `Server` Application
configurations. Select `Client` to launch all included mods. Generate them explicitly
with `./gradlew :workspace:ideaSyncTask` if needed. The dot-free Gradle root name
`26_2_fabric` keeps generated module names consistent with IntelliJ. Reload Gradle
after updating; an existing configuration should use `26_2_fabric.workspace.main`
in its **Use classpath of module** field.

For checkouts elsewhere, pass their location as a Gradle property:

```sh
./gradlew projects
./gradlew :workspace:runClient -Pmod.TheOneProbe=/data/Projects/Top26_2_fabric
./gradlew :workspace:runServer
./gradlew :McJtyLib:build
./gradlew :McJtyLib:runDatagen
./gradlew -PtransferTests :McJtyLib:runTransferTest
```

The `workspace` module declares every included mod as a Loom mod source set and an implementation dependency. It provides client and dedicated server runs without a dummy mod. Individual repositories retain standalone builds. Additional mods can be added to `settings.gradle`; the runtime aggregator follows that list.

## Shared script

`gradletools.gradle` centralizes versions, repositories, dependencies, development runs, access wideners, jars and publishing. Mods apply the [remote `26.2_fabric` script](https://github.com/McJtyMods/MultiWorkSpace/blob/26.2_fabric/gradletools.gradle) directly, both standalone and in this workspace. Do not keep copies in individual mod repositories. The workspace aggregator uses this repository's root script. The `access()` helper discovers `src/main/resources/<mod_id>.accesswidener` when present.

## Dependencies

| Helper | Fabric 26.2 configuration |
| --- | --- |
| `mc()` | Minecraft 26.2, Fabric Loader 0.19.3, Fabric API 0.155.2+26.2 |
| `config()` | Forge Config API Port 26.2.1 (Fabric artifact) |
| `energy()` | Included Team Reborn Energy API 5.0.0 |
| `top()` | Source project when included; otherwise `mcjty.theoneprobe:theoneprobe:26.2-15.0.1-fabric-1` |
| `jei()` | JEI common API and Fabric runtime 30.35.0.223 |
| `mcjtylib()` | Source project when included; otherwise `com.github.mcjty:mcjtylib-fabric:26.2-10.0.3-fabric.7` |
| `hologui()` | Local source project when included; otherwise `com.github.mcjty:hologui-fabric:26.2-0.0.10-beta-fabric-1` |
| `ariente()` | Local source project when included; otherwise `com.github.mcjty:ariente-fabric:26.2-0.0.31-alpha-fabric-1` |
| `rftoolsbase()` | Source project when included; otherwise `com.github.mcjty:rftoolsbase-fabric:26.2-8.0.0-fabric-1` (runtime mod version `26.2-8.0.0-fabric`) |
| `lostcities()` | Source project, otherwise an explicit compatible version property |
| `patchouli()`, `gamestages()`, `sereneseasons()` | Require explicit version properties; no old NeoForge release fallback |
| `curios()` | Rejected because the Curios API used by the NeoForge workspace is not a Fabric API |

The local TOP 26.2 Fabric build supplies the API used by this port; common initialization and TOP plugin registration were also checked together in Fabric. The standalone dependency pins [Jenkins Fabric build 1](https://jenkins.k-4u.nl/view/McJty/job/The%20One%20Probe%2026.2_fabric/1/artifact/build/libs/theoneprobe-26.2-15.0.1-fabric-1.jar). Its Maven version includes the Jenkins build-number suffix `-1`; the unsuffixed local build version is not the CI artifact version. The version can be overridden with `-Ptop_version=<published version>`. [JEI's maintainer confirms Fabric 26.2 release 30.35.0.223](https://github.com/mezz/JustEnoughItems/issues/4491), including a datagen crash fix. The cached JEI common API 30.30.0.204 was used for direct source compilation; dependency resolution for the pinned release still needs a network-enabled Gradle run.

`gamestages()` requires `bookshelf_version` and `gamestages_version`. Other optional integrations require the correspondingly named version property.

## Validation

Run `./gradlew :McJtyLib:build :workspace:classes`, then use `:workspace:runClient` and `:workspace:runServer` for game testing. Fabric datagen uses `runDatagen`; mods must supply their own `fabric-datagen` entrypoint.

During this port, direct Java compilation against cached Fabric 26.2 artifacts, four JUnit tests, native Fabric initialization and transfer checks, client class linking, and shared Gradle syntax/dependency checks passed. The sandbox's read-only Gradle cache prevented a complete Gradle build. Visual client testing, full workspace launches and a network-enabled dependency resolution remain necessary.

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

## Ariente Fabric ports

The workspace includes sibling `ModHoloGui_fabric`, `Ariente_fabric` and
`ArienteWorld_fabric` checkouts on `26.2_fabric`. Build them with
`./gradlew :ModHoloGui:build :Ariente:build :ArienteWorld:build :workspace:classes`.
Development runs load every included mod's compiled source directories.

The `hologui()` and `ariente()` helpers select Jenkins fallbacks when `ModHoloGui`
and `Ariente` are not included. Override their artifact versions with
`-Phologui_version=<version>` and `-Pariente_version=<version>`; included local
sources always take precedence.

Create and validate the tutorial from `ArienteWorld_fabric` with
`python3 tools/create_tutorial.py`, then reload and install it with
`python3 tools/create_tutorial.py --verify --saves ../Multi_fabric/workspace/runs/client/saves`.
The combined Client run finds the world under **Tutorial**.

## RFToolsUtility Fabric

The sibling `RFToolsUtility_fabric` checkout is included as `:RFToolsUtility` by
`settings.gradle` and loaded from source in the combined Client and Server runs.
It uses the included McJtyLib, RFToolsBase, and The One Probe projects.

```sh
./gradlew :RFToolsUtility:build :workspace:classes
./gradlew :RFToolsUtility:runDatagen
./gradlew -PutilityPortTests :RFToolsUtility:runClientGameTest
```
