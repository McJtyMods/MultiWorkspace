#!/usr/bin/env python3
"""Prepare a private Gradle home and print the required IntelliJ setting."""

from pathlib import Path
import re
import shutil


def main():
    workspace = Path(__file__).resolve().parents[1]
    gradle_home = workspace / '.gradle-user-home'
    guard = workspace / 'gradle/gradle-home.init.gradle'
    target = re.search(r"def minecraftTarget = '([^']+)'", guard.read_text()).group(1)
    marker = gradle_home / '.minecraft-target'
    if gradle_home.resolve() == (Path.home() / '.gradle').resolve():
        raise SystemExit('The workspace Gradle home must not point to ~/.gradle.')
    if marker.exists() and marker.read_text().strip() != target:
        raise SystemExit(f'{gradle_home} belongs to another Minecraft target.')

    init_directory = gradle_home / 'init.d'
    init_directory.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(guard, init_directory / 'minecraft-target.gradle')

    # Current IntelliJ stores the user home in GradleLocalSettings in its IDE
    # cache. GradleSettings in gradle.xml ignores this older option. Remove the
    # option written by the previous helper and let the Settings UI persist the
    # actual value, including in the running project's in-memory state.
    ide_settings = workspace / '.idea/gradle.xml'
    if ide_settings.exists():
        content = ide_settings.read_text()
        pattern = r'(?m)^[ \t]*<option name="serviceDirectoryPath" value="\$PROJECT_DIR\$/\.gradle-user-home" />\r?\n'
        updated = re.sub(pattern, '', content)
        if updated != content:
            ide_settings.write_text(updated)

    print('Private Gradle home prepared. In this IntelliJ project, open:')
    print('Settings > Build, Execution, Deployment > Build Tools > Gradle')
    print('Use the Gradle user home field above the per-Gradle-build settings.')
    print('Open different Minecraft workspaces as separate IntelliJ projects.')
    print('Set Gradle user home to:')
    print(gradle_home)
    print('Click Apply, then reload all Gradle projects.')


if __name__ == '__main__':
    main()
