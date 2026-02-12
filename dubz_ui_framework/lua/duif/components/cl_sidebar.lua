--[[
    DUIF - Dubz UI Framework
    File: cl_sidebar.lua
    Purpose: Sidebar navigation container with helper API for item creation.
]]

DUIF = DUIF or {}

function DUIF.CreateSidebar(parent, opts)
    opts = DUIF.MergeOptions({
        width = 230,
        topPadding = 58
    }, opts)

    local sidebar = vgui.Create("DPanel", parent)
    sidebar:SetWide(opts.width)
    sidebar:Dock(LEFT)
    sidebar:DockMargin(0, opts.topPadding, 0, 0)
    sidebar:DockPadding(10, 10, 10, 10)
    sidebar.Items = {}

    sidebar.Paint = function(_, w, h)
        DUIF.DrawRoundedBox(0, 0, 0, w, h, DUIF.GetColor("Surface"))
        surface.SetDrawColor(DUIF.GetColor("Border"))
        surface.DrawLine(w - 1, 0, w - 1, h)
    end

    function sidebar:AddItem(label, onClick, style)
        local btn = DUIF.CreateButton(self, label, style or "ghost", {
            tall = 32,
            onClick = function()
                if isfunction(onClick) then onClick(btn) end
            end
        })

        btn:Dock(TOP)
        btn:DockMargin(0, 0, 0, 6)

        table.insert(self.Items, btn)
        return btn
    end

    return sidebar
end
