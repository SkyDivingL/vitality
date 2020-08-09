local ModHitgroupArray = {'Head','Torso','Arms','Legs'} -- new body groups with separate healths

HitgroupDamageScalingArray = {0.80,0.65,0.25,0.25}  -- damage scaling to overall health from hit body part

DefaultJumpPower = 160              
DefaultWalkSpeed = 200              
DefaultRunSpeed = 200               -- TTT_sprint addon will change this to double the value.
DefaultLadderClimbSpeed = 100   

------------------------------------------
--[[ [*][*][*] DAMAGE SETUP [*][*][*] ]]--
------------------------------------------

-- I am not proud of this section. I recommend you do not look at it.

DamageTypeArray = {                 -- Array of damage types
    [1] = {'DMG_CRUSH', 1},
   [2] = {'DMG_BULLET', 2},
   [3] = {'DMG_SLASH', 4},
   [4] = {'DMG_BURN', 8}, 
   [5] = {'DMG_VEHICLE',16},
   [6] = {'DMG_FALL', 32},
   [7] = {'DMG_BLAST', 64},
   [8] = {'DMG_CLUB', 128},
   [9] = {'DMG_SHOCK', 256},
   [10] = {'DMG_SONIC', 512},
   [11] = {'DMG_ENERGYBEAM', 1024},
   [12] = {'DMG_PREVENT_PHYSICS_FORCE', 2048},
   [13] = {'DMG_NEVERGIB', 4096},
   [14] = {'DMG_ALWAYSGIB', 8192},
   [15] = {'DMG_DROWN', 16384},
   [16] = {'DMG_PARALYZE', 32768}, -- This entry actually does not appear in any of the lists below. The TF2 Sandwich medkit item does this type of damage and damages limbs (even though it doesn't do any physical damage)
   [17] = {'DMG_NERVEGAS', 65536},
   [18] = {'DMG_POISON', 131072},
   [19] = {'DMG_RADIATION', 262144},
   [20] = {'DMG_DROWNRECOVER', 524288},
   [21] = {'DMG_ACID', 1048576},
   [22] = {'DMG_SLOWBURN', 2097152},
   [23] = {'DMG_REMOVENORAGDOLL', 4194304},
   [24] = {'DMG_PHYSGUN', 8388608},
   [25] = {'DMG_PLASMA', 16777216},
   [26] = {'DMG_AIRBOAT', 33554432},
   [27] = {'DMG_DISSOLVE', 67108864},
   [28] = {'DMG_BLAST_SURFACE', 134217728},
   [29] = {'DMG_DIRECT', 268435456},
   [30] = {'DMG_BUCKSHOT', 536870912},
   [31] = {'DMG_SNIPER', 107374824}, --DMG_SNIPER appears all the time even when not this type, so I've removed it from the lists below
   [32] = {'DMG_MISSILEDEFENSE',2147483648}
}

DamageTypeBullet = {'DMG_BULLET', 'DMG_AIRBOAT', 'DMG_BUCKSHOT'} 
DamageTypeMelee = {'DMG_SLASH','DMG_CLUB'}          -- melee type damage
DamageTypePhysics = {'DMG_CRUSH', 'DMG_VEHICLE'}    -- damage from physics objects (hwapoon!)
DamageTypeFall = {'DMG_FALL'}                       -- damage from falling
DamageTypeEverything = {'DMG_BURN','DMG_BLAST','DMG_SHOCK','DMG_SONIC','DMG_ENERGYBEAM','DMG_RADIATION','DMG_ACID','DMG_SLOWBURN','DMG_PLASMA', 'DMG_BLAST_SURFACE','DMG_MISSILEDEFENSE'} -- damage damaging everything
DamageTypeUpperBody = {'DMG_DROWN','DMG_NERVEGAS','DMG_POISON','DMG_DROWNRECOVER','DMG_PHYSGUN'} -- damage I decided should only apply to upper body
DamageTypeSpecial = {'DMG_PREVENT_PHYSICS_FORCE', 'DMG_NEVERGIB','DMG_ALWAYSGIB','DMG_REMOVENORAGDOLL','DMG_DISSOLVE','DMG_DIRECT'} -- damage I don't understand (also known as retarded damage)

DamageTypeScalingBullet = {1, 1, 1, 1}
DamageTypeScalingMelee = {0.15, 0.35, 0.27, 0.23}
DamageTypeScalingPhysics = {0.1, 0.5, 0.2, 0.2}
DamageTypeScalingFall = {0, 0, 0, 1}
DamageTypeScalingEverything = {0.1, 0.5, 0.2, 0.2}
DamageTypeScalingUpperBody = {0.5, 0.5, 0, 0}
DamageTypeScalingSpecial = {0.25,0.25,0.25,0.25}
------------

function MyOwnDotProduct(a,b)
    local sum = 0
    for i = 1, #a do
        sum = sum + a[i]*b[i]
    end
    return sum
end

function Index(list,value)
    for i, v in ipairs(list) do
        if value == v then
            return i
        end
    end
end

function InList(list, value)  -- see if a value is in a list
    for i, v in ipairs(list) do
        if value == v then
            return true
        end
    end
    return false
end

function SoleDamageTypeFinder(dmginfo)
    for k, dmgtype in ipairs(DamageTypeArray) do
        if dmginfo:IsDamageType(dmgtype[2]) then return dmgtype[1] end
    end
end
            
    
---------------------------------------
--[[ [*][*][*] MAIN HOOK [*][*][*] ]]--
---------------------------------------

-- This hook is really the brain of the operation. When a player takes damage, it is called.
hook.Add("EntityTakeDamage","Player_Takes_Damage", function(ply,dmginfo)
    
    if ply:IsPlayer() == false or PrepOngoing then return end  -- prevent errors from entities that are not players (and also stops damage during preptime).

    if dmginfo:IsDamageType(128) then       -- we require a special check for melee. The crowbar does bullet-type damage, which takes precedence over other types, but we don't want that for melee. 
        SoleDamageType = 'DMG_CLUB'
    elseif dmginfo:IsDamageType(0) then     -- again a special case. the penetrator has damage type 0, and that's sort of physics-type damage, so i'll define everything according to this
        SoleDamageType = 'DMG_CRUSH'
    else                                    -- otherwise, find the main damage type as normal.
        SoleDamageType = SoleDamageTypeFinder(dmginfo)
    end

    dmginfo:SetDamage(math.abs(dmginfo:GetDamage()))            -- this is a weird one. I found that fire sometimes does negative damage. I don't know what I did wrong, but I'm forcing it to be positive :)

    if InList( DamageTypeMelee , SoleDamageType) then           -- If the damagetype is melee then this plugin will damage all body parts with different amounts. (also, this nerfs the crowbar)
        
        dmginfo:ScaleDamage(0.5 + 0.01*dmginfo:GetAttacker():GetNWFloat('Arms'))
        local BleedChanceScaling = 1.5

        for i, bodypart in ipairs(ModHitgroupArray) do
            DamagePart(bodypart, dmginfo, ply, DamageTypeScalingMelee[i])
            TryBleed(ply, bodypart, BleedChanceScaling, dmginfo)
        end

        dmginfo:ScaleDamage(MyOwnDotProduct(HitgroupDamageScalingArray,DamageTypeScalingMelee)) -- first part is scaling appropriate to damage type and body parts; second part is scaling according to attacker's arm health

    elseif InList( DamageTypeBullet, SoleDamageType) then       -- The one we really care about - bullet type damage! 
        local lasthitgroup = ply:LastHitGroup()
        if lasthitgroup == 0 then lasthitgroup = dmginfo:GetAttacker():GetEyeTrace().HitGroup end

        if lasthitgroup == 1 then
            ModHitgroup = ModHitgroupArray[1]       -- head: triggered when head is damaged
        elseif lasthitgroup == 2 or lasthitgroup == 3 then
            ModHitgroup = ModHitgroupArray[2]       -- torso: triggered when chest or stomach is damaged
        elseif lasthitgroup == 4 or lasthitgroup == 5 then
            ModHitgroup = ModHitgroupArray[3]       -- arms: triggered when arms are damaged
        elseif lasthitgroup == 6 or lasthitgroup == 7 then
            ModHitgroup = ModHitgroupArray[4]       -- legs: triggered when legs are damage
        end

        ScalingFactor = HitgroupDamageScalingArray[Index(ModHitgroupArray, ModHitgroup)]  

        DamagePart(ModHitgroup, dmginfo, ply, DamageTypeScalingBullet[1])


        if ply:GetNWFloat(ModHitgroup) == 0 then                -- Damage is decreased considerably when the body part is already crippled.
            dmginfo:ScaleDamage(0.1)
        elseif ply:GetNWFloat(ModHitgroup) > 100 then
            dmginfo:ScaleDamage(0)
        else
            dmginfo:ScaleDamage(ScalingFactor)                  -- Otherwise, scale damage appropriately.
        end

        local BleedChanceScaling = 1
        TryBleed(ply, ModHitgroup, BleedChanceScaling, dmginfo)

    elseif InList( DamageTypeFall, SoleDamageType) then         -- Falling damage - damage the legs. Note that this will nerf the overall damage taken from falling
        
        local BleedChanceScaling = 0.75
        DamagePart(ModHitgroupArray[4], dmginfo, ply, DamageTypeScalingFall[4])
        TryBleed(ply, ModHitgroupArray[4], BleedChanceScaling, dmginfo)

        if ply:GetNWFloat(ModHitgroupArray[4]) > 100 then
            dmginfo:ScaleDamage(0)
        else
            dmginfo:ScaleDamage(HitgroupDamageScalingArray[4]*DamageTypeScalingFall[4])
        end
    
    elseif InList( DamageTypePhysics, SoleDamageType) then      -- Physics damage - damage everything, but different amounts.

        local BleedChanceScaling = 0.9
        for i, bodypart in ipairs(ModHitgroupArray) do
            DamagePart(bodypart, dmginfo, ply, DamageTypeScalingPhysics[i])
            TryBleed(ply, bodypart, BleedChanceScaling, dmginfo)
        end

        dmginfo:ScaleDamage(MyOwnDotProduct(HitgroupDamageScalingArray,DamageTypeScalingPhysics))

    elseif InList( DamageTypeUpperBody, SoleDamageType) then    -- Upper body damage - damage the head and torso.

        for i = 1, 2 do 
            DamagePart(ModHitgroupArray[i], dmginfo, ply, DamageTypeScalingUpperBody[i]) 
        end

        dmginfo:ScaleDamage(MyOwnDotProduct(HitgroupDamageScalingArray,DamageTypeScalingUpperBody))

    elseif InList( DamageTypeEverything, SoleDamageType) then   -- Everything damage - damage everything

        for i, bodypart in ipairs(ModHitgroupArray) do
            DamagePart(bodypart, dmginfo, ply, DamageTypeScalingEverything[i])
        end

        dmginfo:ScaleDamage(MyOwnDotProduct(HitgroupDamageScalingArray,DamageTypeScalingEverything))

    elseif InList( DamageTypeSpecial, SoleDamageType) then      -- Other types of damage - again damage everything 

        for i, bodypart in ipairs(ModHitgroupArray) do
            DamagePart(bodypart, dmginfo, ply, DamageTypeScalingSpecial[i])
        end

        dmginfo:ScaleDamage(MyOwnDotProduct(HitgroupDamageScalingArray,DamageTypeScalingSpecial))
    end
    ApplyStatus(ply,dmginfo)
end)

