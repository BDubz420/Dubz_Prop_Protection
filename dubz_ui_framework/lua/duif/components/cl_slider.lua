DUIF = DUIF or {}

function DUIF.CreateSlider(parent, min, max)
    local slider = vgui.Create("DNumSlider", parent)
    slider:SetMin(min or 0)
    slider:SetMax(max or 100)
    slider:SetDecimals(0)
    slider:SetTall(36)
    slider:SetText("")

    slider.Slider.Paint = function(s, w, h)
        local frac = (slider:GetValue() - slider:GetMin()) / (slider:GetMax() - slider:GetMin())
        frac = math.Clamp(frac, 0, 1)

        DUIF.DrawRoundedBox(4, 0, h * 0.5 - 2, w, 4, Color(80, 95, 130))
        DUIF.DrawGradient(0, h * 0.5 - 2, w * frac, 4, DUIF.Theme.Accent, DUIF.Theme.AccentAlt, true)

        local knobX = w * frac
        DUIF.DrawRoundedBox(8, knobX - 7, h * 0.5 - 7, 14, 14, Color(230, 235, 255))
    end

    slider.TextArea:SetVisible(false)
    slider.Label:SetFont("DUIF.Small")
    slider.Label:SetTextColor(DUIF.Theme.TextSecondary)
    slider.Label:SetText("Value")
    return slider
end
