# Workspace

This is the Fabric 1.21.1 MultiWorkspace on branch `1.21_fabric`. Use Java 21, Gradle 8.14.2, and Fabric Loom 1.10.5.

The nested McJtyLib, TheOneProbe, ModHoloGui, Ariente and ArienteWorld folders are separate repositories. Shared build behavior belongs in `gradletools.gradle`. Prefer included source projects for builds and development runs; Jenkins artifacts are standalone fallbacks. Individual mods support an explicit `gradletools_path`, the workspace root, a sibling Multi_fabric directory, a parent script, a standalone local script, and the matching remote branch.

Use `/data/Projects/Multi21_fabric/.gradle-user-home` as the IntelliJ Gradle user home. The workspace wrapper selects its own isolated home automatically. Run `python3 tools/configure-gradle-home.py` to install its target guard.

Build with `./gradlew :McJtyLib:build :TheOneProbe:build :ModHoloGui:build :Ariente:build :ArienteWorld:build :workspace:classes`. Use `:workspace:runClient` and `:workspace:runServer` for integrated playtesting. Datagen uses Fabric `runDatagen` tasks.

Stage task changes, including deletions, without committing. Keep local shared-script copies, Gradle caches and runtime files excluded from Git. Remove empty source directories after verification.
