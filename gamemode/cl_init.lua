-- SHARED LOAD --
include( "shared.lua" )

-- CLIENT LOAD --
include( "cl_bshadows.lua" )
include( "cl_drawing.lua" )
include( "cl_fonts.lua" )
include( "cl_player.lua" )
include( "cl_hud.lua" )
include( "cl_equipment.lua" )
include( "cl_derma_popups.lua" )
include( "cl_admin.lua" )
include( "cl_monsters.lua" )
include( "cl_notifications.lua" )
include( "cl_resources.lua" )
include( "cl_gacha.lua" )
include( "cl_crafting.lua" )
include( "cl_quests.lua" )
include( "cl_panelmeta.lua" )
include( "cl_rewards.lua" )
include( "cl_map.lua" )
include( "cl_characters.lua" )

-- VGUI LOAD --
for k, v in pairs( file.Find( GM.FolderName .. "/gamemode/vgui/*.lua", "LUA" ) ) do
	include( "vgui/" .. v )
end

function GM:ScoreboardShow()
    if( IsValid( BOTCHED_SCOREBOARD ) ) then
        BOTCHED_SCOREBOARD:Remove()
    end

    gui.EnableScreenClicker( true )
    BOTCHED_SCOREBOARD = vgui.Create( "botched_scoreboard" )
end

function GM:ScoreboardHide()
    if( IsValid( BOTCHED_SCOREBOARD ) ) then
        gui.EnableScreenClicker( false )
        BOTCHED_SCOREBOARD:Close()
    end
end

net.Receive( "Botched.SendOpenMainMenu", function( len, ply )
    local page = net.ReadString() or ""

    if( IsValid( BOTCHED_MAINMENU ) ) then
        if( BOTCHED_MAINMENU:IsVisible() ) then
            BOTCHED_MAINMENU:Close()
            return
        else
            BOTCHED_MAINMENU:Open( page )
        end
    else
        BOTCHED_MAINMENU = vgui.Create( "botched_mainmenu" )
    end

    if( page ) then
        BOTCHED_MAINMENU:SetPage( page )
    end

    if( BOTCHED_ACTIVE_QUEST and (BOTCHED_ACTIVE_QUEST.Completed or BOTCHED_ACTIVE_QUEST.Failed) ) then
        local questLine = BOTCHED.CONFIG.QuestsLines[BOTCHED_ACTIVE_QUEST.QuestLine]
        if( not questLine ) then return end
    
        local questConfig = questLine.Quests[BOTCHED_ACTIVE_QUEST.QuestKey]
        if( not questConfig ) then return end

        local popupPanel =  vgui.Create( "botched_popup_quest_over" )
        popupPanel:SetQuestInfo( BOTCHED_ACTIVE_QUEST )
    end
end )

net.Receive( "Botched.SendFirstSpawn", function( len, ply )
    timer.Simple( 1, function()
        if( not IsValid( BOTCHED_NOTICEMENU ) ) then
            BOTCHED_NOTICEMENU = vgui.Create( "botched_popup_notices" )
        end

        if( not IsValid( BOTCHED_LOGINREWARDS_MENU ) ) then
            BOTCHED_LOGINREWARDS_MENU = vgui.Create( "botched_popup_loginrewards" )
        end
    end )
end )

concommand.Add( "botched_admin", function( ply, cmd, args )
    if( IsValid( BOTCHED_ADMINMENU ) ) then BOTCHED_ADMINMENU:Close() return end

    BOTCHED_ADMINMENU = vgui.Create( "botched_adminmenu" )
end )

hook.Add( "OnPlayerChat", "Botched.OnPlayerChat.ChatCommands", function( ply, strText, bTeam, bDead ) 
    if( ply != LocalPlayer() ) then return end
	strText = string.lower( strText )

	if( strText == "/donate" or strText == "!donate" ) then
		BOTCHED.FUNC.DermaMessage( "We don't accept donations, type !store for gems.", "DONATE", "Continue" )
		return true
    elseif( strText == "/store" or strText == "!store" ) then
		BOTCHED.FUNC.DermaCreateGemStore()
		return true
	end
end )

game.AddParticles( "particles/pfx_redux.pcf" )
PrecacheParticleSystem("[2]gushing_blood")
PrecacheParticleSystem("[9]colorful_trail_1")

function BOTCHED.FUNC.CreateChatHintTimer()
    if( timer.Exists( "BOTCHED.Timer.ChatHints" ) ) then
        timer.Remove( "BOTCHED.Timer.ChatHints" )
    end

    local remainingHints = {}
    timer.Create( "BOTCHED.Timer.ChatHints", 300, 0, function()
        if( not remainingHints[1] ) then
            remainingHints = table.Copy( BOTCHED.CONFIG.ChatHints )
        end

        local val, key = table.Random( remainingHints )
        chat.AddText( Color( 26, 188, 156 ), "[HINT] ", Color( 255, 255, 255 ), val )

        table.remove( remainingHints, key )
    end )
end
BOTCHED.FUNC.CreateChatHintTimer()

function GM:HUDDrawTargetID()
    
end

hook.Add( "OnPlayerChat", "Botched.OnPlayerChat.ChatTags", function( ply, text, bTeam, bDead ) 
	if( string.StartWith( text, "//" ) ) then
        text = string.TrimLeft( text, "//" )

		chat.AddText( Color( 52, 152, 219 ), "[GLOBAL] ", Color( 52, 73, 94 ), "[LVL " .. ply:GetLevel() .. "] ", Color( 149, 165, 166 ), ply:Nick() .. ": ", Color( 255, 255, 255 ), text )
		return true
	end

    if( string.StartWith( text, "/" ) or string.StartWith( text, "!" ) ) then
		return true
	end

    chat.AddText( Color( 52, 73, 94 ), "[LVL " .. ply:GetLevel() .. "] ", Color( 149, 165, 166 ), ply:Nick() .. ": ", Color( 255, 255, 255 ), text )
    return true
end )

hook.Add( "PlayerConnect", "Botched.PlayerConnect.ChatMessages", function( name )
	chat.AddText( Color( 231, 76, 60 ), "[SERVER] ", Color( 255, 255, 255 ), name .. " has connected to the server." )
end )

concommand.Add( "botched_removeonclose", function()
    BOTCHED_REMOVEONCLOSE = not BOTCHED_REMOVEONCLOSE
end )