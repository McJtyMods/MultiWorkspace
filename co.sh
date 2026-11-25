git clone https://github.com/McJtyMods/DeepResonance DeepResonance
pushd DeepResonance
git checkout 1.21_neo
popd

git clone https://github.com/McJtyMods/FancyTrinkets Trinkets
pushd Trinkets
git checkout 1.21_neo
popd

git clone https://github.com/McJtyMods/LostCities LostCities
pushd LostCities
git checkout 1.21_neo
popd

#git clone https://github.com/McJtyMods/LostEdit LostEdit
#pushd LostEdit
#git checkout 1.21_neo
#popd

git clone https://github.com/McJtyMods/McJtyLib McJtyLib
pushd McJtyLib
git checkout 1.21_neo
popd

git clone https://github.com/McJtyMods/XNet ModXNet
pushd ModXNet
git checkout 1.21_neo
popd

git clone https://github.com/romelo333/notenoughwands1.8.8 NEW
pushd NEW
git checkout 1.21_neo
popd

git clone https://github.com/McJtyMods/Nice Nice
pushd Nice
git checkout 1.21_neo
popd

git clone https://github.com/McJtyMods/Restrictions Restrictions
pushd Restrictions
git checkout 1.21_neo
popd

git clone https://github.com/McJtyMods/RFToolsBase RFToolsBase
pushd RFToolsBase
git checkout 1.21_neo
popd

git clone https://github.com/McJtyMods/RFToolsBuilder RFToolsBuilder
pushd RFToolsBuilder
git checkout 1.21_neo
popd

if [[ ! -e RFToolsControl && ! -e ../RFToolsControl_neo ]]; then
    git clone --branch 26.1.2_neo --single-branch https://github.com/McJtyMods/RFToolsControl ../RFToolsControl_neo
fi

git clone https://github.com/McJtyMods/RFToolsDimensions RFToolsDimensions
pushd RFToolsDimensions
git checkout 1.21_neo
popd

git clone https://github.com/McJtyMods/RFToolsPower RFToolsPower
pushd RFToolsPower
git checkout 1.21_neo
popd

if [[ ! -e RFToolsStorage && ! -e ../RFToolsStorage_neo ]]; then
    git clone --branch 26.1.2_neo --single-branch https://github.com/McJtyMods/RFToolsStorage ../RFToolsStorage_neo
fi

git clone https://github.com/McJtyMods/RFToolsUtility RFToolsUtility
pushd RFToolsUtility
git checkout 1.21_neo
popd

git clone https://github.com/McJtyMods/SignTastic SignTastic
pushd SignTastic
git checkout 1.21_neo
popd

git clone https://github.com/McJtyMods/InControl InControl
pushd InControl
git checkout 1.21_neo
popd

#git clone https://github.com/McJtyMods/HoloGui ModHoloGui
#pushd ModHoloGui
#git checkout 1.21_neo
#popd

git clone https://github.com/McJtyMods/LostSouls LostSouls
pushd LostSouls
git checkout 1.21_neo
popd

#git clone https://github.com/McJtyMods/LostRuins LostRuins
#pushd LostRuins
#git checkout 1.21_neo
#popd

if [[ ! -e ../LostWorlds_neo && ! -e LostWorlds ]]; then
    git clone --branch 26.1.2_neo --single-branch https://github.com/McJtyMods/LostWorlds ../LostWorlds_neo
fi

git clone https://github.com/McJtyMods/LostRadar Radar
pushd LostRadar
git checkout 1.21_neo
popd


git clone https://github.com/McJtyMods/InteractionWheel
pushd InteractionWheel
git checkout 1.21_neo
popd

git clone https://github.com/McJtyMods/TheOneProbe
pushd TheOneProbe
git checkout 1.21_neo
popd

#git clone https://github.com/McJtyMods/ParsMinima ParsMinima
#pushd ParsMinima
#git checkout 1.21_neo
#popd

