--[[
    DUIF - Dubz UI Framework
    File: cl_fonts.lua
    Purpose: Centralized DUIF font creation with bundled-font detection and fallback chains.
]]

DUIF = DUIF or {}

DUIF.FontConfig = DUIF.FontConfig or {
    -- Optional explicit overrides (set before DUIF loads):
    -- SansFamily = "Your Font Name",
    -- MonoFamily = "Your Mono Font Name",

    SansFallbacks = {
        "Inter",
        "Poppins",
        "Roboto",
        "Segoe UI",
        "Tahoma",
        "Arial"
    },

    MonoFallbacks = {
        "JetBrains Mono",
        "Roboto Mono",
        "Consolas",
        "Courier New"
    },

    -- Common directories where addons place downloadable font files.
    ScanPaths = {
        "resource/fonts/*.ttf",
        "resource/fonts/*.otf",
        "resource/fonts/duif/*.ttf",
        "resource/fonts/duif/*.otf",
        "materials/fonts/*.ttf",
        "materials/fonts/*.otf",
        "materials/fonts/duif/*.ttf",
        "materials/fonts/duif/*.otf"
    }
}

local function filenameToFace(path)
    local name = string.GetFileFromFilename(path)
    name = string.StripExtension(name or "")

    if name == "" then return nil end
    return name
end

local function collectBundledFaces()
    local faces = {}

    for _, pattern in ipairs(DUIF.FontConfig.ScanPaths or {}) do
        local files = file.Find(pattern, "GAME") or {}

        for _, fname in ipairs(files) do
            local guess = filenameToFace(fname)
            if guess then
                faces[#faces + 1] = guess
            end
        end
    end

    return faces
end

local function chooseFamily(overrideName, bundled, fallback)
    if isstring(overrideName) and overrideName ~= "" then
        return overrideName
    end

    if #bundled > 0 then
        return bundled[1]
    end

    return fallback[1]
end

function DUIF.BuildFonts(scale)
    scale = scale or 1

    local bundledFaces = collectBundledFaces()
    local sans = chooseFamily(DUIF.FontConfig.SansFamily, bundledFaces, DUIF.FontConfig.SansFallbacks)
    local mono = chooseFamily(DUIF.FontConfig.MonoFamily, bundledFaces, DUIF.FontConfig.MonoFallbacks)

    surface.CreateFont("DUIF.Title", {
        font = sans,
        size = math.floor(30 * scale),
        weight = 800,
        antialias = true,
        extended = true
    })

    surface.CreateFont("DUIF.Header", {
        font = sans,
        size = math.floor(22 * scale),
        weight = 700,
        antialias = true,
        extended = true
    })

    surface.CreateFont("DUIF.Body", {
        font = sans,
        size = math.floor(17 * scale),
        weight = 520,
        antialias = true,
        extended = true
    })

    surface.CreateFont("DUIF.Small", {
        font = sans,
        size = math.floor(14 * scale),
        weight = 460,
        antialias = true,
        extended = true
    })

    surface.CreateFont("DUIF.Mono", {
        font = mono,
        size = math.floor(14 * scale),
        weight = 500,
        antialias = true,
        extended = true
    })
end

DUIF.BuildFonts()

hook.Add("OnScreenSizeChanged", "DUIF.RebuildFonts", function()
    DUIF.BuildFonts()
end)
