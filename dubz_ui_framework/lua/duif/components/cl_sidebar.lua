DUIF = DUIF or {}

function DUIF.CreateSidebar(parent)
    local sidebar = vgui.Create("DPanel", parent)
    sidebar:SetWide(220)
    sidebar:Dock(LEFT)
    sidebar:DockMargin(0, 52, 0, 0)

    sidebar.Items = {}

    sidebar.Paint = function(_, w, h)
        DUIF.DrawRoundedBox(0, 0, 0, w, h, DUIF.Theme.Panel)
        surface.SetDrawColor(DUIF.Theme.Outline)
        surface.DrawLine(w - 1, 0, w - 1, h)
    end

    function sidebar:AddItem(text, onClick)
        local btn = DUIF.CreateButton(self, text, "ghost")
        btn:Dock(TOP)
        btn:DockMargin(8, 8, 8, 0)
        btn:SetTall(32)
        btn.DoClick = function()
            if isfunction(onClick) then onClick() end
        end

        table.insert(self.Items, btn)
        return btn
    end

    return sidebar
end
