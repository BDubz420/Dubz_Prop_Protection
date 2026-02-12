DUIF = DUIF or {}

DUIF.Themes = DUIF.Themes or {}

DUIF.Themes.default = {
    Background = Color(20, 24, 35),
    Panel = Color(28, 34, 50),
    PanelLight = Color(35, 43, 63),
    Accent = Color(88, 101, 242),
    AccentAlt = Color(0, 200, 170),
    AccentBlue = Color(54, 162, 235),
    TextPrimary = Color(240, 240, 240),
    TextSecondary = Color(150, 160, 180),
    Danger = Color(220, 70, 70),
    Success = Color(50, 200, 120),
    Warning = Color(240, 170, 50),
    Outline = Color(73, 86, 122, 200),
    Shadow = Color(0, 0, 0, 140)
}

DUIF.Themes.purple = {
    Background = Color(20, 21, 32),
    Panel = Color(31, 30, 46),
    PanelLight = Color(44, 41, 65),
    Accent = Color(124, 92, 255),
    AccentAlt = Color(167, 93, 255),
    AccentBlue = Color(99, 132, 255),
    TextPrimary = Color(242, 236, 255),
    TextSecondary = Color(172, 164, 205),
    Danger = Color(224, 85, 106),
    Success = Color(73, 214, 156),
    Warning = Color(244, 179, 80),
    Outline = Color(105, 96, 138, 200),
    Shadow = Color(0, 0, 0, 150)
}

DUIF.ThemeName = DUIF.ThemeName or "default"
DUIF.Theme = table.Copy(DUIF.Themes[DUIF.ThemeName])

function DUIF.GetTheme(name)
    return DUIF.Themes[name]
end

function DUIF.RegisterTheme(name, themeData)
    if not isstring(name) or not istable(themeData) then return end
    DUIF.Themes[name] = table.Copy(themeData)
end

function DUIF.SetTheme(name)
    local newTheme = DUIF.Themes[name]
    if not newTheme then return false end

    DUIF.ThemeName = name
    DUIF.Theme = table.Copy(newTheme)

    hook.Run("DUIF.ThemeChanged", name, DUIF.Theme)
    return true
end
