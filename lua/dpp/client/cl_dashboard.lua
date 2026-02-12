DPP = DPP or {}
DPP.UI = DPP.UI or {}

surface.CreateFont("DPP.Title", {
    font = "Roboto",
    size = 30,
    weight = 700,
    antialias = true,
})

surface.CreateFont("DPP.Subtitle", {
    font = "Roboto",
    size = 19,
    weight = 500,
    antialias = true,
})

surface.CreateFont("DPP.Nav", {
    font = "Roboto",
    size = 18,
    weight = 600,
    antialias = true,
})

surface.CreateFont("DPP.Row", {
    font = "Roboto",
    size = 18,
    weight = 500,
    antialias = true,
})

surface.CreateFont("DPP.Small", {
    font = "Roboto",
    size = 16,
    weight = 500,
    antialias = true,
})

local NAV_CATEGORIES = {
    { code = "CORE", label = "Core System", key = "core" },
    { code = "OWN", label = "Ownership", key = "ownership" },
    { code = "PROT", label = "Build Protection", key = "buildProtection" },
    { code = "WPN", label = "Weapon Control", key = "weaponControl" },
    { code = "TOOL", label = "Toolgun / Physgun", key = "toolgun" },
    { code = "GRAV", label = "Gravgun", key = "gravgun" },
    { code = "DUPE", label = "Adv Dupe 2", key = "advDupe2" },
    { code = "LOG", label = "Logs", key = "logging" },
    { code = "ADV", label = "Advanced", key = "antiCrash" },
}

local KEY_MAP = {
    core = { "core", "general", "automation", "miscs" },
    ownership = { "ownership", "permissions" },
    buildProtection = { "ghosting", "damage", "antiCollide", "spamProtection", "spawnRestriction" },
    weaponControl = { "canProperty", "spawnRestriction" },
    toolgun = { "toolgun", "physgun" },
    gravgun = { "gravgun" },
    advDupe2 = { "advDupe2" },
    logging = { "logging" },
    antiCrash = { "antiCrash", "profiles", "qol" },
}

local function flattenSettings(key)
    local result = {}
    local sections = KEY_MAP[key] or {}
    for _, sectionKey in ipairs(sections) do
        local sec = DPP.Config and DPP.Config[sectionKey]
        if istable(sec) then
            for k, v in pairs(sec) do
                result[#result + 1] = {
                    path = sectionKey .. "." .. k,
                    section = sectionKey,
                    key = k,
                    value = v,
                }
            end
        end
    end
    table.sort(result, function(a, b) return a.path < b.path end)
    return result
end

local function getCategoryLabel(key)
    for _, cat in ipairs(NAV_CATEGORIES) do
        if cat.key == key then return cat.label end
    end
    return "Unknown"
end

local function styleButton(btn)
    btn:SetFont("DPP.Small")
    btn:SetTextColor(Color(225, 232, 245))
end

