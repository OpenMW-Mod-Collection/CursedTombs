local self = require("openmw.self")
local core = require("openmw.core")
local types = require("openmw.types")

local function quickLoot_lootedItems(eventData)
    local obj = eventData[1]

    if not types.Container.objectIsInstance(obj) then return end

    core.sendGlobalEvent("CursedTombs_activatedContainer", { obj = obj, actor = self })
end

return {
    eventHandlers = {
        OwnlysQuickLoot_lootedItem  = quickLoot_lootedItems,
        OwnlysQuickLoot_lootedItems = quickLoot_lootedItems
    }
}
