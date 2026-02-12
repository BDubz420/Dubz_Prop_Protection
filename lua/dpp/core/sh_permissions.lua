DPP = DPP or {}

DPP.Permissions = DPP.Permissions or {}

function DPP.Permissions:GetPrimaryGroup(ply)
    if not IsValid(ply) then return "console" end
    if ply.GetUserGroup then return string.lower(ply:GetUserGroup() or "user") end
    return "user"
end

function DPP.Permissions:IsBypassGroup(ply, groups)
    if not istable(groups) then return false end
    local group = self:GetPrimaryGroup(ply)
    for _, g in ipairs(groups) do
        if group == string.lower(g) then return true end
    end
    return false
end

function DPP.Permissions:CanAccessFeature(ply, featurePath)
    if not IsValid(ply) then return true end
    if ply:IsSuperAdmin() then return true end

    local overrides = DPP.Config.permissions.perFeatureGroupOverride or {}
    local required = overrides[featurePath]
    if not required then return ply:IsAdmin() end

    return self:IsBypassGroup(ply, required)
end
