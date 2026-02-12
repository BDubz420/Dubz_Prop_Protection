--[[
    DUIF - Dubz UI Framework
    File: cl_animations.lua
    Purpose: Lightweight animation scheduler for property, fade, and slide transitions.
]]

DUIF = DUIF or {}
DUIF._Animations = DUIF._Animations or {}

local function queueAnimation(panel, key, build)
    if not IsValid(panel) then return end

    panel._duifAnimId = panel._duifAnimId or tostring(panel)
    local id = panel._duifAnimId .. "_" .. key
    DUIF._Animations[id] = build()
end

hook.Add("Think", "DUIF.AnimationRunner", function()
    local now = CurTime()

    for id, anim in pairs(DUIF._Animations) do
        if not IsValid(anim.panel) then
            DUIF._Animations[id] = nil
        else
            local t = math.TimeFraction(anim.startTime, anim.endTime, now)
            t = math.Clamp(t, 0, 1)
            t = math.ease.InOutQuad(t)

            anim.update(anim.panel, t)

            if t >= 1 then
                if isfunction(anim.onComplete) then
                    anim.onComplete(anim.panel)
                end
                DUIF._Animations[id] = nil
            end
        end
    end
end)

function DUIF.Animate(panel, property, target, duration, onComplete)
    local startValue = panel and panel[property]
    if not IsValid(panel) or startValue == nil then return false end

    local start = CurTime()
    local finish = start + (duration or 0.18)

    queueAnimation(panel, "prop_" .. property, function()
        return {
            panel = panel,
            startTime = start,
            endTime = finish,
            onComplete = onComplete,
            update = function(pnl, frac)
                pnl[property] = Lerp(frac, startValue, target)
            end
        }
    end)

    return true
end

function DUIF.Fade(panel, from, to, duration, onComplete)
    if not IsValid(panel) then return false end

    local start = CurTime()
    local finish = start + (duration or 0.15)
    panel:SetAlpha(from)

    queueAnimation(panel, "fade", function()
        return {
            panel = panel,
            startTime = start,
            endTime = finish,
            onComplete = onComplete,
            update = function(pnl, frac)
                pnl:SetAlpha(Lerp(frac, from, to))
            end
        }
    end)

    return true
end

function DUIF.Slide(panel, fromPos, toPos, duration, onComplete)
    if not IsValid(panel) then return false end

    local fromX, fromY = fromPos.x or fromPos[1], fromPos.y or fromPos[2]
    local toX, toY = toPos.x or toPos[1], toPos.y or toPos[2]

    panel:SetPos(fromX, fromY)

    local start = CurTime()
    local finish = start + (duration or 0.2)

    queueAnimation(panel, "slide", function()
        return {
            panel = panel,
            startTime = start,
            endTime = finish,
            onComplete = onComplete,
            update = function(pnl, frac)
                pnl:SetPos(Lerp(frac, fromX, toX), Lerp(frac, fromY, toY))
            end
        }
    end)

    return true
end
