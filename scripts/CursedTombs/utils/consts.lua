local core = require("openmw.core")

StaticRevenants = {
    "ancestor_ghost",
    "bonelord",
    "bonewalker",
    "Bonewalker_Greater",
    "skeleton",
    "skeleton archer",
    "skeleton warrior",
    "skeleton champion",
}

LeveledRevenants = {
    "in_tomb_all_lev+0",
    "in_tomb_bone_lev+0",
    "in_tomb_skele_lev+0",
}

CursedContainers = {
    "com_chest_02_tomb",
    "chest_tomb",
    "urn_ash",
    "bm_nordictomb",
}

local expansions = {
    ["OAAB_Data.esm"] = function ()
        CursedContainers[#CursedContainers+1] = "ab_o_urnash"
    end,
    ["Tamrield_Data.esm"] = function ()
        
    end,
}

for plugin, foo in pairs(expansions) do
    if core.contentFiles.has(plugin) then
        foo()
    end
end

-- TODO expand the container and revenant lists based on what mods players have installed
-- - OAAB_Data (It does. Did you search for "tomb" in containers? There's also an AB tomb leveled list that you could look up the usages for.)
-- - Tamriel_Data
