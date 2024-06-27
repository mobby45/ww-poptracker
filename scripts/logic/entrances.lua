local Entrance = require("objects/entrance")
ENTRANCE_RANDO_ENABLED = Tracker.ActiveVariantUID == "variant_entrance_rando"

-- Each entrance starts with its vanilla exit.
ENTRANCES = {
    Entrance.new("Dungeon Entrance on Dragon Roost Island", "Dragon Roost Cavern", "dungeon"),
    Entrance.new("Dungeon Entrance in Forest Haven Sector", "Forbidden Woods", "dungeon"),
    Entrance.new("Dungeon Entrance in Tower of the Gods Sector", "Tower of the Gods", "dungeon"),
    Entrance.new("Dungeon Entrance on Headstone Island", "Earth Temple", "dungeon"),
    Entrance.new("Dungeon Entrance on Gale Isle", "Wind Temple", "dungeon"),
    Entrance.new("Miniboss Entrance in Forbidden Woods", "Forbidden Woods Miniboss Arena", "miniboss", "Forbidden Woods"),
    Entrance.new("Miniboss Entrance in Tower of the Gods", "Tower of the Gods Miniboss Arena", "miniboss", "Tower of the Gods"),
    Entrance.new("Miniboss Entrance in Earth Temple", "Earth Temple Miniboss Arena", "miniboss", "Earth Temple"),
    Entrance.new("Miniboss Entrance in Wind Temple", "Wind Temple Miniboss Arena", "miniboss", "Wind Temple"),
    Entrance.new("Miniboss Entrance in Hyrule Castle", "Master Sword Chamber", "miniboss"),
    Entrance.new("Boss Entrance in Dragon Roost Cavern", "Gohma Boss Arena", "boss", "Dragon Roost Cavern"),
    Entrance.new("Boss Entrance in Forbidden Woods", "Kalle Demos Boss Arena", "boss", "Forbidden Woods"),
    Entrance.new("Boss Entrance in Tower of the Gods", "Gohdan Boss Arena", "boss", "Tower of the Gods"),
    Entrance.new("Boss Entrance in Forsaken Fortress", "Helmaroc King Boss Arena", "boss"),
    Entrance.new("Boss Entrance in Earth Temple", "Jalhalla Boss Arena", "boss", "Earth Temple"),
    Entrance.new("Boss Entrance in Wind Temple", "Molgera Boss Arena", "boss", "Wind Temple"),
    Entrance.new("Secret Cave Entrance on Outset Island", "Savage Labyrinth", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Dragon Roost Island", "Dragon Roost Island Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Fire Mountain", "Fire Mountain Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Ice Ring Isle", "Ice Ring Isle Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Private Oasis", "Cabana Labyrinth", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Needle Rock Isle", "Needle Rock Isle Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Angular Isles", "Angular Isles Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Boating Course", "Boating Course Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Stone Watcher Island", "Stone Watcher Island Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Overlook Island", "Overlook Island Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Bird's Peak Rock", "Bird's Peak Rock Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Pawprint Isle", "Pawprint Isle Chuchu Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Pawprint Isle Side Isle", "Pawprint Isle Wizzrobe Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Diamond Steppe Island", "Diamond Steppe Island Warp Maze Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Bomb Island", "Bomb Island Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Rock Spire Isle", "Rock Spire Isle Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Shark Island", "Shark Island Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Cliff Plateau Isles", "Cliff Plateau Isles Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Horseshoe Island", "Horseshoe Island Secret Cave", "secret_cave"),
    Entrance.new("Secret Cave Entrance on Star Island", "Star Island Secret Cave", "secret_cave"),
    Entrance.new("Inner Entrance in Ice Ring Isle Secret Cave", "Ice Ring Isle Inner Cave", "inner", "Ice Ring Isle Secret Cave"),
    Entrance.new("Inner Entrance in Cliff Plateau Isles Secret Cave", "Cliff Plateau Isles Inner Cave", "inner", "Cliff Plateau Isles Secret Cave"),
    Entrance.new("Fairy Fountain Entrance on Outset Island", "Outset Fairy Fountain", "fairy"),
    Entrance.new("Fairy Fountain Entrance on Thorned Fairy Island", "Thorned Fairy Fountain", "fairy"),
    Entrance.new("Fairy Fountain Entrance on Eastern Fairy Island", "Eastern Fairy Fountain", "fairy"),
    Entrance.new("Fairy Fountain Entrance on Western Fairy Island", "Western Fairy Fountain", "fairy"),
    Entrance.new("Fairy Fountain Entrance on Southern Fairy Island", "Southern Fairy Fountain", "fairy"),
    Entrance.new("Fairy Fountain Entrance on Northern Fairy Island", "Northern Fairy Fountain", "fairy"),
}

