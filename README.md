# MultiWorkSpace for Minecraft 26.1.2 / Fabric

Use Java 25, Gradle 9.5.1 and Fabric Loom 1.17.17. Open the root `build.gradle` in IntelliJ. Settings include available nested checkouts or sibling `*_fabric` checkouts, including `RFToolsBase_fabric`, `RFToolsPower_fabric` and `ModXNet_fabric`. Missing mods are skipped. Override a checkout location with `-Pmod.<Name>=<path>`.

Refreshing Gradle in IntelliJ generates `Client` and `Server` run configurations for the combined workspace. To generate them from the command line, run `./gradlew :workspace:ideaSyncTask`. Loom's IDE configuration generation is explicitly enabled for this subproject.

The Gradle root name is `26_1_2_fabric` so Loom and IntelliJ agree on the module `26_1_2_fabric.workspace.main`. Dots in the root name cause IntelliJ to normalize the name differently from Loom. Existing generated Application configurations retain their module selection on refresh; if migrating from the dotted name, select this module in both configurations or remove their generated XML files under `.idea/runConfigurations` and regenerate them.

McJtyLib, The One Probe, and other included mods always use local source checkouts. Published artifacts are standalone fallbacks. Logical project names remain `:RFToolsBase`, `:RFToolsPower`, `:ModXNet`, `:McJtyLib` and `:TheOneProbe`.

```sh
./gradlew projects
./gradlew :RFToolsBase:build :RFToolsPower:build :ModXNet:build :workspace:classes
./gradlew :workspace:runClient
./gradlew :workspace:runServer
./gradlew :RFToolsBase:runDatagen :RFToolsPower:runDatagen :ModXNet:runDatagen
./gradlew -PfabricPortTests :RFToolsBase:runClientGameTest
```

The `workspace` module declares every included mod as a Loom mod source set and an implementation dependency. It provides client and dedicated server runs without a dummy mod. Individual repositories retain standalone builds. Only include Fabric ports.

## Shared script

`gradletools.gradle` centralizes versions, repositories, dependencies, development runs, access wideners, jars and publishing. Modules apply the workspace root script, then an optional standalone local copy, then the remote `26.1.2_fabric` script. `access()` discovers `src/main/resources/<mod_id>.accesswidener`.

Until the branch is published, copy the script into each standalone checkout:

```sh
# From a sibling *_fabric checkout
cp ../Multi_fabric/gradletools.gradle gradletools.gradle
```

Exclude `/gradletools.gradle` in that checkout's `.git/info/exclude`, keep the files identical and do not commit the copy. RFToolsPower and XNet standalone settings include sibling RFToolsBase sources when available. Isolated CI builds need a published RFToolsBase Fabric artifact, selected with `-Prftoolsbase_version=<published-version>`.

## Dependencies

| Helper | Fabric 26.1.2 configuration |
| --- | --- |
| `mc()` | Minecraft 26.1.2, Fabric Loader 0.19.3 minimum, Fabric API 0.155.3+26.1.2 |
| `config()` | Forge Config API Port 26.1.5 (Fabric artifact) |
| `energy()` | Included Team Reborn Energy API 5.0.0 |
| `top()` | `mcjty.theoneprobe:theoneprobe:26.1.2-14.0.0-fabric-4`, or an included source project |
| `jei()` | JEI common API and Fabric runtime 29.35.0.95 |
| `mcjtylib()` | `com.github.mcjty:mcjtylib-fabric:26.1.2-10.0.1-fabric.2`, or an included source project |
| `rftoolsbase()` | Included source project; otherwise `com.github.mcjty:rftoolsbase-fabric:${rftoolsbase_version}` (default `26.1.2-7.0.0-fabric`) |
| `lostcities()`, `patchouli()`, `gamestages()`, `sereneseasons()`, `trinkets()` | Require explicit compatible version properties unless the helper supports an included source project |
| `curios()` | Rejected because the Curios API used by the NeoForge workspace is not a Fabric API |

`top_version`, `mcjtylib_version` and `rftoolsbase_version` select Maven artifact revisions. Runtime mod constraints use base versions without Jenkins suffixes. TOP is optional in the ports' metadata but available during development. `gamestages()` additionally requires `bookshelf_version`.

## Validation

All three RFTools/XNet builds, their datagen runs and seven JUnit tests pass against the pinned Jenkins libraries. The opt-in `fabricPortTests` client test starts a real integrated server and checks native energy, item and fluid transactions, coal generation, synchronized menus, facade removal and textured cable/antenna geometry. Its fixture is excluded from release jars.

Library source development uses the same workspace with an explicit opt-in:

```sh
./gradlew :TheOneProbe:build :TheOneProbe:gametestClasses :McJtyLib:build :workspace:classes
./gradlew :TheOneProbe:runClientGameTest
./gradlew -PtransferTests :McJtyLib:runTransferTest
```

The earlier TOP client test covered packet exchange, chest contents, fluid components, welcome note and command screens. McJtyLib's transfer checks covered native item/fluid rollback and TOP provider registration. Fabric datagen uses `runDatagen` and each mod's `fabric-datagen` entrypoint.
