if ARCHIPELAGO_LOADED then
    return
else
    ARCHIPELAGO_LOADED = true
end

ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")
ScriptHost:LoadScript("scripts/logic/entrances.lua")
ScriptHost:LoadScript("scripts/items/exit_mappings.lua")
ScriptHost:LoadScript("scripts/utils.lua")

CUR_INDEX = -1
SLOT_DATA = nil

-- Tracker Tab names and the Stages that should swap to those tabs.
-- Stage names from https://github.com/LagoLunatic/wwrando/blob/master/data/stage_names.txt
local _STAGE_MAPPING = {
    {
        "The Great Sea",
        {
            -- Stages which do not form connections with potentially randomized entrances are not included in this list.
            "sea", -- The Great Sea
            "Abesso", -- Cabana Interior
            "Adanmae", -- Dragon Roost Cavern Entrance
            "A_mori", -- Outset Island Fairy Woods
            -- Caves 06 and 08 are unused.
            "Cave01", -- Bomb Island Cave
            "Cave02", -- Star Island Cave
            "Cave03", -- Cliff Plateau Isles Cave
            "Cave04", -- Rock Spire Isle Cave
            "Cave05", -- Horseshoe Island Cave
            "Cave07", -- Pawprint Isle Wizzrobe Cave
            "Cave09", -- Savage Labyrinth
            "Cave10", -- Savage Labyrinth
            "Cave11", -- Savage Labyrinth
            "Edaichi", -- Earth Temple Entrance (the room on Headstone Island before the dungeon)
            "Ekaze", -- Wind Temple Entrance (the room on Gale Isle before the dungeon)
            "Fairy01", -- Northern Fairy Island Fairy Fountain
            "Fairy02", -- Eastern Fairy Island Fairy Fountain
            "Fairy03", -- Western Fairy Island Fairy Fountain
            "Fairy04", -- Outset Island Fairy Fountain
            "Fairy05", -- Thorned Fairy Island Fairy Fountain
            "Fairy06", -- Southern Fairy Island Fairy Fountain
            "ITest62", -- Ice Ring Isle Inner Cave
            "ITest63", -- Shark Island Cave
            "kenroom", -- Master Sword Chamber
            "MiniHyo", -- Ice Ring Isle Cave
            "MiniKaz", -- Fire Mountain Cave
            "SubD42", -- Needle Rock Isle Cave
            "SubD43", -- Angular Isles Cave
            "SubD71", -- Boating Course Cave
            -- TF 05 and 07 are unused.
            "TF_01", -- Stone Watcher Island Cave
            "TF_02", -- Overlook Island Cave
            "TF_03", -- Bird's Peak Rock Cave
            "TF_04", -- Cabana Labyrinth
            "TF_06", -- Dragon Roost Island Secret Cave
            "TyuTyu", -- Pawprint Isle Chuchu Cave
            "WarpD", -- Diamond Steppe Island Warp Maze
        }
    },
    {
        "Dragon Roost Cavern",
        {
            "M_Dra09", -- Dragon Roost Cavern Moblin Miniboss Room
            "M_DragB", -- Dragon Roost Cavern Gohma Boss Room
            "M_NewD2", -- Dragon Roost Cavern
        }
    },
    {
        "Forbidden Woods",
        {
            "kinBOSS", -- Forbidden Woods Kalle Demos Boss Room
            "kindan", -- Forbidden Woods
            "kinMB", -- Forbidden Woods Mothula Miniboss Room
        }
    },
    {
        "Tower of the Gods",
        {
            "Siren", -- Tower of the Gods
            "SirenB", -- Tower of the Gods Gohdan Boss Room
            "SirenMB", -- Tower of the Gods Darknut Miniboss Room
        }
    },
    {
        "Forsaken Fortress",
        {
            -- Not sure exactly which stages are used by the randomizer currently, so simply including them all.
            "M2ganon", -- Forsaken Fortress Ganon's Room (2nd visit)
            "M2tower", -- Forsaken Fortress Tower (2nd visit)
            "ma2room", -- Forsaken Fortress Interior (2nd visit)
            "ma3room", -- Forsaken Fortress Interior (3rd visit)
            "majroom", -- Forsaken Fortress Interior (1st visit)
            "MajyuE", -- Forsaken Fortress Exterior (1st visit)
            "Mjtower", -- Forsaken Fortress Tower (1st visit)
        }
    },
    {
        "Earth Temple",
        {
            "M_Dai", -- Earth Temple
            "M_DaiB", -- Earth Temple Jalhalla Boss Room
            "M_DaiMB", -- Earth Temple Stalfos Miniboss Room
        }
    },
    {
        "Wind Temple",
        {
            "kaze", -- Wind Temple
            "kazeB", -- Wind Temple Molgera Boss Room
            "kazeMB", -- Wind Temple Wizzrobe Miniboss Room
        }
    },
}
local STAGE_NAME_TO_TAB_NAME = {}
for _, pair in ipairs({_STAGE_MAPPING}) do
    tab_name = pair[0]
    stage_list = pair[1]
    for _, stage_name in ipairs(stage_list) do
        STAGE_NAME_TO_TAB_NAME[stage_name] = tab_name
    end
