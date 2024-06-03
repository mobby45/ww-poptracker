local Entrance = {}
Entrance.__index = Entrance

function Entrance.new(name, vanilla_exit, parent_exit)
    local self = setmetatable({}, Entrance)
    -- The name of this entrance.
    self.name = name
    -- The exit that has been assigned to this entrance. Always starts off as vanilla and won't change if Entrance
    -- Randomization is not enabled.
    self.exit = vanilla_exit
    -- There are no entrances accessible from multiple different exits, so a single parent_exit is all that is needed.
    -- Defaults to "The Great Sea" when not set, which is always accessible.
    self.parent_exit = parent_exit or "The Great Sea"
    -- The location which holds this entrance's logic, or `nil` if the entrance is always accessible.
    self.entrance_logic = "@Entrance Logic/" .. name
    return self
end

function Entrance:canAccess()
    if not self.entrance_logic then
        return true
    end
    local location = Tracker:FindObjectForCode(self.entrance_logic)
    local accessibility = location.AccessibilityLevel
    return accessibility == AccessibilityLevel.Normal
end

return Entrance