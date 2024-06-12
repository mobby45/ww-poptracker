require("scripts/logic/entrances")

EXITS = {
    "Dragon Roost Cavern",
    "Forbidden Woods",
    "Tower of the Gods",
    "Earth Temple",
    "Wind Temple",
    "Forbidden Woods Miniboss Arena",
    "Tower of the Gods Miniboss Arena",
    "Earth Temple Miniboss Arena",
    "Wind Temple Miniboss Arena",
    "Master Sword Chamber",
    "Gohma Boss Arena",
    "Kalle Demos Boss Arena",
    "Gohdan Boss Arena",
    "Helmaroc King Boss Arena",
    "Jalhalla Boss Arena",
    "Molgera Boss Arena",
    "Savage Labyrinth",
    "Dragon Roost Island Secret Cave",
    "Fire Mountain Secret Cave",
    "Ice Ring Isle Secret Cave",
    "Cabana Labyrinth",
    "Needle Rock Isle Secret Cave",
    "Angular Isles Secret Cave",
    "Boating Course Secret Cave",
    "Stone Watcher Island Secret Cave",
    "Overlook Island Secret Cave",
    "Bird's Peak Rock Secret Cave",
    "Pawprint Isle Chuchu Cave",
    "Pawprint Isle Wizzrobe Cave",
    "Diamond Steppe Island Warp Maze Cave",
    "Bomb Island Secret Cave",
    "Rock Spire Isle Secret Cave",
    "Shark Island Secret Cave",
    "Cliff Plateau Isles Secret Cave",
    "Horseshoe Island Secret Cave",
    "Star Island Secret Cave",
    "Ice Ring Isle Inner Cave",
    "Cliff Plateau Isles Inner Cave",
    "Outset Fairy Fountain",
    "Thorned Fairy Fountain",
    "Eastern Fairy Fountain",
    "Western Fairy Fountain",
    "Southern Fairy Fountain",
    "Northern Fairy Fountain"
}

NUM_EXITS = #EXITS

_selected_exit_mapping = nil
function set_selected_exit_mapping(new)
    local old = _selected_exit_mapping
    if old == new then
        -- Nothing to do.
        return
    end
    _selected_exit_mapping = new

    -- Update the names of the exits.
    -- TODO: Do not change the name of already assigned exits and include the entrance name in assigned exits.
    if new then
        -- Update the names of the exits to include the name of the selected entrance.
        local entrance = ENTRANCES[new:Get("entrance_idx")]
        local entrance_name = entrance.name
        for _, exit_lua_item in ipairs(exit_lua_items) do
            exit_lua_item.Name = "Assign " .. entrance_name .. " -> " .. exit_lua_item:Get("exit_name")
        end
        update_exit_mapping_icon(new)
    else
        -- Update the names of the exits to only be the exit name.
        for _, exit_lua_item in ipairs(exit_lua_items) do
            exit_lua_item.Name = exit_lua_item:Get("exit_name")
        end
    end

    if old then
        update_exit_mapping_icon(old)
    end
end

function get_selected_exit_mapping()
    return _selected_exit_mapping
end

function update_exit_mapping_icon(lua_item, entrance_name, exit_name)
    if not entrance_name then
        local entrance_idx = lua_item:Get("entrance_idx")
        local entrance = ENTRANCES[entrance_idx]
        entrance_name = entrance.name
    end

    if not exit_name then
        local exit_idx = lua_item:Get("exit_idx")
        exit_name = EXITS[exit_idx]
    end

    local entrance_icon = "images/items/entrances/" .. entrance_name .. ".png"

    local exit_overlay = "overlay|images/items/entrances/exits/"
    if exit_name then
        exit_overlay = exit_overlay .. exit_name .. ".png"
    else
        exit_overlay = exit_overlay .. "Unknown.png"
    end

    local full_icon_path = entrance_icon .. ":" .. exit_overlay

    if get_selected_exit_mapping() == lua_item then
        -- Apply an outline to the selected exit mapping
        full_icon_path = full_icon_path .. ",overlay|images/items/entrances/active_overlay.png"
    end
    -- We use .IconMods to mark impossible to reach exits with @disabled, so pre-add the icon mods in the
    -- ImageReference for .Icon instead.
    print("updating .Icon to: " .. full_icon_path)
    lua_item.Icon = ImageReference:FromPackRelativePath(full_icon_path)
end

-- Update an exit mapping's name, image and exit name after its "exit_idx" has been changed
function exit_mapping_update(lua_item)
    local entrance_idx = lua_item:Get("entrance_idx")
    local entrance = ENTRANCES[entrance_idx]
    local entrance_name = entrance.name
    local exit_idx = lua_item:Get("exit_idx")
    local exit_name = EXITS[exit_idx]
    if exit_name then
        entrance.exit = exit_name
        lua_item.Name = entrance_name ..  " -> " .. exit_name
    else
        entrance.exit = nil
        lua_item.Name = entrance_name ..  " -> Unknown"
    end
    update_exit_mapping_icon(lua_item, entrance_name, exit_name)
    update_entrances()