end
_STAGE_MAPPING = nil

function setNonRandomizedEntrancesFromSlotData(slot_data)
    local vanilla_dungeons = slot_data['randomize_dungeon_entrances'] == 0
    local vanilla_minibosses = slot_data['randomize_miniboss_entrances'] == 0
    local vanilla_bosses = slot_data['randomize_boss_entrances'] == 0
    local vanilla_secret_caves = slot_data['randomize_secret_cave_entrances'] == 0
    local vanilla_secret_cave_inner_entrances = slot_data['randomize_secret_cave_inner_entrances'] == 0
    local vanilla_fairy_fountains = slot_data['randomize_fairy_fountain_entrances'] == 0

    local all_vanilla_entrances = {}
    local add_vanilla_entrances = function(entrance_type)
        for _, entrance in ipairs(ENTRANCE_TYPE_TO_ENTRANCES[entrance_type]) do
            table.insert(all_vanilla_entrances, entrance)
        end
    end

    if vanilla_dungeons then
        add_vanilla_entrances("dungeon")
    end
    if vanilla_minibosses then
        add_vanilla_entrances("miniboss")
    end
    if vanilla_bosses then
        add_vanilla_entrances("boss")
    end
    if vanilla_secret_caves then
        add_vanilla_entrances("secret_cave")
    end
    if vanilla_secret_cave_inner_entrances then
        add_vanilla_entrances("inner")
    end
    if vanilla_fairy_fountains then
        add_vanilla_entrances("fairy")
    end

    PAUSE_ENTRANCE_UPDATES = true
    -- Disabled for now to prevent modifying already assigned exits in-case the user connects to the wrong slot.
--     -- For the first pass, set all vanilla entrances to unassigned
--     for _, entrance in ipairs(all_vanilla_entrances) do
--         local exit_mapping = Tracker:FindObjectForCode(entrance.name)
--         exit_mapping_assign(exit_mapping, nil)
--     end
--     PAUSE_ENTRANCE_UPDATES = false
--     -- Update the exit_to_entrance table
--     update_entrances()
--     PAUSE_ENTRANCE_UPDATES = true

    -- For the second pass, set all the entrances to their vanilla exit
    local all_set_correctly = true
    for _, entrance in ipairs(all_vanilla_entrances) do
        local exit_mapping = Tracker:FindObjectForCode(entrance.name)
        local set_correctly = exit_mapping_assign(exit_mapping, entrance.vanilla_exit)
        if not set_correctly then
            -- Exit was most likely already assigned to an entrance
            all_set_correctly = false
        end
    end
    if not all_set_correctly then
        print("Some exit mappings could not be set to their vanilla entrances." ..
              " Their vanilla exits are probably already assigned to another entrance.")
    end

    -- Now update the entrance logic.
    PAUSE_ENTRANCE_UPDATES = false
    update_entrances()
end

