-- hi

local files = {
    "mrb_main.lua",
    "mrb_menu.lua",
    "mrb_debug.lua"
}

-- if SERVER then
--     for _, x in pairs(files) do
--         AddCSLuaFile("midaweksRadialBinds/" .. x)
--         print("[MCRB] AddedCSLuaFile " .. x)
--     end
-- end

if CLIENT then
    for _, x in pairs(files) do
        include("midaweksRadialBinds/" .. x)
        print("[MCRB] Included " .. x)
    end
end
