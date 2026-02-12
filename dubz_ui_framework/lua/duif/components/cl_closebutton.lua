--[[
    DUIF - Dubz UI Framework
    File: cl_closebutton.lua
    Purpose: Minimal close control with red hover fade and press scale.
]]

DUIF = DUIF or {}

function DUIF.CreateCloseButton(parent, opts)
    opts = DUIF.MergeOptions({
        w = 26,
        h = 26,
        onClick = nil
    }, opts)

    local btn = vgui.Create("DButton", parent)
    btn:SetText("")
    btn:SetSize(opts.w, opts.h)
    btn.HoverFrac = 0
    btn.PressFrac = 0

    btn.DoClick = function(self)
        if isfunction(opts.onClick) then
            opts.onClick(self)
        else
            local p = self:GetParent()
            if IsValid(p) then p:Remove() end
        end
    end

    btn.Paint = function(self, w, h)
        self.HoverFrac = Lerp(FrameTime() * 14, self.HoverFrac, self:IsHovered() and 1 or 0)
        self.PressFrac = Lerp(FrameTime() * 16, self.PressFrac, self:IsDown() and 1 or 0)

        local scale = 1 - (self.PressFrac * 0.06)
        local dw, dh = w * scale, h * scale
        local x, y = (w - dw) * 0.5, (h - dh) * 0.5

        DUIF.DrawRoundedBox(7, x, y, dw, dh, Color(220, 70, 70, 20 + (80 * self.HoverFrac)))
        surface.SetDrawColor(245, 245, 250, 180 + (65 * self.HoverFrac))
        surface.DrawLine(8, 8, w - 8, h - 8)
        surface.DrawLine(w - 8, 8, 8, h - 8)
    end

    return btn
end