---------------------------------------------
--[[ [*][*][*] PLAYER SPAWNING [*][*][*] ]]--
---------------------------------------------

-- These two hooks initialize the health of body parts when a player (re)spawns or the round begins.

hook.Add("TTTPrepareRound", "Round_Preparing", function(ply) 
    PrepOngoing = true
end)

hook.Add("TTTBeginRound", "Round_Beginning", function(ply) 
    PrepOngoing = false
end)

hook.Add("PlayerSpawn", "Player_ReSpawned", function(ply)    -- set health of body parts on (re)spawn
    if PrepOngoing then                             -- if spawned during round prep, set all health to 100
        ply:SetNWFloat('Prev_Health',100)
        for k, bodypart in ipairs(ModHitgroupArray) do
            ply:SetNWFloat(bodypart, 100)
            ply:SetNWFloat('Bleeding_'..bodypart, false)
        end
    else
        for k, bodypart in ipairs(ModHitgroupArray) do
            if ply:GetNWFloat(bodypart) < 80 then 
                ply:SetNWFloat(bodypart, 80)
            else
                ply:SetNWFloat(bodypart,ply:GetNWFloat(bodypart))
            end
            ply:SetNWFloat('Bleeding_'..bodypart, false)
        end
    end
end)

hook.Add("TTTBeginRound","Round_Begin_Player_Health",function()    -- set health of body parts at round start
    for k, ply in ipairs( player.GetAll() ) do 
        ply:SetNWFloat('Prev_Health',100)
        for k, bodypart in ipairs(ModHitgroupArray) do
            ply:SetNWFloat(bodypart, 100)
            ply:SetNWFloat('Bleeding_'..bodypart, false)
        end
    end
end)

