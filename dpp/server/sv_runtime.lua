DPP = DPP or {}

local SpawnTracker = {}

local function id64(ply)
    return ply:SteamID64() or ply:SteamID() or ply:Nick()
end

local function in_list(val, tbl)
    return istable(tbl) and tbl[string.lower(tostring(val or ""))] == true
end

local function markSpawn(ply)
    local key = id64(ply)
    local cfg = DPP.Config.spamProtection
    local now = CurTime()

    SpawnTracker[key] = SpawnTracker[key] or { list = {}, last = 0 }
    local data = SpawnTracker[key]

    if (now - data.last) < (cfg.debounceWindow or 0.1) then
        return #data.list
    end

    data.last = now
    table.insert(data.list, now)

    local cutoff = now - (cfg.spawnDelay or 1)
    for i = #data.list, 1, -1 do
        if data.list[i] < cutoff then
            table.remove(data.list, i)
        end
    end

    return #data.list
end

local function isBypass(ply, section)
    if not IsValid(ply) then return true end
    local groups = DPP.Config[section] and DPP.Config[section].bypassGroups
    return DPP.Permissions:IsBypassGroup(ply, groups)
end

local function shouldBlockSpawn(ply, className, model)
    if not DPP:IsEnabled("spawnRestriction") or isBypass(ply, "spawnRestriction") then return false end
    local cfg = DPP.Config.spawnRestriction

    local cls = string.lower(className or "")
    local mdl = string.lower(model or "")

    if cfg.blockedClassesAsBlacklist and in_list(cls, cfg.blockedSENTs) then return true end
    if cfg.blockedModelsAsBlacklist and in_list(mdl, cfg.blockedModels) then return true end

    return false
end

local function spamTriggered(ply)
    if not DPP:IsEnabled("spamProtection") then return false end
    return markSpawn(ply) > (DPP.Config.spamProtection.spawnThreshold or 66)
end

DPP.Registry:EnableHook("Ownership", "PlayerSpawnedProp", function(ply, _, ent)
    DPP.Ownership:SetOwner(ent, ply)
    if DPP.Config.miscs.freezeOnSpawn and ent.GetPhysicsObject then
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then phys:EnableMotion(false) end
    end
end)

DPP.Registry:EnableHook("Spawn", "PlayerSpawnProp", function(ply, model)
    if shouldBlockSpawn(ply, "prop_physics", model) then return false end
    if spamTriggered(ply) then
        DPP.Log:Write("violation", "Prop spam threshold exceeded", ply)
        DPP.State.stats.violations = DPP.State.stats.violations + 1
        DPP.Log:NotifyStaff("spam_prop_" .. id64(ply), ply:Nick() .. " exceeded prop spam threshold")
        return false
    end
end)

DPP.Registry:EnableHook("Spawn", "PlayerSpawnSENT", function(ply, class)
    if shouldBlockSpawn(ply, class, nil) then return false end
    if spamTriggered(ply) then return false end
end)

DPP.Registry:EnableHook("Toolgun", "CanTool", function(ply, tr, tool)
    if not DPP:IsEnabled("toolgun") then return end
    if isBypass(ply, "toolgun") then return end

    if in_list(tool, DPP.Config.toolgun.restrictedTools) then
        DPP.Log:Write("violation", "Restricted tool used: " .. tostring(tool), ply)
        DPP.State.stats.violations = DPP.State.stats.violations + 1
        return false
    end

    local ent = tr.Entity
    if IsValid(ent) and not DPP.Ownership:CanInteract(ply, ent) and not DPP.Config.toolgun.canTargetPlayerOwnedEntities then
        return false
    end
end)

DPP.Registry:EnableHook("Physgun", "PhysgunPickup", function(ply, ent)
    if not DPP:IsEnabled("physgun") then return end
    if isBypass(ply, "physgun") then return end

    if IsValid(ent) and not DPP.Ownership:CanInteract(ply, ent) and not DPP.Config.physgun.canTargetPlayerOwnedEntities then
        DPP.State.stats.violations = DPP.State.stats.violations + 1
        return false
    end

    if DPP.Config.ghosting.ghostOnPhysgun and IsValid(ent) then
        local c = DPP.Config.ghosting.color
        ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
        ent:SetColor(Color(c.r, c.g, c.b, c.a))
    end
end)

DPP.Registry:EnableHook("Physgun", "PhysgunDrop", function(_, ent)
    if DPP.Config.physgun.stopMotionOnDrop and IsValid(ent) and ent.GetPhysicsObject then
        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then phys:SetVelocityInstantaneous(vector_origin) end
    end
end)

DPP.Registry:EnableHook("Damage", "EntityTakeDamage", function(ent, dmg)
    if not DPP:IsEnabled("damage") or not IsValid(ent) then return end
    local cfg = DPP.Config.damage

    if cfg.disableVehicleDamage and ent:IsVehicle() then
        dmg:SetDamage(0)
        return true
    end

    if cfg.disableWorldDamage and not IsValid(DPP.Ownership:GetOwner(ent)) then
        dmg:SetDamage(0)
        return true
    end

    if cfg.disableBlacklistedEntityDamage and in_list(ent:GetClass(), cfg.blacklistedEntities) then
        dmg:SetDamage(0)
        return true
    end
end)

DPP.Registry:EnableHook("Property", "CanProperty", function(ply, property, ent)
    if not DPP:IsEnabled("canProperty") or isBypass(ply, "canProperty") then return end

    local cfg = DPP.Config.canProperty
    local listed = in_list(property, cfg.blockedProperties)
    local blocked = cfg.blockedPropertiesAsBlacklist and listed or not listed
    if blocked then return false end

    if IsValid(ent) and not DPP.Ownership:CanInteract(ply, ent) and not cfg.canTargetPlayerOwnedEntities then
        return false
    end
end)

DPP.Registry:EnableHook("DisconnectCleanup", "PlayerDisconnected", function(ply)
    if not DPP.Config.general.globalPropActions.removeDisconnectedEntities then return end

    local sid = id64(ply)
    timer.Simple(DPP.Config.general.globalPropActions.removeDisconnectTimerSeconds, function()
        local queue = {}
        for _, ent in ipairs(ents.GetAll()) do
            local owner = DPP.Ownership:GetOwner(ent)
            if IsValid(owner) and id64(owner) == sid then
                queue[#queue + 1] = ent
            end
        end

        local batchSize = DPP.Config.core.asyncCleanupBatchSize or 100
        local idx = 1
        timer.Create("DPP.CleanupBatch." .. sid, 0.05, 0, function()
            for _ = 1, batchSize do
                if idx > #queue then
                    timer.Remove("DPP.CleanupBatch." .. sid)
                    DPP.State.stats.lastCleanupBatch = #queue
                    return
                end
                if IsValid(queue[idx]) then queue[idx]:Remove() end
                idx = idx + 1
                DPP.State.stats.entitiesProcessed = DPP.State.stats.entitiesProcessed + 1
            end
        end)
    end)
end)

timer.Create("DPP.ClearDecals", 1, 0, function()
    if not DPP:IsEnabled("miscs") then return end
    local t = DPP.Config.miscs.clearDecalsTimer
    if not t or t <= 0 then return end

    DPP._nextDecal = DPP._nextDecal or (CurTime() + t)
    if CurTime() >= DPP._nextDecal then
        game.ConsoleCommand("r_cleardecals\n")
        DPP._nextDecal = CurTime() + t
    end
end)
