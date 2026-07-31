-- MIDAWEK'S COOLER RADIAL BINDS
if SERVER then return end
MCRB = MCRB or {}

MCRB.Binds = {
    "Command", "Bind", "Toggle", "Instant", "Falling Edge", "Burst", "Dual Edge"
    --[[
    Command - when selected, pressing the bind key will activate this one.
    Bind - when selected, pressing the bind key will use it with + and -
    Toggle - when selected, pressing the bind key will toggle + and -
    Instant - when selected, this command will trigger instantly. It will then act like CMD.
    Falling Edge - command triggers on falling edge
    Burst - command triggers for X seconds
    Dual Edge - command triggers on rising and falling edge
    ]]
}

MCRB.Radials = {
    {
        {
            PrintName = "Stims",
            BindType = MCRB.Binds[2],
            Command = "arc_vm_medshot",
            SegmentFade = 0,
        },
        {
            PrintName = "Night Vision",
            BindType = MCRB.Binds[1],
            Command = "arc_vm_nvg",
            SegmentFade = 0,
        },
        {
            PrintName = "Armor",
            BindType = MCRB.Binds[2],
            Command = "armorplate",
            SegmentFade = 0,
        }
    },
    {},
    {}
}

MCRB.SelectedMenu = 1
MCRB.Selection = 0

MCRB.Open = false
MCRB.Fade = 0

MCRB.MouseAng = 0
MCRB.MouseRad = 0


MCRB.Colour = CreateConVar("mcrb_colour", "000000", 128, "The colour of the radial binds")
MCRB.SelectedColour = CreateConVar("mcrb_selected_colour", "FFFFFF", 128, "The colour of radial bind when selected")
MCRB.Font = CreateConVar("mcrb_font", "Bahnschrift", 128, "The font used in radial binds")

function MCRB:CreateFonts()
    surface.CreateFont("mcrbRadialBinds16", {
        font = MCRB.Font:GetString(),
        size = ScreenScale(16),
        weight = 0,
        antialias = true,
        extended = true, -- Required for non-latin fonts
    })

    surface.CreateFont("mcrbRadialBinds16Shadow", {
        font = MCRB.Font:GetString(),
        size = ScreenScale(16),
        blursize = 5,
        weight = 0,
        antialias = true,
        extended = true, -- Required for non-latin fonts
    })
end

MCRB:CreateFonts()

cvars.AddChangeCallback("mcrb_font", function(convar_name, value_old, value_new)
    MCRB:CreateFonts()
end)

cvars.AddChangeCallback("mcrb_colour", function(convar_name, value_old, value_new)
    chat.AddText(Color(0, 255, 0), "[MCRB] Color updated to: " .. value_new)
end)

cvars.AddChangeCallback("mcrb_selected_colour", function(convar_name, value_old, value_new)
    chat.AddText(Color(0, 255, 0), "[MCRB] Selected color updated to: " .. value_new)
end)

local function RadiusSpoke(x, y, angle, rad)
    x = x + (math.cos(angle) * rad)
    y = y + (math.sin(angle) * rad)

    return x, y
end
MCRB.mat_ring = Material("sgm/playercircle")
MCRB.segmentfadetime = 0.25
MCRB.fadetime = 0.1

function MCRB:HexToColor(hex)
    hex = hex:gsub("#", "")

    if string.len(hex) == 6 then
        return Color(
            tonumber("0x" .. string.sub(hex, 1, 2)),
            tonumber("0x" .. string.sub(hex, 3, 4)),
            tonumber("0x" .. string.sub(hex, 5, 6)),
            255
        )
    end

    return Color(255, 255, 255, 255)
end

