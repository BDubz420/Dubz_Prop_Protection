DUIF = DUIF or {}

local roundedBox = draw.RoundedBox
local simpleText = draw.SimpleText
local lerp = Lerp
local clamp = math.Clamp

function DUIF.DrawRoundedBox(radius, x, y, w, h, color)
    roundedBox(radius, x, y, w, h, color)
end

function DUIF.LerpColor(frac, from, to)
    return Color(
        lerp(frac, from.r, to.r),
        lerp(frac, from.g, to.g),
        lerp(frac, from.b, to.b),
        lerp(frac, from.a or 255, to.a or 255)
    )
end

function DUIF.DrawGradient(x, y, w, h, col1, col2, horizontal)
    local segments = 32
    for i = 0, segments do
        local frac = i / segments
        local col = DUIF.LerpColor(frac, col1, col2)

        if horizontal then
            local sx = x + frac * w
            local sw = (w / segments) + 1
            surface.SetDrawColor(col)
            surface.DrawRect(sx, y, sw, h)
        else
            local sy = y + frac * h
            local sh = (h / segments) + 1
            surface.SetDrawColor(col)
            surface.DrawRect(x, sy, w, sh)
        end
    end
end

function DUIF.DrawShadowedPanel(x, y, w, h, radius, panelColor, shadowColor)
    local shadow = shadowColor or DUIF.Theme.Shadow
    roundedBox(radius + 2, x + 2, y + 2, w, h, shadow)
    roundedBox(radius, x, y, w, h, panelColor)
end

function DUIF.CreateLabel(parent, text, font, textColor)
    local label = vgui.Create("DLabel", parent)
    label:SetText(text or "")
    label:SetFont(font or "DUIF.Body")
    label:SetTextColor(textColor or DUIF.Theme.TextPrimary)
    label:SizeToContents()

    return label
end

function DUIF.DrawCodeSnippet(panel, code)
    local padding = 10
    DUIF.DrawRoundedBox(6, 0, 0, panel:GetWide(), panel:GetTall(), DUIF.Theme.Background)
    simpleText(code, "DUIF.Mono", padding, padding, DUIF.Theme.TextSecondary, TEXT_ALIGN_LEFT)
end

function DUIF.Clamp01(value)
    return clamp(value, 0, 1)
end
