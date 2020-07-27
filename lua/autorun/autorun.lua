if (SERVER) then
	print("[HEALTH (SERVER)] Alright server, let's see if you can handle me...")

	AddCSLuaFile()

    AddCSLuaFile("cl_health.lua")
        
	include('sv_health.lua')
	print("[HEALTH (SERVER)] Wow! Such an amazing server! The addon is yours to use.")
end

if (CLIENT) then
	print("[HEALTH (CLIENT)] Very well, client. I will see what I can do.")

	include('cl_health.lua')

	print("[HEALTH (SERVER)] Good news, client. You may use this addon.")
end
