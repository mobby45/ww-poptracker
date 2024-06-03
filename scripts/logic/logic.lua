require("scripts/logic/entrances")

function can_destroy_cannons()
    return (has("boomerang") or has("bombs"))
end

function can_access_exit(exit_name)
    if impossible_exits[exit_name] then
        -- Exit is part of an inaccessible loop
--         print("Cannot access exit " .. exit_name .. " because it is part of a loop")
        return false
    end

    -- This shouldn't normally need to be checked, but it is here for completeness.
    if exit_name == "The Great Sea" then
        -- Always accessible
--         print("Can access exit " .. exit_name .. " because it is always accessible")
        return true
    end

    -- Find the entrance in this entrance <-> exit pair.
    local entrance_name = exit_to_entrance[exit_name]
    if not entrance_name then
        -- Exit is currently unmapped and considered unreachable
--         print("Cannot access exit " .. exit_name .. " because it is unmapped")
        return false
    end

    local entrance = ENTRANCE_BY_NAME[entrance_name]
    -- Return if the entrance can be accessed.
    return entrance:canAccess()
end