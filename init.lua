-- Dubz Prop Protection (DPP)
-- Bootstrap loader

DPP = DPP or {}
DPP.VERSION = "1.0.0-framework"
DPP.NAMESPACE = "DPP"

local SHARED_FILES = {
    "dpp/core/sh_core.lua",
    "dpp/core/sh_config.lua",
    "dpp/core/sh_permissions.lua",
    "dpp/core/sh_logger.lua",
    "dpp/core/sh_ownership.lua",
    "dpp/core/sh_registry.lua",
}

local SERVER_FILES = {
    "dpp/server/sv_network.lua",
    "dpp/server/sv_runtime.lua",
}

local CLIENT_FILES = {
    "dpp/client/cl_network.lua",
    "dpp/client/cl_dashboard.lua",
}

for _, path in ipairs(SHARED_FILES) do
    if SERVER then AddCSLuaFile(path) end
    include(path)
end

if SERVER then
    for _, path in ipairs(CLIENT_FILES) do
        AddCSLuaFile(path)
    end
    for _, path in ipairs(SERVER_FILES) do
        AddCSLuaFile(path)
        include(path)
    end
else
    for _, path in ipairs(CLIENT_FILES) do
        include(path)
    end
end
