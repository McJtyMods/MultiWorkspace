# MultiWorkSpace for Minecraft 26.1.2 / Fabric

Use Java 25. The wrapper uses Gradle 9.5.1 and the build uses Fabric Loom 1.17.17.

Open the root `build.gradle` in IntelliJ. `settings.gradle` includes available nested checkouts such as `Multi_fabric/McJtyLib`, or sibling checkouts such as `../McJtyLib_fabric`. Missing mods are skipped. Logical names remain `:McJtyLib`, `:TheOneProbe`, etc. Only include Fabric ports in this workspace.

For checkouts elsewhere, pass their location as a Gradle property:

```sh
./gradlew projects
./gradlew :workspace:runClient -Pmod.TheOneProbe=/path/to/TheOneProbe_fabric
./gradlew :workspace:runServer
./gradlew :McJtyLib:build
./gradlew :McJtyLib:runDatagen
./gradlew -PtransferTests :McJtyLib:runTransferTest
```

The `workspace` module declares every included mod as a Loom mod source set and an implementation dependency. It provides client and dedicated server runs without a dummy mod. Individual repositories retain standalone builds. Additional mods can be added to `settings.gradle`; the runtime aggregator follows that list.

## Shared script

`gradletools.gradle` centralizes versions, repositories, dependencies, development runs, access wideners, jars and publishing. Modules apply the workspace root script, then an optional standalone local copy, then the remote `26.1.2_fabric` script. The `access()` helper discovers `src/main/resources/<mod_id>.accesswidener` when present.

Until this branch is published, copy the script into the standalone library checkout:

```sh
# Run from McJtyLib_fabric
cp ../Multi_fabric/gradletools.gradle gradletools.gradle
```

Exclude `/gradletools.gradle` in that checkout's `.git/info/exclude`, keep the files identical and do not commit or push the copy.

## Dependencies

| Helper | Fabric 26.1.2 configuration |
| --- | --- |
| `mc()` | Minecraft 26.1.2, Fabric Loader 0.19.3, Fabric API 0.155.3+26.1.2 |
| `config()` | Forge Config API Port 26.1.5 (Fabric artifact) |
| `energy()` | Included Team Reborn Energy API 5.0.0 |
| `top()` | Source project when included; explicit `top_version` for a compatible published runtime; otherwise the published 26.2 Fabric API on `compileOnly` with transitive dependencies disabled |
| `jei()` | JEI common API and Fabric runtime 29.35.0.95 |
| `mcjtylib()` | Source project when included; otherwise `com.github.mcjty:mcjtylib-fabric:26.1.2-10.0.1-fabric` after publication |
| `rftoolsbase()`, `lostcities()` | Source project, otherwise an explicit compatible version property |
| `patchouli()`, `gamestages()`, `sereneseasons()`, `trinkets()` | Require explicit compatible version properties |
| `curios()` | Rejected because the Curios API used by the NeoForge workspace is not a Fabric API |

Version pins are backed by [Fabric's Maven repository](https://maven.fabricmc.net/net/fabricmc/fabric-api/fabric-api/0.155.3%2B26.1.2/), [Forge Config API Port's Maven POM](https://raw.githubusercontent.com/Fuzss/modresources/main/maven/fuzs/forgeconfigapiport/forgeconfigapiport-fabric/26.1.5/forgeconfigapiport-fabric-26.1.5.pom) and [JEI's Fabric Maven repository](https://maven.blamejared.com/mezz/jei/jei-26.1.2-fabric/). Team Reborn Energy 5.0.0 targets the 26.1 API and is bundled by `energy()`.

There is no published 26.1.2 Fabric TOP branch at the time of this backport. Its optional integration compiles against the API from `mcjty.theoneprobe:theoneprobe:26.2-15.0.1-fabric-1`; that artifact is never added to the default runtime. Supply a compatible source checkout with `-Pmod.TheOneProbe=<path>`, or a compatible published Fabric version with `-Ptop_version=<version>`. The compile-only API pin can be overridden with `-Ptop_api_version=<version>`.

`gamestages()` requires `bookshelf_version` and `gamestages_version`. Other optional integrations require the correspondingly named version property.

## Validation

Run `./gradlew :McJtyLib:build :workspace:classes`, then use `:workspace:runClient` and `:workspace:runServer` for game testing. Fabric datagen uses `runDatagen`; mods must supply their own `fabric-datagen` entrypoint.

Direct Java 25 compilation of all McJtyLib main sources and both test source sets against cached Minecraft 26.1.2 classes passed, together with all four JUnit regression tests and checks of the five mixin targets. Fabric API signatures used by the library were compared with upstream 26.1.2 sources; the changed tag provider was compiled from those sources, while other Fabric APIs and Forge Config API Port used cached 26.2 binaries. Gradle script syntax, source-project dependency selection, optional TOP dependency behavior, sibling checkout discovery and standalone shared-script equality also passed isolated checks. This is source validation rather than a complete dependency or runtime validation.

The full Gradle build could not start in this sandbox: the default Gradle cache is read-only, and an isolated writable cache fails when Gradle attempts to open its lock-coordination socket. Shell network access is also unavailable. Dependency resolution for the pinned Fabric 26.1.2 artifacts, full builds, datagen, native transfer tests and client/server runs must still be checked in a normal environment.
