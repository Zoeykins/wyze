local targetFrame, targetHPFrame, targetNameFrame, targetCastbarFrame, targetMobClass

local function Target_icon(mobClass)
    local eliteIcon = getglobal(targetFrame:GetName() .. "IconElite")
    local rareEliteIcon = getglobal(targetFrame:GetName() .. "IconRareElite")
    local rareIcon = getglobal(targetFrame:GetName() .. "IconRare")
    local worldBossIcon = getglobal(targetFrame:GetName() .. "IconWorldBoss")

    eliteIcon:Hide()
    rareEliteIcon:Hide()
    rareIcon:Hide()
    worldBossIcon:Hide()

    if "elite" == mobClass then
        eliteIcon:Show()
    elseif "rareelite" == mobClass then
        rareEliteIcon:Show()
    elseif "worldboss" == mobClass then
        worldBossIcon:Show()
    elseif "rare" == mobClass then
        rareIcon:Show()
    end
end

local function updateHealth(frame)
    local health = UnitHealth(frame.unit)
    local maxHealth = UnitHealthMax(frame.unit)
    local healthPercent = health / maxHealth * 100

    frame:SetMinMaxValues(0, maxHealth)
    frame:SetValue(health)
    frame.leftText:SetText(format("%.0f", healthPercent) .. "%")
    frame.rightText:SetText(health)
end

local function Target_changed()
    local targetName = UnitName("Target")

    if targetName == nil then
        targetFrame:Hide()
        targetNameFrame.text:SetText("Unknown")
    else
        -- Add class colors for players and red for enemies
        targetFrame:Show()
        updateHealth(targetHPFrame)
        targetNameFrame.text:SetText(targetName)
        Target_icon(UnitClassification("Target"))
    end
end

local function Target_event(self, event)
    if event == "PLAYER_TARGET_CHANGED" then
        Target_changed()
    end
end

local function TargetHP_event(self, event)
    if event == "UNIT_MAXHEALTH" then
        updateHealth(self)
    elseif event == "UNIT_HEALTH" or event == "UNIT_HEALTH_FREQUENT" then
        updateHealth(self)
    end
end

local function CreateText(frame, align, offX, offY)
    text = frame:CreateFontString(nil, "OVERLAY")
    text:SetFont("Fonts\\ARIALN.ttf", 13, "OUTLINE")
    text:SetPoint(align, offX, offY)
    return text
end

-- Register the parent frame and all its children
function Target_register(frame)
    targetFrame = frame
    local childFrames = {frame:GetChildren()}

    for _, childFrame in ipairs(childFrames) do
        if childFrame:GetName() == frame:GetName() .. "HP" then
            targetHPFrame = childFrame
            targetHPFrame.unit = "Target"
            targetHPFrame:SetScript("OnEvent", TargetHP_event)
            targetHPFrame:RegisterUnitEvent("UNIT_MAXHEALTH", frame.unit)
            targetHPFrame:RegisterUnitEvent("UNIT_HEALTH", frame.unit)
            targetHPFrame.leftText = CreateText(targetHPFrame, "LEFT", 20, 0)
            targetHPFrame.rightText = CreateText(targetHPFrame, "RIGHT", -20, 0)
        elseif childFrame:GetName() == frame:GetName() .. "Name" then
            targetNameFrame = childFrame
            targetNameFrame.text = CreateText(targetNameFrame, "BOTTOM", 0, 0)
        end
    end

    frame:SetScript("OnEvent", Target_event)
    frame:RegisterEvent("PLAYER_TARGET_CHANGED")
end

function Target_registerClickarea(frame)
    frame:EnableMouse(true)

    frame:SetScript(
        "OnMouseDown",
        function(self, button)
            if button == "RightButton" then
                ToggleDropDownMenu(1, nil, TargetFrameDropDown, frame, 100, 0)
            end
        end
    )
end