end

function exit_mapping_save_func(lua_item)
    --print("Saving exit mapping data")
    -- "entrance_idx" is not saved/loaded.
    return { exit_idx = lua_item.ItemState.exit_idx }
end

function exit_mapping_load_func(lua_item, data)
    --print("Reading exit mapping during load")
    -- "entrance_idx" is not saved/loaded.
    if data == nil then
        print("Error: Data to read for exit mapping " .. lua_item.Name .. " was nil")
        -- The entrance's default exit_idx will be used.
        return
    end

    local exit_idx = data.exit_idx
    if exit_idx then
        lua_item:Set("exit_idx", exit_idx)
    end
    exit_mapping_update(lua_item)
end

-- Select the exit mapping
function exit_mapping_left_click(lua_item)
    if lua_item:Get("exit_idx") ~= 0 then
        -- The exit mapping is already assigned. The user should right/middle click to clear the mapping.
        return
    end

    set_selected_exit_mapping(lua_item)
    -- Swap to exits tab so the user can pick the exit to assign.
    Tracker:UiHint("ActivateTab", "Exits")
end

-- Deselect the exit mapping if it's selected, or reset the exit mapping to Unknown
function exit_mapping_right_click(lua_item)
    if lua_item == get_selected_exit_mapping() then
        set_selected_exit_mapping(nil)
    else
        exit_mapping_middle_click(lua_item)
    end
end

-- Reset back to "Unknown" exit
function exit_mapping_middle_click(lua_item)
    local exit_idx = lua_item:Get("exit_idx")
    if exit_idx == 0 then
        -- No changes
        return
    end
    lua_item:Set("exit_idx", 0)
    exit_mapping_update(lua_item)
end

function create_mapping_lua_item(idx, entrance)
    local mapping_item = ScriptHost:CreateLuaItem()

    if not mapping_item.ItemSate then
        mapping_item.ItemState = {}
    end

    mapping_item.LoadFunc = exit_mapping_load_func
    mapping_item.SaveFunc = exit_mapping_save_func

    mapping_item:Set("entrance_idx", idx)

    if not mapping_item:Get("exit_idx") then
        mapping_item:Set("exit_idx", idx)
    end

    local entrance_name = entrance.name
    mapping_item.Name = entrance_name
    --mapping_item.Icon = ImageReference:FromPackRelativePath("images/items/entrances/" .. entrance_name .. ".png")

    local codeFunc = function(self, code)
        return code == entrance_name
    end
    mapping_item.CanProvideCodeFunc = codeFunc
    mapping_item.ProvidesCodeFunc = codeFunc
    mapping_item.OnLeftClickFunc = exit_mapping_left_click
    mapping_item.OnRightClickFunc = exit_mapping_right_click
    mapping_item.OnMiddleClickFunc = exit_mapping_middle_click
    exit_mapping_update(mapping_item)

    -- TODO: Also create the placeholder items here?
    -- TODO: If an exit has been assigned to an exit mapping, can we make the exit location appear as checkable?
    --       This way, we can tell apart locations we can/cannot access and which of those have been assigned
end

exit_lua_items = {}

function create_exit_lua_item(idx, entrance)
    local exit_item = ScriptHost:CreateLuaItem()

    if not exit_item.ItemSate then
        exit_item.ItemState = {}
    end

    local exit_name = entrance.exit

    exit_item:Set("exit_name", exit_name)

    exit_item.Name = exit_name
    exit_item.Icon = ImageReference:FromPackRelativePath("images/items/exits/" .. exit_name .. ".png")

    codeFunc = function(self, code) return code == exit_name end
    exit_item.CanProvideCodeFunc = codeFunc
    exit_item.ProvidesCodeFunc = codeFunc
    exit_item.OnLeftClickFunc = function(self)
        local selected = get_selected_exit_mapping()
        if selected then
            local already_assigned_entrance = exit_to_entrance[exit_name]
            if already_assigned_entrance then
                -- Can't pick an exit that has already been assigned.
                return
            end

            --selected_exit_mapping = nil
            selected:Set("exit_idx", idx)

            set_selected_exit_mapping(nil)
            exit_mapping_update(selected)
            Tracker:UiHint("ActivateTab", "Assignment")
        end
    end

    exit_item:Set("exit_idx", idx)

    table.insert(exit_lua_items, exit_item)
end

PAUSE_ENTRANCE_UPDATES = true
for idx, entrance in ipairs(ENTRANCES) do
   create_mapping_lua_item(idx, entrance)
   create_exit_lua_item(idx, entrance)
end
PAUSE_ENTRANCE_UPDATES = false
update_entrances()