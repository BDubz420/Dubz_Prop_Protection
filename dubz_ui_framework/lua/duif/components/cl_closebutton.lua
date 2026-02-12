DUIF = DUIF or {}

function DUIF.CreateCloseButton(parent)
    local close = vgui.Create("DButton", parent)
    close:SetText("")
    close:SetSize(28, 28)
    close.HoverFrac = 0

    close.DoClick = function(self)
        local p = self:GetParent()
        if IsValid(p) then
            p:AlphaTo(0, 0.1, 0, function()
                if IsValid(p) then p:Remove() end
            end)
        end
    end

    close.Paint = function(self, w, h)
        self.HoverFrac = Lerp(FrameTime() * 12, self.HoverFrac, self:IsHovered() and 1 or 0)
        local size = 1 + (0.05 * self.HoverFrac)
        local x = (w * (1 - size)) * 0.5
        local y = (h * (1 - size)) * 0.5

        DUIF.DrawRoundedBox(6, x, y, w * size, h * size, Color(220, 70, 70, 20 + 70 * self.HoverFrac))

        surface.SetDrawColor(230, 235, 255, 180 + 75 * self.HoverFrac)
        surface.DrawLine(9, 9, w - 9, h - 9)
        surface.DrawLine(w - 9, 9, 9, h - 9)
    end

    return close
end
