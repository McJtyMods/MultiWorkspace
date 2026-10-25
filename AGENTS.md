# AGENTS.md

## Workspace

- This is the Fabric 26.2 MultiWorkSpace. Use Java 25, Gradle 9.5.1 and Fabric Loom 1.17.17.
- Root settings include available nested or sibling `*_fabric` repositories. Each mod must also build standalone. Override checkout paths with `-Pmod.<Name>=<path>`.
- Shared behavior lives in `gradletools.gradle`. Mods apply the remote `26.2_fabric` script directly, both standalone and in the workspace. Do not keep mod-local copies. The workspace aggregator uses this repository's root script.
- `workspace/build.gradle` collects all included mods through Loom mod source sets and implementation dependencies; it has no dummy mod entrypoint.

## Fabric conventions

- Use separate `ModInitializer` and `ClientModInitializer` entrypoints in `fabric.mod.json`.
- Register native registries during common initialization. McJtyLib deferred register helpers use `register()` without event bus arguments.
- Use Fabric block/item lookups, attachments, events, extended menus and transfer transactions. GUI slot helpers are library-owned APIs; automation uses native Fabric Storage and Team Reborn EnergyStorage.
- Forge Config API Port provides the TOML config API. Its config class names retain `net.neoforged` packages but no NeoForge loader is used.
- Separate server and client payload receivers. TOP discovers plugins via the `theoneprobe` entrypoint.
- Datagen uses Fabric's `DataGeneratorEntrypoint`, `FabricPackOutput` and registry lookup future. Generated resources remain under `src/generated/resources`.
- Only include Fabric ports; this workspace does not convert other sibling mods automatically.

## Checks

- `./gradlew :McJtyLib:build :workspace:classes`
- `./gradlew -PtransferTests :McJtyLib:runTransferTest` runs item/fluid transaction checks in Fabric and exits.
- `./gradlew :workspace:runClient` and `:workspace:runServer` cover game behavior.
- `./gradlew :<Mod>:runDatagen` requires that mod's datagen entrypoint.
- Do not publish or push without the user's instruction. The user's staging preference includes additions, modifications and deletions.