------------------------------------------------
--[[ [*][*][*] HEALING AND DAMAGE [*][*][*] ]]--
------------------------------------------------

-- This hook checks whether a person has healed health and heals body parts
hook.Add("Think", "Players_Test_Healed", function()
    for k, ply in ipairs(player.GetAll()) do
        HealthDiff = ply:Health() - ply:GetNWFloat('Prev_Health')
        if HealthDiff > 0 then
            if ply:Health() == 100 then
                for k, bodypart in ipairs(ModHitgroupArray) do ply:SetNWFloat(bodypart, 100) end
            else
                HealthyLimbs = 0
                for k, bodypart in ipairs(ModHitgroupArray) do
                    if ply:GetNWFloat(bodypart) == 100 then 
                        HealthyLimbs = HealthyLimbs + 1
                    end
                end

                BaseHealing = 2*HealthDiff/(4-HealthyLimbs)
                GlobalOverfull = 0

                -- This bit here handles healing the body part from immediate health gain and adds to the overfull healing amount
                for k, bodypart in ipairs(ModHitgroupArray) do  
                    if ply:GetNWFloat(bodypart) < 100 then
                        if ply:GetNWFloat(bodypart) + BaseHealing  > 100 then
                            ply:SetNWFloat(bodypart, 100)
                            GlobalOverfull = GlobalOverfull + (ply:GetNWFloat(bodypart) + BaseHealing - 100)
                        else
                            ply:SetNWFloat(bodypart, ply:GetNWFloat(bodypart) + BaseHealing)         
                        end
                    end
                end
                
                -- This bit further heals body parts using the overfull healing amount
                for k, bodypart in ipairs(ModHitgroupArray) do

                    if ply:GetNWFloat(bodypart) < 100 then
                        if ply:GetNWFloat(bodypart) + GlobalOverfull > 100 then
                            GlobalOverfull = GlobalOverfull - (100 - ply:GetNWFloat(bodypart))
                            ply:SetNWFloat(bodypart, 100)
                        else
                            ply:SetNWFloat(bodypart, ply:GetNWFloat(bodypart) + GlobalOverfull)
                            GlobalOverfull = 0         
                        end
                    end
                end
            end
        end
    ply:SetNWFloat('Prev_Health', ply:Health())
    end
end)