local function createControl(parent, item)
    local row = parent:Add("DPanel")
    row:Dock(TOP)
    row:SetTall(46)
    row:DockMargin(0, 0, 0, 8)
    row.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(28, 35, 49, 245))
    end

    local name = vgui.Create("DLabel", row)
    name:SetPos(14, 12)
    name:SetText(item.path)
    name:SetFont("DPP.Row")
    name:SetTextColor(Color(227, 233, 245))
    name:SizeToContents()

    local valueType = type(item.value)
    if valueType == "boolean" then
        local cb = vgui.Create("DCheckBox", row)
        cb:SetValue(item.value and 1 or 0)
        cb.OnChange = function(_, b)
            DPP.Config[item.section][item.key] = b
        end
        row.PerformLayout = function(self)
            cb:SetPos(self:GetWide() - 28, 15)
        end
    elseif valueType == "number" then
        local nw = vgui.Create("DNumberWang", row)
        nw:SetMin(-999999)
        nw:SetMax(999999)
        nw:SetValue(item.value)
        nw:SetSize(126, 30)
        nw:SetFont("DPP.Small")
        nw.OnValueChanged = function(_, n)
            DPP.Config[item.section][item.key] = tonumber(n) or 0
        end
        row.PerformLayout = function(self)
            nw:SetPos(self:GetWide() - 140, 8)
        end
    elseif valueType == "string" then
        local te = vgui.Create("DTextEntry", row)
        te:SetText(item.value)
        te:SetSize(240, 30)
        te:SetFont("DPP.Small")
        te.OnChange = function(self)
            DPP.Config[item.section][item.key] = self:GetValue()
        end
        row.PerformLayout = function(self)
            te:SetPos(self:GetWide() - 254, 8)
        end
    else
        local btn = vgui.Create("DButton", row)
        btn:SetText("Edit Table")
        btn:SetSize(120, 30)
        styleButton(btn)
        btn.DoClick = function()
            local fr = vgui.Create("DFrame")
            fr:SetSize(ScrW() * 0.52, ScrH() * 0.66)
            fr:Center()
            fr:SetTitle(item.path)
            fr:MakePopup()

            local txt = vgui.Create("DTextEntry", fr)
            txt:Dock(FILL)
            txt:SetMultiline(true)
            txt:SetFont("DPP.Small")
            txt:SetText(util.TableToJSON(item.value, true) or "{}")

            local save = vgui.Create("DButton", fr)
            save:Dock(BOTTOM)
            save:SetTall(36)
            save:SetText("Save JSON")
            styleButton(save)
            save.DoClick = function()
                local tbl = util.JSONToTable(txt:GetValue() or "")
                if istable(tbl) then
                    DPP.Config[item.section][item.key] = tbl
                    fr:Close()
                end
            end
        end
        row.PerformLayout = function(self)
            btn:SetPos(self:GetWide() - 134, 8)
        end
    end

    return row
end

