function Z_showFrames()
    local frame = getglobal("ZP1")
    if (frame) then
        frame:Show()
    end
end

function Frames_Move(frame)
    frame:StartMoving()
end

function Frames_Stop(frame)
    frame:StopMovingOrSizing()
end

function Frames_unlock(unlock)
    local frame = getglobal("ZP1_Drag")
    if (unlock == true) then
        frame:Show()
    else
        frame:Hide()
    end
end

function Frames_registerHP(frame, unit)
    frame.unit = unit

    frame:SetScript(
        "OnEvent",
        function(self, event)
            if event == "UNIT_MAXHEALTH" then
                self:SetMinMaxValues(0, UnitHealthMax(self.unit)) -- Update max value for the bar
            elseif event == "UNIT_HEALTH" or event == "UNIT_HEALTH_FREQUENT" then
                self:SetValue(UnitHealth(self.unit)) -- Update current value for the bar to reflect our health
            elseif event == "PLAYER_ENTERING_WORLD" then -- Update everything after a loading screen
                self:SetMinMaxValues(0, UnitHealthMax(self.unit))
                self:SetValue(UnitHealth(self.unit))
            end
        end
    )

    frame:RegisterUnitEvent("UNIT_MAXHEALTH", frame.unit)
    frame:RegisterUnitEvent("UNIT_HEALTH", frame.unit)
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
end

local function setPowerColor(frame)
    -- TODO generic function that works for npcs?
    c = RAID_CLASS_COLORS[select(2, UnitClass(frame.unit))]
    local texture = frame:GetStatusBarTexture()
    frame:SetStatusBarColor(c.r, c.g, c.b)
end

function Frames_registerResource(frame, unit)
    frame.unit = unit
    powerType = UnitPowerType(unit)
    frame.powerType = powerType
    setPowerColor(frame)
    frame:SetReverseFill(true)

    frame:SetScript(
        "OnEvent",
        function(self, event)
            if event == "UNIT_POWER_UPDATE" then
                frame:SetValue(UnitPower(frame.unit, frame.powerType))
            elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN" then -- Update everything after a loading screen
                frame:SetValue(UnitPower(frame.unit, frame.powerType))
                frame:SetMinMaxValues(0, UnitPowerMax(unit, powerType))
            end
        end
    )

    frame:RegisterUnitEvent("UNIT_POWER_UPDATE", frame.unit)
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("PLAYER_LOGIN")
end

function UnitSecondaryPower(unit)
    -- TODO Update this to 0 for no power
    local secondPower = 0
    local currentSpec = GetSpecialization()
    local currentSpecName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"
    local localizedClass, englishClass, classIndex = UnitClass(unit);

    if "Windwalker" == currentSpecName then
        secondPower = SPELL_POWER_CHI
    elseif "ROGUE" == englishClass then
        -- Combo points doesn't seem to have a specific variable
        secondPower = 4
    elseif "DRUID" == englishClass then
        local nStance = GetShapeshiftForm();
        if nStance == 3 then
            secondPower = 4
        end
    end
    return secondPower
end

function Frame_Show_Combopoints(frame, points, maxPoints)
    maxDot = getglobal(frame:GetName() .. "_BCombo6")
    if maxPoints == 6 then
        maxDot:Show()
    else
        maxDot:Hide()
    end
    for i=1,6,1
    do
        dot = getglobal(frame:GetName() .. "_Combo" .. i)
        if points >= i then
            dot:Show()
        else
            dot:Hide()
        end
    end
end

function Frames_SPower(frame, unit)
    frame.unit = unit

    frame:SetScript(
        "OnEvent",
        function(self, event)
            if event == "UNIT_POWER_UPDATE" then
                if frame.powerType > 0 then
                    local power = UnitPower(frame.unit, frame.powerType)
                    local maxPower = UnitPowerMax(frame.unit, frame.powerType)
                    Frame_Show_Combopoints(frame, power, maxPower)
                end
            elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LOGIN" then -- Update everything after a loading screen
                frame.powerType = UnitSecondaryPower(unit)
                if frame.powerType > 0 then
                    frame:Show()
                    local power = UnitPower(frame.unit, frame.powerType)
                    local maxPower = UnitPowerMax(frame.unit, frame.powerType)
                    Frame_Show_Combopoints(frame, power, maxPower)
                else
                    frame:Hide()
                end
            elseif event == "UNIT_AURA" then
                frame.powerType = UnitSecondaryPower(unit)
                if frame.powerType > 0 then
                    frame:Show()
                    local power = UnitPower(frame.unit, frame.powerType)
                    local maxPower = UnitPowerMax(frame.unit, frame.powerType)
                    Frame_Show_Combopoints(frame, power, maxPower)
                else
                    frame:Hide()
                end
            elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
                frame.powerType = UnitSecondaryPower(unit)
                if frame.powerType > 0 then
                    frame:Show()
                    local power = UnitPower(frame.unit, frame.powerType)
                    local maxPower = UnitPowerMax(frame.unit, frame.powerType)
                    Frame_Show_Combopoints(frame, power, maxPower)
                else
                    frame:Hide()
                end
            end
        end
    )

    frame:RegisterUnitEvent("UNIT_POWER_UPDATE", frame.unit)
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    frame:RegisterEvent("UNIT_AURA")
end

function Frames_registerUnit(frame, unit)
    frame:SetAttribute("unit", unit)
    frame:SetAttribute("type", "target")
    frame:EnableMouse(true)

    frame:SetAttribute("*type2", "togglemenu")
    frame.menu = function()
        ToggleDropDownMenu(1, nil, PlayerFrameDropDown, frame)
    end

    hooksecurefunc(
        "UnitPopup_OnClick",
        function()
            Frames_unlock(PLAYER_FRAME_UNLOCKED)
        end
    )

    frame:SetScript(
        "OnMouseDown",
        function(self, button)
            if button == "RightButton" then
                if unit == "Player" then
                    ToggleDropDownMenu(1, nil, PlayerFrameDropDown, frame, 0, 0)
                end
            end
        end
    )
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("VARIABLES_LOADED")

frame:SetScript(
    "OnEvent",
    function(self, event, arg1)
        if event == "ADDON_LOADED" and arg1 == "WyzeUI_Hud" then
            if WyzeUI_Hud == nill then
                WyzeUI_Hud = {}
                WyzeUI_Hud.x = 0
                WyzeUI_Hud.y = 0
            end

            local frame = getglobal("ZP1")
            frame:ClearAllPoints()
            frame:SetPoint("CENTER", WyzeUI_Hud.x, WyzeUI_Hud.y)
        elseif event == "PLAYER_LOGOUT" then
            local frame = getglobal("ZP1")
            point, relativeTo, relativePoint, offset_x, offset_y = frame:GetPoint(n)
            WyzeUI_Hud.x = offset_x
            WyzeUI_Hud.y = offset_y
        elseif event == "VARIABLES_LOADED" then
            Frames_unlock(PLAYER_FRAME_UNLOCKED)
        end
    end
)
