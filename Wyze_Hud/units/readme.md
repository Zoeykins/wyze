# Pattern to follow

## Target frame
|Element|Name|
|---|---|
|Target health|$parentHP|
|Target name|$parentName|
|Target castbar|$parentCastbar|


## Frame layers
|Layer name|Level|Description|
|---|---|---|
|BACKGROUND | Level 0   | Place the background of your frame here.              |
|BORDER     | Level 1   | Place the artwork of your frame here .                |
|ARTWORK    | Level 2   | Place the artwork of your frame here.                 |
|OVERLAY    | Level 3   | Place your text, objects, and buttons in this level.  |
|HIGHLIGHT  | Level 4   | Place your text, objects, and buttons in this level.  |



## Constants
### Unit classifactions
"worldboss", "rareelite", "elite", "rare", "normal", "trivial" or "minus"

Determine using 

    if ( UnitClassification("target") == "worldboss" ) then
        -- If unit is a world boss show skull regardless of level
        TargetLevelText:Hide();
        TargetHighLevelTexture:Show();
    end