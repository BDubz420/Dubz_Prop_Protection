DUIF = DUIF or {}

function DUIF.Animate(panel, property, target, duration, onComplete)
    if not IsValid(panel) then return end

    local startValue = panel[property]
    if startValue == nil then return end

    local startTime = CurTime()
    local endTime = startTime + (duration or 0.2)

    panel.Think = panel.Think or function() end
    local oldThink = panel.Think

    panel.Think = function(self)
        if oldThink then oldThink(self) end

        local now = CurTime()
        local frac = math.TimeFraction(startTime, endTime, now)
        frac = math.Clamp(frac, 0, 1)
        frac = math.ease.InOutQuad(frac)

        self[property] = Lerp(frac, startValue, target)

        if frac >= 1 then
            self[property] = target
            if isfunction(onComplete) then
                onComplete(self)
            end

            self.Think = oldThink
        end
    end
end

function DUIF.FadeIn(panel, duration)
    if not IsValid(panel) then return end

    panel:SetAlpha(0)
    panel:AlphaTo(255, duration or 0.18, 0)
end

function DUIF.SlideIn(panel, fromX, fromY, duration)
    if not IsValid(panel) then return end

    local targetX, targetY = panel:GetPos()
    panel:SetPos(fromX or targetX, fromY or targetY)
    panel:MoveTo(targetX, targetY, duration or 0.22, 0, -1)
end
