--[[
    DUIF - Dubz UI Framework
    File: cl_card.lua
    Purpose: Reusable premium card container with optional header/icon/accent border.
]]

DUIF = DUIF or {}

function DUIF.CreateCard(parent, opts)
    opts = DUIF.MergeOptions({
        dock = TOP,
        tall = 140,
        margin = {0, 0, 0, 10},
        rounded = 10,
        header = nil,
        description = nil,
        icon = nil,
        accentBorder = false,
        onClick = nil
    }, opts)

    local card = vgui.Create(isfunction(opts.onClick) and "DButton" or "DPanel", parent)
    card:SetTall(opts.tall)
    card:Dock(opts.dock)
    card:DockMargin(opts.margin[1], opts.margin[2], opts.margin[3], opts.margin[4])
    if card.SetText then card:SetText("") end

    card.Header = opts.header
    card.Description = opts.description

    card.Paint = function(self, w, h)
        DUIF.DrawShadowedPanel(0, 0, w, h, opts.rounded, DUIF.GetColor("Surface"))

        if opts.accentBorder then
            DUIF.DrawGradient(0, 0, w, 4, DUIF.GetColor("Accent"), DUIF.GetColor("AccentAlt"), true)
        end

        if opts.icon then
            draw.SimpleText(opts.icon, "DUIF.Header", 14, 16, DUIF.GetColor("AccentAlt"), TEXT_ALIGN_LEFT)
        end

        if self.Header then
            draw.SimpleText(self.Header, "DUIF.Header", opts.icon and 44 or 14, 14, DUIF.GetColor("Text"), TEXT_ALIGN_LEFT)
        end

        if self.Description then
            draw.SimpleText(self.Description, "DUIF.Small", 14, self.Header and 48 or 16, DUIF.GetColor("TextMuted"), TEXT_ALIGN_LEFT)
        end
    end

    if card.DoClick then
        card.DoClick = function(self)
            opts.onClick(self)
        end
    end

    return card
end
