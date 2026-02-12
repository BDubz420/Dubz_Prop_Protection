DUIF = DUIF or {}

function DUIF.CreateTextEntry(parent, placeholder)
    local entry = vgui.Create("DTextEntry", parent)
    entry:SetFont("DUIF.Body")
    entry:SetTextColor(DUIF.Theme.TextPrimary)
    entry:SetCursorColor(DUIF.Theme.Accent)
    entry:SetHighlightColor(Color(DUIF.Theme.Accent.r, DUIF.Theme.Accent.g, DUIF.Theme.Accent.b, 80))
    entry:SetPaintBackground(false)
    entry:SetTall(34)

    if placeholder then
        entry:SetPlaceholderText(placeholder)
    end

    entry.Paint = function(self, w, h)
        local active = self:HasFocus() and 1 or 0
        local col = DUIF.LerpColor(active, DUIF.Theme.PanelLight, DUIF.Theme.Accent)
        DUIF.DrawRoundedBox(8, 0, 0, w, h, DUIF.Theme.Panel)
        surface.SetDrawColor(col)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        self:DrawTextEntryText(DUIF.Theme.TextPrimary, DUIF.Theme.Accent, DUIF.Theme.TextPrimary)
    end

    return entry
end
