DUIF = DUIF or {}

function DUIF.CreateFrame(title, width, height)
    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetSize(width or 900, height or 620)
    frame:Center()
    frame:MakePopup()
    frame:ShowCloseButton(false)
    frame.Paint = function(self, w, h)
        DUIF.DrawShadowedPanel(0, 0, w, h, 10, DUIF.Theme.Background)
        DUIF.DrawRoundedBox(10, 0, 0, w, 52, DUIF.Theme.Panel)
        draw.SimpleText(title or "DUIF Frame", "DUIF.Subtitle", 16, 26, DUIF.Theme.TextPrimary, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(DUIF.Theme.Outline)
        surface.DrawLine(0, 52, w, 52)
    end

    local close = DUIF.CreateCloseButton(frame)
    close:SetPos(frame:GetWide() - 42, 10)

    DUIF.FadeIn(frame, 0.2)
    return frame
end

function DUIF.CreatePanel(parent, dock, margin)
    local panel = vgui.Create("DPanel", parent)
    panel.Paint = function(_, w, h)
        DUIF.DrawRoundedBox(8, 0, 0, w, h, DUIF.Theme.Panel)
    end

    if dock then
        panel:Dock(dock)
    end

    if margin then
        panel:DockMargin(margin[1], margin[2], margin[3], margin[4])
    end

    return panel
end
