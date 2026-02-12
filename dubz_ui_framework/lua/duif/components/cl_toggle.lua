DUIF = DUIF or {}

function DUIF.CreateToggle(parent, defaultValue)
    local toggle = vgui.Create("DButton", parent)
    toggle:SetText("")
    toggle:SetSize(56, 28)
    toggle.Value = tobool(defaultValue)
    toggle.SlideFrac = toggle.Value and 1 or 0

    function toggle:SetValue(val, noCallback)
        self.Value = tobool(val)
        if not noCallback and isfunction(self.OnChanged) then
            self:OnChanged(self.Value)
        end
    end

    function toggle:GetValue()
        return self.Value
    end

    toggle.DoClick = function(self)
        self:SetValue(not self.Value)
    end

    toggle.Paint = function(self, w, h)
        self.SlideFrac = Lerp(FrameTime() * 14, self.SlideFrac, self.Value and 1 or 0)
        local bg = DUIF.LerpColor(self.SlideFrac, Color(90, 100, 130), DUIF.Theme.AccentAlt)

        DUIF.DrawRoundedBox(h / 2, 0, 0, w, h, bg)

        if self.SlideFrac > 0.3 then
            local glowAlpha = 40 * self.SlideFrac
            DUIF.DrawRoundedBox(h / 2, 0, 0, w, h, Color(DUIF.Theme.AccentAlt.r, DUIF.Theme.AccentAlt.g, DUIF.Theme.AccentAlt.b, glowAlpha))
        end

        local knobX = 2 + ((w - h) * self.SlideFrac)
        DUIF.DrawRoundedBox((h - 4) / 2, knobX, 2, h - 4, h - 4, Color(245, 245, 245))
    end

    return toggle
end
