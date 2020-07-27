local ModHitgroupArray = {                             -- new body groups with separate healths (1. name; 2. damage scaling for bullets)
    'Head',                    
    'Torso',                  
    'Arms',                    
    'Legs'                     
}

HitgroupDamageScalingArray = {
    0.80,
    0.65,
    0.25,
    0.25
}

DefaultJumpPower = 160              -- Jump height. I don't actually know what all the default values are here.
DefaultWalkSpeed = 200              -- Walk speed. reasonable
DefaultRunSpeed = 200               -- Sprint speed. TTT_sprint addon will change this to double the value.
DefaultLadderClimbSpeed = 100       -- Ladder climb speed.

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
   [16] = {'DMG_PARALYZE', 32768},
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
   [31] = {'DMG_SNIPER', 107374824},
   [32] = {'DMG_MISSILEDEFENSE',2147483648}
}


DamageTypeBullet = {'DMG_BULLET', 'DMG_AIRBOAT', 'DMG_BUCKSHOT', --[['DMG_SNIPER']]} --DMG_SNIPER appears all the bloody time even when not this type -- Bullet type damage
DamageTypeMelee = {'DMG_SLASH','DMG_CLUB'}          -- melee type damage
DamageTypePhysics = {'DMG_CRUSH', 'DMG_VEHICLE'}    -- damage from physics objects (hwapoon!)
DamageTypeFall = {'DMG_FALL'}                       -- damage from falling
DamageTypeEverything = {'DMG_BURN','DMG_BLAST','DMG_SHOCK','DMG_SONIC','DMG_ENERGYBEAM','DMG_RADIATION','DMG_ACID','DMG_SLOWBURN','DMG_PLASMA', 'DMG_BLAST_SURFACE','DMG_MISSILEDEFENSE'} -- damage damaging everything
DamageTypeUpperBody = {'DMG_DROWN','DMG_PARALYZE','DMG_NERVEGAS','DMG_POISON','DMG_DROWNRECOVER','DMG_PHYSGUN'} -- damage I decided should only apply to upper body
DamageTypeSpecial = {'DMG_PREVENT_PHYSICS_FORCE', 'DMG_NEVERGIB','DMG_ALWAYSGIB','DMG_REMOVENORAGDOLL','DMG_DISSOLVE','DMG_DIRECT'} -- damage I don't understand (also known as retarded damage)

-------------------------------------------------- scalings for different types of damage:
DamageTypeScalingBullet = {1, 1, 1, 1}
DamageTypeScalingMelee = {0.15, 0.35, 0.27, 0.23}
DamageTypeScalingPhysics = {0.1, 0.5, 0.2, 0.2}
DamageTypeScalingFall = {0, 0, 0, 1}
DamageTypeScalingEverything = {0.1, 0.5, 0.2, 0.2}
DamageTypeScalingUpperBody = {0.5, 0.5, 0, 0}
DamageTypeScalingSpecial = {0.25,0.25,0.25,0.25}

function IsMelee(dmginfo)
    return dmginfo:IsDamageType(128)
end

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

function SoleDamageTypeFinder(DamageTypeArray, dmginfo)  -- find last damage type (busted for crowbar)
    for k,v in ipairs(DamageTypeArray) do
        if dmginfo:IsDamageType(v[2]) then  
            return v[1]
        end           
    end
end 

function ResetStatus(terrorist)                                 -- handles resetting all status effects on player from damaged body parts
    terrorist:SetLadderClimbSpeed(DefaultLadderClimbSpeed)                          
    terrorist:SetWalkSpeed(DefaultWalkSpeed)
    terrorist:SetJumpPower(DefaultJumpPower)
    terrorist:SetRunSpeed(DefaultRunSpeed)
    terrorist:SprintEnable()
end

function InitializeHealthGroups(terrorist)   -- initialize health of new body parts
    terrorist:SetNWFloat('Head', 100)
    terrorist:SetNWFloat('Torso', 100)
    terrorist:SetNWFloat('Arms', 100)
    terrorist:SetNWFloat('Legs', 100)
end

function ModHitgroupFinder(DefaultHitgroup)     -- handles finding new modified hitgroup from LastHitGroup()
    if DefaultHitgroup == 1 then
        ModHitgroup = ModHitgroupArray[1]       -- head: triggered when head is damaged (duh)
    elseif DefaultHitgroup == 2 or DefaultHitgroup == 3 then
        ModHitgroup = ModHitgroupArray[2]       -- torso: triggered when chest or stomach is damaged
    elseif DefaultHitgroup == 4 or DefaultHitgroup == 5 then
        ModHitgroup = ModHitgroupArray[3]       -- arms: triggered when arms are damaged
    else
        ModHitgroup = ModHitgroupArray[4]       -- legs: when in doubt, legs
    end
    return ModHitgroup
