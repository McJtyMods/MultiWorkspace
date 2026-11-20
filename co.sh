#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

for mod in LostCities LostWorlds; do
    checkout="../${mod}_neo"
    if [[ ! -e "$checkout" && ! -e "$mod" ]]; then
        git clone --branch 1.21.11_neo --single-branch "https://github.com/McJtyMods/$mod" "$checkout"
    fi
done
