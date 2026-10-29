# AGENTS.md

## Workspace

- This is the Fabric 26.1.2 MultiWorkSpace. Use Java 25, Gradle 9.5.1 and Fabric Loom 1.17.17.
- Root settings include available nested or sibling `*_fabric` repositories. Always include local McJtyLib and TOP checkouts when available; published dependencies are standalone fallbacks. Each mod must also build standalone. Override checkout paths with `-Pmod.<Name>=<path>`.
- Shared behavior lives in `gradletools.gradle`. Ports apply the root copy, an ignored standalone copy, or the remote `26.1.2_fabric` copy in that order. Keep temporary standalone copies identical and excluded from Git.
- `workspace/build.gradle` collects all included mods through Loom mod source sets and implementation dependencies; it has no dummy mod entrypoint.
- Keep `generateRunConfig` enabled for workspace runs: Loom disables IDE generation in subprojects by default. IntelliJ Gradle sync generates the combined `Client` and `Server` configurations; `:workspace:ideaSyncTask` generates them explicitly.
- Keep the Gradle root name `26_1_2_fabric` free of dots so Loom's generated module names match IntelliJ's imported names. Loom preserves existing Application configurations' module selections; migrating old files requires correcting or regenerating them.

## Fabric conventions

- Use separate `ModInitializer` and `ClientModInitializer` entrypoints in `fabric.mod.json`.
- Register native registries during common initialization. McJtyLib deferred register helpers use `register()` without event bus arguments.
- Use Fabric block/item lookups, attachments, events, extended menus and transfer transactions. GUI slot helpers are library-owned APIs; automation uses native Fabric Storage and Team Reborn EnergyStorage.
- Forge Config API Port provides the TOML config API. Its config class names retain `net.neoforged` packages but no NeoForge loader is used.
- Separate server and client payload receivers. TOP discovers plugins via the `theoneprobe` entrypoint.
- Datagen uses Fabric's `DataGeneratorEntrypoint`, `FabricPackOutput` and registry lookup future. Generated resources remain under `src/generated/resources`.
- Only include Fabric ports; this workspace does not convert other sibling mods automatically.
- `top()` defaults to `26.1.2-14.0.0-fabric-4`; `mcjtylib()` defaults to `26.1.2-10.0.1-fabric.2`. These are Fabric Jenkins fallbacks for standalone builds. Workspace builds and development runs always prefer the included source projects. Minimum mod dependency versions omit artifact revision suffixes.
- `rftoolsbase()` prefers included Fabric sources and otherwise resolves `com.github.mcjty:rftoolsbase-fabric`. Isolated CI needs a published version selected with `-Prftoolsbase_version=<version>`.

## Checks

- `./gradlew :RFToolsBase:build :RFToolsPower:build :ModXNet:build :workspace:classes`
- `./gradlew -PfabricPortTests :RFToolsBase:runClientGameTest` covers native transfers, generation, menus, facade removal and model geometry against Jenkins libraries.
- `./gradlew :McJtyLib:build :workspace:classes`
- `./gradlew -PtransferTests :McJtyLib:runTransferTest` runs item/fluid transaction checks in Fabric and exits.
- `./gradlew :workspace:runClient` and `:workspace:runServer` cover game behavior.
- `./gradlew :<Mod>:runDatagen` requires that mod's datagen entrypoint.
- Do not publish or push without the user's instruction. The user's staging preference includes additions, modifications and deletions; the temporary local shared script stays excluded.
