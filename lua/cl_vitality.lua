-------------------------------------------------
--[[ [*][*][*] VITALITY CLIENTSIDE [*][*][*] ]]--
-------------------------------------------------

-- ModHitgroupArray contains the list of names of new player hitgroups
local ModHitgroupArray = {"Head", "Torso", "Arms", "Legs"}
surface.CreateFont("HUDFont", {font = "Trebuchet24", size = 24, weight = 750})

-- The VitaPanel contains the player health bars.
-- These parameters set its size and position.
-- The VitaPanel is not a DPanel.
local VitaPanelW = 250
local VitaPanelH = 210
local VitaPanelY = ScrH() - 365
local VitaPanelX = 10

-- These parameters set the size and position of the health bars.
local HealthBarW = VitaPanelW - 18
local HealthBarH = 27
local HealthBarX = VitaPanelX + 9
local HealthBarY = {VitaPanelY + 25, VitaPanelY + 75, VitaPanelY + 125, VitaPanelY + 175}

-- DrawHealthBar handles drawing the health bars in the VitaPanel.
function DrawHealthBar(ply, item, posy)
    draw.RoundedBox(8, HealthBarX, posy, HealthBarW, HealthBarH, Color(100, 25, 25, 222))   -- draws background health bar (dark)

    if item == 'Health' then                    -- get health and status of item
        Status = HealthStatus(ply:Health())
        health = ply:Health()
    else
        Status = PartStatus(item, ply)
        health = ply:GetNWFloat(item)
    end

    if health >= 100 then                                                                    
        draw.RoundedBox(8, HealthBarX, posy, HealthBarW, HealthBarH, Color(200, 50, 50, 250))   -- if health >= 100 draw full health bar
        if health > 200 then                                                                    -- if health > 100 draw additional health bar on top (used for exoskeletons)
            draw.RoundedBox(8, HealthBarX, posy, HealthBarW, HealthBarH, Color(255, 0, 255, 250))
        else
            draw.RoundedBox(8, HealthBarX, posy, HealthBarW * (health-100) * 0.01, HealthBarH, Color(255, 0, 255, 250))
        end    
    else                                                                                        -- otherwise draw health bar appropriately
        draw.RoundedBox(8, HealthBarX, posy, HealthBarW * health * 0.01, HealthBarH, Color(200, 50, 50, 250))
    end

    draw.SimpleText(item, "TabLarge", VitaPanelX + VitaPanelW - 15, posy - 15, Color(255,255,255,255),TEXT_ALIGN_RIGHT)             -- write name above health bar
    draw.SimpleText(math.floor(health), "HUDFont", VitaPanelX + VitaPanelW - 27, posy + 3, Color(0, 0, 0, 255), TEXT_ALIGN_RIGHT)    -- create shadow of health% (goes first)
    draw.SimpleText(math.floor(health), "HUDFont", VitaPanelX + VitaPanelW - 29, posy + 1, Color(255,255,255,255), TEXT_ALIGN_RIGHT) -- write health% on health bar
    draw.SimpleText(Status, "TabLarge", HealthBarX + 10, posy + 7, Color(255,255,255,255),TEXT_ALIGN_LEFT)                          -- write status on health bar
end

-- PartStatus returns the status of the body part.
function PartStatus(bodypart, ply) 
    local Status
    if ply:GetNWFloat('Bleeding_'..bodypart) then
        Status = 'Bleeding'
    elseif ply:GetNWFloat(bodypart) > 100 then
        Status= "Powered"
    elseif ply:GetNWFloat(bodypart) <= 100 and ply:GetNWFloat(bodypart) > 80 then
        Status = "Healthy"
    elseif ply:GetNWFloat(bodypart) <= 80 and ply:GetNWFloat(bodypart) > 60 then
        Status = 'Hurt'
    elseif ply:GetNWFloat(bodypart) <= 60 and ply:GetNWFloat(bodypart) > 40 then
        Status = "Wounded"
    elseif ply:GetNWFloat(bodypart) <= 40 and ply:GetNWFloat(bodypart) > 20 then
        Status = "Badly wounded"
    elseif ply:GetNWFloat(bodypart) <= 20 then 
        Status = "Crippled"
    end
    return Status
end

-- PartStatus returns the health status. Used for target only.
function HealthStatus(health) 
    local Status
    if health <= 100 and health > 80 then
        Status = "Healthy"
    elseif health <= 80 and health > 60 then
        Status = 'Hurt'
    elseif health <= 60 and health > 40 then
        Status = "Wounded"
    elseif health <= 40 and health > 20 then
        Status = "Badly wounded"
    elseif health <= 20 then
        Status = "Near death"
    end
    return Status
end

-- Draw_VitaPanel is responsible for calling all relevant functions.
hook.Add("HUDPaint", "Draw_VitaPanel", function()
    ply = LocalPlayer()
    if ply:Alive() and ply:IsTerror() and !ply:IsSpec() then          -- only draw VitaPanels when player is alive

        draw.RoundedBox(8, VitaPanelX, VitaPanelY, VitaPanelW, VitaPanelH, Color(0,0,0,200))                                -- creates container panel of VitaPanel
        draw.SimpleText("VitaPanel", "TabLarge", VitaPanelX + 5, VitaPanelY - 6, Color(255,255,255,255),TEXT_ALIGN_LEFT)    -- writes name of panel on container

        for k, bodypart in ipairs(ModHitgroupArray) do      -- draw health bar of every body part
            DrawHealthBar(ply, bodypart, HealthBarY[k])
        end

        plytarget = ply:GetEyeTrace().Entity                -- entity player is targeting
        if ply:Alive() and DEBUG and plytarget:IsPlayer() then   -- if target is a player, draw their health bars (debug)

            draw.RoundedBox(8, VitaPanelX, VitaPanelYDebug, VitaPanelW, VitaPanelH, Color(0,0,0,200))                           -- creates container panel
            draw.SimpleText('Target', 'TabLarge', VitaPanelX + 5, VitaPanelYDebug - 5, Color(255,255,255,255),TEXT_ALIGN_LEFT)  -- writes name

            draw.RoundedBox(8, VitaPanelX, VitaPanelYDebug-70, VitaPanelW, 50, Color(0,0,0,200))        -- draw target health bar container
            DrawHealthBar(plytarget, 'Health', VitaPanelYDebug -55)                                     -- draw target health bar

            for k, bodypart in ipairs(ModHitgroupArray) do      -- draw health bar of target body parts
                DrawHealthBar(plytarget, bodypart, HealthBarYDebug[k])
            end
        end
    end
end)

------ DEBUG
DEBUG = true

VitaPanelYDebug = VitaPanelY - 220
HealthBarXDebug = VitaPanelX + 9
HealthBarYDebug = {VitaPanelYDebug + 25, VitaPanelYDebug + 75, VitaPanelYDebug + 125, VitaPanelYDebug + 175}