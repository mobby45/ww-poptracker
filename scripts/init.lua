local ENTRANCE_RANDO_ENABLED = Tracker.ActiveVariantUID == "variant_entrance_rando"

-- Logic
ScriptHost:LoadScript("scripts/utils.lua")
ScriptHost:LoadScript("scripts/logic/logic.lua")
print("Logic scripts loaded")

-- Items
Tracker:AddItems("items/items.json")
Tracker:AddItems("items/settings.json")

if ENTRANCE_RANDO_ENABLED then
    -- Variants have separate auto-save state and exported state includes the active variant, so there's no need to
    -- create these items when entrance rando is not enabled.
    Tracker:AddItems("items/internal.json")
    Tracker:AddItems("items/entrance_names.json")
    -- Lua Items
    ScriptHost:LoadScript("scripts/items/exit_mappings.lua")
    print("Exit mapping lua items loaded")
end

-- Maps
Tracker:AddMaps("maps/maps.json")

-- Logic Locations
Tracker:AddLocations("locations/logic/exits.json")
Tracker:AddLocations("locations/logic/macros.json")
Tracker:AddLocations("locations/logic/entrances.json")

-- Locations
Tracker:AddLocations("locations/ff.json")
Tracker:AddLocations("locations/wt.json")
Tracker:AddLocations("locations/drc.json")
Tracker:AddLocations("locations/totg.json")
Tracker:AddLocations("locations/fw.json")
Tracker:AddLocations("locations/et.json")
Tracker:AddLocations("locations/locations.json")
Tracker:AddLocations("locations/salvage.json")

-- Layout
Tracker:AddLayouts("layouts/items.json")
Tracker:AddLayouts("layouts/entrances.json")
Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/broadcast.json")

-- AutoTracking for Poptracker
ScriptHost:LoadScript("scripts/autotracking.lua")
print("Autotracking script loaded")
