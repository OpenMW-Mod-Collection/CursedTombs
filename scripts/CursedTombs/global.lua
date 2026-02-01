local storage = require("openmw.storage")
local world = require("openmw.world")
local types = require("openmw.types")
local I = require("openmw.interfaces")

require("scripts.CursedTombs.utils.consts")

local sectionChecks = storage.globalSection("SettingsCursedTombs_checks")
local sectionRevenants = storage.globalSection("SettingsCursedTombs_revenants")
local sectionOther = storage.globalSection("SettingsCursedTombs_other")
local triggeredContainers = {}
local activatedContainers = {}

local function onSave()
    return {
        triggeredContainers = triggeredContainers,
        activatedContainers = activatedContainers,
    }
end

local function onLoad(saveData)
    triggeredContainers = saveData.triggeredContainers
    activatedContainers = saveData.activatedContainers
end

local function cursableContainer(obj)
    for _, pattern in pairs(CursedContainers) do
        if string.find(obj.recordId, pattern) then
            return true
        end
    end
end

local function hasKey(obj, actor)
    local keyRecord = obj.type.getKeyRecord(obj)
    if not keyRecord then return false end

    local inv = actor.type.inventory(actor)
    return inv:find(keyRecord.id) ~= nil
end

local function attributeCheckSucceeded(actor)
    local baseChance = math.random(
        sectionChecks:get("minBaseSafeChance"),
        sectionChecks:get("maxBaseSafeChance")
    )
    local attrs = actor.type.stats.attributes
    local safeChance = baseChance +
        attrs.luck(actor).modified * sectionChecks:get("luckModifier") +
        attrs.agility(actor).modified * sectionChecks:get("agilityModifier")

    return math.random(100) <= safeChance
end

local function clearActivatedContainers(cellId)
    for recordedCellId, _ in pairs(activatedContainers) do
        if recordedCellId ~= cellId then
            activatedContainers[recordedCellId] = nil
        end
    end
end

local function triggerCurse(actor)
    local revenantList = sectionRevenants:get("useLeveledLists")
        and LeveledRevenants or StaticRevenants
    local revenant = world.createObject(revenantList[math.random(#revenantList)], 1)
    -- TODO make them spawn behind the player
    revenant:teleport(actor.cell.name, actor.position)
end

local function doFeedback(actor)
    if sectionOther:get("enableMessages") then
        -- TODO make a message picker
        actor:sendEvent("ShowMessage", { message = "test" })
    end
    if sectionOther:get("enableSfx") then
        -- TODO pick sfx
        actor:sendEvent("PlaySound3d", { sound = "asd" })
    end
end

local function onContainerActive(obj, actor)
    if triggeredContainers[obj.id]
        or (
            activatedContainers[obj.cell.id]
            and activatedContainers[obj.cell.id][obj.id]
        )
        or not cursableContainer(obj)
        or obj.type.isLocked(obj)
        or hasKey(obj, actor)
        or attributeCheckSucceeded(actor)
    then
        activatedContainers[obj.cell.id][obj.id] = true
        return
    end

    clearActivatedContainers(actor.cell.id)

    activatedContainers[obj.cell.id][obj.id] = true
    triggeredContainers[obj.id] = true

    local revenantCount = math.random(sectionRevenants:get("maxRevenantCount"))
    for _ = 1, revenantCount do
        triggerCurse(actor)
    end

    doFeedback(actor)
end

I.Activation.addHandlerForType(types.Container, onContainerActive)

return {
    engineHandlers = {
        onSave = onSave,
        onLoad = onLoad,
    },
}
