local function printCommands()
    Z_log('Commands')
    Z_out('lock - lock all frames')
    Z_out('unlock - unlock all frames')
end

function Z_log(text)
    DEFAULT_CHAT_FRAME:AddMessage("Z: " .. text, 1.0, 1.0, 0, 1, 10)
end

function Z_out(text)
    DEFAULT_CHAT_FRAME:AddMessage("   " .. text)
end

function Z_registerCommands()
    SLASH_Z1 = "/z"
    SlashCmdList["Z"] = Z_handleCommand
end

function Z_handleCommand(args)
    if (args == "lock") then
        Frames_unlock(true)
        return
    end

    if (args == "unlock") then
        Frames_unlock(false)
        return
    end
    
    printCommands()
end