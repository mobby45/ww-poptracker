local Entrance = {}
Entrance.__index = Entrance

function Entrance.new(name, vanilla_exit, entrance_type, parent_exit)
    local self = setmetatable({}, Entrance)
    -- The name of this entrance.
    self.name = name
    -- The vanilla exit, stored here for simpler lookup.
    self.vanilla_exit = vanilla_exit
    -- The exit that has been assigned to this entrance. Always starts off as vanilla and won't change if Entrance
    -- Randomization is not enabled.
    self.exit = vanilla_exit
    -- There are no entrances accessible from multiple different exits, so a single parent_exit is all that is needed.
    -- Defaults to "The Great Sea" when not set, which is always accessible.
    self.parent_exit = parent_exit or "The Great Sea"
    -- The location which holds this entrance's logic, or `nil` if the entrance is always accessible.
    self.entrance_logic = "@Entrance Logic/" .. name
    -- The type of the entrance: "dungeon", "miniboss", "boss", "secret_cave", "inner", "fairy"
    self.entrance_type = entrance_type
    return self
end

function Entrance:getAccessibility()
    if not self.entrance_logic then
        return AccessibilityLevel.Normal
    end
    local location = Tracker:FindObjectForCode(self.entrance_logic)
    return location.AccessibilityLevel
end

return Entrance