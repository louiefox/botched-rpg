util.AddNetworkString( "Botched.RequestChooseModel" )
net.Receive( "Botched.RequestChooseModel", function( len, ply )
    local characterKey = net.ReadString()
    if( not characterKey ) then return end

    local chosenModel, character = ply:GetChosenCharacter()
    if( character == characterKey ) then return end

    local ownedCharacters = ply:GetOwnedCharacters()
    if( BOTCHED.CONFIG.Characters[characterKey] and ownedCharacters[characterKey] ) then
        ply:SetChosenCharacter( characterKey )
    end
end )