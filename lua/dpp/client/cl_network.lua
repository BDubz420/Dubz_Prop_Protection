DPP = DPP or {}
DPP.Client = DPP.Client or {}
DPP.Client.Live = DPP.Client.Live or { violations = 0, actions = 0, entitiesProcessed = 0 }

local function sendAction(action, payload)
    net.Start(DPP.NET.ACTION)
    net.WriteString(action)
    net.WriteString(payload or "")
    net.SendToServer()
end

DPP.Client.SendAction = sendAction

net.Receive(DPP.NET.CONFIG_SYNC, function()
    local payload = net.ReadString()
    local tbl = util.JSONToTable(payload or "")
    if istable(tbl) then
        DPP.Config = tbl
    end
end)

net.Receive(DPP.NET.LIVE_STATS, function()
    DPP.Client.Live.violations = net.ReadUInt(20)
    DPP.Client.Live.actions = net.ReadUInt(20)
    DPP.Client.Live.entitiesProcessed = net.ReadUInt(24)
end)
