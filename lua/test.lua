for k, ply in ipairs(player.GetAll()) do
    if !ply:IsBot() then
        ply:SetNWFloat('Legs', 200)
        ply:SetNWFloat('Arms', 200)
        ply:Give('ttt_bandage')
        ApplyStatus(ply)
    end
end