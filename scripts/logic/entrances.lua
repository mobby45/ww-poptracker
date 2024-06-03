local Entrance = require("objects/entrance")
ENTRANCE_RANDO_ENABLED = Tracker.ActiveVariantUID == "variant_entrance_rando"

-- Each entrance starts with its vanilla exit.
ENTRANCES = {
    Entrance.new("Dungeon Entrance on Dragon Roost Island", "Dragon Roost Cavern"),
    Entrance.new("Dungeon Entrance in Forest Haven Sector", "Forbidden Woods"),
    Entrance.new("Dungeon Entrance in Tower of the Gods Sector", "Tower of the Gods"),
    Entrance.new("Dungeon Entrance on Headstone Island", "Earth Temple"),
    Entrance.new("Dungeon Entrance on Gale Isle", "Wind Temple"),
    Entrance.new("Miniboss Entrance in Forbidden Woods", "Forbidden Woods Miniboss Arena", "Forbidden Woods"),
    Entrance.new("Miniboss Entrance in Tower of the Gods", "Tower of the Gods Miniboss Arena", "Tower of the Gods"),
    Entrance.new("Miniboss Entrance in Earth Temple", "Earth Temple Miniboss Arena", "Earth Temple"),
    Entrance.new("Miniboss Entrance in Wind Temple", "Wind Temple Miniboss Arena", "Wind Temple"),
    Entrance.new("Miniboss Entrance in Hyrule Castle", "Master Sword Chamber"),
    Entrance.new("Boss Entrance in Dragon Roost Cavern", "Gohma Boss Arena", "Dragon Roost Cavern"),
    Entrance.new("Boss Entrance in Forbidden Woods", "Kalle Demos Boss Arena", "Forbidden Woods"),
    Entrance.new("Boss Entrance in Tower of the Gods", "Gohdan Boss Arena", "Tower of the Gods"),
    Entrance.new("Boss Entrance in Forsaken Fortress", "Helmaroc King Boss Arena"),
    Entrance.new("Boss Entrance in Earth Temple", "Jalhalla Boss Arena", "Earth Temple"),
    Entrance.new("Boss Entrance in Wind Temple", "Molgera Boss Arena", "Wind Temple"),
    Entrance.new("Secret Cave Entrance on Outset Island", "Savage Labyrinth"),
    Entrance.new("Secret Cave Entrance on Dragon Roost Island", "Dragon Roost Island Secret Cave"),
    Entrance.new("Secret Cave Entrance on Fire Mountain", "Fire Mountain Secret Cave"),
    Entrance.new("Secret Cave Entrance on Ice Ring Isle", "Ice Ring Isle Secret Cave"),
    Entrance.new("Secret Cave Entrance on Private Oasis", "Cabana Labyrinth"),
    Entrance.new("Secret Cave Entrance on Needle Rock Isle", "Needle Rock Isle Secret Cave"),
    Entrance.new("Secret Cave Entrance on Angular Isles", "Angular Isles Secret Cave"),
    Entrance.new("Secret Cave Entrance on Boating Course", "Boating Course Secret Cave"),
    Entrance.new("Secret Cave Entrance on Stone Watcher Island", "Stone Watcher Island Secret Cave"),
    Entrance.new("Secret Cave Entrance on Overlook Island", "Overlook Island Secret Cave"),
    Entrance.new("Secret Cave Entrance on Bird's Peak Rock", "Bird's Peak Rock Secret Cave"),
    Entrance.new("Secret Cave Entrance on Pawprint Isle", "Pawprint Isle Chuchu Cave"),
    Entrance.new("Secret Cave Entrance on Pawprint Isle Side Isle", "Pawprint Isle Wizzrobe Cave"),
    Entrance.new("Secret Cave Entrance on Diamond Steppe Island", "Diamond Steppe Island Warp Maze Cave"),
    Entrance.new("Secret Cave Entrance on Bomb Island", "Bomb Island Secret Cave"),
    Entrance.new("Secret Cave Entrance on Rock Spire Isle", "Rock Spire Isle Secret Cave"),
    Entrance.new("Secret Cave Entrance on Shark Island", "Shark Island Secret Cave"),
    Entrance.new("Secret Cave Entrance on Cliff Plateau Isles", "Cliff Plateau Isles Secret Cave"),
    Entrance.new("Secret Cave Entrance on Horseshoe Island", "Horseshoe Island Secret Cave"),
    Entrance.new("Secret Cave Entrance on Star Island", "Star Island Secret Cave"),
    Entrance.new("Inner Entrance in Ice Ring Isle Secret Cave", "Ice Ring Isle Inner Cave", "Ice Ring Isle Secret Cave"),
    Entrance.new("Inner Entrance in Cliff Plateau Isles Secret Cave", "Cliff Plateau Isles Inner Cave", "Cliff Plateau Isles Secret Cave"),
    Entrance.new("Fairy Fountain Entrance on Outset Island", "Outset Fairy Fountain"),
    Entrance.new("Fairy Fountain Entrance on Thorned Fairy Island", "Thorned Fairy Fountain"),
    Entrance.new("Fairy Fountain Entrance on Eastern Fairy Island", "Eastern Fairy Fountain"),
    Entrance.new("Fairy Fountain Entrance on Western Fairy Island", "Western Fairy Fountain"),
    Entrance.new("Fairy Fountain Entrance on Southern Fairy Island", "Southern Fairy Fountain"),
    Entrance.new("Fairy Fountain Entrance on Northern Fairy Island", "Northern Fairy Fountain"),
}

