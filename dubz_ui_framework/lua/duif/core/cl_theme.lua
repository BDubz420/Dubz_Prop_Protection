--[[
    DUIF - Dubz UI Framework
    File: cl_theme.lua
    Purpose: Theme registry, runtime theme switching, and dynamic color access.
]]

DUIF = DUIF or {}
DUIF.Themes = DUIF.Themes or {}

DUIF.Themes.dark = {
    Background = Color(20, 24, 35),
    Surface = Color(28, 34, 50),
    SurfaceAlt = Color(35, 43, 63),
    Border = Color(72, 86, 122, 200),
    Accent = Color(88, 101, 242),
    AccentAlt = Color(0, 200, 170),
    AccentBlue = Color(66, 153, 225),
    Text = Color(240, 240, 240),
    TextMuted = Color(150, 160, 180),
    Danger = Color(220, 70, 70),
    Success = Color(50, 200, 120),
    Warning = Color(240, 170, 50),
    Shadow = Color(0, 0, 0, 150)
}

DUIF.Themes.light = {
    Background = Color(238, 242, 252),
    Surface = Color(255, 255, 255),
    SurfaceAlt = Color(230, 236, 248),
    Border = Color(180, 193, 220, 200),
    Accent = Color(63, 94, 251),
    AccentAlt = Color(0, 176, 155),
    AccentBlue = Color(42, 138, 246),
    Text = Color(32, 40, 62),
    TextMuted = Color(105, 115, 138),
    Danger = Color(210, 66, 84),
    Success = Color(24, 177, 108),
    Warning = Color(228, 155, 37),
    Shadow = Color(0, 0, 0, 70)
}

DUIF.Themes.neon = {
    Background = Color(14, 17, 29),
    Surface = Color(22, 29, 48),
    SurfaceAlt = Color(34, 44, 70),
    Border = Color(94, 106, 152, 210),
    Accent = Color(0, 194, 255),
    AccentAlt = Color(144, 79, 255),
    AccentBlue = Color(60, 138, 255),
    Text = Color(235, 245, 255),
    TextMuted = Color(141, 158, 193),
    Danger = Color(255, 94, 113),
    Success = Color(74, 226, 170),
    Warning = Color(255, 189, 92),
    Shadow = Color(0, 0, 0, 165)
}

DUIF.ThemeName = DUIF.ThemeName or "dark"
DUIF.Theme = table.Copy(DUIF.Themes[DUIF.ThemeName])

function DUIF.RegisterTheme(name, data)
    if not isstring(name) or not istable(data) then return false end
    DUIF.Themes[name] = table.Copy(data)
    return true
end

function DUIF.SetTheme(name)
    local theme = DUIF.Themes[name]
    if not theme then return false end

    DUIF.ThemeName = name
    DUIF.Theme = table.Copy(theme)

    hook.Run("DUIF.ThemeChanged", name, DUIF.Theme)
    return true
end

function DUIF.GetTheme(name)
    return DUIF.Themes[name or DUIF.ThemeName]
end

function DUIF.GetColor(key, fallback)
    local col = DUIF.Theme and DUIF.Theme[key]
    if col then return col end
    return fallback or color_white
end
