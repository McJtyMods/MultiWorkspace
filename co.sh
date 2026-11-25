#!/usr/bin/env bash
set -euo pipefail

branch=26.3_fabric
repos=(
    "DeepResonance=https://github.com/McJtyMods/DeepResonance"
    "Trinkets=https://github.com/McJtyMods/FancyTrinkets"
    "LostCities=https://github.com/McJtyMods/LostCities"
    "LostWorlds=https://github.com/McJtyMods/LostWorlds"
    "McJtyLib=https://github.com/McJtyMods/McJtyLib"
    "ModXNet=https://github.com/McJtyMods/XNet"
    "NEW=https://github.com/romelo333/notenoughwands1.8.8"
    "Nice=https://github.com/McJtyMods/Nice"
    "Restrictions=https://github.com/McJtyMods/Restrictions"
    "RFToolsBase=https://github.com/McJtyMods/RFToolsBase"
    "RFToolsBuilder=https://github.com/McJtyMods/RFToolsBuilder"
    "RFToolsControl=https://github.com/McJtyMods/RFToolsControl"
    "RFToolsDimensions=https://github.com/McJtyMods/RFToolsDimensions"
    "RFToolsPower=https://github.com/McJtyMods/RFToolsPower"
    "RFToolsStorage=https://github.com/McJtyMods/RFToolsStorage"
    "RFToolsUtility=https://github.com/McJtyMods/RFToolsUtility"
    "SignTastic=https://github.com/McJtyMods/SignTastic"
    "InControl=https://github.com/McJtyMods/InControl"
    "LostSouls=https://github.com/McJtyMods/LostSouls"
    "Radar=https://github.com/McJtyMods/LostRadar"
    "InteractionWheel=https://github.com/McJtyMods/InteractionWheel"
    "TheOneProbe=https://github.com/McJtyMods/TheOneProbe"
)

for entry in "${repos[@]}"; do
    name=${entry%%=*}
    url=${entry#*=}
    checkout="$name"
    if [[ "$name" == LostWorlds ]]; then
        checkout="../LostWorlds_fabric"
    elif [[ "$name" == RFToolsStorage || "$name" == RFToolsControl ]]; then
        checkout="../${name}_fabric"
    fi
    if [[ -e "$name" || -e "$checkout" ]]; then
        printf 'Keeping existing checkout: %s\n' "$name"
        continue
    fi
    if git ls-remote --exit-code --heads "$url" "$branch" >/dev/null; then
        git clone --branch "$branch" --single-branch "$url" "$checkout"
    else
        printf 'Skipping %s: %s is unavailable\n' "$name" "$branch"
    fi
done