local function openDashboard()
    if IsValid(DPP.UI.Frame) then DPP.UI.Frame:Remove() end

    local frame = vgui.Create("DFrame")
    DPP.UI.Frame = frame
    frame:SetSize(ScrW() * 0.90, ScrH() * 0.90)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)

    local activeCategory = "core"

    frame.Paint = function(_, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(14, 20, 30, 248))
        draw.RoundedBoxEx(12, 0, 0, w, 70, Color(20, 30, 45), true, true, false, false)
        draw.SimpleText("Dubz Prop Protection Dashboard", "DPP.Title", 16, 34, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("namespace: DPP", "DPP.Subtitle", w - 62, 34, Color(130, 180, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    local close = vgui.Create("DButton", frame)
    close:SetText("X")
    close:SetFont("DPP.Subtitle")
    close:SetSize(36, 36)
    close:SetPos(frame:GetWide() - 44, 17)
    close.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, self:IsHovered() and Color(170, 68, 68) or Color(42, 53, 69))
    end
    close.DoClick = function() frame:Close() end

    local top = vgui.Create("DPanel", frame)
    top:SetPos(12, 78)
    top:SetSize(frame:GetWide() - 24, 52)
    top.Paint = function(_, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(24, 34, 48)) end

    local search = vgui.Create("DTextEntry", top)
    search:SetPos(12, 10)
    search:SetSize(320, 32)
    search:SetFont("DPP.Small")
    search:SetPlaceholderText("Search settings...")

    local master = vgui.Create("DCheckBoxLabel", top)
    master:SetPos(344, 16)
    master:SetText("Master Enable")
    master:SetFont("DPP.Small")
    master:SetTextColor(Color(235, 240, 250))
    master:SetValue((DPP.Config.core and DPP.Config.core.masterEnable) and 1 or 0)
    master:SizeToContents()
    master.OnChange = function(_, b)
        DPP.Config.core.masterEnable = b
    end

    local quick = vgui.Create("DComboBox", top)
    quick:SetPos(top:GetWide() - 356, 10)
    quick:SetSize(220, 32)
    quick:SetFont("DPP.Small")
    quick:SetValue("Quick Actions")
    quick:AddChoice("Ghost Everyone's Props", "ghost_all")
    quick:AddChoice("Freeze Everyone's Props", "freeze_all")
    quick:AddChoice("Remove Owned Entities", "remove_owned")
    quick.OnSelect = function(_, _, _, action)
        DPP.Client.SendAction("quick_action", action)
    end

    local save = vgui.Create("DButton", top)
    save:SetText("Save Config")
    save:SetPos(top:GetWide() - 126, 10)
    save:SetSize(114, 32)
    styleButton(save)
    save.DoClick = function()
        DPP.Client.SendAction("save_config", util.TableToJSON(DPP.Config, false, true) or "{}")
    end

    local left = vgui.Create("DPanel", frame)
    left:SetPos(12, 136)
    left:SetSize(230, frame:GetTall() - 148)
    left.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(22, 31, 44))
        draw.SimpleText("Sections", "DPP.Subtitle", 14, 20, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local right = vgui.Create("DPanel", frame)
    right:SetPos(frame:GetWide() - 282, 136)
    right:SetSize(270, frame:GetTall() - 148)
    right.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(22, 31, 44))
        draw.SimpleText("Live Monitor", "DPP.Subtitle", 14, 24, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("Violations: " .. tostring(DPP.Client.Live.violations or 0), "DPP.Small", 14, 62, Color(255, 140, 140))
        draw.SimpleText("Actions: " .. tostring(DPP.Client.Live.actions or 0), "DPP.Small", 14, 90, Color(168, 216, 255))
        draw.SimpleText("Entities Processed: " .. tostring(DPP.Client.Live.entitiesProcessed or 0), "DPP.Small", 14, 118, Color(165, 255, 171))
    end

    local main = vgui.Create("DPanel", frame)
    main:SetPos(248, 136)
    main:SetSize(frame:GetWide() - 536, frame:GetTall() - 148)
    main.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(20, 28, 40))
        draw.SimpleText("Current Tab: " .. getCategoryLabel(activeCategory), "DPP.Subtitle", 14, 22, Color(224, 231, 247), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local scroll = vgui.Create("DScrollPanel", main)
    scroll:SetPos(10, 42)
    scroll:SetSize(main:GetWide() - 20, main:GetTall() - 52)

    local function rebuildMain()
        scroll:Clear()
        local query = string.lower(string.Trim(search:GetValue() or ""))
        for _, item in ipairs(flattenSettings(activeCategory)) do
            if query == "" or string.find(string.lower(item.path), query, 1, true) then
                createControl(scroll, item)
            end
        end
    end

    local y = 46
    for _, cat in ipairs(NAV_CATEGORIES) do
        local b = vgui.Create("DButton", left)
        b:SetPos(10, y)
        b:SetSize(left:GetWide() - 20, 40)
        b:SetText(cat.code .. "  -  " .. cat.label)
        b:SetFont("DPP.Nav")
        b:SetContentAlignment(4)
        b:SetTextColor(Color(230, 236, 246))
        b.Paint = function(self, w, h)
            local active = activeCategory == cat.key
            local clr = active and Color(58, 122, 221) or (self:IsHovered() and Color(38, 49, 65) or Color(28, 38, 52))
            draw.RoundedBox(7, 0, 0, w, h, clr)
        end
        b.DoClick = function()
            activeCategory = cat.key
            main:InvalidateLayout(true)
            rebuildMain()
        end
        y = y + 46
    end

    search.OnValueChange = rebuildMain
    rebuildMain()
end

net.Receive(DPP.NET.ACTION, function()
    local action = net.ReadString()
    net.ReadString()
    if action == "open_ui" then
        openDashboard()
    end
end)
