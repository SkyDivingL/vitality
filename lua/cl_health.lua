


local ModHitgroupArray = {"Head", "Torso", "Arms", "Legs"} -- new body groups with separate healths


surface.CreateFont("HUDFont", {font = "Trebuchet24", size = 24, weight = 750})

ContainerPanelWidth = 250
ContainerPanelHeight = 210
ContainerPanelPosy = ScrH() - 365
ContainerPanelPosx = 10

HealthBarLength = ContainerPanelWidth - 18
HealthBarHeight = 27
HealthBarPosx = ContainerPanelPosx + 9

HealthBarPosyHead = ContainerPanelPosy + 25
HealthBarPosyTorso = ContainerPanelPosy + 75
HealthBarPosyArms = ContainerPanelPosy + 125
HealthBarPosyLegs = ContainerPanelPosy + 175


function GetPartHealth(terrorist)   -- handles receiving body part healths from server

    BodyPartHealthHead = terrorist:GetNWFloat(ModHitgroupArray[1])
    BodyPartHealthTorso = terrorist:GetNWFloat(ModHitgroupArray[2])
    BodyPartHealthArms = terrorist:GetNWFloat(ModHitgroupArray[3])
    BodyPartHealthLegs = terrorist:GetNWFloat(ModHitgroupArray[4])
end

function DrawHealth(terrorist) -- handles drawing the surrounding panel and calls on functions drawing health bars

    GetPartHealth(terrorist) -- get all body part healths

    draw.RoundedBox(8, ContainerPanelPosx, ContainerPanelPosy, ContainerPanelWidth, ContainerPanelHeight, Color(0,0,0,200))                         -- creates surrounding panel
    draw.SimpleText("Body parts health (WIP)", "TabLarge", ContainerPanelPosx + 5, ContainerPanelPosy - 5, Color(255,255,255,255),TEXT_ALIGN_LEFT)  -- writes name of panel

    DrawHealthBar("Head", BodyPartHealthHead, HealthBarPosx, HealthBarPosyHead)        -- draw health bar for head
    DrawHealthBar("Torso", BodyPartHealthTorso, HealthBarPosx, HealthBarPosyTorso)     -- draw health bar for torso
    DrawHealthBar("Arms", BodyPartHealthArms, HealthBarPosx, HealthBarPosyArms)        -- draw health bar for arms
    DrawHealthBar("Legs", BodyPartHealthLegs, HealthBarPosx, HealthBarPosyLegs)        -- draw health bar for legs
    
end


function DrawHealthBar(BodyPart, BodyPartHealth, HealthBarPosx, HealthBarPosy) -- handles drawing health bars and everything on them
    
    draw.RoundedBox(8, HealthBarPosx, HealthBarPosy, HealthBarLength, HealthBarHeight, Color(100, 25, 25, 222))             -- draws background health bar (dark) (taken from gamemode)

    if BodyPartHealth > 100 then                                                                                            -- if >100, cap health bar to full health
        draw.RoundedBox(8, HealthBarPosx, HealthBarPosy, HealthBarLength, HealthBarHeight, Color(200, 50, 50, 250))                         -- draw overfull health bar         
    else
        draw.RoundedBox(8, HealthBarPosx, HealthBarPosy, HealthBarLength * BodyPartHealth * 0.01, HealthBarHeight, Color(200, 50, 50, 250)) -- draw health bar
    end

    draw.SimpleText(BodyPart, "TabLarge", ContainerPanelPosx + ContainerPanelWidth - 15, HealthBarPosy - 15, Color(255,255,255,255),TEXT_ALIGN_RIGHT)    -- write body part name on top of health bar
    
    draw.SimpleText(math.ceil(BodyPartHealth), "HUDFont", ContainerPanelPosx + ContainerPanelWidth - 27, HealthBarPosy + 3, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT) -- create shadow of health%
    draw.SimpleText(math.ceil(BodyPartHealth), "HUDFont", ContainerPanelPosx + ContainerPanelWidth - 29, HealthBarPosy + 1, Color(255,255,255,255), TEXT_ALIGN_RIGHT) -- write health% on top of health bar

    BodyPartStatus = DefineDamage(BodyPartHealth)

    draw.SimpleText(BodyPartStatus, "TabLarge", HealthBarPosx + 10, HealthBarPosy + 7, Color(255,255,255,255),TEXT_ALIGN_LEFT)

