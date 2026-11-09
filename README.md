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
| `mcjtylib()` | `com.github.mcjty:mcjtylib-fabric:26.1.2-10.0.3-fabric.4`, or an included source project |
| `hologui()` | Local source project when included; otherwise `com.github.mcjty:hologui-fabric:26.1.2-0.0.10-beta-fabric-1` |
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
`ArienteWorld_fabric` checkouts on `26.1.2_fabric`. Build them with
`./gradlew :ModHoloGui:build :Ariente:build :ArienteWorld:build :workspace:classes`.
Development runs load every included mod's compiled source directories.

The `hologui()` helper selects the HoloGui Jenkins fallback when `ModHoloGui` is
not included. Override its artifact version with `-Phologui_version=<version>`;
included local sources always take precedence.

Create and validate the tutorial from `ArienteWorld_fabric` with
`python3 tools/create_tutorial.py`, then reload and install it with
`python3 tools/create_tutorial.py --verify --saves ../Multi_fabric/workspace/runs/client/saves`.
The combined Client run finds the world under **Tutorial**.
