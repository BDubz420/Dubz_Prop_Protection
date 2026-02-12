DPP = DPP or {}

util.AddNetworkString(DPP.NET.CONFIG_SYNC)
util.AddNetworkString(DPP.NET.ACTION)
util.AddNetworkString(DPP.NET.LOG_STREAM)
util.AddNetworkString(DPP.NET.LIVE_STATS)

local function syncConfig(target)
    net.Start(DPP.NET.CONFIG_SYNC)
    net.WriteString(util.TableToJSON(DPP.Config) or "{}")
    if IsValid(target) then net.Send(target) else net.Broadcast() end
end

local function broadcastStats()
    if not DPP.Config.logging.liveMonitorEnabled then return end
    net.Start(DPP.NET.LIVE_STATS)
    net.WriteUInt(DPP.State.stats.violations or 0, 20)
    net.WriteUInt(DPP.State.stats.actions or 0, 20)
    net.WriteUInt(DPP.State.stats.entitiesProcessed or 0, 24)
    net.Broadcast()
end

timer.Create("DPP.LiveStats", 2, 0, broadcastStats)

hook.Add("PlayerInitialSpawn", "DPP.SyncConfig", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then syncConfig(ply) end
    end)
end)

concommand.Add("dpp_menu", function(ply)
    if not IsValid(ply) then return end
    if not DPP.Permissions:CanAccessFeature(ply, "ui.menu") then return end
    syncConfig(ply)
    net.Start(DPP.NET.ACTION)
    net.WriteString("open_ui")
    net.WriteString("")
    net.Send(ply)
end)

net.Receive(DPP.NET.ACTION, function(_, ply)
    if not IsValid(ply) then return end
    local action = net.ReadString()
    local payload = net.ReadString()

    if action == "save_config" then
        if not DPP.Permissions:CanAccessFeature(ply, "config.save") then return end
        local incoming = util.JSONToTable(payload or "")
        if not istable(incoming) then return end

        DPP.Config = incoming
        DPP:Merge(DPP.Config, DPP.DefaultConfig)
        DPP.Log:Write("action", "Configuration saved", ply)
        DPP.State.stats.actions = (DPP.State.stats.actions or 0) + 1
        syncConfig()
        return
    end

    if action == "quick_action" then
        if not DPP.Permissions:CanAccessFeature(ply, "admin.quick_action") then return end

        if payload == "ghost_all" then
            for _, ent in ipairs(ents.GetAll()) do
                if IsValid(ent) and ent:GetClass() == "prop_physics" then
                    local c = DPP.Config.ghosting.color
                    ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
                    ent:SetColor(Color(c.r, c.g, c.b, c.a))
                end
            end
        elseif payload == "freeze_all" then
            for _, ent in ipairs(ents.GetAll()) do
                if IsValid(ent) and ent.GetPhysicsObject then
                    local phys = ent:GetPhysicsObject()
                    if IsValid(phys) then phys:EnableMotion(false) end
                end
            end
        elseif payload == "remove_owned" then
            for _, ent in ipairs(ents.GetAll()) do
                if IsValid(ent) and IsValid(DPP.Ownership:GetOwner(ent)) then
                    ent:Remove()
                end
            end
        end

        DPP.Log:Write("action", "Quick action: " .. payload, ply)
        DPP.State.stats.actions = (DPP.State.stats.actions or 0) + 1
    end
end)
