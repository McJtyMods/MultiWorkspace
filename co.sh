#!/usr/bin/env bash
set -euo pipefail

cd -- "$(dirname -- "${BASH_SOURCE[0]}")"

checkout() {
    local repository="$1"
    local directory="$2"
    if [[ -d "$directory" ]]; then
        printf 'Keeping existing checkout: %s\n' "$directory"
    else
        git clone --branch 1.21_fabric --single-branch "https://github.com/McJtyMods/$repository" "$directory"
    fi
}

checkout McJtyLib McJtyLib
checkout TheOneProbe TheOneProbe
checkout HoloGui ModHoloGui
checkout Ariente Ariente
checkout ArienteWorld ArienteWorld