hook.Add("HUDPaint", "MCRB_HUD", function()
    local activemenu = MCRB.Radials[MCRB.SelectedMenu]

    if ! activemenu then return end

    if MCRB.Open then
        MCRB.Fade = math.Approach(MCRB.Fade, 1, FrameTime() / MCRB.fadetime)
    else
        MCRB.Fade = math.Approach(MCRB.Fade, 0, FrameTime() / MCRB.fadetime)
    end

    local a = MCRB.Fade * 255

    if a <= 0 then return end

    local ss = ScreenScale(1)

    local col_base = MCRB:HexToColor(MCRB.Colour:GetString())
    local col_selected = MCRB:HexToColor(MCRB.SelectedColour:GetString())

    local col_fg = Color(col_base.r, col_base.g, col_base.b, a)
    local col_fg_h = Color(col_selected.r, col_selected.g, col_selected.b, a)

    local segments = table.Count(activemenu)

    local x = ScrW() / 2
    local y = ScrH() / 2

    local rad = ss * 100

    if segments > 0 then
        -- draw each segment
        local arc = 360 / segments

        for i = 1, segments do
            local angle = (i * arc) - 90

            local d = (MCRB.MouseAng - angle + 180 + 360) % 360 - 180
            d = math.abs(d)

            local selected = d <= arc / 2

            if MCRB.MouseRad == 0 then
                selected = false
            end

            if ! activemenu[i] then continue end

            activemenu[i].SegmentFade = activemenu[i].SegmentFade or 0

            local size = rad * (1 + (activemenu[i].SegmentFade * 0.1))

            local inf_x, inf_y = RadiusSpoke(x, y, math.rad(angle), size)

            if selected then
                MCRB.Selection = i
                activemenu[i].SegmentFade = math.Approach(activemenu[i].SegmentFade, 1,
                    FrameTime() / MCRB.segmentfadetime)
            else
                activemenu[i].SegmentFade = math.Approach(activemenu[i].SegmentFade, 0,
                    FrameTime() / MCRB.segmentfadetime)
            end

            surface.SetFont("mcrbRadialBinds16")
            local inf_w, inf_h = surface.GetTextSize(activemenu[i].PrintName)

            local tb_w = inf_w + (ss * 4)

            if selected then
                surface.SetDrawColor(255, 255, 255, a * 0.5)
            else
                surface.SetDrawColor(0, 0, 0, a * 0.8)
            end
            surface.DrawRect(inf_x - (tb_w / 2), inf_y - (ss * 0.5), tb_w, inf_h + (ss * 1))

            surface.SetTextColor(0, 0, 0, a)
            surface.SetFont("mcrbRadialBinds16Shadow")
            surface.SetTextPos(inf_x - (inf_w / 2), inf_y)
            surface.DrawText(activemenu[i].PrintName)

            if selected then
                surface.SetTextColor(col_fg_h)
            else
                surface.SetTextColor(col_fg)
            end
            surface.SetFont("mcrbRadialBinds16")
            surface.SetTextPos(inf_x - (inf_w / 2), inf_y)
            surface.DrawText(activemenu[i].PrintName)
        end
    end
end)
local function instant()
    local activemenu = MCRB.Radials[MCRB.SelectedMenu]
    local selection = activemenu[MCRB.Selection]

    if ! selection then return end

    local ply = LocalPlayer()

    if selection.BindType == "Instant" then
        ply:ConCommand(selection.Command)
    end
end

concommand.Add("+arc_radial_menu", function(ply, cmd, args)
    MCRB.SelectedMenu = 1
    MCRB.Open = true
end)

concommand.Add("-arc_radial_menu", function()
    MCRB.Open = false
end)

concommand.Add("+arc_radial_menu_2", function(ply, cmd, args)
    MCRB.SelectedMenu = 2
    MCRB.Open = true
end)

concommand.Add("-arc_radial_menu_2", function()
    MCRB.Open = false
    instant()
end)

concommand.Add("+arc_radial_menu_3", function(ply, cmd, args)
    MCRB.SelectedMenu = 3
    MCRB.Open = true
end)

