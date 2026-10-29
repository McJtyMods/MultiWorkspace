# AGENTS.md

## Workspace

- This is the Fabric 26.3 MultiWorkSpace. Use Java 25, Gradle 9.6.0 and Fabric Loom 1.17.21.
- Root settings include available nested or sibling `*_fabric` repositories. Each mod must also build standalone. Override checkout paths with `-Pmod.<Name>=<path>`.
- Shared behavior lives in `gradletools.gradle`. McJtyLib applies the integrated root script, the sibling `../Multi_fabric/gradletools.gradle`, a nested parent script, or the remote `26.3_fabric` script. Do not keep a copied script inside McJtyLib.
- `workspace/build.gradle` collects every included mod through Loom mod source sets and implementation dependencies; it has no dummy mod entrypoint.
- Keep `generateRunConfig` enabled for workspace runs; Loom disables IDE generation for subprojects by default. Use the dot-free Gradle root name `26_3_fabric` to match IntelliJ module names. `:workspace:ideaSyncTask` generates the combined `Client` and `Server` configurations.
- Dependency helpers and aggregate runs always prefer included local checkouts of McJtyLib, RFToolsBase, TheOneProbe, and other mods. Published artifacts are standalone fallbacks.
- `rftoolsbase()` uses the included local port until a Jenkins artifact exists. Power and XNet standalone settings also include the sibling RFToolsBase checkout.

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
- `./gradlew -PtransferTests :McJtyLib:runDatagenTest` checks recipe, advancement, loot and model generation.
- `./gradlew -PtransferTests -PclientTests :McJtyLib:runClient` checks pipelines, SDL input and text focus, then exits.
- `./gradlew :workspace:runClient` and `:workspace:runServer` cover game behavior.
- `./gradlew :<Mod>:runDatagen` requires that mod's datagen entrypoint.
- Do not publish or push without the user's instruction. The user's staging preference includes additions, modifications and deletions; do not add a copied shared script to McJtyLib.
