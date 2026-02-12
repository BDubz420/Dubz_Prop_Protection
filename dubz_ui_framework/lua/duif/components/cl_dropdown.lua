--[[
    DUIF - Dubz UI Framework
    File: cl_dropdown.lua
    Purpose: Styled dropdown with option list support and selection callbacks.
]]

DUIF = DUIF or {}

function DUIF.CreateDropdown(parent, optionsTable, opts)
    opts = DUIF.MergeOptions({
        tall = 36,
        rounded = 8,
        placeholder = "Select option",
        onSelect = nil
    }, opts)

    local combo = vgui.Create("DComboBox", parent)
    combo:SetTall(opts.tall)
    combo:SetFont("DUIF.Body")
    combo:SetValue(opts.placeholder)
    combo:SetTextColor(DUIF.GetColor("Text"))

    for _, option in ipairs(optionsTable or {}) do
        combo:AddChoice(option)
    end

    combo.Paint = function(self, w, h)
        DUIF.DrawRoundedBox(opts.rounded, 0, 0, w, h, DUIF.GetColor("Surface"))
        surface.SetDrawColor(DUIF.GetColor("Border"))
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        draw.SimpleText(self:GetText() ~= "" and self:GetText() or self:GetValue(), "DUIF.Body", 10, h * 0.5, DUIF.GetColor("Text"), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText("▾", "DUIF.Body", w - 14, h * 0.5, DUIF.GetColor("TextMuted"), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    combo.OnSelect = function(self, index, value, data)
        if isfunction(opts.onSelect) then opts.onSelect(self, index, value, data) end
    end

    return combo
end
