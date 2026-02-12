--[[
    DUIF - Dubz UI Framework
    File: cl_textentry.lua
    Purpose: Theme-aware text input with focus animation and callback passthrough.
]]

DUIF = DUIF or {}

function DUIF.CreateTextEntry(parent, placeholder, opts)
    opts = DUIF.MergeOptions({
        tall = 36,
        rounded = 8,
        onEnter = nil,
        onValueChanged = nil
    }, opts)

    local entry = vgui.Create("DTextEntry", parent)
    entry:SetTall(opts.tall)
    entry:SetPaintBackground(false)
    entry:SetFont("DUIF.Body")
    entry:SetTextColor(DUIF.GetColor("Text"))
    entry:SetCursorColor(DUIF.GetColor("Accent"))
    entry:SetHighlightColor(ColorAlpha(DUIF.GetColor("Accent"), 80))
    entry:SetPlaceholderText(placeholder or "")
    entry.FocusFrac = 0

    entry.OnEnter = function(self)
        if isfunction(opts.onEnter) then opts.onEnter(self, self:GetValue()) end
    end

    entry.OnValueChange = function(self, val)
        if isfunction(opts.onValueChanged) then opts.onValueChanged(self, val) end
    end

    entry.Paint = function(self, w, h)
        self.FocusFrac = Lerp(FrameTime() * 10, self.FocusFrac, self:HasFocus() and 1 or 0)
        local border = DUIF.LerpColor(self.FocusFrac, DUIF.GetColor("Border"), DUIF.GetColor("Accent"))

        DUIF.DrawRoundedBox(opts.rounded, 0, 0, w, h, DUIF.GetColor("Surface"))
        surface.SetDrawColor(border)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
        self:DrawTextEntryText(DUIF.GetColor("Text"), DUIF.GetColor("Accent"), DUIF.GetColor("Text"))
    end

    return entry
end
