# MultiWorkSpace for Minecraft 26.3 / Fabric

Use Java 25, Gradle 9.6.0 and Fabric Loom 1.17.21. These versions follow
[Fabric's 26.3 porting guidance](https://www.fabricmc.net/2026/09/15/263.html).

Open the root `build.gradle` in IntelliJ. Settings include available nested Fabric
checkouts such as `Multi_fabric/McJtyLib`, or sibling checkouts such as
`../McJtyLib_fabric`. Missing mods are skipped. Logical project names remain
`:McJtyLib`, `:TheOneProbe`, etc. Override paths with `-Pmod.<Name>=<path>`.

`workspace` collects the included mods through Loom mod source sets and project
dependencies. Its client and server runs use those mods without a dummy mod
entrypoint. Only include Fabric ports. `co.sh` clones repositories only when their
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
wideners, jars and publishing. McJtyLib finds the integrated root script, the
sibling `Multi_fabric` script, a nested parent script, or the remote `26.3_fabric`
script. No copied script is needed in the library checkout. Standalone builds
without a local workspace require the remote branch to have been published.

| Helper | Fabric 26.3 configuration |
| --- | --- |
| `mc()` | Minecraft 26.3, Loader 0.19.5, Fabric API 0.164.0+26.3 |
| `config()` | Forge Config API Port 26.3.1, Fabric artifact |
| `energy()` | Included Team Reborn Energy API 5.0.0 |
| `top()` | Source project when included; otherwise `mcjty.theoneprobe:theoneprobe:26.3-16.0.0-fabric-1` |
| `jei()` | JEI common API and Fabric runtime 31.12.0.65 |
| `mcjtylib()` | Source project when included; otherwise `com.github.mcjty:mcjtylib-fabric:26.3-11.0.0-fabric` |
| `rftoolsbase()`, `lostcities()` | Source project, otherwise an explicit compatible version property |
| `trinkets()`, `patchouli()`, `gamestages()`, `sereneseasons()` | Require explicit compatible version properties |
| `curios()` | Rejects the NeoForge API; use a Fabric accessory integration |

TOP's trailing `-1` identifies the Maven build, rather than its mod dependency
version. Override CI artifact coordinates with `-Ptop_version=<version>` or
`-Pmcjtylib_version=<version>` when a different build is published. Integrated builds
use source projects and do not need a published McJtyLib artifact. JEI's pinned
Fabric artifact is listed in its [Maven repository](https://maven.blamejared.com/mezz/jei/jei-26.3-fabric/).
Trinkets has no default version configured for this branch; an older 26.2 artifact
is never selected implicitly.

## Validation

Main and test sources compiled against cached 26.3 artifacts. All four JUnit checks,
native Fabric transfer checks, datagen checks and client input checks passed with
the local TOP Fabric port. Gradle script syntax and workspace inclusion rules were
checked separately. The six available Fabric source checkouts also initialized
together in the native client. Full Gradle execution is blocked by the sandbox's
local networking restrictions; a network-enabled run must still resolve standalone
Maven dependencies and build the aggregate workspace through Loom. JEI runtime
integration and in-world gameplay were not exercised.
