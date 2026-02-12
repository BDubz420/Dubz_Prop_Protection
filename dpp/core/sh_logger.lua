DPP = DPP or {}
DPP.Log = DPP.Log or {}

DPP.Log.ActionHistory = DPP.Log.ActionHistory or {}
DPP.Log.ViolationHistory = DPP.Log.ViolationHistory or {}
DPP.Log.LastStaffNotify = DPP.Log.LastStaffNotify or {}

local function push_limited(buffer, item, max)
    buffer[#buffer + 1] = item
    if #buffer > max then
        table.remove(buffer, 1)
    end
end

function DPP.Log:Write(kind, msg, actor)
    if not DPP.Config.logging.enabled then return end

    local entry = {
        time = os.time(),
        kind = kind,
        msg = msg,
        actor = IsValid(actor) and actor:Nick() or tostring(actor or "system"),
    }

    local isViolation = kind == "violation"
    local max = isViolation and DPP.Config.logging.violationHistorySize or DPP.Config.logging.actionHistorySize
    push_limited(isViolation and self.ViolationHistory or self.ActionHistory, entry, max)

    if SERVER and DPP.Config.logging.consoleLogging then
        print(string.format("[DPP][%s] %s :: %s", string.upper(kind), entry.actor, msg))
    end

    if SERVER and DPP.Config.logging.fileLogging then
        file.CreateDir("dpp")
        file.Append("dpp/history.log", string.format("%d|%s|%s|%s\n", entry.time, kind, entry.actor, msg))
    end
end

function DPP.Log:NotifyStaff(key, text)
    if not SERVER then return end
    local throttle = DPP.Config.core.notifyThrottleSeconds or 3
    local now = CurTime()
    if (self.LastStaffNotify[key] or 0) + throttle > now then return end
    self.LastStaffNotify[key] = now

    for _, ply in ipairs(player.GetHumans()) do
        if ply:IsAdmin() then
            DPP:Msg(ply, text)
        end
    end
end
