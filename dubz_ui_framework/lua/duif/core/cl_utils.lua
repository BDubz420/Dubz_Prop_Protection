--[[
    DUIF - Dubz UI Framework
    File: cl_utils.lua
    Purpose: Shared draw helpers, interpolation helpers, and small utility builders.
]]

DUIF = DUIF or {}

function DUIF.DrawRoundedBox(radius, x, y, w, h, color)
    draw.RoundedBox(radius, x, y, w, h, color)
end

function DUIF.LerpColor(frac, fromCol, toCol)
    return Color(
        Lerp(frac, fromCol.r, toCol.r),
        Lerp(frac, fromCol.g, toCol.g),
        Lerp(frac, fromCol.b, toCol.b),
        Lerp(frac, fromCol.a or 255, toCol.a or 255)
    )
end

function DUIF.DrawGradient(x, y, w, h, startCol, endCol, horizontal)
    local steps = 28

    for i = 0, steps do
        local t = i / steps
        local c = DUIF.LerpColor(t, startCol, endCol)
        surface.SetDrawColor(c)

        if horizontal then
            local sw = (w / steps) + 1
            surface.DrawRect(x + (t * w), y, sw, h)
        else
            local sh = (h / steps) + 1
            surface.DrawRect(x, y + (t * h), w, sh)
        end
    end
end

function DUIF.DrawShadowedPanel(x, y, w, h, radius, mainColor, shadowColor)
    DUIF.DrawRoundedBox(radius + 1, x + 2, y + 2, w, h, shadowColor or DUIF.GetColor("Shadow"))
    DUIF.DrawRoundedBox(radius, x, y, w, h, mainColor)
end

function DUIF.Clamp01(n)
    return math.Clamp(n, 0, 1)
end

function DUIF.MergeOptions(defaults, custom)
    local out = table.Copy(defaults or {})
    for k, v in pairs(custom or {}) do
        out[k] = v
    end
    return out
end


function DUIF.AttachTooltip(panel, text)
    if not IsValid(panel) then return end
    panel:SetTooltip(text or "")
end

function DUIF.Toast(message, duration)
    duration = duration or 3

    local toast = vgui.Create("DPanel")
    toast:SetSize(320, 44)
    toast:SetPos(ScrW() - 340, 24)
    toast:SetAlpha(0)
    toast:SetMouseInputEnabled(false)
    toast.Paint = function(self, w, h)
        DUIF.DrawShadowedPanel(0, 0, w, h, 8, DUIF.GetColor("Surface"))
        DUIF.DrawGradient(0, 0, 4, h, DUIF.GetColor("Accent"), DUIF.GetColor("AccentAlt"))
        draw.SimpleText(message or "Toast", "DUIF.Body", 12, h * 0.5, DUIF.GetColor("Text"), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    DUIF.Fade(toast, 0, 255, 0.18)

    timer.Simple(duration, function()
        if not IsValid(toast) then return end
        DUIF.Fade(toast, toast:GetAlpha(), 0, 0.2, function(pnl)
            if IsValid(pnl) then pnl:Remove() end
        end)
    end)
end
