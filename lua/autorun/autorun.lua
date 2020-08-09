if (SERVER) then
	print("[VITALITY {ALPHA}] Vitality add-on detected")

	AddCSLuaFile()
	resource.AddFile("sound/vitality_sfx/drbones.mp3")
	resource.AddFile("sound/vitality_sfx/shellshock.wav")
	AddCSLuaFile("cl_vitality.lua")
	AddCSLuaFile('weapons/vitality_bandage.lua')
        
	include('sv_vitality.lua')
	print("[VITALITY {ALPHA}] Successfully included Vitality")
end

if (CLIENT) then
	print("[VITALITY {ALPHA}] Vitality add-on detected")

	include('cl_vitality.lua')

	print("[VITALITY {ALPHA}] Successfully included Vitality")
end