-- DamagePart handles determining the damage done to a body part

function DamagePart(ModHitgroup, dmginfo, ply, ScalingFactor) 
    
    SetHitgroupHealth = ply:GetNWFloat(ModHitgroup) - ScalingFactor * dmginfo:GetDamage()       
    if SetHitgroupHealth < 0 then         
        SetHitgroupHealth = 0
    end
    ply:SetNWFloat(ModHitgroup, SetHitgroupHealth)  
end



-- ApplyStatus applies the appropriate status when parts become damaged (speeds, death, etc)

function ApplyStatus(ply, dmginfo)
    if !ply:Alive() then return end
            
    ply:SetWalkSpeed((0.75 + 0.0025 * ply:GetNWFloat('Legs')) * DefaultWalkSpeed)       -- reduce walk speed as legs become damaged
    ply:SetRunSpeed((0.75 + 0.0025 * ply:GetNWFloat('Legs')) * DefaultRunSpeed)     -- reduce run speed as legs become damaged
    ply:SetLadderClimbSpeed((0.1 + (0.009 * ply:GetNWFloat('Arms') * (0.4 + 0.006 * ply:GetNWFloat('Legs'))))*DefaultLadderClimbSpeed) -- reduce climb speed with damage
    ply:SetJumpPower(math.log10(ply:GetNWFloat('Legs')/10) * DefaultJumpPower)
            
    if ply:GetNWFloat('Head') < 40 then 
        TryBlindness(ply)
    end
    
    if ply:GetNWFloat('Arms') < 20 then 
        DropHeavyWeapons(ply) 
        TryButterfingers(ply)
    end

    if ply:GetNWFloat('Head') == 0 or ply:GetNWFloat('Torso') == 0 then ply:SetHealth(0) end
