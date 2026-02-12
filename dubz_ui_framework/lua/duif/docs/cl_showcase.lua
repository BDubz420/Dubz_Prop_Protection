DUIF = DUIF or {}

local function sectionHeader(parent, title, description)
    local pnl = vgui.Create("DPanel", parent)
    pnl:Dock(TOP)
    pnl:SetTall(54)
    pnl:DockMargin(0, 0, 0, 8)
    pnl.Paint = function(_, w, h)
        draw.SimpleText(title, "DUIF.Subtitle", 0, 2, DUIF.Theme.TextPrimary, TEXT_ALIGN_LEFT)
        draw.SimpleText(description or "", "DUIF.Small", 0, 30, DUIF.Theme.TextSecondary, TEXT_ALIGN_LEFT)
    end

    return pnl
end

local function codeBlock(parent, code)
    local pnl = vgui.Create("DPanel", parent)
    pnl:Dock(TOP)
    pnl:SetTall(48)
    pnl:DockMargin(0, 6, 0, 12)
    pnl.Paint = function(self, w, h)
        DUIF.DrawRoundedBox(8, 0, 0, w, h, DUIF.Theme.Background)
        draw.SimpleText(code, "DUIF.Mono", 10, h * 0.5, DUIF.Theme.TextSecondary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    return pnl
end

local function buildShowcase(frame)
    local sidebar = DUIF.CreateSidebar(frame)
    local contentWrap = vgui.Create("DPanel", frame)
    contentWrap:Dock(FILL)
    contentWrap:DockMargin(12, 60, 12, 12)
    contentWrap.Paint = nil

    local scroller = vgui.Create("DScrollPanel", contentWrap)
    scroller:Dock(FILL)

    sidebar:AddItem("Default Theme", function() DUIF.SetTheme("default") end)
    sidebar:AddItem("Purple Theme", function() DUIF.SetTheme("purple") end)

    sectionHeader(scroller, "Buttons", "Primary, secondary, danger, success, ghost, gradient styles")
    local buttonRow = vgui.Create("DPanel", scroller)
    buttonRow:Dock(TOP)
    buttonRow:SetTall(40)
    buttonRow.Paint = nil

    local styles = { "primary", "secondary", "danger", "success", "ghost", "gradient" }
    for _, style in ipairs(styles) do
        local btn = DUIF.CreateButton(buttonRow, style, style)
        btn:Dock(LEFT)
        btn:DockMargin(0, 0, 8, 0)
        btn:SetWide(112)
    end

    codeBlock(scroller, 'DUIF.CreateButton(parent, "Confirm", "primary")')

    sectionHeader(scroller, "Toggle", "Animated toggle with OnChanged callback")
    local toggleContainer = DUIF.CreatePanel(scroller, TOP)
    toggleContainer:SetTall(48)
    toggleContainer:DockMargin(0, 0, 0, 6)

    local toggle = DUIF.CreateToggle(toggleContainer, true)
    toggle:SetPos(10, 10)
    toggle.OnChanged = function(val)
        chat.AddText(DUIF.Theme.AccentAlt, "DUIF Toggle: ", DUIF.Theme.TextPrimary, tostring(val))
    end

    codeBlock(scroller, "local t = DUIF.CreateToggle(panel, true)")

    sectionHeader(scroller, "Inputs", "Text entry, slider, dropdown")
    local inputCard = DUIF.CreateCard(scroller, {
        header = "Input Examples",
        description = "Styled interactive controls",
        accentBorder = true,
        tall = 150
    })

    local txt = DUIF.CreateTextEntry(inputCard, "Type command or value...")
    txt:SetPos(12, 60)
    txt:SetSize(260, 32)

    local slider = DUIF.CreateSlider(inputCard, 0, 100)
    slider:SetPos(282, 58)
    slider:SetSize(260, 32)

    local combo = DUIF.CreateDropdown(inputCard, { "Teal", "Purple", "Blue" })
    combo:SetPos(552, 60)
    combo:SetSize(180, 32)

    codeBlock(scroller, "DUIF.CreateTextEntry / CreateSlider / CreateDropdown")

    sectionHeader(scroller, "Cards", "Rounded premium card layout with optional icon")
    local card = DUIF.CreateCard(scroller, {
        header = "Server Overview",
        description = "Player count, economy and status widgets can go here.",
        icon = "◆",
        accentBorder = true,
        tall = 96
    })
    card:DockMargin(0, 0, 0, 8)

    codeBlock(scroller, "DUIF.CreateCard(parent, { header = 'Title', accentBorder = true })")
end

function DUIF.OpenShowcase()
    if IsValid(DUIF.ShowcaseFrame) then
        DUIF.ShowcaseFrame:Remove()
    end

    local frame = DUIF.CreateFrame("DUIF Showcase / UI Wiki", 1024, 720)
    DUIF.ShowcaseFrame = frame
    buildShowcase(frame)
end

concommand.Add("duif_showcase", function()
    DUIF.OpenShowcase()
end)
