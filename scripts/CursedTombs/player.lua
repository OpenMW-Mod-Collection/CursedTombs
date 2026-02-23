local self = require("openmw.self")
local core = require("openmw.core")
local types = require("openmw.types")

require("scripts.CursedTombs.utils.raycast")

local function initCurse(reventants)
    core.sendGlobalEvent("CursedTombs_triggerCurse", {
        revenants = reventants,
        actor = self,
        spawnPos = FindSafeSpawnPos(self)
    })
end

local function quickLoot_lootedItems(eventData)
    local obj = eventData[1]

    if not types.Container.objectIsInstance(obj) then return end

    core.sendGlobalEvent("CursedTombs_activatedContainer", {
        obj = obj,
        actor = self,
        spawnPos = FindSafeSpawnPos(self)
    })
end

return {
    eventHandlers = {
        CursedTombs_initCurse       = initCurse,
        OwnlysQuickLoot_lootedItem  = quickLoot_lootedItems,
        OwnlysQuickLoot_lootedItems = quickLoot_lootedItems,
    }
}