end

function ApplyStatusFromPart(ModHitgroup, ModHitgroupHealth, terrorist, dmginfo)    -- handles deciding status effects to apply to player from part damage

    TargetHealth = terrorist:Health()
    if ModHitgroup == 'Head' then            -- head
        if ModHitgroupHealth <= 0 then          -- 0% means you die (no other effects... for now)
            terrorist:SetHealth(0)
        end

    elseif ModHitgroup == 'Torso' then       -- torso
        if ModHitgroupHealth <= 0 then          -- 0% means you die (no other effects... for now)
            terrorist:SetHealth(0)
        end

    elseif ModHitgroup == 'Arms' then        -- arms
        if ModHitgroupHealth <= 0 then          -- arms: no ladders
            terrorist:SetLadderClimbSpeed(0)
        end

    elseif ModHitgroup == 'Legs' then        -- legs

        terrorist:SetWalkSpeed((0.75 + 0.0025 * ModHitgroupHealth ) * DefaultWalkSpeed)     -- reduce walk speed according to health (with a minimum of 75% default walk speed)
        
        if ModHitgroupHealth > 20 then 
            terrorist:SetJumpPower((0.25 + 0.0075 * ModHitgroupHealth ) * DefaultJumpPower )-- reduce jump height according to health (minimum 25%)
        else
            terrorist:SetJumpPower(0)                                                       -- disable jumping when crippled
        end

        if ModHitgroupHealth > 20 then
            terrorist:SetRunSpeed((0.75 + 0.0025 * ModHitgroupHealth ) * DefaultRunSpeed)   -- reduce run speed according to health (with same minimum as above)
        else
            terrorist:SprintDisable()                                                       -- disable sprinting when crippled
        end


        if ModHitgroupHealth > 20 then
            terrorist:SetLadderClimbSpeed((0.9 +0.001 * ModHitgroupHealth) * DefaultLadderClimbSpeed)  -- reduce ladder climbing speed according to health (minimum 90%)
        else
            terrorist:SetLadderClimbSpeed(0.7 * DefaultLadderClimbSpeed)                                -- further reduce when crippled
        end
    end
end

function DamagePart(ModHitgroup, dmginfo, terrorist, ScalingFactor)     -- handles calculating damage to part

    ModHitgroupDamage =  ScalingFactor * dmginfo:GetDamage()            -- damage to part is overall damage done multiplied by scale
    GetHitgroupHealth = terrorist:GetNWFloat(ModHitgroup, 0)         -- call health from server
    SetHitgroupHealth = GetHitgroupHealth - ModHitgroupDamage           -- calculate new health
    if SetHitgroupHealth < 0 then                                       -- prevent health from becoming negative
        SetHitgroupHealth = 0
    end
    
    terrorist:SetNWFloat(ModHitgroup, SetHitgroupHealth)             -- set body part health

    ApplyStatusFromPart(ModHitgroup, SetHitgroupHealth, terrorist , dmginfo)    -- apply status from body part health

end

hook.Add("TTTPrepareRound","RoundPrepare", function()                   -- preparing round - intialize
    for k, terrorist in ipairs( player.GetAll() ) do    
        InitializeHealthGroups(terrorist)
        ResetStatus(terrorist)
    end
end)

hook.Add("TTTBeginRound","RoundBegin", function()                       -- beginning round - initialize because you probably died
    for k, terrorist in ipairs( player.GetAll() ) do    
        InitializeHealthGroups(terrorist)
        ResetStatus(terrorist)
    end
end)

hook.Add("PlayerDeath", "PlayerDied", function(terrorist)                    -- Reset health and stuff in case of defib
    InitializeHealthGroups(terrorist)
    ResetStatus(terrorist)
end)