end

hook.Add("PlayerDeath","Player_has_died",function(ply)
    if timer.Exists(ply:Name()..'_Butterfingers') then timer.Remove(ply:Name()..'_Butterfingers') end
end)

function TryBleed(ply, bodypart, BleedChanceScaling, dmginfo)     -- try to add bleed effect to body part

    BleedChanceStart = 0.5

    if math.random() < BleedChanceStart*BleedChanceScaling and !ply:GetNWFloat('Bleeding_'..bodypart) and !(ply:GetNWFloat(bodypart) <= 1) then
        
        ply:SetNWFloat('Bleeding_'..bodypart, true)

        BleedDamage = 1
        BleedInterval = 1
        BleedChanceStop = 0.1
        BleedDamageCollected = 0

        timer.Create(ply:Name()..'_'..bodypart..'_Bleeding', BleedInterval, 0, function()

            
            if math.random() < BleedChanceStop or ply:GetNWFloat(bodypart) <= 1 or ply:Health() <= 4 then
                ply:SetNWFloat('Bleeding_'..bodypart, false)
            end

            if !ply:GetNWFloat('Bleeding_'..bodypart) or !ply:Alive() then
                timer.Remove(ply:Name()..'_'..bodypart..'_Bleeding')
                return
            end

            if ply:GetNWFloat(bodypart)-BleedDamage < 1 then 
                ply:SetNWFloat(bodypart, 1) 

            else
                ply:SetNWFloat(bodypart, ply:GetNWFloat(bodypart) - BleedDamage)

                -- this code here is used because player health is an int and always takes ceil of bleed damage
                BleedDamageCollected = BleedDamageCollected + HitgroupDamageScalingArray[Index(ModHitgroupArray, bodypart)]*BleedDamage
                if math.floor(BleedDamageCollected) > 0 then    
                    ply:SetHealth(ply:Health() - math.floor(BleedDamageCollected))
                    BleedDamageCollected = BleedDamageCollected - math.floor(BleedDamageCollected)
                    ApplyStatus(ply,dmginfo)
                end
            end

            
        end)

    end
end
-------------------------------------------------
--[[ [*][*][*] HEAD DAMAGE EFFECTS [*][*][*] ]]--
-------------------------------------------------

function TryBlindness(ply)
    BlindChance = 0.6
    BlindnessInterval = 30
            
    if !timer.Exists(ply:Name()..'_Blindness') then
        timer.Create(ply:Name()..'_Blindness',BlindnessInterval,0,function()
            if ply:GetNWFloat('Head') >= 40 or !ply:Alive() then 
                timer.Remove(ply:Name()..'_Blindness') 
                return 
            end

            if math.random() < BlindChance then
                ply:ScreenFade(SCREENFADE.OUT, Color(120, 0, 0, 200), 3.5, 2.5 )
                ply:EmitSound("vitality_sfx/shellshock.mp3")
                timer.Simple(6, function()
                    ply:ScreenFade(SCREENFADE.IN, Color(120, 0, 0, 200), 2.5, 3.5 )
                end)
            end
        end)
    end
end

-------------------------------------------------
--[[ [*][*][*] ARMS DAMAGE EFFECTS [*][*][*] ]]--
-------------------------------------------------
HeavyWeaponList = {'rpg', 'physgun', 'ar2','shotgun', 'smg', 'melee2', 'melee','crossbow'}  -- weapon hold types that will be dropped automatically when arms are crippled
ProtectedWeaponList = {'weapon_zm_improvised', 'weapon_zm_carry', 'weapon_ttt_unarmed'}     -- protected weapons that cannot be dropped due to butterfingers

function DropHeavyWeapons(ply)
    local WeaponList = ply:GetWeapons()
    for k, wep in ipairs(WeaponList) do
        if InList(HeavyWeaponList, wep:GetHoldType()) and !InList(ProtectedWeaponList, wep:GetClass()) then ply:DropWeapon(wep) end            -- drop heavy weapons when arms are crippled
    end
