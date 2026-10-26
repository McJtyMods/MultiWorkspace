# AGENTS.md

## Big picture
- `Multi_neo` is a **multi-mod NeoForge 26.3 workspace**: root `settings.gradle` includes available nested or sibling standalone mod repos plus a special `workspace` aggregator module.
- Treat each top-level mod folder (`McJtyLib`, `RFToolsBase`, `RFToolsUtility`, `LostCities`, etc.) as a repo that should still build standalone. The root workspace is mainly for integrated development and debugging.
- Shared Gradle behavior lives in `gradletools.gradle`; nearly every module `build.gradle` applies that local file, or falls back to the 26.3 remote copy if opened standalone. Standalone McJtyLib applies the sibling `../Multi_neo/gradletools.gradle` directly (or the parent script for nested checkouts).
- `workspace/build.gradle` is the dev runtime hub: it adds included mods other than the McJtyLib checkout as both `modSource` and `implementation`; McJtyLib resolves from the Jenkins-published version in `gradletools.gradle`, so integrated playtesting should happen there.

## Dependency / architecture map
- `McJtyLib` is the common foundation library (`McJtyLib/README.md`, `McJtyLib/src/main/java/mcjty/lib/...`).
- RFTools-family mods generally layer as **`McJtyLib` -> `RFToolsBase` -> feature mod** (see `RFToolsUtility/build.gradle`, `RFToolsPower/build.gradle`, `RFToolsStorage/build.gradle`).
- Build dependencies are declared through helper functions from `gradletools.gradle` such as `mc()`, `mcjtylib()`, `rftoolsbase()`, `top()`, `jei()`, `patchouli()`, `curios()`, `lostcities()` instead of repeating Maven coordinates.
- `mcjtylib()` always resolves the published library. `rftoolsbase()` uses the included local checkout when present, with `rftoolsbase_version` as its Maven fallback.
- External integrations worth preserving: The One Probe API, JEI, Patchouli, Curios, and LostCities; publishing hooks for Modrinth/CurseForge are also centralized in `gradletools.gradle`.

## Code structure patterns to follow
- Mod entrypoints are intentionally thin. Follow the pattern in `RFToolsBase/src/main/java/mcjty/rftoolsbase/RFToolsBase.java`, `RFToolsUtility/.../RFToolsUtility.java`, and `LostCities/.../LostCities.java`:
  - register config,
  - initialize `setup/Registration`,
  - attach event listeners,
  - branch client-only listeners on `Dist`.
- Most feature work belongs in a **module class** implementing `mcjty.lib.modules.IModule`; mods collect them with `mcjty.lib.modules.Modules` (`McJtyLib/src/main/java/mcjty/lib/modules/Modules.java`). Add new gameplay areas by registering a module in the mod’s `setupModules(...)`, not by bloating the `@Mod` class.
- Central registries live in each mod’s `setup/Registration.java`. Use the existing `RBlockRegistry`, `DeferredBlocks`, `DeferredItems`, and `DeferredRegister` instances there rather than creating ad-hoc registries elsewhere.
- Data components and player/entity attachments are first-class patterns here (examples: `RFToolsBase/modules/*Module.java` and `RFToolsUtility/setup/Registration.java`). Prefer them over older NBT-only storage approaches when touching related systems.
- Creative-tab population is routed through the mod `setup` object plus `Registration.TAB`; examples are in `RFToolsBase/setup/Registration.java` and `RFToolsUtility/setup/Registration.java`.

## Data generation, assets, and networking
- Many mods include `src/generated/resources` in `sourceSets.main.resources`; generated assets are expected to be committed/used from there.
- Datagen is usually driven from the mod entrypoint via `GatherDataEvent` and delegated into modules with `mcjty.lib.datagen.DataGen` / `Dob` builders (see `RFToolsBase.java`, `RFToolsUtility.java`, `modules/crafting/CraftingModule.java`).
- Networking is standardized around NeoForge `PayloadRegistrar` with `.versioned("1.0").optional()` in `*Messages.java`, often wrapped by McJtyLib helper packets/typed commands (`McJtyLib/src/main/java/mcjty/lib/network/Networking.java`).

## Cross-mod communication to be aware of
- `RFToolsUtility` exposes IMC hooks for `getTeleportationManager` and `getScreenModuleRegistry` in `RFToolsUtility.java`.
- `LostCities` exposes IMC APIs through `ILostCities.GET_LOST_CITIES` / `GET_LOST_CITIES_PRE`; do not break those method strings or callback shapes.
- The One Probe is both a dependency and an API surface used by other mods; avoid changes that silently break `mcjty.theoneprobe.api` consumers.

## Developer workflow
- Preferred IDE setup comes from the root README: open the **root `build.gradle`** in IntelliJ, run `ideSync`, then use the generated run config for the `workspace` module.
- Command-line work should usually be run from the repo root with project-qualified tasks, for example:
  - `./gradlew :workspace:runClient`
  - `./gradlew :RFToolsUtility:build`
  - `./gradlew :RFToolsUtility:runClientData`
- Important environment note: current builds require **Java 25 to launch Gradle, and the scripts target Java toolchain 25** (`java.toolchain.languageVersion = 25`). A root `gradlew projects` run failed under Java 8 in this workspace, so fix `JAVA_HOME` first if Gradle dies early.
- McJtyLib has JUnit regression checks for transactions, NBT conversion, and model JSON. Run `:McJtyLib:test` or `:McJtyLib:portingRegression`, plus targeted builds, datagen, and `:workspace` game runs.
- Publishing tasks are conditional: `modrinth` needs `modrinth_token`, `curseforge` needs `curseforge_key`, and some modules publish to a local Maven repo when `local_maven` is set.

