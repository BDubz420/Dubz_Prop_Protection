DPP = DPP or {}
DPP.UI = DPP.UI or {}

local ICON_CATEGORIES = {
    { icon = "🏠", label = "Core", key = "core" },
    { icon = "👥", label = "Ownership", key = "ownership" },
    { icon = "🛡", label = "Protection", key = "buildProtection" },
    { icon = "🔫", label = "Weapons", key = "weaponControl" },
    { icon = "🧰", label = "Tools", key = "toolgun" },
    { icon = "🚗", label = "Vehicles", key = "gravgun" },
    { icon = "📦", label = "Duplication", key = "advDupe2" },
    { icon = "📊", label = "Logs", key = "logging" },
    { icon = "⚙", label = "Advanced", key = "antiCrash" },
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

local function createControl(parent, item)
    local row = parent:Add("DPanel")
    row:Dock(TOP)
    row:SetTall(40)
    row:DockMargin(0, 0, 0, 8)
    row.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(30, 36, 48, 245))
    end

    local name = vgui.Create("DLabel", row)
    name:SetPos(10, 12)
    name:SetText(item.path)
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
            cb:SetPos(self:GetWide() - 24, 12)
        end
    elseif valueType == "number" then
        local nw = vgui.Create("DNumberWang", row)
        nw:SetMin(-999999)
        nw:SetMax(999999)
        nw:SetValue(item.value)
        nw:SetSize(110, 24)
        nw.OnValueChanged = function(_, n)
            DPP.Config[item.section][item.key] = tonumber(n) or 0
        end
        row.PerformLayout = function(self)
            nw:SetPos(self:GetWide() - 120, 8)
        end
    elseif valueType == "string" then
        local te = vgui.Create("DTextEntry", row)
        te:SetText(item.value)
        te:SetSize(210, 24)
        te.OnChange = function(self)
            DPP.Config[item.section][item.key] = self:GetValue()
        end
        row.PerformLayout = function(self)
            te:SetPos(self:GetWide() - 220, 8)
        end
    else
        local btn = vgui.Create("DButton", row)
        btn:SetText("Edit Table")
        btn:SetSize(100, 24)
        btn.DoClick = function()
            local fr = vgui.Create("DFrame")
            fr:SetSize(ScrW() * 0.5, ScrH() * 0.6)
            fr:Center()
            fr:SetTitle(item.path)
            fr:MakePopup()

            local txt = vgui.Create("DTextEntry", fr)
            txt:Dock(FILL)
            txt:SetMultiline(true)
            txt:SetText(util.TableToJSON(item.value, true) or "{}")

            local save = vgui.Create("DButton", fr)
            save:Dock(BOTTOM)
            save:SetTall(32)
            save:SetText("Save JSON")
            save.DoClick = function()
                local tbl = util.JSONToTable(txt:GetValue() or "")
                if istable(tbl) then
                    DPP.Config[item.section][item.key] = tbl
                    fr:Close()
                end
            end
        end
        row.PerformLayout = function(self)
            btn:SetPos(self:GetWide() - 110, 8)
        end
    end

    return row
end

