# MultiWorkSpace for Minecraft 26.3 / Fabric

Use Java 25, Gradle 9.6.0 and Fabric Loom 1.17.21. These versions follow
[Fabric's 26.3 porting guidance](https://www.fabricmc.net/2026/09/15/263.html).

Open the root `build.gradle` in IntelliJ. Settings include available nested Fabric
checkouts such as `Multi_fabric/McJtyLib`, or sibling checkouts such as
`../McJtyLib_fabric`. Missing mods are skipped. Logical project names remain
`:McJtyLib`, `:TheOneProbe`, etc. Override paths with `-Pmod.<Name>=<path>`.

`workspace` collects every included local mod through Loom mod source sets and project
dependencies. Its client and server runs use those mods without a dummy mod
entrypoint. IntelliJ Gradle sync generates the combined `Client` and `Server`
Application configurations. Select `Client` to launch all included mods. Generate
them explicitly with `./gradlew :workspace:ideaSyncTask` if needed.

The Gradle root name is `26_3_fabric` so Loom's generated module names match
IntelliJ's imported modules. Reload the Gradle project after updating this setup.
For an existing configuration with an invalid module, choose
`26_3_fabric.workspace.main` in its **Use classpath of module** field.

Only include Fabric ports. `co.sh` clones repositories only when their
`26.3_fabric` branch exists and preserves existing checkout directories.

```sh
./gradlew projects
./gradlew :McJtyLib:build :workspace:classes
./gradlew -PtransferTests :McJtyLib:runTransferTest
./gradlew -PtransferTests :McJtyLib:runDatagenTest
./gradlew -PtransferTests -PclientTests :McJtyLib:runClient
./gradlew :workspace:runClient
./gradlew :workspace:runServer
```

The test runs are opt-in; their classes and generated output stay out of release
jars. `runDatagenTest` writes beneath McJtyLib's `build/` directory. Individual mods
can use `runDatagen` when they provide a `fabric-datagen` entrypoint.

## Shared build tools

`gradletools.gradle` owns versions, repositories, dependency helpers, runs, access
wideners, jars and publishing. McJtyLib and the three RFTools/XNet ports find the integrated root script, the
sibling `Multi_fabric` script, a nested parent script, or the remote `26.3_fabric`
script. No copied script is needed in those checkouts. Standalone builds
without a local workspace require the remote branch to have been published.

| Helper | Fabric 26.3 configuration |
| --- | --- |
| `mc()` | Minecraft 26.3, Loader 0.19.5, Fabric API 0.164.0+26.3 |
| `config()` | Forge Config API Port 26.3.1, Fabric artifact |
| `energy()` | Included Team Reborn Energy API 5.0.0 |
| `top()` | Source project when included; otherwise `mcjty.theoneprobe:theoneprobe:26.3-16.0.0-fabric-1` |
| `jei()` | JEI common API and Fabric runtime 31.12.0.65 |
| `mcjtylib()` | Local source project when included; otherwise Jenkins `com.github.mcjty:mcjtylib-fabric:26.3-11.0.4-fabric.7` |
| `hologui()` | Local source project when included; otherwise `com.github.mcjty:hologui-fabric:26.3-0.0.10-beta-fabric-1` |
| `ariente()` | Local source project when included; otherwise `com.github.mcjty:ariente-fabric:26.3-0.0.31-alpha-fabric-1` |
| `rftoolsbase()` | Local source project for the unpublished port; eventual Jenkins fallback uses `rftoolsbase_version=26.3-9.0.0-fabric-1` |
| `lostcities()` | Source project, otherwise an explicit compatible version property |
| `trinkets()`, `patchouli()`, `gamestages()`, `sereneseasons()` | Require explicit compatible version properties |
| `curios()` | Rejects the NeoForge API; use a Fabric accessory integration |

TOP's trailing `-1` identifies the Maven build, rather than its mod dependency
version. Override CI artifact coordinates with `-Ptop_version=<version>` or
`-Pmcjtylib_version=<version>` when a different build is published. Integrated builds
always prefer included local mod projects and load their source outputs, including McJtyLib. Power and XNet include the
sibling RFToolsBase source project for standalone builds until its port is published. JEI's pinned
Fabric artifact is listed in its [Maven repository](https://maven.blamejared.com/mezz/jei/jei-26.3-fabric/).
Trinkets has no default version configured for this branch; an older 26.2 artifact
is never selected implicitly.

## Validation

All three ports build through Multi_fabric and standalone with the published
Jenkins McJtyLib. The aggregate workspace classes also compile, including the
existing Fabric mods. All 15 combined JUnit checks, all three Gradle datagen runs,
and McJtyLib's native transfer, datagen and SDL client regression checks pass. Native codec
checks cover all four ore features, 16 placement modifier round trips, and legacy
facade block properties and attachment persistence.

The in-world client integration test passes with the patched library source via
a temporary Gradle dependency substitution used only for validation. Release
standalone builds use Jenkins, while integrated development runs use the local library.

```sh
./gradlew :RFToolsBase:build :RFToolsPower:build :ModXNet:build :workspace:classes
./gradlew -PfabricPortTests :RFToolsBase:runClientGameTest
```

The client fixture checks native energy and inventory rollback, fluid rounding,
menus, legacy facade persistence, facade removal, cable/antenna models and cable
outlines while holding a connector. JEI starts alongside the mods; recipe transfer
interactions were not tested. Use Java 25 for the Gradle JVM and launch tests
from a desktop session with an available SDL video device.

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
`ArienteWorld_fabric` checkouts on `26.3_fabric`. Build them with
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
