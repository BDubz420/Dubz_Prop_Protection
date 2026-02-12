DUIF = DUIF or {}

function DUIF.BuildFonts()
    surface.CreateFont("DUIF.Title", {
        font = "Roboto",
        size = 28,
        weight = 700,
        antialias = true,
        extended = true
    })

    surface.CreateFont("DUIF.Subtitle", {
        font = "Roboto",
        size = 22,
        weight = 600,
        antialias = true,
        extended = true
    })

    surface.CreateFont("DUIF.Body", {
        font = "Roboto",
        size = 18,
        weight = 500,
        antialias = true,
        extended = true
    })

    surface.CreateFont("DUIF.Small", {
        font = "Roboto",
        size = 15,
        weight = 450,
        antialias = true,
        extended = true
    })

    surface.CreateFont("DUIF.Mono", {
        font = "Roboto Mono",
        size = 15,
        weight = 500,
        antialias = true,
        extended = true
    })
end

DUIF.BuildFonts()
hook.Add("OnScreenSizeChanged", "DUIF.RebuildFonts", DUIF.BuildFonts)
