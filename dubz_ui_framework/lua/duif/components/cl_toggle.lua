--[[
    DUIF - Dubz UI Framework
    File: cl_toggle.lua
    Purpose: Modern animated toggle switch with callback support and glow state.
]]

DUIF = DUIF or {}

function DUIF.CreateToggle(parent, defaultValue, opts)
    opts = DUIF.MergeOptions({
        w = 56,
        h = 28,
        onColor = nil,
        offColor = Color(95, 104, 130),
        onChanged = nil
    }, opts)

    local toggle = vgui.Create("DButton", parent)
    toggle:SetText("")
    toggle:SetSize(opts.w, opts.h)
    toggle.Value = tobool(defaultValue)
    toggle.Anim = toggle.Value and 1 or 0

    function toggle:SetValue(v, skipCallback)
        self.Value = tobool(v)
        if not skipCallback then
            if isfunction(self.OnChanged) then self:OnChanged(self.Value) end
            if isfunction(opts.onChanged) then opts.onChanged(self, self.Value) end
        end
    end

    function toggle:GetValue()
        return self.Value
    end

    toggle.DoClick = function(self)
        self:SetValue(not self.Value)
    end

    toggle.Paint = function(self, w, h)
        self.Anim = Lerp(FrameTime() * 12, self.Anim, self.Value and 1 or 0)

        local onColor = opts.onColor or DUIF.GetColor("AccentAlt")
        local bg = DUIF.LerpColor(self.Anim, opts.offColor, onColor)

        DUIF.DrawRoundedBox(h * 0.5, 0, 0, w, h, bg)

        if self.Anim > 0.2 then
            DUIF.DrawRoundedBox(h * 0.5, 0, 0, w, h, Color(onColor.r, onColor.g, onColor.b, 45 * self.Anim))
        end

        local k = 2 + ((w - h) * self.Anim)
        DUIF.DrawRoundedBox((h - 4) * 0.5, k, 2, h - 4, h - 4, Color(245, 247, 252))
    end

    return toggle
end
