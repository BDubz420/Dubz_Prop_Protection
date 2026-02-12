--[[
    DUIF - Dubz UI Framework
    File: cl_panel.lua
    Purpose: Base container builders including themed frame and generic panel.
]]

DUIF = DUIF or {}

function DUIF.CreateFrame(title, width, height, opts)
    opts = DUIF.MergeOptions({
        rounded = 10,
        draggable = true,
        showClose = true,
        onClose = nil
    }, opts)

    local frame = vgui.Create("DFrame")
    frame:SetTitle("")
    frame:SetSize(width or 900, height or 620)
    frame:Center()
    frame:SetDraggable(opts.draggable)
    frame:MakePopup()
    frame:ShowCloseButton(false)

    frame.Title = title or "DUIF Frame"

    frame.Paint = function(self, w, h)
        DUIF.DrawShadowedPanel(0, 0, w, h, opts.rounded, DUIF.GetColor("Background"))
        DUIF.DrawRoundedBox(opts.rounded, 0, 0, w, 56, DUIF.GetColor("Surface"))
        surface.SetDrawColor(DUIF.GetColor("Border"))
        surface.DrawLine(0, 56, w, 56)
        draw.SimpleText(self.Title, "DUIF.Header", 16, 28, DUIF.GetColor("Text"), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    if opts.showClose then
        local close = DUIF.CreateCloseButton(frame, {
            onClick = function()
                if isfunction(opts.onClose) then opts.onClose(frame) end
                frame:Remove()
            end
        })
        close:SetPos(frame:GetWide() - 38, 10)
    end

    DUIF.Fade(frame, 0, 255, 0.16)
    return frame
end

function DUIF.CreatePanel(parent, opts)
    opts = DUIF.MergeOptions({
        dock = nil,
        margin = nil,
        rounded = 8,
        color = nil,
        padding = 10
    }, opts)

    local panel = vgui.Create("DPanel", parent)
    panel:DockPadding(opts.padding, opts.padding, opts.padding, opts.padding)

    panel.Paint = function(_, w, h)
        DUIF.DrawRoundedBox(opts.rounded, 0, 0, w, h, opts.color or DUIF.GetColor("Surface"))
    end

    if opts.dock then panel:Dock(opts.dock) end
    if opts.margin then panel:DockMargin(opts.margin[1], opts.margin[2], opts.margin[3], opts.margin[4]) end

    return panel
end