end


function DefineDamage(BodyPartHealth)   -- handles status to write on health bar (healthy etc.)

    if BodyPartHealth > 100 then
        BodyPartStatus = "Super Healthy!"

    elseif BodyPartHealth == 100 then
        BodyPartStatus = "Healthy"

    elseif BodyPartHealth < 100 and BodyPartHealth >= 90 then
        BodyPartStatus = "Scratched"

    elseif BodyPartHealth < 90 and BodyPartHealth >= 75 then
        BodyPartStatus = "Hurting"

    elseif BodyPartHealth < 75 and BodyPartHealth >= 50 then
        BodyPartStatus = "Damaged"

    elseif BodyPartHealth < 50 and BodyPartHealth >= 30 then 
        BodyPartStatus = "Badly damaged"

    elseif BodyPartHealth < 30 and BodyPartHealth >= 20 then
        BodyPartStatus = "Dangerously damaged"

    elseif BodyPartHealth < 20 and BodyPartHealth >= 0 then
        BodyPartStatus = "Crippled"
    else 
        BodyPartStatus = "You cracked the code!"
    end

    return BodyPartStatus
end


hook.Add("HUDPaint", "DrawHealthOnHUD", function()
    PlayerTarget = LocalPlayer()

    if PlayerTarget:Alive() and PlayerTarget:IsTerror() and (not LocalPlayer():IsSpec()) then 
        DrawHealth(PlayerTarget)
    end

    OtherTarget = PlayerTarget:GetEyeTrace().Entity
    if DEBUG and OtherTarget:IsPlayer() then    
        DrawEnemyHealthDebug(OtherTarget)
    end
end)

------ DEBUG
DEBUG = true

ContainerPanelPosyDebug = ContainerPanelPosy - 220
ContainerPanelPosxDebug = ContainerPanelPosx
ContainerPanelWidthDebug = ContainerPanelWidth
ContainerPanelHeightDebug = ContainerPanelHeight

HealthBarPosxDebug = ContainerPanelPosxDebug + 9
HealthBarPosyHeadDebug = ContainerPanelPosyDebug + 25
HealthBarPosyTorsoDebug = ContainerPanelPosyDebug + 75
HealthBarPosyArmsDebug = ContainerPanelPosyDebug + 125
HealthBarPosyLegsDebug = ContainerPanelPosyDebug + 175

function DrawEnemyHealthDebug(terrorist)

    GetPartHealth(terrorist)
    EnemyHealth = terrorist:Health()

    draw.RoundedBox(8, ContainerPanelPosxDebug, ContainerPanelPosyDebug, ContainerPanelWidthDebug, ContainerPanelHeightDebug, Color(0,0,0,200))                         -- creates surrounding panel
    draw.SimpleText("Enemy body parts health (DEBUG)", "TabLarge", ContainerPanelPosxDebug + 5, ContainerPanelPosyDebug - 5, Color(255,255,255,255),TEXT_ALIGN_LEFT)  -- writes name of panel

    draw.RoundedBox(8, ContainerPanelPosxDebug, ContainerPanelPosyDebug-70, ContainerPanelWidthDebug, 50, Color(0,0,0,200))
    DrawHealthBar("Health", EnemyHealth, HealthBarPosxDebug, ContainerPanelPosyDebug -55)

    DrawHealthBar("Head", BodyPartHealthHead, HealthBarPosxDebug, HealthBarPosyHeadDebug)        -- draw health bar for head
    DrawHealthBar("Torso", BodyPartHealthTorso, HealthBarPosxDebug, HealthBarPosyTorsoDebug)     -- draw health bar for torso
    DrawHealthBar("Arms", BodyPartHealthArms, HealthBarPosxDebug, HealthBarPosyArmsDebug)        -- draw health bar for arms
    DrawHealthBar("Legs", BodyPartHealthLegs, HealthBarPosxDebug, HealthBarPosyLegsDebug)        -- draw health bar for legs

end