EXIT_NAMES = {}
ENTRANCE_BY_NAME = {}
ENTRANCE_TYPE_TO_ENTRANCES = {}
for _, entrance in ipairs(ENTRANCES) do
    ENTRANCE_BY_NAME[entrance.name] = entrance
    table.insert(EXIT_NAMES, entrance.exit)
    local by_type_table = ENTRANCE_TYPE_TO_ENTRANCES[entrance.entrance_type]
    if by_type_table == nil then
        by_type_table = {}
        ENTRANCE_TYPE_TO_ENTRANCES[entrance.entrance_type] = by_type_table
    end
    table.insert(by_type_table, entrance)
end

-- Quick lookup tables for exits.
exit_to_entrance = {}
-- Entrances may by set by the user such that they form loops that make access to some areas impossible. All of the
-- exits in the loop will be considered impossible.
-- While it should not happen through normal usage, an exit is also considered impossible if it is assigned to more than
-- one entrance.
impossible_exits = {}

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

    -- Prevent infinite loops by keeping a set of the exit names checked so far.
    if not checked_set then
        checked_set = {}
    end
    if checked_set[exit_name] then
        -- Already checked this exit, so we've got a loop.
        return false
    end
    checked_set[exit_name] = true

    -- Get the entrance object that leads to this exit
    local entrance = exit_to_entrance[exit_name]
    if not entrance then
        -- No entrance is currently mapped to this exit, so the exit is considered unreachable.
        return false
    end
    -- Check if the parent exit that leads to this entrance is possible
    local parent_exit = entrance.parent_exit
    return is_exit_possible(parent_exit, checked_set)
end

PAUSE_ENTRANCE_UPDATES = false

function forceLogicUpdate()
    local update = Tracker:FindObjectForCode("update")
    -- If this function is called too early, the item won't exist yet. The item also won'#t exist when entrance
    -- randomization is not enabled.
    if update then
        --print("Forced update!")
        update.Active = not update.Active
    end
end

function update_entrances(initializing)
    if not initializing and (PAUSE_ENTRANCE_UPDATES or not ENTRANCE_RANDO_ENABLED) then
        return
    end
    -- Reset the global lookup tables.
    exit_to_entrance = {}
    impossible_exits = {}
    -- Create mappings for entrance -> exit pairs
    for _, entrance in ipairs(ENTRANCES) do
        local exit = entrance.exit
        -- `exit` is `nil` when the exit is set to "Unknown" by the user.
        if exit then
            -- An exit can only be mapped to a single entrance. If not, the exit is considered impossible.
            local current_mapped_entrance = exit_to_entrance[exit]
            if current_mapped_entrance then
                impossible_exits[exit] = true
                --print("Exit '" .. exit .. "' trying to be mapped from " .. entrance.name .. ", but is already mapped from '" .. current_mapped_entrance.name .. "'. Marking the exit as impossible.")
            else
                exit_to_entrance[exit] = entrance
            end
        end
    end

    if initializing then
        -- When initializing with the vanilla exits, there is no need to check for unreachable exits.
        return
    end

    -- Check for unreachable exits
    for _, entrance in ipairs(ENTRANCES) do
        local exit_name = entrance.exit
        if exit_name and not is_exit_possible(exit_name) then
            --print("Exit '" .. exit_name .. "' is impossible to reach")
            impossible_exits[exit_name] = true
        end
    end

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

    -- Force logic to update because the result of lua functions that check exit accessibility may now give different
    -- results.
    forceLogicUpdate()
end

-- Update the global lookup tables with the vanilla exits.
update_entrances(true)