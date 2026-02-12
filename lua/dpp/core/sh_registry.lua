DPP = DPP or {}
DPP.Registry = DPP.Registry or {}

function DPP.Registry:RegisterModule(name, def)
    DPP.State.modules[name] = def
end

function DPP.Registry:EnableHook(name, event, fn)
    local id = "DPP." .. name .. "." .. event
    if DPP.State.hooks[id] then return end
    hook.Add(event, id, fn)
    DPP.State.hooks[id] = true
end

function DPP.Registry:DisableHook(name, event)
    local id = "DPP." .. name .. "." .. event
    hook.Remove(event, id)
    DPP.State.hooks[id] = nil
end
