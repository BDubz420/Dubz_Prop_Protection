DUIF = DUIF or {}

function DUIF.CreateCard(parent, opts)
    opts = opts or {}

    local card = vgui.Create("DPanel", parent)
    card:SetTall(opts.tall or 140)
    card:Dock(opts.dock or TOP)
    card:DockMargin(0, 0, 0, 8)

    card.Header = opts.header
    card.Description = opts.description
    card.Icon = opts.icon
    card.AccentBorder = opts.accentBorder

    card.Paint = function(self, w, h)
        DUIF.DrawShadowedPanel(0, 0, w, h, 10, DUIF.Theme.Panel)

        if self.AccentBorder then
            DUIF.DrawGradient(0, 0, w, 4, DUIF.Theme.Accent, DUIF.Theme.AccentAlt, true)
        end

        if self.Icon then
            draw.SimpleText(self.Icon, "DUIF.Subtitle", 14, 20, DUIF.Theme.AccentAlt, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        if self.Header then
            draw.SimpleText(self.Header, "DUIF.Subtitle", self.Icon and 44 or 14, 14, DUIF.Theme.TextPrimary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end

        if self.Description then
            draw.SimpleText(self.Description, "DUIF.Small", 14, self.Header and 48 or 20, DUIF.Theme.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        end
    end

    return card
end
