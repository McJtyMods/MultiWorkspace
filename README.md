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
| `mcjtylib()` | Source project when included; otherwise `com.github.mcjty:mcjtylib-fabric:26.2-10.0.0-fabric` after publication |
| `rftoolsbase()` | Source project when included; otherwise `com.github.mcjty:rftoolsbase-fabric:26.2-8.0.0-fabric-1` (runtime mod version `26.2-8.0.0-fabric`) |
| `lostcities()` | Source project, otherwise an explicit compatible version property |
| `patchouli()`, `gamestages()`, `sereneseasons()` | Require explicit version properties; no old NeoForge release fallback |
| `curios()` | Rejected because the Curios API used by the NeoForge workspace is not a Fabric API |

The local TOP 26.2 Fabric build supplies the API used by this port; common initialization and TOP plugin registration were also checked together in Fabric. The standalone dependency pins [Jenkins Fabric build 1](https://jenkins.k-4u.nl/view/McJty/job/The%20One%20Probe%2026.2_fabric/1/artifact/build/libs/theoneprobe-26.2-15.0.1-fabric-1.jar). Its Maven version includes the Jenkins build-number suffix `-1`; the unsuffixed local build version is not the CI artifact version. The version can be overridden with `-Ptop_version=<published version>`. [JEI's maintainer confirms Fabric 26.2 release 30.35.0.223](https://github.com/mezz/JustEnoughItems/issues/4491), including a datagen crash fix. The cached JEI common API 30.30.0.204 was used for direct source compilation; dependency resolution for the pinned release still needs a network-enabled Gradle run.

`gamestages()` requires `bookshelf_version` and `gamestages_version`. Other optional integrations require the correspondingly named version property.

## Validation

Run `./gradlew :McJtyLib:build :workspace:classes`, then use `:workspace:runClient` and `:workspace:runServer` for game testing. Fabric datagen uses `runDatagen`; mods must supply their own `fabric-datagen` entrypoint.

During this port, direct Java compilation against cached Fabric 26.2 artifacts, four JUnit tests, native Fabric initialization and transfer checks, client class linking, and shared Gradle syntax/dependency checks passed. The sandbox's read-only Gradle cache prevented a complete Gradle build. Visual client testing, full workspace launches and a network-enabled dependency resolution remain necessary.
