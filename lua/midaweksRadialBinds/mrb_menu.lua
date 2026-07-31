-- MCRB menu

if not CLIENT then return end
MCRB = MCRB or {}
MCRB.bindToText = MCRB.bindToText or {}
MCRB.helpEntries = {
    ["Using Binds"] = [[
        Using Binds:
        This is an explanation of how to use the binds you've created.

        Bind +arc_radial_menu, +arc_radial_menu_2, and +arc_radial_menu_3 to access your binds.
        These correspond to your three menus.

        Hold the key you bound to select a bind.

        Bind +arc_radial_bind to execute the bind you've selected. The way it will be executed depends on the bind type that has been assigned to it.
            ]],
    ["Bind Types"] = [[
        Bind Types:
        This is an explanation of the ways you can set your binds to work.
        Bind type can be selected with the "Bind Type" option when customizing a bind.

        Command: Pressing the bind key will trigger the command.
        Bind: Pressing the bind key will trigger +command. Releasing will trigger -command.
        Toggle: Pressing the bind key will alternate between triggering +command and -command.
        Instant: Selecting the bind in the radial menu will instantly activate the command.
        Falling Edge: Releasing the bind key will trigger the command.
        Burst: The bind will immediately activate +command, then turn it off with -command after the designated time.
        Dual Edge: Both pressing and releasing the bind key will trigger the command.]],
    ["QUICKSTART"] = [[
        Quickstart:
        HANDY THREE STEP GUIDE FOR IDIOTS

        1. Do the following commands:
            bind n +arc_radial_menu
            bind m +arc_radial_bind

            (n and m can be substituted for any key you like, such as "bind j +arc_radial_menu")

        2. Click "Create New" under Menu 1 on this screen. Fill in the options. OMIT + AND - FROM THE COMMAND!

        3. Hold N and use your mouse to select the bind you just created. Press M to execute it.

        ]],
    ["Tips and Tricks"] = [[
        Tips and Tricks:
        This guide will help you to use your radial binds to their full potential.

            - Get creative! Almost any console commands work!
            - You can give commands arguments, like "say Sometimes I dream about cheese".
            - This mod works with ANY other mod! The possibilities are endless.
            - You can use Radial Binds to trigger alias macros.
            - Need more space? Bind the commands +arc_radial_menu_2 and +arc_radial_menu_3 to access Menu 2 and 3.
            - Binds are saved to your /data file. You can share your bind settings with other people by giving them the file named "arcticradialbinds.json".
            - Saving occurs when you close your customization menu.
            - You can share your menus with friends! Look for "arcticradialbinds" in your /data folder. There is one for each of your three menus.
            ]]
}


