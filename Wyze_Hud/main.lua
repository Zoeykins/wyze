local function hideDefaultFrames()
    PlayerFrame:Hide()
    -- TargetFrame:Hide()
end

hideDefaultFrames()

function Frames_OnLoad()
    Z_showFrames()
    Z_registerCommands()
end

function Frames_SlashCommandHandler(msg)
    if (msg == "0") then
        ReloadUI()
    end
end