end   

function TryButterfingers(ply)

    DropChance = 0.2
    DropInterval = 10

    if !timer.Exists(ply:Name()..'_Butterfingers') then
        timer.Create(ply:Name()..'_Butterfingers', DropInterval, 0, function()
            if ply:GetNWFloat('Arms') >= 20 or !ply:Alive() then 
                timer.Remove(ply:Name()..'_Butterfingers') 
                return
            end
            if math.random() < DropChance and !InList(ProtectedWeaponList, ply:GetActiveWeapon():GetClass()) then ply:DropWeapon() end
        end)
    end
end

hook.Add("PlayerCanPickupWeapon", 'Can_Pickup_Weapon', function(ply, wep)                          -- prevent player from picking up heavy weapons when arms are crippled
    if ply:GetNWFloat('Arms')<20 and InList(HeavyWeaponList, wep:GetHoldType()) then return false end 
end)
-------------------------------------------------
--[[ [*][*][*] LEGS DAMAGE EFFECTS [*][*][*] ]]--
-------------------------------------------------

-- This entire code is taken from the Randomat TTT addon (and slightly modified). All credit goes to its creator.
--[[
local t = {start=nil,endpos=nil,mask=MASK_PLAYERSOLID,filter=nil}
local ply = nil

local function PlayerNotStuck()

	t.start = ply:GetPos()
	t.endpos = t.start
	t.filter = ply
	
	return util.TraceEntity(t,ply).StartSolid == false
	
end

local function FindPassableSpace( direction, step )

	local i = 0
	while ( i < 100 ) do
		local origin = ply:GetPos()

		--origin = VectorMA( origin, step, direction )
		origin = origin + step * direction
		
		ply:SetPos( origin )
		if PlayerNotStuck( ply ) then
			NewPos = ply:GetPos()
			return true
		end
		i = i + 1
	end
	return false
end
-- 	
--	Purpose: Unstucks player
--	Note: Very expensive to call, you have been warned!
--
local function UnstuckPlayer( pl )
	ply = pl

	NewPos = ply:GetPos()
	local OldPos = NewPos
	
	if not PlayerNotStuck( ply ) then
	
		local angle = ply:GetAngles()
		
		local forward = angle:Forward()
		local right = angle:Right()
		local up = angle:Up()
		
		local SearchScale = 1 -- Increase and it will unstuck you from even harder places but with lost accuracy. Please, don't try higher values than 12

		if	not FindPassableSpace( forward, SearchScale ) and	-- forward
			not FindPassableSpace( right, SearchScale ) and  	-- right
			not FindPassableSpace( right, -SearchScale ) and 	-- left
			not FindPassableSpace( up, SearchScale ) and    	-- up
			not FindPassableSpace( up, -SearchScale ) and   	-- down
			not FindPassableSpace( forward, -SearchScale )   	-- back
		then								
			--Msg( "Can't find the world for player "..tostring(ply).."\n" )
			return false
		end
		
		if OldPos == NewPos then 
			return true -- Not stuck?
		else
			ply:SetPos( NewPos )
			if SERVER and ply and ply:IsValid() and ply:GetPhysicsObject():IsValid() then
				if ply:IsPlayer() then
					ply:SetVelocity(vector_origin)
				end
				ply:GetPhysicsObject():SetVelocity(vector_origin) -- prevents bugs :s
			end
		
			return true
		end
		
	end
	
	
end

local function unragdollPlayer( v )
	v.inRagdoll = false
	v:SetParent()

	local ragdoll = v.ragdoll
	v.ragdoll = nil -- Gotta do this before spawn or our hook catches it

	v:Spawn()

	if ragdoll:IsValid() then
		local pos = ragdoll:GetPos()
		pos.z = pos.z + 10
		v:SetPos( pos )
		v:SetVelocity( ragdoll:GetVelocity() )
		local yaw = ragdoll:GetAngles().yaw
		v:SetAngles( Angle( 0, yaw, 0 ) )
		ragdoll:DisallowDeleting( false )
		ragdoll:Remove()
	end

	v:SetHealth(v.spawnInfo.health)
	for i, j in pairs(v.spawnInfo.weps) do
		v:Give(i)
		local wep = v:GetWeapon( i )
		if v.spawnInfo.weps[i].Clip then
			wep:SetClip1(v.spawnInfo.weps[i].Clip)
		end
		v:SetAmmo(v.spawnInfo.weps[i].Reserve, wep:GetPrimaryAmmoType(), true)
		v:SelectWeapon(v.spawnInfo.activeWeapon)
	end

	
	v:SetCredits(v.spawnInfo.credits)

	for i, j in pairs(v.spawnInfo.equipment) do
		if j then
			v:GiveEquipmentItem(i)
		end
	end

	timer.Simple(0.1, function()
		if v:IsInWorld() then
			UnstuckPlayer(v) -- Thanks to SunRed on GitHub for the unstuck script
		end
	end)

end

local function ragdollPlayer( v )
	v.inRagdoll = true

	v.spawnInfo = {}

	local weps = {}
	for i, j in pairs(v:GetWeapons()) do
		weps[j.ClassName] = {}
		weps[j.ClassName].Clip = j:Clip1()
		weps[j.ClassName].Reserve = v:GetAmmoCount(j:GetPrimaryAmmoType())
	end

	local equipment = {}
	equipment[EQUIP_RADAR] = false
	equipment[EQUIP_ARMOR] = false
	equipment[EQUIP_DISGUISE] = false

	if v:HasEquipmentItem(EQUIP_RADAR) then
		equipment[EQUIP_RADAR] = true
	end
	if v:HasEquipmentItem(EQUIP_ARMOR) then
		equipment[EQUIP_ARMOR] = true
	end
	if v:HasEquipmentItem(EQUIP_DISGUISE) then
		equipment[EQUIP_DISGUISE] = true
	end

	local info = {}
	info.weps = weps
	info.activeWeapon = v:GetActiveWeapon().ClassName
	info.health = v:Health()
	info.credits = v:GetCredits()
	info.equipment = equipment
	v.spawnInfo = info
	
	local ragdoll = ents.Create( "prop_ragdoll" )
	ragdoll.ragdolledPly = v
	ragdoll:SetPos( v:GetPos() )
	local velocity = v:GetVelocity()
	ragdoll:SetAngles( v:GetAngles() )
	ragdoll:SetModel( v:GetModel() )
	ragdoll:Spawn()
	ragdoll:Activate()
	v:SetParent( ragdoll )

	for j=0, ragdoll:GetPhysicsObjectCount() -1 do
		local phys_obj = ragdoll:GetPhysicsObjectNum(j)
		phys_obj:SetVelocity(velocity)
	end

	v:Spectate( OBS_MODE_CHASE )
	v:SpectateEntity( ragdoll )
	v:StripWeapons() 

	ragdoll:DisallowDeleting( true, function( old, new )
		if v:IsValid() then v.ragdoll = new end
	end )

    v.ragdoll = ragdoll
    
	hook.Add("Think", v:Nick().."UnragdollTimer", function()
		if ragdoll:IsValid() then
			if ragdoll:GetPhysicsObjectNum( 1 ):GetVelocity():Length() <= 10 then
				unragdollPlayer(v)
				hook.Remove("Think", v:Nick().."UnragdollTimer")
			end
		end
	end)
end

for k, v in pairs(player.GetAll()) do
    v.inRagdoll = false
end

hook.Add("EntityTakeDamage", "RdmtRagdollDMGTaken", function(ent, dmg)
	for k, v in pairs(player.GetAll()) do
		for i, j in pairs(ent:GetChildren()) do
			if j == v then
				v:TakeDamageInfo(dmg)
			end
		end
	end
end)
]]--
--[[
-- This is my code again.
RagdollChance = 0.1 -- weapon drop chance per interval
RagdollInterval = 1 -- seconds
RagdollLastOccurance = -RagdollInterval

function InitiateRagdoll(plyf)             
    local TimeElapsed = CurTime() - RagdollLastOccurance
    if TimeElapsed > RagdollInterval then
        if math.random() < RagdollChance then
            ragdollPlayer(plyf)
        end
        RagdollLastOccurance = CurTime()
    end
end

hook.Add("Think", "TryRagdoll", function()
    for k, plyf in ipairs(player.GetAll()) do
        if plyf:GetNWFloat('Legs')<20 and !plyf.inRagdoll then
            InitiateRagdoll(plyf)
        end
    end
end)
]]--
