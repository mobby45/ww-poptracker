-- Logic
require("scripts/utils")
require("scripts/logic/logic")
print("Logic scripts loaded")

-- Lua Items
-- The base variant does not have entrance rando, so these items and their global functions are not needed and loading
-- exit_mappings.lua will return `false`.
if require("scripts/items/exit_mappings") then
    print("Exit mapping lua items loaded")
end

-- Items
Tracker:AddItems("items/items.json")
Tracker:AddItems("items/settings.json")
Tracker:AddItems("items/internal.json")

-- Maps
Tracker:AddMaps("maps/maps.json")

-- Logic Locations
Tracker:AddLocations("locations/logic/general_logic.json")
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
Tracker:AddLayouts("layouts/items_variant.json") -- itemgrid layouts that change depending on the active variant.
Tracker:AddLayouts("layouts/entrances.json")
Tracker:AddLayouts("layouts/tracker.json")
Tracker:AddLayouts("layouts/broadcast.json")
Tracker:AddLayouts("layouts/settings.json")

-- AutoTracking for Poptracker
require("scripts/autotracking")
print("Autotracking script loaded")

-- Pause logic updates until the next frame, so that auto-save state can load without causing updates.
pauseLogicUntilNextFrame("tracker post-init")