concommand.Add("-arc_radial_menu_3", function()
    MCRB.Open = false
    instant()
end)

hook.Add("InputMouseApply", "MCRB_Mouse", function(cmd, x, y, ang)
    if ! MCRB.Open then return end

    if math.abs(x) + math.abs(y) <= 0 then return end

    cmd:SetMouseX(0)
    cmd:SetMouseY(0)

    local mousex = math.cos(math.rad(MCRB.MouseAng)) * MCRB.MouseRad
    local mousey = math.sin(math.rad(MCRB.MouseAng)) * MCRB.MouseRad

    mousex = mousex + x
    mousey = mousey + y

    local newang = math.deg(math.atan2(mousey, mousex))
    local newrad = math.sqrt(math.pow(mousex, 2) + math.pow(mousey, 2))
    -- local newrad = Vector(mousex, mousey):Length()

    newrad = math.min(newrad, ScreenScale(100))

    MCRB.MouseRad = newrad
    MCRB.MouseAng = newang

    -- MCRB.SelectAngle = math.NormalizeAngle(MCRB.SelectAngle)

    return true
end)

hook.Add("PlayerBindPress", "MCRB_Scroll", function(ply, bind, pressed)
    if ! MCRB.Open then return end

    if bind == "invnext" then
        MCRB.SelectedMenu = MCRB.SelectedMenu + 1
        if MCRB.SelectedMenu > 3 then
            MCRB.SelectedMenu = 1
        end
        return true
    elseif bind == "invprev" then
        MCRB.SelectedMenu = MCRB.SelectedMenu - 1
        if MCRB.SelectedMenu < 1 then
            MCRB.SelectedMenu = 3
        end
        return true
    end
end)
-- Commands for actual binds
concommand.Add("+arc_radial_bind", function()
    local activemenu = MCRB.Radials[MCRB.SelectedMenu]
    local selection = activemenu[MCRB.Selection]

    if ! selection then return end

    local ply = LocalPlayer()

    if selection.BindType == "Command" then
        ply:ConCommand(selection.Command)
    elseif selection.BindType == "Toggle" then
        selection.BindToggle = selection.BindToggle or false

        if selection.BindToggle then
            ply:ConCommand("-" .. selection.Command)
        else
            ply:ConCommand("+" .. selection.Command)
        end

        selection.BindToggle = ! selection.BindToggle
    elseif selection.BindType == "Bind" then
        ply:ConCommand("+" .. selection.Command)
    elseif selection.BindType == "Dual Edge" then
        ply:ConCommand(selection.Command)
    elseif selection.BindType == "Burst" then
        ply:ConCommand("+" .. selection.Command)

        timer.Simple(selection.BurstLength or 0.1, function()
            ply:ConCommand("-" .. selection.Command)
        end)
    end
end)

concommand.Add("-arc_radial_bind", function()
    local activemenu = MCRB.Radials[MCRB.SelectedMenu]
    local selection = activemenu[MCRB.Selection]

    if ! selection then return end

    local ply = LocalPlayer()

    if selection.BindType == "Bind" then
        ply:ConCommand("-" .. selection.Command)
    elseif selection.BindType == "Falling Edge" then
        ply:ConCommand(selection.Command)
    elseif selection.BindType == "Dual Edge" then
        ply:ConCommand(selection.Command)
    end
end)

concommand.Add("mcrb_customize", function()
    MCRB:OpenMenu()
end)

concommand.Add("mcrb_import_data", function()
    MCRB:Load()
    chat.AddText(Color(0, 255, 0), "[MCRB] Data loaded from file.")
end)

concommand.Add("mcrb_import_legacy_data", function()
    if MCRB:LoadLegacy() then
        MCRB:Save()
        chat.AddText(Color(0, 255, 0), "[MCRB] Legacy files imported and converted to new format!")
    else
        chat.AddText(Color(255, 0, 0), "[MCRB] No legacy files found to import.")
    end
end)
