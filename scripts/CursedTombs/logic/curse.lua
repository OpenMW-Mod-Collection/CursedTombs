local world = require("openmw.world")
local storage = require("openmw.storage")
local util = require("openmw.util")
local core = require("openmw.core")

require("scripts.CursedTombs.utils.messages")

local sectionRevenants = storage.globalSection("SettingsCursedTombs_revenants")
local sectionOther = storage.globalSection("SettingsCursedTombs_other")

local function spawnRevenant(revenantList, actor)
    local revenant = world.createObject(
        revenantList[math.random(#revenantList)], 1)

    local yaw = actor.rotation:getYaw()
    local dir = util.vector3(
        math.sin(yaw),
        math.cos(yaw),
        0
    ):normalize()
    local spawnPosition = actor.position + dir * -200

    revenant:teleport(actor.cell, spawnPosition, {
        rotation = actor.rotation,
        onGround = true,
    })
end

local function doFeedback(actor)
    if sectionOther:get("enableMessages") then
        local msgs = CollectAllMessagesByPrefix("msg_remnantSpawned", core.l10n("CursedTombs"))
        print("Collected messages: " .. #msgs)
        actor:sendEvent("ShowMessage", { message = msgs[math.random(#msgs)] })
    end
    if sectionOther:get("enableSfx") then
        actor:sendEvent("PlaySound3d", { sound = "bonelord scream" })
    end
end

function TriggerCurse(reventats, actor)
    local revenantList = sectionRevenants:get("useLeveledLists")
        and reventats.leveled or reventats.static
    local revenantCount = math.random(
        sectionRevenants:get("minRevenantCount"),
        sectionRevenants:get("maxRevenantCount")
    )

    for _ = 1, revenantCount do
        spawnRevenant(revenantList, actor)
    end

    doFeedback(actor)
end