function onClear(slot_data)
    -- autotracking settings from YAML
    local function setFromSlotData(slot_data_key, item_code)
        local v = slot_data[slot_data_key]
        if not v then
            print(string.format("Could not find key '%s' in slot data", slot_data_key))
            return
        end

        local obj = Tracker:FindObjectForCode(item_code)
        if not obj then
            print(string.format("Could not find item for code '%s'", item_code))
            return
        end

        if obj.Type == 'toggle' then
            obj.Active = v ~= 0
        elseif obj.Type == 'progressive' then
            obj.CurrentStage = v
        else
            print(string.format("Unsupported item type '%s' for item '%s'", tostring(obj.Type), item_code))
        end
    end

    setFromSlotData('progression_dungeons', 'dungeons')
    setFromSlotData('progression_puzzle_secret_caves', 'puzzlecaves')
    setFromSlotData('progression_island_puzzles', 'islandpuzzles')
    setFromSlotData('progression_combat_secret_caves', 'combat')
    setFromSlotData('progression_savage_labyrinth', 'labyrinth')
    setFromSlotData('progression_great_fairies', 'fairies')
    setFromSlotData('progression_free_gifts', 'gifts')
    setFromSlotData('progression_tingle_chests', 'tinglechests')
    setFromSlotData('progression_short_sidequests', 'shortsq')
    setFromSlotData('progression_long_sidequests', 'longsq')
    setFromSlotData('progression_spoils_trading', 'spoilssq')
    setFromSlotData('progression_expensive_purchases', 'expensive')
    setFromSlotData('progression_misc', 'misc')
    setFromSlotData('progression_battlesquid', 'sploosh')
    setFromSlotData('progression_platforms_rafts', 'lookouts')
    setFromSlotData('progression_submarines', 'submarines')
    setFromSlotData('progression_triforce_charts', 'triforcesalvage')
    setFromSlotData('progression_treasure_charts', 'treasuresalvage')
    setFromSlotData('progression_eye_reef_chests', 'reefs')
    setFromSlotData('progression_mail', 'mail')
    setFromSlotData('progression_big_octos_gunboats', 'octos')
    setFromSlotData('progression_minigames', 'minigames')
    setFromSlotData('progression_dungeon_secrets', 'secretpot')

    setFromSlotData('enable_tuner_logic', 'tunerlogic')
    setFromSlotData('logic_obscurity', 'tww_obscure')
    setFromSlotData('logic_precision', 'tww_precise')
    setFromSlotData('sword_mode', 'tww_sword_mode')
    setFromSlotData('skip_rematch_bosses', 'tww_rematch_bosses_skipped')
    setFromSlotData('swift_sail', 'swift_sail')

    if ENTRANCE_RANDO_ENABLED then
        setNonRandomizedEntrancesFromSlotData(slot_data)
    end

    -- junk that was in here from the template
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, v in pairs(LOCATION_MAPPING) do
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onClear: clearing location %s", v))
        end
        local obj = Tracker:FindObjectForCode(v)
        if obj then
            obj.AvailableChestCount = obj.ChestCount
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onClear: could not find object for code %s", v))
        end
    end
    -- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onClear: clearing item %s", v))
        end
        local obj = Tracker:FindObjectForCode(v)
        if obj then
            local obj_type = obj.Type
            if obj_type == "toggle" then
                obj.Active = false
            elseif obj_type == "progressive" then
                obj.CurrentStage = 0
                obj.Active = false
            elseif obj_type == "consumable" then
                obj.AcquiredCount = 0
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: unknown item type %s for code %s", obj_type, v))
            end
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onClear: could not find object for code %s", v))
        end
    end
end

function onClearHandler(slot_data)
    pauseLogicUntilNextFrame("AP onClearHandler")
    onClear(slot_data)
end

function onMap(stage_name)
    if not stage_name then
        return
    end

    local tab_name = STAGE_NAME_TO_TAB_NAME[stage_name]
    if tab_name then
        Tracker:UiHint("ActivateTab", tab_name)
    end
end

-- called when an item gets collected
function onItem(index, item_id, item_name, player_number)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onItem: %s, %s, %s, %s, %s", index, item_id, item_name, player_number, CUR_INDEX))
    end
    if not AUTOTRACKER_ENABLE_ITEM_TRACKING then
        return
    end
    if index <= CUR_INDEX then
        return
    end
    local is_local = player_number == Archipelago.PlayerNumber
    CUR_INDEX = index;
    local v = ITEM_MAPPING[item_id]
    if not v then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: could not find item mapping for id %s", item_id))
        end
        return
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: code: %s", v))
    end
    local obj = Tracker:FindObjectForCode(v)
    if obj then
        local obj_type = obj.Type
        if obj_type == "toggle" then
            obj.Active = true
        elseif obj_type == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif obj_type == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: unknown item type %s for code %s", obj_type, v))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", v))
    end
end

-- called when a location gets cleared
function onLocation(location_id, location_name)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onLocation: %s, %s", location_id, location_name))
    end
    if not AUTOTRACKER_ENABLE_LOCATION_TRACKING then
        return
    end
    local v = LOCATION_MAPPING[location_id]
    if not v then
        if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onLocation: could not find location mapping for id %s", location_id))
        end
        return
    end
    local obj = Tracker:FindObjectForCode(v)
    if obj then
        obj.AvailableChestCount = obj.AvailableChestCount - 1
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find object for code %s", v))
    end
end

-- called when a locations is scouted
function onScout(location_id, location_name, item_id, item_name, item_player)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onScout: %s, %s, %s, %s, %s", location_id, location_name, item_id, item_name,
            item_player))
    end
    -- not implemented yet :(
end

-- called when a bounce message is received 
function onBounced(value)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onBounce: %s", dump_table(value)))
    end

    local data = value["data"]
    if not data then
        return
    end

    -- The key is specified in the AP client.
    onMap(data["tww_stage_name"])
end

-- add AP callbacks
-- un-/comment as needed
Archipelago:AddClearHandler("clear handler", onClearHandler)
Archipelago:AddBouncedHandler("bounced handler", onBounced)
if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    Archipelago:AddItemHandler("item handler", onItem)
end
if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    Archipelago:AddLocationHandler("location handler", onLocation)
end
-- Archipelago:AddScoutHandler("scout handler", onScout)
