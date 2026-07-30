-- MCRB menu

if not CLIENT then return end
MCRB.menu = MCRB.menu or {}

if MCRB.Menu.Loaded then return end
MCRB.Menu.Loaded = true


list.Set("DesktopWindows", "MCRB_Menu", {
    title = "Midawek's Cooler Radial Binds",

})
