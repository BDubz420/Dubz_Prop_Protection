if SERVER then
    local files = {
        "autorun/client/duif_autorun.lua",
        "duif/core/cl_init.lua",
        "duif/core/cl_theme.lua",
        "duif/core/cl_utils.lua",
        "duif/core/cl_fonts.lua",
        "duif/core/cl_animations.lua",
        "duif/components/cl_panel.lua",
        "duif/components/cl_card.lua",
        "duif/components/cl_button.lua",
        "duif/components/cl_toggle.lua",
        "duif/components/cl_closebutton.lua",
        "duif/components/cl_textentry.lua",
        "duif/components/cl_slider.lua",
        "duif/components/cl_dropdown.lua",
        "duif/components/cl_sidebar.lua",
        "duif/docs/cl_showcase.lua"
    }

    for _, filePath in ipairs(files) do
        AddCSLuaFile(filePath)
    end

    return
end

include("autorun/client/duif_autorun.lua")
