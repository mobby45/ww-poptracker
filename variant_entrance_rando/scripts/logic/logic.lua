require("scripts/logic/entrances")

function exit_accessibility(exit_name)
    if impossible_exits[exit_name] then
        -- Exit is part of an inaccessible loop or is assigned to multiple entrances.
--         print("Cannot access exit " .. exit_name .. " because it is impossible")
        return AccessibilityLevel.None
    end

    -- This shouldn't normally need to be checked, but it is here for completeness.
    if exit_name == "The Great Sea" then
        -- Always accessible
--         print("Can access exit " .. exit_name .. " because it is always accessible")
        return AccessibilityLevel.Normal
    end

    -- Find the entrance in this entrance <-> exit pair.
    local entrance = exit_to_entrance[exit_name]
    if not entrance then
        -- Exit is currently unmapped and considered unreachable
--         print("Cannot access exit " .. exit_name .. " because it is unmapped")
        return AccessibilityLevel.None
    else
        -- Return the entrance's accessibility.
        return entrance:getAccessibility()
    end
end