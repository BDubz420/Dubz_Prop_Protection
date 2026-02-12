--[[
    DUIF - Dubz UI Framework
    File: autorun/duif.lua
    Purpose: Standalone addon loader (server AddCSLuaFile/resource provisioning + client bootstrap).
]]

if SERVER then
    local files = {
        "autorun/client/duif_autorun.lua",
        "duif/core/cl_init.lua",
        "duif/core/cl_theme.lua",
        "duif/core/cl_utils.lua",
        "duif/core/cl_fonts.lua",
        "duif/core/cl_animations.lua",
        "duif/components/cl_panel.lua",
        "duif/components/cl_button.lua",
        "duif/components/cl_toggle.lua",
        "duif/components/cl_closebutton.lua",
        "duif/components/cl_textentry.lua",
        "duif/components/cl_slider.lua",
        "duif/components/cl_dropdown.lua",
        "duif/components/cl_sidebar.lua",
        "duif/components/cl_card.lua",
        "duif/docs/cl_showcase.lua"
    }

    for _, path in ipairs(files) do
        AddCSLuaFile(path)
    end

    -- Optional bundled font distribution support.
    -- If you place fonts in resource/fonts or resource/fonts/duif, they will be sent to clients.
    local fontPatterns = {
        "resource/fonts/*.ttf",
        "resource/fonts/*.otf",
        "resource/fonts/duif/*.ttf",
        "resource/fonts/duif/*.otf"
    }

    for _, pattern in ipairs(fontPatterns) do
        local found = file.Find(pattern, "GAME") or {}
        local baseDir = string.GetPathFromFilename(pattern)

        for _, fileName in ipairs(found) do
            resource.AddFile(baseDir .. fileName)
        end
    end

    return
end

include("autorun/client/duif_autorun.lua")
