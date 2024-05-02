ScriptHost:LoadScript("scripts/autotracking/item_mapping.lua")
ScriptHost:LoadScript("scripts/autotracking/location_mapping.lua")

CUR_INDEX = -1
SLOT_DATA = nil
LOCAL_ITEMS = {}
GLOBAL_ITEMS = {}

function onClear(slot_data)
    -- autotracking settings from YAML
    if slot_data['progression_dungeons'] then
        local obj = Tracker:FindObjectForCode("dungeons")
        if obj then
            obj.Active = slot_data['progression_dungeons']
        end
    end

    if slot_data['progression_puzzle_secret_caves'] then
        local obj = Tracker:FindObjectForCode("puzzlecaves")
        if obj then
            obj.Active = slot_data['progression_puzzle_secret_caves']
        end
    end

    if slot_data['progression_island_puzzles'] then
        local obj = Tracker:FindObjectForCode("islandpuzzles")
        if obj then
            obj.Active = slot_data['progression_island_puzzles']
        end
    end
    
    if slot_data['progression_combat_secret_caves'] then
        local obj = Tracker:FindObjectForCode("combat")
        if obj then
            obj.Active = slot_data['progression_combat_secret_caves']
        end
    end

    if slot_data['progression_savage_labyrinth'] then
        local obj = Tracker:FindObjectForCode("labyrinth")
        if obj then
            obj.Active = slot_data['progression_savage_labyrinth']
        end
    end
    
    if slot_data['progression_great_fairies'] then
        local obj = Tracker:FindObjectForCode("fairies")
        if obj then
            obj.Active = slot_data['progression_great_fairies']
        end
    end
    
    if slot_data['progression_free_gifts'] then
        local obj = Tracker:FindObjectForCode("gifts")
        if obj then
            obj.Active = slot_data['progression_free_gifts']
        end
    end
    
    if slot_data['progression_tingle_chests'] then
        local obj = Tracker:FindObjectForCode("tinglechests")
        if obj then
            obj.Active = slot_data['progression_tingle_chests']
        end
    end
    
    if slot_data['enable_tuner_logic'] then
        local obj = Tracker:FindObjectForCode("tunerlogic")
        if obj then
            obj.CurrentStage = slot_data['enable_tuner_logic']
        end
    end
    
    if slot_data['progression_short_sidequests'] then
        local obj = Tracker:FindObjectForCode("shortsq")
        if obj then
            obj.Active = slot_data['progression_short_sidequests']
        end
    end
    
    if slot_data['progression_long_sidequests'] then
        local obj = Tracker:FindObjectForCode("longsq")
        if obj then
            obj.Active = slot_data['progression_long_sidequests']
        end
    end
    
    if slot_data['progression_spoils_trading'] then
        local obj = Tracker:FindObjectForCode("spoilssq")
        if obj then
            obj.Active = slot_data['progression_spoils_trading']
        end
    end
    
    if slot_data['progression_expensive_purchases'] then
        local obj = Tracker:FindObjectForCode("expensive")
        if obj then
            obj.Active = slot_data['progression_expensive_purchases']
        end
    end
    
    if slot_data['progression_misc'] then
        local obj = Tracker:FindObjectForCode("misc")
        if obj then
            obj.Active = slot_data['progression_misc']
        end
    end
    
    if slot_data['progression_battlesquid'] then
        local obj = Tracker:FindObjectForCode("sploosh")
        if obj then
            obj.Active = slot_data['progression_battlesquid']
        end
    end
    
    if slot_data['progression_platforms_rafts'] then
        local obj = Tracker:FindObjectForCode("lookouts")
        if obj then
            obj.Active = slot_data['progression_platforms_rafts']
        end
    end
    
    if slot_data['progression_submarines'] then
        local obj = Tracker:FindObjectForCode("submarines")
        if obj then
            obj.Active = slot_data['progression_submarines']
        end
    end
    
    if slot_data['progression_triforce_charts'] then
        local obj = Tracker:FindObjectForCode("triforcesalvage")
        if obj then
            obj.Active = slot_data['progression_triforce_charts']
        end
    end
    
    if slot_data['progression_treasure_charts'] then
        local obj = Tracker:FindObjectForCode("treasuresalvage")
        if obj then
            obj.Active = slot_data['progression_treasure_charts']
        end
    end
    
    if slot_data['progression_eye_reef_chests'] then
        local obj = Tracker:FindObjectForCode("reefs")
        if obj then
            obj.Active = slot_data['progression_eye_reef_chests']
        end
    end
    
    if slot_data['progression_mail'] then
        local obj = Tracker:FindObjectForCode("mail")
        if obj then
            obj.Active = slot_data['progression_mail']
        end
    end
    
    if slot_data['progression_big_octos_gunboats'] then
        local obj = Tracker:FindObjectForCode("octos")
        if obj then
            obj.Active = slot_data['progression_big_octos_gunboats']
        end
    end
    
    if slot_data['progression_minigames'] then
        local obj = Tracker:FindObjectForCode("minigames")
        if obj then
            obj.Active = slot_data['progression_minigames']
        end
    end
    
    if slot_data['progression_dungeon_secrets'] then
        local obj = Tracker:FindObjectForCode("dungeon_secrets")
        if obj then
            obj.Active = slot_data['progression_dungeon_secrets']
        end
    end
    
    -- junk that was in here from the template
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onClear, slot_data:\n%s", dump_table(slot_data)))
    end
    SLOT_DATA = slot_data
    CUR_INDEX = -1
    -- reset locations
    for _, v in pairs(LOCATION_MAPPING) do
        if v[1] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing location %s", v[1]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[1]:sub(1, 1) == "@" then
                    obj.AvailableChestCount = obj.ChestCount
                else
                    obj.Active = false
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    -- reset items
    for _, v in pairs(ITEM_MAPPING) do
        if v[1] and v[2] then
            if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: clearing item %s of type %s", v[1], v[2]))
            end
            local obj = Tracker:FindObjectForCode(v[1])
            if obj then
                if v[2] == "toggle" then
                    obj.Active = false
                elseif v[2] == "progressive" then
                    obj.CurrentStage = 0
                    obj.Active = false
                elseif v[2] == "consumable" then
                    obj.AcquiredCount = 0
                elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                    print(string.format("onClear: unknown item type %s for code %s", v[2], v[1]))
                end
            elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
                print(string.format("onClear: could not find object for code %s", v[1]))
            end
        end
    end
    LOCAL_ITEMS = {}
    GLOBAL_ITEMS = {}
    -- manually run snes interface functions after onClear in case we are already ingame
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here
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
        print(string.format("onItem: code: %s, type %s", v[1], v[2]))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[2] == "toggle" then
            obj.Active = true
        elseif v[2] == "progressive" then
            if obj.Active then
                obj.CurrentStage = obj.CurrentStage + 1
            else
                obj.Active = true
            end
        elseif v[2] == "consumable" then
            obj.AcquiredCount = obj.AcquiredCount + obj.Increment
        elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
            print(string.format("onItem: unknown item type %s for code %s", v[2], v[1]))
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onItem: could not find object for code %s", v[1]))
    end
    -- track local items via snes interface
    if is_local then
        if LOCAL_ITEMS[v[1]] then
            LOCAL_ITEMS[v[1]] = LOCAL_ITEMS[v[1]] + 1
        else
            LOCAL_ITEMS[v[1]] = 1
        end
    else
        if GLOBAL_ITEMS[v[1]] then
            GLOBAL_ITEMS[v[1]] = GLOBAL_ITEMS[v[1]] + 1
        else
            GLOBAL_ITEMS[v[1]] = 1
        end
    end
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("local items: %s", dump_table(LOCAL_ITEMS)))
        print(string.format("global items: %s", dump_table(GLOBAL_ITEMS)))
    end
    if PopVersion < "0.20.1" or AutoTracker:GetConnectionState("SNES") == 3 then
        -- add snes interface functions here for local item tracking
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
    if not v and AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find location mapping for id %s", location_id))
    end
    if not v[1] then
        return
    end
    local obj = Tracker:FindObjectForCode(v[1])
    if obj then
        if v[1]:sub(1, 1) == "@" then
            obj.AvailableChestCount = obj.AvailableChestCount - 1
        else
            obj.Active = true
        end
    elseif AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("onLocation: could not find object for code %s", v[1]))
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
function onBounce(json)
    if AUTOTRACKER_ENABLE_DEBUG_LOGGING_AP then
        print(string.format("called onBounce: %s", dump_table(json)))
    end
    -- your code goes here
end

-- add AP callbacks
-- un-/comment as needed
Archipelago:AddClearHandler("clear handler", onClear)
if AUTOTRACKER_ENABLE_ITEM_TRACKING then
    Archipelago:AddItemHandler("item handler", onItem)
end
if AUTOTRACKER_ENABLE_LOCATION_TRACKING then
    Archipelago:AddLocationHandler("location handler", onLocation)
end
-- Archipelago:AddScoutHandler("scout handler", onScout)
-- Archipelago:AddBouncedHandler("bounce handler", onBounce)