function MCRB:OpenMenu()
    if MCRB.Menu then
        MCRB.log(self, "Menu already exists! This shouldn't happen. Removing...")
        MCRB.Menu:Remove()
    end

    MCRB.Menu = vgui.Create("DFrame")
    main = MCRB.Menu
    main:SetSize(600, 350)
    main:Center()
    main:SetTitle("Arctic's Radial Binds")
    main:MakePopup()
    main.OnRemove = function()
        MCRB:Save()
    end

    local leftbar = vgui.Create("DCategoryList", main)
    leftbar:SetSize(150, 350)
    leftbar:Dock(LEFT)
    leftbar:DockPadding(2, 2, 2, 2)

    local editmenu = vgui.Create("DPanel", main)
    editmenu:SetSize(440, 350)
    editmenu:Dock(RIGHT)
    editmenu:DockPadding(2, 2, 2, 2)

    function MCRB:EditBind(submenu, bind)
        editmenu:Clear()

        local bindtbl = MCRB.Radials[submenu][bind]

        local edit_label_name = vgui.Create("DLabel", editmenu)
        edit_label_name:Dock(TOP)
        edit_label_name:DockMargin(2, 2, 2, 2)
        edit_label_name:SetText("Bind Name:")
        edit_label_name:SetTextColor(Color(0, 0, 0))

        local edit_namebar = vgui.Create("DTextEntry", editmenu)
        edit_namebar:Dock(TOP)
        edit_namebar:DockMargin(2, 2, 2, 2)
        edit_namebar:SetText(bindtbl.PrintName or "Unnamed")
        edit_namebar.OnChange = function(self)
            bindtbl.PrintName = self:GetValue() or ""
        end

        local edit_label_bindtype = vgui.Create("DLabel", editmenu)
        edit_label_bindtype:Dock(TOP)
        edit_label_bindtype:DockMargin(2, 2, 2, 2)
        edit_label_bindtype:SetText("Bind Type:")
        edit_label_bindtype:SetTextColor(Color(0, 0, 0))

        local edit_bindtype = vgui.Create("DComboBox", editmenu)
        edit_bindtype:Dock(TOP)
        edit_bindtype:DockMargin(2, 2, 2, 2)
        edit_bindtype:SetValue(bindtbl.BindType or MCRB.Binds[1])

        for i, k in pairs(MCRB.Binds) do
            edit_bindtype:AddChoice(k, k)
        end

        edit_bindtype.OnSelect = function(self, index, value, data)
            bindtbl.BindType = data
            MCRB:EditBind(submenu, bind)
        end

        local edit_label_command = vgui.Create("DLabel", editmenu)
        edit_label_command:Dock(TOP)
        edit_label_command:DockMargin(2, 2, 2, 2)
        edit_label_command:SetText("Command (Omit + or -):")
        edit_label_command:SetTextColor(Color(0, 0, 0))

        local edit_command = vgui.Create("DTextEntry", editmenu)
        edit_command:Dock(TOP)
        edit_command:DockMargin(2, 2, 2, 2)
        edit_command:SetText(bindtbl.Command or "")
        edit_command.OnChange = function(self)
            bindtbl.Command = self:GetValue() or ""
        end

        local sel = bindtbl.BindType

        if sel == "Burst" then
            local edit_label_burst = vgui.Create("DLabel", editmenu)
            edit_label_burst:Dock(TOP)
            edit_label_burst:DockMargin(2, 2, 2, 2)
            edit_label_burst:SetText("Burst Length (Seconds):")
            edit_label_burst:SetTextColor(Color(0, 0, 0))

            local edit_burst = vgui.Create("DNumSlider", editmenu)
            edit_burst:Dock(TOP)
            edit_burst:DockMargin(2, 2, 2, 2)
            edit_burst:SetMin(0.1)
            edit_burst:SetMax(600)
            edit_burst:SetDecimals(1)
            edit_burst:SetDefaultValue(bindtbl.BurstLength or 0.1)
        end

        local edit_remove = vgui.Create("DButton", editmenu)
        edit_remove:Dock(TOP)
        edit_remove:DockMargin(2, 2, 2, 2)
        edit_remove:SetText("Remove Bind")
        edit_remove:SetTextColor(Color(0, 0, 0))
        edit_remove.DoClick = function()
            table.remove(MCRB.Radials[submenu], bind)
            editmenu:Clear()
            MCRB:RegenBindMenu()
        end
    end

    function MCRB:HelpScreen(text)
        editmenu:Clear()

        local display = vgui.Create("DLabel", editmenu)
        display:Dock(FILL)
        display:SetTextColor(Color(0, 0, 0))
        display:SetText("")
        display.Paint = function(self, w, h)
            local tline = ""
            local x = 0
            local y = 0
            surface.SetFont("DermaDefault")
            surface.SetTextColor(0, 0, 0)

            local newlined = string.Split(text, "\n")

            for _, line in pairs(newlined) do
                local words = string.Split(line, " ")

                for _, word in pairs(words) do
                    local tx = surface.GetTextSize(word)

                    if x + tx >= w then
                        surface.SetTextPos(0, y)
                        surface.DrawText(tline)
                        local _, ty = surface.GetTextSize(tline)
                        y = y + ty
                        tline = ""
                        x = 0
                    end

                    tline = tline .. word .. " "

                    x = x + surface.GetTextSize(word .. " ")
                end

                surface.SetTextPos(0, y)
                surface.DrawText(tline)
                local _, ty = surface.GetTextSize(tline)
                y = y + ty
                tline = ""
                x = 0
            end
        end
    end

    function MCRB:RegenBindMenu()
        leftbar:Clear()

        local hcat = leftbar:Add("Help")

        for i, k in pairs(MCRB.helpEntries) do
            local helpbutton = vgui.Create("DButton", hcat)
            helpbutton:SetText(i)
            helpbutton:Dock(TOP)
            helpbutton:DockMargin(0, 0, 0, 2)
            helpbutton.DoClick = function()
                MCRB:HelpScreen(k)
            end
        end

        for i1, bindmenu in pairs(MCRB.Radials) do
            local cat = leftbar:Add("Menu " .. tostring(i1))
            for i2, bind in pairs(bindmenu) do
                local bindbutton = vgui.Create("DButton", cat)
                bindbutton:SetText(bind.PrintName or "Unnamed")
                bindbutton:Dock(TOP)
                bindbutton:DockMargin(0, 0, 0, 2)
                bindbutton.DoClick = function()
                    MCRB:EditBind(i1, i2)
                end
            end

            local bindbutton = vgui.Create("DButton", cat)
            bindbutton:SetText("Create New")
            bindbutton:Dock(TOP)
            bindbutton:DockMargin(0, 0, 0, 2)
            bindbutton.DoClick = function()
                local newbind = {
                    PrintName = "New Bind",
                    BindType = MCRB.Binds[1],
                    Command = "",
                    SegmentFade = 0,
                    BurstLength = 0.1
                }

                table.insert(MCRB.Radials[i1], newbind)
                MCRB:RegenBindMenu()
                MCRB:EditBind(i1, #MCRB.Radials[i1])
            end
        end

        local mcat = leftbar:Add("Utility")
    end

    MCRB:RegenBindMenu()

    MCRB.legacyFilenameOld = "arcticradialbinds.json"
    MCRB.legacyFilename = "arcticradialbinds1.json"
    MCRB.legacyFilename2 = "arcticradialbinds2.json"
    MCRB.legacyFilename3 = "arcticradialbinds3.json"
    MCRB.newFilename = "midaweksradialbinds1.json"
    MCRB.newFilename2 = "midaweksradialbinds2.json"
    MCRB.newFilename3 = "midaweksradialbinds3.json"

    function MCRB:Save()
        local serial = util.TableToJSON(MCRB.Radials[1])
        local serial2 = util.TableToJSON(MCRB.Radials[2])
        local serial3 = util.TableToJSON(MCRB.Radials[3])
        MCRB.log(self, serial)
        file.Write(MCRB.newFilename, serial)
        file.Write(MCRB.newFilename2, serial2)
        file.Write(MCRB.newFilename3, serial3)
    end

    function MCRB:ConvertLegacyBindType(bindType)
        if type(bindType) == "number" then
            local bindTypeMap = {
                [0] = "Command",
                [1] = "Bind",
                [2] = "Toggle",
                [3] = "Instant",
                [4] = "Falling Edge",
                [5] = "Burst",
                [6] = "Dual Edge"
            }
            return bindTypeMap[bindType] or "Command"
        end
        return bindType
    end

    function MCRB:LoadLegacy()
        local loaded = false
        for i, k in pairs({ MCRB.legacyFilename, MCRB.legacyFilename2, MCRB.legacyFilename3 }) do
            if file.Exists(k, "DATA") then
                local serial = file.Read(k, "DATA")
                local data = util.JSONToTable(serial)

                local newtbl = {}
                for _, v in pairs(data) do
                    v.BindType = MCRB:ConvertLegacyBindType(v.BindType)
                    table.insert(newtbl, v)
                end

                MCRB.Radials[i] = newtbl
                loaded = true
            end
        end

        if not loaded then
            if file.Exists(MCRB.legacyFilenameOld, "DATA") then
                local serial = file.Read(MCRB.legacyFilenameOld, "DATA")
                local data = util.JSONToTable(serial)

                for i = 1, 3 do
                    if data[i] then
                        local newtbl = {}
                        for _, v in pairs(data[i]) do
                            v.BindType = MCRB:ConvertLegacyBindType(v.BindType)
                            table.insert(newtbl, v)
                        end
                        MCRB.Radials[i] = newtbl
                    end
                end
                loaded = true
            end
        end

        return loaded
    end

    function MCRB:Load()
        for i, k in pairs({ MCRB.newFilename, MCRB.newFilename2, MCRB.newFilename3 }) do
            if file.Exists(k, "DATA") then
                local serial = file.Read(k, "DATA")
                MCRB.Radials[i] = util.JSONToTable(serial)

                local newtbl = {}
                for _, v in pairs(MCRB.Radials[i]) do
                    table.insert(newtbl, v)
                end

                MCRB.Radials[i] = newtbl
            end
        end
    end
end

-- Auto-load on startup
MCRB:Load()
