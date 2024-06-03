require("scripts/logic/entrances")

function exit_accessibility(exit_name)
    if impossible_exits[exit_name] then
        -- Exit is part of an inaccessible loop
--         print("Cannot access exit " .. exit_name .. " because it is part of a loop")
        return AccessibilityLevel.None
    end

    -- This shouldn't normally need to be checked, but it is here for completeness.
    if exit_name == "The Great Sea" then
        -- Always accessible
--         print("Can access exit " .. exit_name .. " because it is always accessible")
        return AccessibilityLevel.Normal
    end

    -- Find the entrance in this entrance <-> exit pair.
    local entrance_name = exit_to_entrance[exit_name]
    if not entrance_name then
        -- Exit is currently unmapped and considered unreachable
--         print("Cannot access exit " .. exit_name .. " because it is unmapped")
        return AccessibilityLevel.None
    end

    local entrance = ENTRANCE_BY_NAME[entrance_name]
    -- Return the entrance's accessibility.
    return entrance:getAccessibility()
end

function is_exit_assigned(entrance_name)
    -- This is used to mark entrances which have been assigned an exit, but are inaccessible, as Blue instead of Red.
    -- This is a common state for inaccessible entrances that were not randomized.
    return entrance_to_exit[entrance_name] ~= nil
end