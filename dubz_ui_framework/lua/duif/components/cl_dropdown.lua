DUIF = DUIF or {}

function DUIF.CreateDropdown(parent, optionsTable)
    local combo = vgui.Create("DComboBox", parent)
    combo:SetTall(34)
    combo:SetFont("DUIF.Body")
    combo:SetValue("Select option")

    for _, option in ipairs(optionsTable or {}) do
        combo:AddChoice(option)
    end

    combo.Paint = function(self, w, h)
        DUIF.DrawRoundedBox(8, 0, 0, w, h, DUIF.Theme.Panel)
        surface.SetDrawColor(DUIF.Theme.Outline)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        draw.SimpleText(self:GetText() or self:GetValue(), "DUIF.Body", 10, h * 0.5, DUIF.Theme.TextPrimary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("▾", "DUIF.Body", w - 14, h * 0.5, DUIF.Theme.TextSecondary, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    combo.OpenMenu = function(self)
        if IsValid(self.Menu) then
            self.Menu:Remove()
        end

        self.Menu = DermaMenu(false, self)
        for _, choice in ipairs(self.Choices or {}) do
            self.Menu:AddOption(choice, function()
                self:SetValue(choice)
                if isfunction(self.OnSelect) then
                    self:OnSelect(nil, choice, choice)
                end
            end)
        end

        self.Menu:SetMinimumWidth(self:GetWide())
        self.Menu:Open()
    end

    return combo
end
