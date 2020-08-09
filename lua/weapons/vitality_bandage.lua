local ModHitgroupArray = {"Head", "Torso", "Arms", "Legs"}

AddCSLuaFile()

-------------

SWEP.PrintName          = 'Bandage'
SWEP.Author             = 'SkyDivingL'
SWEP.Purpose            = 'Heal yourself and stop bleeding. Made for the Vitality add-on.'

-------------

SWEP.Base				= 'weapon_tttbase'
SWEP.Kind               = WEAPON_NADE
SWEP.CanBuy             = {ROLE_TRAITOR, ROLE_DETECTIVE}
SWEP.AutoSpawnable      = true
SWEP.InLoadoutFor       = nil
SWEP.IsSilent           = false
SWEP.NoSights           = true

---------------
if CLIENT then
    SWEP.Icon = "VGUI/ttt/icon_medkit"
    SWEP.EquipMenuData = { type = "Bandage", desc = "Heal yourself and stop bleeding."};
end
    
if SERVER then
    resource.AddFile("materials/VGUI/ttt/icon_medkit.vmt")
end

SWEP.Primary.ClipSize		= 3
SWEP.Primary.DefaultClip	= 3
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.AutoSpawnable      = true
SWEP.UseHands           = true

SWEP.ViewModel			= "models/weapons/c_medkit.mdl"
SWEP.WorldModel			= "models/weapons/w_medkit.mdl"

SWEP.ViewModelFOV		= 54
SWEP.Slot				= 3
SWEP.SlotPos			= 4

SWEP.HealAmount = 10

function SWEP:Initialize()
    self:SetHoldType('slam')
    return
end

local HealSound = Sound( 'vitality_sfx/zapsplat_riptear.wav' )

function SWEP:PrimaryAttack()

    local ply = self.Owner
    local healing = self.HealAmount
    local healthhealing = 3

    local parttarget
    
    if CLIENT then 
        if ply:GetNWFloat(ModHitgroupArray[1]) >= 100 and ply:GetNWFloat(ModHitgroupArray[2]) >= 100 and ply:GetNWFloat(ModHitgroupArray[3]) >= 100 and ply:GetNWFloat(ModHitgroupArray[4]) >= 100 then return end

        local Healpanel = vgui.Create("DFrame")
        surface.CreateFont("HealFont", {font = "Trebuchet24", size = 15, weight = 750})

        local HealpanelY = ScrH() - 365
        local HealpanelX = 10
        local HealpanelW = 250
        local HealpanelH = 210

        local ButtonX = HealpanelX-1
        local ButtonY = {25,  75 ,  125,  175}
        local ButtonW = HealpanelW - 18
        local ButtonH = 27

        local ButtonTxt = ''

        Healpanel:SetDraggable(false)
        Healpanel:SetDeleteOnClose(true)
        Healpanel:ShowCloseButton(false)
        Healpanel:SetTitle('')

        Healpanel:SetSize(HealpanelW,HealpanelH)
        Healpanel:SetPos(HealpanelX, HealpanelY)
        Healpanel:MakePopup()
        Healpanel.Paint = function(self, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(0,0,0,0))
        end

        local Button_Cancel = vgui.Create("DButton", Healpanel)
        Button_Cancel:SetFont("TabLarge")
        Button_Cancel:SetText("Press health bar to heal | Cancel")
        Button_Cancel:SetTextColor(Color(255,255,255,255))
        Button_Cancel:SetPos(5,3)
        Button_Cancel:SetSize(200, 20)
        Button_Cancel.Paint = function(self, w, h)
            draw.RoundedBox(8,0,0, w, h, Color(41,128,185,0))
        end

        Button_Cancel.DoClick = function()
            Healpanel:Close()
        end

        for i = 1, 4 do
            local parthealth = ply:GetNWFloat(ModHitgroupArray[i])

            if parthealth < 100 then

                local Button= vgui.Create("DButton", Healpanel)
                Button:SetFont("TabLarge")
                Button:SetText(ButtonTxt)
                Button:SetTextColor(Color(255,255,255,255))
                Button:SetPos(ButtonX, ButtonY[i])
                Button:SetSize(ButtonW, ButtonH)
                Button.Paint = function(self, w, h)
                    draw.RoundedBox(8,0,0, w, h, Color(41,128,185,0))
                end
                

                Button.DoClick = function()
                    net.Start("SendHealTarget")
                    net.WriteString(ModHitgroupArray[i])
                    net.SendToServer()
                    Healpanel:Close()
                end
            end
        end
        
    elseif SERVER then
        util.AddNetworkString("SendHealTarget")

        local healtarget = nil

        net.Receive("SendHealTarget", function(len, ply)
            if ply:GetActiveWeapon():GetClass() != 'ttt_bandage' then return end
            healtarget = net.ReadString()
            if ply:GetNWFloat('Bleeding_'..healtarget) then ply:SetNWFloat('Bleeding_'..healtarget, false) end
            if ply:GetNWFloat(healtarget) + healing > 100 then
                ply:SetNWFloat(healtarget, 100)
            else
                ply:SetNWFloat(healtarget, ply:GetNWFloat(healtarget) + healing)
            end
            ply:EmitSound(HealSound)

            ApplyStatus(ply)
            self:TakePrimaryAmmo(1)
            if self:Clip1() == 0 then ply:StripWeapon('vitality_bandage') end -- disabled for debugging
        end)
    end
    
end

function SWEP:OnRemove()
	timer.Stop( "weapon_idle" .. self:EntIndex() )
end

function SWEP:Holster()

	timer.Stop( "weapon_idle" .. self:EntIndex() )
	
	return true

end