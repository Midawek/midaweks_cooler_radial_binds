-- hi

if SERVER then
    local files = {
        "mrb_main.lua",
        "mrb_menu.lua",
    }
    for _, x in pairs(files) do
        AddCSLuaFile("midaweksRadialBinds/" .. x)
        print("[MCRB] AddedCSLuaFile " .. x)
    end
end
