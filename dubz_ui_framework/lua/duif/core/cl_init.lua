--[[
    DUIF - Dubz UI Framework
    File: cl_init.lua
    Purpose: Client entrypoint that loads all DUIF modules in a deterministic order.
]]

DUIF = DUIF or {}
DUIF.Version = DUIF.Version or "0.2.0"
DUIF.Loaded = DUIF.Loaded or false

local files = {
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
    include(path)
end

DUIF.Loaded = true
hook.Run("DUIF.Loaded", DUIF.Version)
