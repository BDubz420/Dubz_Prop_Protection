DUIF = DUIF or {}

local styleColor = function(style)
    local t = DUIF.Theme
    local map = {
        primary = t.Accent,
        secondary = t.PanelLight,
        danger = t.Danger,
        success = t.Success,
        ghost = ColorAlpha(t.TextPrimary, 20),
        gradient = t.Accent
    }

    return map[style or "primary"] or t.Accent
end

function DUIF.CreateButton(parent, text, style)
    local btn = vgui.Create("DButton", parent)
    btn:SetText("")
    btn:SetTall(34)
    btn.Style = style or "primary"
    btn.Text = text or "Button"
    btn.HoverFrac = 0
    btn.PressFrac = 0
    btn.RippleFrac = 0

    btn.Paint = function(self, w, h)
        self.HoverFrac = Lerp(FrameTime() * 12, self.HoverFrac, self:IsHovered() and 1 or 0)
        self.PressFrac = Lerp(FrameTime() * 18, self.PressFrac, self:IsDown() and 1 or 0)
        self.RippleFrac = Lerp(FrameTime() * 9, self.RippleFrac, self:IsHovered() and 1 or 0)

        local base = styleColor(self.Style)
        local target = DUIF.LerpColor(self.HoverFrac, base, Color(255, 255, 255, 255))
        local bg = DUIF.LerpColor(0.15, base, target)

        if self.Style == "gradient" then
            DUIF.DrawRoundedBox(8, 0, 0, w, h, DUIF.Theme.PanelLight)
            DUIF.DrawGradient(1, 1, w - 2, h - 2, DUIF.Theme.Accent, DUIF.Theme.AccentAlt, true)
        else
            DUIF.DrawRoundedBox(8, 0, 0, w, h, bg)
        end

        if self.RippleFrac > 0.01 then
            local highlightW = w * 0.35
            local x = (w + highlightW) * self.RippleFrac - highlightW
            surface.SetDrawColor(255, 255, 255, 14)
            surface.DrawRect(x, 0, highlightW, h)
        end

        if self.PressFrac > 0.01 then
            DUIF.DrawRoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 40 * self.PressFrac))
        end

        draw.SimpleText(self.Text, "DUIF.Body", w * 0.5, h * 0.5 + self.PressFrac, DUIF.Theme.TextPrimary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    return btn
end