hook.Add("EntityTakeDamage","DamageTrigger", function(target,dmginfo)   -- damage detected
    
    if target:IsPlayer() == false then                             -- prevent errors for wooden tables etc
        return
    end

    if IsMelee(dmginfo) then    -- special check for melee. Crowbars for some reason count as bullet-type damage (but contain no hitgroup info!)
        SoleDamageType = 'DMG_CLUB'
    elseif dmginfo:GetDamageType() == 0 then    -- special case. for example, the penetrator has damage type 0, and that's sort of physics-type damage, so i'll define everything according to this
        SoleDamageType = 'DMG_CRUSH'
    else
        SoleDamageType = SoleDamageTypeFinder(DamageTypeArray,dmginfo)
    end

    if InList( DamageTypeMelee , SoleDamageType) then                                           -- melee: hit everything
        DamagePart(ModHitgroupArray[1], dmginfo, target, DamageTypeScalingMelee[1])
        DamagePart(ModHitgroupArray[2], dmginfo, target, DamageTypeScalingMelee[2])
        DamagePart(ModHitgroupArray[3], dmginfo, target, DamageTypeScalingMelee[3])
        DamagePart(ModHitgroupArray[4], dmginfo, target, DamageTypeScalingMelee[4])

        
        dmginfo:ScaleDamage(MyOwnDotProduct(HitgroupDamageScalingArray,DamageTypeScalingMelee))

    elseif InList( DamageTypeBullet, SoleDamageType) then          

        ModHitgroup = ModHitgroupFinder( target:LastHitGroup() )
        
        ScalingFactor = HitgroupDamageScalingArray[Index(ModHitgroupArray, ModHitgroup)]

        DamagePart(ModHitgroup, dmginfo, target, DamageTypeScalingBullet[1])
        if target:GetNWFloat(ModHitgroup) == 0 then     -- do A LOT less damage when group is already crippled
            dmginfo:ScaleDamage(0.1)
        else
            dmginfo:ScaleDamage(ScalingFactor)          -- do normal damage
        end

    elseif InList( DamageTypeFall, SoleDamageType) then                         -- fall: damage legs
        DamagePart(ModHitgroupArray[4], dmginfo, target, DamageTypeScalingFall[4])

        dmginfo:ScaleDamage(MyOwnDotProduct(HitgroupDamageScalingArray, DamageTypeScalingFall))

    elseif InList( DamageTypePhysics, SoleDamageType) then                      -- physics: hit everything

        DamagePart(ModHitgroupArray[1], dmginfo, target, DamageTypeScalingPhysics[1])
        DamagePart(ModHitgroupArray[2], dmginfo, target, DamageTypeScalingPhysics[2])
        DamagePart(ModHitgroupArray[3], dmginfo, target, DamageTypeScalingPhysics[3])
        DamagePart(ModHitgroupArray[4], dmginfo, target, DamageTypeScalingPhysics[4])

        dmginfo:ScaleDamage(MyOwnDotProduct(HitgroupDamageScalingArray,DamageTypeScalingPhysics))

    elseif InList( DamageTypeUpperBody, SoleDamageType) then                    -- upper body: torso and head

        DamagePart(ModHitgroupArray[1], dmginfo, target, DamageTypeScalingUpperBody[1])
        DamagePart(ModHitgroupArray[2], dmginfo, target, DamageTypeScalingUpperBody[2])

        dmginfo:ScaleDamage(MyOwnDotProduct(HitgroupDamageScalingArray,DamageTypeScalingUpperBody))

    elseif InList( DamageTypeEverything, SoleDamageType) then                   -- everything: everything
    
        DamagePart(ModHitgroupArray[1], dmginfo, target, DamageTypeScalingEverything[1])
        DamagePart(ModHitgroupArray[2], dmginfo, target, DamageTypeScalingEverything[2])
        DamagePart(ModHitgroupArray[3], dmginfo, target, DamageTypeScalingEverything[3])
        DamagePart(ModHitgroupArray[4], dmginfo, target, DamageTypeScalingEverything[4])

        dmginfo:ScaleDamage(MyOwnDotProduct(HitgroupDamageScalingArray,DamageTypeScalingEverything))

    elseif InList( DamageTypeSpecial, SoleDamageType) then                      -- other: spread damage    

        DamagePart(ModHitgroupArray[1], dmginfo, target, DamageTypeScalingSpecial[1])
        DamagePart(ModHitgroupArray[2], dmginfo, target, DamageTypeScalingSpecial[2])
        DamagePart(ModHitgroupArray[3], dmginfo, target, DamageTypeScalingSpecial[3])
        DamagePart(ModHitgroupArray[4], dmginfo, target, DamageTypeScalingSpecial[4])

        dmginfo:ScaleDamage(MyOwnDotProduct(HitgroupDamageScalingArray,DamageTypeScalingSpecial))
    end

end)


