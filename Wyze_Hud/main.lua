local function hideDefaultFrames()
    PlayerFrame:Hide()
    -- TargetFrame:Hide()
end

hideDefaultFrames()

function Frames_OnLoad()
    Z_showFrames()
    Z_log("OnLoad")

    Z_registerCommands()
end

function Frames_SlashCommandHandler(msg)
    if (msg == "0") then
        ReloadUI()
    end
    if (Frames_Toggle(msg) == false) then
        Z_log("Unknown command")
    end
end

function Frames_Toggle(value)
    if (value == "lock") then
        Z_log("Locking frames")
        local frame = getglobal("ZDrag")
        frame:Hide()
        toggle = false
        return true
    end
    if (value == "unlock") then
        local frame = getglobal("ZDrag")
        frame:Show()
        Z_log("Unlocking frames")
        toggle = true
        return true
    end
    return false
end