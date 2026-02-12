DPP = DPP or {}

DPP.Ownership = DPP.Ownership or {
    cache = {},
    trust = {},
    tempTrust = {},
}

local M = DPP.Ownership

function M:GetOwner(ent)
    if not IsValid(ent) then return nil end

    local idx = ent:EntIndex()
    local cached = self.cache[idx]
    if IsValid(cached) then return cached end

    if ent.CPPIGetOwner then
        local owner = ent:CPPIGetOwner()
        if IsValid(owner) then
            self.cache[idx] = owner
            return owner
        end
    end

    local owner = ent.GetOwner and ent:GetOwner() or nil
    if IsValid(owner) and owner:IsPlayer() then
        self.cache[idx] = owner
        return owner
    end

    if IsValid(ent.DPP_Owner) then
        self.cache[idx] = ent.DPP_Owner
        return ent.DPP_Owner
    end

    return nil
end

function M:SetOwner(ent, ply)
    if not IsValid(ent) or not IsValid(ply) then return end
    ent.DPP_Owner = ply
    self.cache[ent:EntIndex()] = ply
end

function M:CanInteract(ply, ent)
    if not IsValid(ply) or not IsValid(ent) then return false end
    if ply:IsSuperAdmin() then return true end

    local owner = self:GetOwner(ent)
    if not IsValid(owner) then return DPP.Config.toolgun.canTargetWorldEntities end
    if owner == ply then return true end

    local ownerId = owner:SteamID64() or owner:SteamID()
    local plyId = ply:SteamID64() or ply:SteamID()

    if self.trust[ownerId] and self.trust[ownerId][plyId] then return true end

    local expiry = self.tempTrust[ownerId] and self.tempTrust[ownerId][plyId]
    if expiry and expiry > os.time() then return true end

    if DPP.Config.ownership.teamBasedTrust and owner:Team() == ply:Team() then return true end

    return false
end

function M:SetTrust(owner, target, trusted, minutes)
    if not IsValid(owner) or not IsValid(target) then return end
    local ownerId = owner:SteamID64() or owner:SteamID()
    local targetId = target:SteamID64() or target:SteamID()

    self.trust[ownerId] = self.trust[ownerId] or {}
    self.tempTrust[ownerId] = self.tempTrust[ownerId] or {}

    self.trust[ownerId][targetId] = trusted and true or nil
    if trusted and minutes and minutes > 0 then
        self.tempTrust[ownerId][targetId] = os.time() + (minutes * 60)
    else
        self.tempTrust[ownerId][targetId] = nil
    end

    DPP.Log:Write("action", string.format("Trust update: %s -> %s (%s)", owner:Nick(), target:Nick(), tostring(trusted)), owner)
end