ENTRANCE_BY_NAME = {}
-- Exits mapped to entrances located in that exit
ENTRANCE_ACCESSIBILITY = {}
for _, entrance in ipairs(ENTRANCES) do
    ENTRANCE_BY_NAME[entrance.name] = entrance

    local parent_exit = entrance.parent_exit
    local entrances_list = ENTRANCE_ACCESSIBILITY[parent_exit]
    if entrances_list == nil then
        entrances_list = {}
        ENTRANCE_ACCESSIBILITY[parent_exit] = entrances_list
    end
    table.insert(entrances_list, entrance)
end

ENTRANCE_ACCESSIBILITY_REVERSE = {}
for exit, entrances in pairs(ENTRANCE_ACCESSIBILITY) do
    for _, entrance in ipairs(entrances) do
        ENTRANCE_ACCESSIBILITY_REVERSE[entrance] = exit
    end
end

entrance_to_exit = {}
exit_to_entrance = {}
-- Entrances may form loops that make access to some areas impossible. All of these entrances will then be considered
-- impossible.
impossible_entrances = {}
impossible_exits = {}

-- local function is_possible(entrance_name, checked_set)
--     if not checked_set then
--         checked_set = {}
--     end
--     if checked_set[entrance_name] then
--         -- Already checked this entrance, so we've got a loop.
--         return false
--     end
--     checked_set[entrance_name] = true
--
--     local entrance = ENTRANCE_BY_NAME[entrance_name]
--     local parent_exit = entrance.parent_exit
--     if parent_exit == "The Great Sea" then
--         -- The Great Sea is always accessible
--         return true
--     end
--     -- Check if the parent_exit's entrance is possible to access.
--     local parent_entrance = exit_to_entrance[parent_exit]
--     return is_possible(parent_entrance, checked_set)
-- end

local function is_exit_possible(exit_name, checked_set)
    if exit_name == "The Great Sea" then
        -- The Great Sea is always accessible.
        return true
    end
    if impossible_exits[exit_name] then
        -- This exit has already been found to be impossible.
        -- This should not normally happen because left/right click to cycle through exits skips already assigned exits.
        return false
    end

    if not checked_set then
        checked_set = {}
    end
    if checked_set[exit_name] then
        -- Already checked this exit, so we've got a loop.
        return false
    end
    checked_set[exit_name] = true

    -- Get the name of the entrance that leads to this exit
    local entrance_name = exit_to_entrance[exit_name]
    if not entrance_name then
        -- No entrance is currently mapped to this exit, so the exit is considered unreachable.
        return false
    end
    -- Get the entrance object by its name
    local entrance = ENTRANCE_BY_NAME[entrance_name]
    -- Check if the parent exit that leads to this entrance is possible
    local parent_exit = entrance.parent_exit
    return is_exit_possible(parent_exit, checked_set)
end

PAUSE_ENTRANCE_UPDATES = false

function forceLogicUpdate()
    local update = Tracker:FindObjectForCode("update")
    -- If we call this too early, the item doesn't seem to exist yet
    if update then
        print("Forced update!")
        update.Active = not update.Active
    end
end

function update_entrances(initializing)
    if not initializing and (PAUSE_ENTRANCE_UPDATES or not ENTRANCE_RANDO_ENABLED) then
        return
    end
    -- Reset
    entrance_to_exit = {}
    exit_to_entrance = {}
    impossible_exits = {}
    -- Create mappings for entrance -> exit pairs
    for _, entrance in ipairs(ENTRANCES) do
        local exit = entrance.exit
        entrance_to_exit[entrance.name] = exit
        -- exit may be `nil` if it has not been set
        if exit then
            local current_mapped_entrance = exit_to_entrance[exit]
            if current_mapped_entrance then
                impossible_exits[exit] = true
                print("Exit '" .. exit .. "' trying to be mapped from " .. entrance.name .. ", but is already mapped from '" .. current_mapped_entrance .. "'. Marking the exit as impossible.")
            else
                exit_to_entrance[exit] = entrance.name
            end
        end
    end

    if initializing then
        -- When initializing, there is no need to check for unreachable exits because any assigned exits won't have been
        -- loaded from auto-saved state yet (and entrance randomization may not even be enabled).
        return
    end

    -- Check for unreachable exits
    for _, entrance in ipairs(ENTRANCES) do
        local exit_name = entrance.exit
        if exit_name and not is_exit_possible(exit_name) then
            print("Exit '" .. exit_name .. "' is impossible to reach")
            impossible_exits[exit_name] = true
        end
    end
    forceLogicUpdate()

    -- Visibly mark impossible exits
    for _, entrance in ipairs(ENTRANCES) do
        local exit_name = entrance.exit
        local lua_item = Tracker:FindObjectForCode(entrance.name)
        -- It's possible we could be trying to update before all the items have been created in exit_mappings.lua.
        if lua_item then
            -- TODO: Also find the placeholder items and change their overlay colour too (will require replacing them
            --       with `LuaItem` instances too)
            if exit_name and impossible_exits[exit_name] then
                -- TODO: Red overlay or something else that stands out more to indicate that the exit is impossible to
                --       reach (or invalid due to being duplicated).
                lua_item.IconMods = "@disabled"
            else
                lua_item.IconMods = "none"
            end
        end
    end
end

update_entrances(true)