local function openDashboard()
    if IsValid(DPP.UI.Frame) then DPP.UI.Frame:Remove() end

    local frame = vgui.Create("DFrame")
    DPP.UI.Frame = frame
    frame:SetSize(ScrW() * 0.88, ScrH() * 0.88)
    frame:Center()
    frame:SetTitle("")
    frame:MakePopup()
    frame:ShowCloseButton(false)

    local activeCategory = "core"

    frame.Paint = function(_, w, h)
        draw.RoundedBox(12, 0, 0, w, h, Color(17, 21, 29, 250))
        draw.RoundedBoxEx(12, 0, 0, w, 58, Color(23, 29, 40), true, true, false, false)
        draw.SimpleText("Dubz Prop Protection Dashboard", "Trebuchet24", 16, 29, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("namespace: DPP", "Trebuchet18", w - 16, 29, Color(120, 176, 255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    end

    local close = vgui.Create("DButton", frame)
    close:SetText("×")
    close:SetFont("Trebuchet24")
    close:SetSize(40, 40)
    close:SetPos(frame:GetWide() - 46, 9)
    close.DoClick = function() frame:Close() end

    local top = vgui.Create("DPanel", frame)
    top:SetPos(12, 64)
    top:SetSize(frame:GetWide() - 24, 44)
    top.Paint = function(_, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(28, 35, 47)) end

    local search = vgui.Create("DTextEntry", top)
    search:SetPos(10, 8)
    search:SetSize(280, 28)
    search:SetPlaceholderText("Search everything...")

    local master = vgui.Create("DCheckBoxLabel", top)
    master:SetPos(300, 11)
    master:SetText("Master Enable")
    master:SetValue((DPP.Config.core and DPP.Config.core.masterEnable) and 1 or 0)
    master:SizeToContents()
    master.OnChange = function(_, b)
        DPP.Config.core.masterEnable = b
    end

    local quick = vgui.Create("DComboBox", top)
    quick:SetPos(top:GetWide() - 300, 8)
    quick:SetSize(180, 28)
    quick:SetValue("Quick Actions")
    quick:AddChoice("Ghost Everyone's Props", "ghost_all")
    quick:AddChoice("Freeze Everyone's Props", "freeze_all")
    quick:AddChoice("Remove Owned Entities", "remove_owned")
    quick.OnSelect = function(_, _, _, action)
        DPP.Client.SendAction("quick_action", action)
    end

    local save = vgui.Create("DButton", top)
    save:SetText("Save")
    save:SetPos(top:GetWide() - 110, 8)
    save:SetSize(100, 28)
    save.DoClick = function()
        DPP.Client.SendAction("save_config", util.TableToJSON(DPP.Config, false, true) or "{}")
    end

    local left = vgui.Create("DPanel", frame)
    left:SetPos(12, 114)
    left:SetSize(60, frame:GetTall() - 126)
    left.Paint = function(_, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(26, 31, 42)) end

    local right = vgui.Create("DPanel", frame)
    right:SetPos(frame:GetWide() - 260, 114)
    right:SetSize(248, frame:GetTall() - 126)
    right.Paint = function(_, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(26, 31, 42))
        draw.SimpleText("Live Monitor", "Trebuchet20", 12, 20, color_white)
        draw.SimpleText("Violations: " .. tostring(DPP.Client.Live.violations or 0), "Trebuchet18", 12, 56, Color(255, 140, 140))
        draw.SimpleText("Actions: " .. tostring(DPP.Client.Live.actions or 0), "Trebuchet18", 12, 84, Color(168, 216, 255))
        draw.SimpleText("Entities Processed: " .. tostring(DPP.Client.Live.entitiesProcessed or 0), "Trebuchet18", 12, 112, Color(165, 255, 171))
    end

    local main = vgui.Create("DPanel", frame)
    main:SetPos(78, 114)
    main:SetSize(frame:GetWide() - 344, frame:GetTall() - 126)
    main.Paint = function(_, w, h) draw.RoundedBox(8, 0, 0, w, h, Color(22, 27, 37)) end

    local scroll = vgui.Create("DScrollPanel", main)
    scroll:SetPos(10, 10)
    scroll:SetSize(main:GetWide() - 20, main:GetTall() - 20)

    local function rebuildMain()
        scroll:Clear()
        local query = string.lower(string.Trim(search:GetValue() or ""))
        for _, item in ipairs(flattenSettings(activeCategory)) do
            if query == "" or string.find(string.lower(item.path), query, 1, true) then
                createControl(scroll, item)
            end
        end
    end

    local y = 10
    for _, cat in ipairs(ICON_CATEGORIES) do
        local b = vgui.Create("DButton", left)
        b:SetPos(8, y)
        b:SetSize(44, 44)
        b:SetText(cat.icon)
        b:SetToolTip(cat.label)
        b.Paint = function(self, w, h)
            local active = activeCategory == cat.key
            draw.RoundedBox(8, 0, 0, w, h, active and Color(57, 121, 220) or (self:IsHovered() and Color(42, 50, 67) or Color(31, 37, 49)))
        end
        b.DoClick = function()
            activeCategory = cat.key
            rebuildMain()
        end
        y = y + 50
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
