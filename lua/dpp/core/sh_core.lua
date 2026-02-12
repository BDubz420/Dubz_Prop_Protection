DPP = DPP or {}

DPP.NET = {
    CONFIG_SYNC = "dpp_config_sync",
    ACTION = "dpp_action",
    LOG_STREAM = "dpp_log_stream",
    LIVE_STATS = "dpp_live_stats",
}

DPP.State = DPP.State or {
    startTime = os.time(),
    modules = {},
    hooks = {},
    stats = {
        violations = 0,
        actions = 0,
        entitiesProcessed = 0,
        lastCleanupBatch = 0,
    },
}

function DPP:DeepCopy(value)
    if not istable(value) then return value end
    local out = {}
    for k, v in pairs(value) do
        out[k] = self:DeepCopy(v)
    end
    return out
end

function DPP:Merge(dst, src)
    for k, v in pairs(src) do
        if istable(v) then
            dst[k] = dst[k] or {}
            self:Merge(dst[k], v)
        elseif dst[k] == nil then
            dst[k] = v
        end
    end
    return dst
end

function DPP:IsEnabled(path)
    if not self.Config then return false end
    if self.Config.core and self.Config.core.masterEnable == false then return false end
    if not path then return true end

    local node = self.Config
    for token in string.gmatch(path, "[^%.]+") do
        if not istable(node) then return false end
        node = node[token]
    end

    if istable(node) and node.enabled ~= nil then
        return node.enabled == true
    end

    return node ~= false and node ~= nil
end

function DPP:Msg(target, msg)
    local text = string.format("[%s] %s", self.NAMESPACE or "DPP", msg)
    if SERVER then
        if IsValid(target) then
            target:ChatPrint(text)
        else
            print(text)
        end
    else
        chat.AddText(Color(72, 154, 255), "[DPP] ", color_white, msg)
    end
end
