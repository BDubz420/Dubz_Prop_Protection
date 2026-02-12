--[[
    DUIF - Dubz UI Framework
    File: cl_button.lua
    Purpose: Styled animated button component with multiple visual variants.
]]

DUIF = DUIF or {}

local function getStyleBase(style)
    local colors = {
        primary = DUIF.GetColor("Accent"),
        secondary = DUIF.GetColor("SurfaceAlt"),
        danger = DUIF.GetColor("Danger"),
        success = DUIF.GetColor("Success"),
        ghost = ColorAlpha(DUIF.GetColor("Text"), 25),
        gradient = DUIF.GetColor("Accent")
    }

    return colors[style] or colors.primary
end

function DUIF.CreateButton(parent, text, style, opts)
    opts = DUIF.MergeOptions({
        tall = 36,
        rounded = 8,
        paddingX = 14,
        onClick = nil,
        icon = nil
    }, opts)

    local btn = vgui.Create("DButton", parent)
    btn:SetText("")
    btn:SetTall(opts.tall)
    btn.Label = text or "Button"
    btn.Style = style or "primary"
    btn.HoverFrac = 0
    btn.PressFrac = 0

    btn.DoClick = function(self)
        if isfunction(self.OnClick) then self:OnClick() end
        if isfunction(opts.onClick) then opts.onClick(self) end
    end

    btn.Paint = function(self, w, h)
        self.HoverFrac = Lerp(FrameTime() * 12, self.HoverFrac, self:IsHovered() and 1 or 0)
        self.PressFrac = Lerp(FrameTime() * 16, self.PressFrac, self:IsDown() and 1 or 0)

        local base = getStyleBase(self.Style)
        local hoverTint = DUIF.LerpColor(self.HoverFrac * 0.25, base, Color(255, 255, 255))

        local drawW = w * (1 - 0.02 * self.PressFrac)
        local drawH = h * (1 - 0.06 * self.PressFrac)
        local x = (w - drawW) * 0.5
        local y = (h - drawH) * 0.5

        if self.Style == "gradient" then
            DUIF.DrawRoundedBox(opts.rounded, x, y, drawW, drawH, DUIF.GetColor("SurfaceAlt"))
            DUIF.DrawGradient(x + 1, y + 1, drawW - 2, drawH - 2, DUIF.GetColor("Accent"), DUIF.GetColor("AccentAlt"), true)
        else
            DUIF.DrawRoundedBox(opts.rounded, x, y, drawW, drawH, hoverTint)
        end

        if self.HoverFrac > 0.02 then
            surface.SetDrawColor(255, 255, 255, 12 + (22 * self.HoverFrac))
            surface.DrawRect(x + 3, y + 3, drawW - 6, 3)
        end

        local tx = w * 0.5
        if opts.icon then
            draw.SimpleText(opts.icon, "DUIF.Body", tx - 24, h * 0.5, DUIF.GetColor("Text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(self.Label, "DUIF.Body", tx + 8, h * 0.5, DUIF.GetColor("Text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        else
            draw.SimpleText(self.Label, "DUIF.Body", tx, h * 0.5, DUIF.GetColor("Text"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    return btn
end
