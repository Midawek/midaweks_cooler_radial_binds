-- MCRB menu

if not CLIENT then return end

local function panel(panel)
    panel:SetName("Midawek's Cooler Radial Binds")
    local mrow = panel:Add("DButton")
    mrow:SetText("Press this to open menu")
end

hook.Add("PopulateToolMenu", "MCRB_PopulateToolMenu", function()
    spawnmenu.AddToolMenuOption("Options", "Midawek", "Midawek's Cooler Radial Binds", "Cooler Radial Binds", "", "",
        panel)
end)
