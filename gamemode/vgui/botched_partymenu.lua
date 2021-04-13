local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW(), ScrH() )
    self:MakePopup()
    self:SetTitle( "" )
    self:ShowCloseButton( false )

    local middleSpacing = ScrW()*0.1

    self.leftPanel = vgui.Create( "DPanel", self )
    self.leftPanel:SetSize( ScrW()*0.2, 0 )
    self.leftPanel:SetPos( (self:GetWide()/2)-self.leftPanel:GetWide()-(middleSpacing/2), (self:GetTall()/2)-(self.leftPanel:GetTall()/2) )
    self.leftPanel.HeaderH = 60
    self.leftPanel:DockPadding( 25, self.leftPanel.HeaderH+25, 25, 0 )
    self.leftPanel.Paint = function( self2, w, h )
        BSHADOWS.BeginShadow( "partymenu_leftpanel" )
        BSHADOWS.SetShadowSize( "partymenu_leftpanel", w, h )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "partymenu_leftpanel", x, y, 1, 2, 2, 255, 0, 0, false )

        draw.RoundedBoxEx( 8, 0, 0, w, self2.HeaderH, BOTCHED.FUNC.GetTheme( 2, 100 ), true, true )
        draw.SimpleText( "PARTY MEMBERS", "MontserratBold40", w/2, self2.HeaderH/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
    self.leftPanel.OnSizeChanged = function( self2 )
        self2:SetPos( (self:GetWide()/2)-self2:GetWide()-(middleSpacing/2), (self:GetTall()/2)-(self2:GetTall()/2) )
    end

    local inviteButton, bottomButtonPanel

    local partyID = LocalPlayer():GetPartyID()

    self.rightPanel = vgui.Create( "DPanel", self )
    self.rightPanel:SetSize( ScrW()*0.2, 0 )
    self.rightPanel.Paint = function( self2, w, h )
        BSHADOWS.BeginShadow( "partymenu_rightpanel" )
        BSHADOWS.SetShadowSize( "partymenu_rightpanel", w, h )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
        BSHADOWS.EndShadow( "partymenu_rightpanel", x, y, 1, 2, 2, 255, 0, 0, false )

        if( partyID == 0 ) then
            draw.SimpleText( "NO PARTY", "MontserratBold40", w/2, 75/2, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end

    if( partyID != 0 ) then
        self.rightPanel:SetPos( (self:GetWide()/2)+(middleSpacing/2), (self:GetTall()/2)-(self.rightPanel:GetTall()/2) )
    else
        self.rightPanel:Center()
    end

    self.rightPanel.OnSizeChanged = function( self2 )
        if( partyID != 0 ) then
            self2:SetPos( (self:GetWide()/2)+(middleSpacing/2), (self:GetTall()/2)-(self2:GetTall()/2) )
        else
            self2:Center()
        end

        inviteButton:SetPos( select( 1, self2:GetPos() )+self2:GetWide()-inviteButton:GetWide(), select( 2, self2:GetPos() )-10-inviteButton:GetTall() )

        if( IsValid( self.invitePopout ) ) then
            self.invitePopout:SetPos( select( 1, inviteButton:GetPos() )+inviteButton:GetWide()+10, select( 2, inviteButton:GetPos() ) )
        end

        bottomButtonPanel:SetPos( select( 1, self2:GetPos() ), select( 2, self2:GetPos() )+self2:GetTall()+10 )
    end

    self.rightPanel:SizeTo( self.rightPanel:GetWide(), 75+75, 0.2 )

    inviteButton = vgui.Create( "DButton", self )
	inviteButton:SetText( "" )
    local inviteMat = Material( "materials/botched/icons/mail.png" )
	inviteButton.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( false, 75 )

        BSHADOWS.BeginShadow( "partymenu_invitebutton" )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )	
        BSHADOWS.EndShadow( "partymenu_invitebutton", x, y, 1, 2, 2, 255, 0, 0, false )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, self2.alpha ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 1 ), 8 )

        local textColor = BOTCHED.FUNC.GetTheme( 4, 75+(180*(self2.alpha/75)) )

        local inviteCount = table.Count( BOTCHED_PARTY_INVITES or {} ) 
        draw.SimpleText( inviteCount .. " PARTY INVITE" .. ((inviteCount != 1 and "S") or ""), "MontserratMedium21", (w-h)/2, h/2-1, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        draw.RoundedBoxEx( 8, w-h, 0, h, h, BOTCHED.FUNC.GetTheme( 2, 100 ), false, true, false, true )

		surface.SetDrawColor( textColor )
		surface.SetMaterial( inviteMat )
        local iconSize = 24
		surface.DrawTexturedRect( w-(h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
	end
    inviteButton.UpdateSize = function( self2 )
        local inviteCount = table.Count( BOTCHED_PARTY_INVITES or {} ) 

        surface.SetFont( "MontserratMedium21" )
        local textX, textY = surface.GetTextSize( inviteCount .. " PARTY INVITE" .. ((inviteCount != 1 and "S") or "") )

        self2:SetSize( textX+50+25, 50 )
        self2:SetPos( select( 1, self.rightPanel:GetPos() )+self.rightPanel:GetWide()-self2:GetWide(), select( 2, self.rightPanel:GetPos() )-10-self2:GetTall() )
    end
    inviteButton.DoClick = function( self2 )
        if( IsValid( self.invitePopout ) ) then 
            self.invitePopout:SizeTo( self.invitePopout:GetWide(), 0, 0.2, 0, -1, function()
                self.invitePopout:Remove()
            end )

            return 
        end

        self.invitePopout = vgui.Create( "DPanel", self )
        self.invitePopout:SetSize( ScrW()*0.2, 0 )
        self.invitePopout:SetPos( select( 1, self2:GetPos() )+self2:GetWide()+10, select( 2, self2:GetPos() ) )
        self.invitePopout:SizeTo( self.invitePopout:GetWide(), ScrH()*0.3, 0.2 )
        self.invitePopout.HeaderH = 60
        self.invitePopout:DockPadding( 25, self.invitePopout.HeaderH, 25, 0 )
        self.invitePopout.Paint = function( self2, w, h )
            BSHADOWS.BeginShadow( "partymenu_invitepanel" )
            BSHADOWS.SetShadowSize( "partymenu_invitepanel", w, h )
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )			
            BSHADOWS.EndShadow( "partymenu_invitepanel", x, y, 1, 2, 2, 255, 0, 0, false )
    
            draw.SimpleText( "PARTY INVITES", "MontserratBold40", w/2, self2.HeaderH/2-1, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
        self.invitePopout.Refresh = function( self2 )
            self2:Clear()

            local extraTall = 0
            for ply, v in pairs( BOTCHED_PARTY_INVITES or {} ) do
                if( not IsValid( ply ) ) then continue end

                local topText = ply:Nick()
                surface.SetFont( "MontserratBold30" )
                local topTextY = select( 2, surface.GetTextSize( topText ) )
        
                local steamID64 = ply:SteamID64()
                surface.SetFont( "MontserratBold18" )
                local bottomTextY = select( 2, surface.GetTextSize( steamID64 ) )
        
                local contentH = topTextY+bottomTextY-15

                local invitePanel = vgui.Create( "DPanel", self2 )
                invitePanel:Dock( TOP )
                invitePanel:SetTall( 75 )
                invitePanel:DockMargin( 0, 0, 0, 10 )
                invitePanel.Paint = function( self2, w, h )
                    local x, y = self2:LocalToScreen( 0, 0 )
        
                    local uniqueID = "partymenu_invite_" .. steamID64
                    BSHADOWS.BeginShadow( uniqueID )
                    draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
                    BSHADOWS.EndShadow( uniqueID, x, y, 1, 1, 1, 255, 0, 0, false )
        
                    draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 1 ) )
        
                    if( IsValid( self2.button ) ) then
                        self2.button:CreateFadeAlpha( false, 75 )
                        draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 2, self2.button.alpha ) )
                        BOTCHED.FUNC.DrawClickCircle( self2.button, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), 8 )
                    end
        
                    draw.SimpleText( topText, "MontserratBold30", w/2, (h/2)-(contentH/2)-8, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0 )
                    draw.SimpleText( steamID64, "MontserratBold18", w/2, (h/2)+(contentH/2)+3, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

                    if( CurTime() >= v+60 ) then
                        draw.SimpleText( "EXPIRED", "MontserratBold18", w-25, h/2, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                    else
                        draw.SimpleText( "EXPIRES IN " .. math.ceil( v+60-CurTime() ), "MontserratBold18", w-25, h/2, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                    end
                end
        
                local avatarIcon = vgui.Create( "botched_avatar", invitePanel )
                avatarIcon:SetPos( 7, 7 )
                avatarIcon:SetSize( invitePanel:GetTall()-14, invitePanel:GetTall()-14 )
                avatarIcon:SetSteamID( steamID64, 128 )
                avatarIcon:SetRounded( 8 )
        
                invitePanel.button = vgui.Create( "DButton", invitePanel )
                invitePanel.button:Dock( FILL )
                invitePanel.button:SetText( "" )
                invitePanel.button.Paint = function( self2, w, h ) end
                invitePanel.button.DoClick = function()
                    if( LocalPlayer():GetPartyID() != 0 ) then 
                        notification.AddLegacy( "You must leave your current party first!", 1, 3 )
                        return 
                    end

                    BOTCHED.FUNC.DermaQuery( "Are you sure you want to accept this invite?", "PARTY", "Yes", function()
                        net.Start( "Botched.SendAcceptPartyInvite" )
                            net.WriteEntity( ply )
                        net.SendToServer()
                    end, "No" )
                end

                extraTall = extraTall+75+((extraTall > 0 and 10) or 25)
            end

            self2:SizeTo( self2:GetWide(), self2.HeaderH+extraTall, 0.2 )
        end
        self.invitePopout:Refresh()
    end

    inviteButton:UpdateSize()

    hook.Add( "Botched.Hooks.PartyInvitesUpdated", self, function()
        inviteButton:UpdateSize()

        if( IsValid( self.invitePopout ) ) then
            self.invitePopout:Refresh()
        end
    end )

    bottomButtonPanel = vgui.Create( "DPanel", self )
	bottomButtonPanel:SetSize( self.rightPanel:GetWide(), 50 )
	bottomButtonPanel:SetPos( select( 1, self.rightPanel:GetPos() ), select( 2, self.rightPanel:GetPos() )+self.rightPanel:GetTall()+10 )
	bottomButtonPanel.Paint = function( self2, w, h ) end

    surface.SetFont( "MontserratBold25" )
    local textX, textY = surface.GetTextSize( "CLOSE" )

    local iconSize = 16
    local contentW = textX+iconSize+10

    local closeButton = vgui.Create( "DButton", bottomButtonPanel )
	closeButton:Dock( RIGHT )
	closeButton:SetWide( textX+50+25 )
	closeButton:SetText( "" )
    local closeMat = Material( "materials/botched/icons/close_16.png" )
	closeButton.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( false, 75 )

        BSHADOWS.BeginShadow( "partymenu_closebutton" )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )	
        BSHADOWS.EndShadow( "partymenu_closebutton", x, y, 1, 2, 2, 255, 0, 0, false )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, self2.alpha ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 1 ), 8 )

        local textColor = BOTCHED.FUNC.GetTheme( 4, 75+(180*(self2.alpha/75)) )

        surface.SetDrawColor( textColor )
		surface.SetMaterial( closeMat )
		surface.DrawTexturedRect( (w/2)-(contentW/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( "CLOSE", "MontserratBold25", (w/2)+(contentW/2), h/2-1, textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	end
    closeButton.DoClick = function()
        self:Remove()
    end

    local function CreateLeaveButton()
        if( IsValid( self.leaveButton ) ) then return end

        surface.SetFont( "MontserratBold25" )
        local textX, textY = surface.GetTextSize( "LEAVE" )

        local iconSize = 16
        local contentW = textX+iconSize+10

        self.leaveButton = vgui.Create( "DButton", bottomButtonPanel )
        self.leaveButton:Dock( RIGHT )
        self.leaveButton:SetWide( textX+50+25 )
        self.leaveButton:DockMargin( 0, 0, 10, 0 )
        self.leaveButton:SetText( "" )
        local leaveMat = Material( "materials/botched/icons/exit.png" )
        self.leaveButton.Paint = function( self2, w, h )
            self2:CreateFadeAlpha( false, 75 )

            BSHADOWS.BeginShadow( "partymenu_leavebutton" )
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )	
            BSHADOWS.EndShadow( "partymenu_leavebutton", x, y, 1, 2, 2, 255, 0, 0, false )

            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, self2.alpha ) )

            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 1 ), 8 )

            local textColor = BOTCHED.FUNC.GetTheme( 4, 75+(180*(self2.alpha/75)) )

            surface.SetDrawColor( textColor )
            surface.SetMaterial( leaveMat )
            surface.DrawTexturedRect( (w/2)-(contentW/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( "LEAVE", "MontserratBold25", (w/2)+(contentW/2), h/2-1, textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
        end
        self.leaveButton.DoClick = function()
            BOTCHED.FUNC.DermaQuery( "Are you sure you want to leave this party?", "PARTY", "Yes", function()
                net.Start( "Botched.SendLeaveParty" )
                net.SendToServer()
            end, "No" )
        end
    end

    local function RefreshPartyID()
        partyID = LocalPlayer():GetPartyID()

        self.leftPanel:Clear()
        self.leftPanel:SetTall( 0 )

        self.rightPanel:Clear()
        self.rightPanel:SizeTo( self.rightPanel:GetWide(), 75+75, 0.2 )

        if( partyID != 0 ) then
            CreateLeaveButton()
            self.rightPanel:SetPos( (self:GetWide()/2)+(middleSpacing/2), (self:GetTall()/2)-(self.rightPanel:GetTall()/2) )
            self:Refresh()
        else
            if( IsValid( self.leaveButton ) ) then self.leaveButton:Remove() end
            self.rightPanel:Center()
            timer.Simple( 0.2, function()
                if( not IsValid( self ) ) then return end

                local createButton = vgui.Create( "DButton", self.rightPanel )
                createButton:Dock( TOP )
                createButton:SetTall( 50 )
                createButton:DockMargin( 25, 75, 25, 0 )
                createButton:SetText( "" )
                local createMat = Material( "materials/botched/icons/edit_24.png" )
                createButton.Paint = function( self2, w, h )
                    local x, y = self2:LocalToScreen( 0, 0 )

                    BSHADOWS.BeginShadow( "partymenu_create" )
                    draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
                    BSHADOWS.EndShadow( "partymenu_create", x, y, 1, 1, 1, 255, 0, 0, false )

                    draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 1 ) )

                    self2:CreateFadeAlpha( false, 75 )
                    draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 2, self2.alpha ) )
                    BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), 8 )

                    surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
                    surface.SetMaterial( createMat )
                    local iconSize = 24
                    surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

                    draw.SimpleText( "CREATE PARTY", "MontserratBold30", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
                end
                createButton.DoClick = function()
                    net.Start( "Botched.SendCreateParty" )
                    net.SendToServer()
                end
            end )
        end
    end
    RefreshPartyID()

    hook.Add( "Botched.Hooks.PartyIDUpdated", self, RefreshPartyID )

    hook.Add( "Botched.Hooks.PartyTableUpdated", self, function()
        self:Refresh()

        if( not self.currentPlayer ) then return end
        self:OpenPlayerInfo( self.currentPlayer )
    end )
end

function PANEL:Refresh()
    self.leftPanel:Clear()
    self.leftPanel:SetTall( 0 )

    local partyID = LocalPlayer():GetPartyID()
    local partyTable = BOTCHED.FUNC.GetPartyTable( partyID )

    if( not partyTable ) then return end

    self:OpenPlayerInfo( partyTable.Members[1] )

    local memberTall = 100
    local memberSpacing = 10

    self.leftPanel:SizeTo( self.leftPanel:GetWide(), self.leftPanel.HeaderH+50+(#partyTable.Members*(memberTall+memberSpacing))+((partyTable.Leader == LocalPlayer() and memberTall+memberSpacing) or 0)-memberSpacing, 0.2 )

    local leaderMat = Material( "materials/botched/icons/leader.png" )

    for k, ply in ipairs( partyTable.Members ) do
        if( not IsValid( ply ) ) then continue end

        local topText = ply:Nick()
        surface.SetFont( "MontserratBold30" )
        local topTextY = select( 2, surface.GetTextSize( topText ) )

        local steamID64 = ply:SteamID64()
        surface.SetFont( "MontserratBold18" )
        local bottomTextY = select( 2, surface.GetTextSize( steamID64 ) )

        local contentH = topTextY+bottomTextY-15

        local memberPanel = vgui.Create( "DPanel", self.leftPanel )
        memberPanel:Dock( TOP )
        memberPanel:SetTall( memberTall )
        memberPanel:DockMargin( 0, 0, 0, memberSpacing )
        memberPanel.Paint = function( self2, w, h )
            local x, y = self2:LocalToScreen( 0, 0 )

            local uniqueID = "partymenu_member_" .. k
            BSHADOWS.BeginShadow( uniqueID )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
            BSHADOWS.EndShadow( uniqueID, x, y, 1, 1, 1, 255, 0, 0, false )

            draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 1 ) )

            if( IsValid( self2.button ) ) then
                self2.button:CreateFadeAlpha( false, 75 )
                draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 2, self2.button.alpha ) )
                BOTCHED.FUNC.DrawClickCircle( self2.button, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), 8 )
            end

            if( partyTable.Leader == ply ) then
                surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
                surface.SetMaterial( leaderMat )
                local iconSize = 32
                surface.DrawTexturedRect( w-(h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
            end

            draw.SimpleText( topText, "MontserratBold30", w/2, (h/2)-(contentH/2)-8, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0 )
            draw.SimpleText( steamID64, "MontserratBold18", w/2, (h/2)+(contentH/2)+3, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        end

        local avatarIcon = vgui.Create( "botched_avatar", memberPanel )
        avatarIcon:SetPos( 7, 7 )
        avatarIcon:SetSize( memberPanel:GetTall()-14, memberPanel:GetTall()-14 )
        avatarIcon:SetSteamID( steamID64, 128 )
        avatarIcon:SetRounded( 8 )

        memberPanel.button = vgui.Create( "DButton", memberPanel )
        memberPanel.button:Dock( FILL )
        memberPanel.button:SetText( "" )
        memberPanel.button.Paint = function( self2, w, h ) end
        memberPanel.button.DoClick = function()
            self:OpenPlayerInfo( ply )
        end
    end

    surface.SetFont( "MontserratBold30" )
    local textX = surface.GetTextSize( "INVITE PLAYER" )

    local iconSize = 24
    local contentW = iconSize+textX+10

    if( partyTable.Leader == LocalPlayer() and #partyTable.Members < 5 ) then
        local addMemberButton = vgui.Create( "DButton", self.leftPanel )
        addMemberButton:Dock( TOP )
        addMemberButton:SetTall( memberTall )
        addMemberButton:DockMargin( 0, 0, 0, memberSpacing )
        addMemberButton:SetText( "" )
        local addMat = Material( "materials/botched/icons/add_24.png" )
        addMemberButton.Paint = function( self2, w, h )
            self2:CreateFadeAlpha( false, 75 )

            local x, y = self2:LocalToScreen( 0, 0 )

            local uniqueID = "partymenu_member_add"
            BSHADOWS.BeginShadow( uniqueID )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
            BSHADOWS.EndShadow( uniqueID, x, y, 1, 1, 1, 255, 0, 0, false )

            draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 1 ) )

            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, self2.alpha ) )

            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ), 8 )

            local textColor = BOTCHED.FUNC.GetTheme( 4, 75+(180*(self2.alpha/75)) )
            surface.SetDrawColor( textColor )
            surface.SetMaterial( addMat )
            surface.DrawTexturedRect( (w/2)-(contentW/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( "INVITE PLAYER", "MontserratBold30", (w/2)+(contentW/2), h/2-1, textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
        end
        addMemberButton.DoClick = function()
            local options = {}
            for k, v in ipairs( player.GetAll() ) do
                if( table.HasValue( partyTable.Members, v ) ) then continue end
                options[v] = v:Nick()
            end

            BOTCHED.FUNC.DermaComboRequest( "Who would you like to invite?", "PARTY", options, "", false, "Continue", function( value, key )
                net.Start( "Botched.SendInviteToParty" )
                    net.WriteEntity( key )
                net.SendToServer()
            end )
        end
    end
end

function PANEL:OpenPlayerInfo( ply )
    self.rightPanel:Clear()

    local partyID = LocalPlayer():GetPartyID()
    local partyTable = BOTCHED.FUNC.GetPartyTable( partyID )

    if( not partyTable or not IsValid( ply ) or not table.HasValue( partyTable.Members, ply ) ) then return end

    self.currentPlayer = ply

    local steamID64 = ply:SteamID64()

    local leaderMat = Material( "materials/botched/icons/leader.png" )

    local topText = ply:Nick()
    surface.SetFont( "MontserratBold50" )
    local topTextY = select( 2, surface.GetTextSize( topText ) )

    local bottomText = "LEVEL " .. ply:GetLevel()
    surface.SetFont( "MontserratBold30" )
    local bottomTextY = select( 2, surface.GetTextSize( bottomText ) )

    local contentH = topTextY+bottomTextY-25

    local infoPanel = vgui.Create( "DPanel", self.rightPanel )
    infoPanel:Dock( TOP )
    infoPanel:SetTall( ScrH()*0.1 )
    infoPanel.Paint = function( self2, w, h )
        draw.SimpleText( topText, "MontserratBold50", w/2, (h/2)-(contentH/2)-8, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0 )
        draw.SimpleText( bottomText, "MontserratBold30", w/2, (h/2)+(contentH/2)+3, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

        if( partyTable.Leader == ply ) then
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
            surface.SetMaterial( leaderMat )
            local iconSize = 32
            surface.DrawTexturedRect( w-(h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
    end

    local modelPanel = vgui.Create( "DModelPanel", self.rightPanel )
    modelPanel:Dock( TOP )
    modelPanel:SetTall( ScrH()*0.2 )
    modelPanel:SetCursor( "arrow" )
    modelPanel:SetModel( ply:GetModel() )
    modelPanel:SetFOV( 80 )
    modelPanel.LayoutEntity = function() end
    if( IsValid( modelPanel.Entity ) ) then
        local bone = modelPanel.Entity:LookupBone( "ValveBiped.Bip01_Head1" )
        if( bone ) then
            local headpos = modelPanel.Entity:GetBonePosition( bone )
            modelPanel:SetLookAt( headpos )
            modelPanel:SetCamPos( headpos-Vector( -35, 0, 0 ) )
        end
    end

    local statsPanel = vgui.Create( "DPanel", self.rightPanel )
    statsPanel:Dock( TOP )
    statsPanel:DockMargin( 25, 0, 25, 0 )
    statsPanel:DockPadding( 0, 2, 0, 0 )
    statsPanel.Paint = function( self2, w, h )
        local x, y = self2:LocalToScreen( 0, 0 )

        BSHADOWS.BeginShadow( "partymenu_right_spacer" )
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
        surface.DrawRect( x, y, w, 2 )
        BSHADOWS.EndShadow( "partymenu_right_spacer", x, y, 1, 1, 1, 255, 0, 0, false )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 100 ) )
        surface.DrawRect( 0, 0, w, 2 )
    end

    surface.SetFont( "MontserratBold40" )
    local topTextX, topTextY = surface.GetTextSize( string.Comma( ply:GetMaxHealth() ) )

    surface.SetFont( "MontserratBold20" )
    local bottomTextX, bottomTextY = surface.GetTextSize( "HEALTH" )

    local contentH = topTextY+bottomTextY-23
    local healthMat = Material( "materials/botched/icons/heart.png" )

    local healthPanel = vgui.Create( "DPanel", statsPanel )
    healthPanel:Dock( TOP )
    healthPanel:SetTall( 65 )
    healthPanel:DockMargin( 0, 25, 0, 0 )
    healthPanel.Paint = function( self2, w, h )
        local x, y = self2:LocalToScreen( 0, 0 )

        BSHADOWS.BeginShadow( "partymenu_right_health" )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
        BSHADOWS.EndShadow( "partymenu_right_health", x, y, 1, 1, 1, 255, 0, 0, false )

        draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 1 ) )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
        surface.SetMaterial( healthMat )
        local iconSize = 32
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( string.Comma( ply:GetMaxHealth() ), "MontserratBold40", w/2, (h/2)-(contentH/2)-11, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0 )
        draw.SimpleText( "HEALTH", "MontserratBold20", w/2, (h/2)+(contentH/2)+3, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end

    local experiencePanel = vgui.Create( "DPanel", statsPanel )
    experiencePanel:Dock( TOP )
    experiencePanel:SetTall( 50 )
    experiencePanel:DockMargin( 0, 10, 0, 0 )
    local iconMat = Material( "materials/botched/icons/exp_bottle.png" )
    experiencePanel.Paint = function( self2, w, h )
        local level, experience = ply:GetLevel(), ply:GetExperience()
        local nextLevelTable = BOTCHED.CONFIG.Levels[level+1]
        local requiredEXP = (nextLevelTable or {}).RequiredEXP or 1
        
        local x, y = self2:LocalToScreen( 0, 0 )
        BSHADOWS.BeginShadow( "partymenu_right_experience" )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
        BSHADOWS.EndShadow( "partymenu_right_experience", x, y, 1, 1, 1, 255, 0, 0, false )

        draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 1 ) )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
        surface.SetMaterial( iconMat )
        local iconSize = 24
        surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( "EXP", "MontserratBold40", h, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), 0, TEXT_ALIGN_CENTER )

        draw.SimpleText( math.Round( math.Clamp( experience/requiredEXP, 0, 1 )*100, 2 ) .. "%", "MontserratBold30", w-15, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

        draw.SimpleText( string.Comma( experience ) .. "/" .. string.Comma( requiredEXP ), "MontserratMedium20", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    local actionPanel = vgui.Create( "DPanel", statsPanel )
    actionPanel:Dock( TOP )
    actionPanel:SetTall( 50 )
    actionPanel:DockMargin( 0, 10, 0, 0 )
    actionPanel.Paint = function( self2, w, h ) end

    local actions = {
        {
            Title = "View Profile",
            Icon = Material( "materials/botched/icons/view.png" ),
            ClickFunc = function() 
                gui.OpenURL( "https://steamcommunity.com/profiles/" .. steamID64 )
            end
        }
    }

    if( partyTable.Leader == LocalPlayer() and ply != LocalPlayer() ) then
        table.insert( actions, {
            Title = "Kick Player",
            Icon = Material( "materials/botched/icons/kick_24.png" ),
            ClickFunc = function() 
                BOTCHED.FUNC.DermaQuery( "Are you sure you want to kick this player?", "PARTY", "Yes", function()
                    net.Start( "Botched.SendKickFromParty" )
                        net.WriteEntity( ply )
                    net.SendToServer()
                end, "No" )
            end
        } )

        table.insert( actions, {
            Title = "Transfer Leadership",
            Icon = Material( "materials/botched/icons/transfer.png" ),
            ClickFunc = function() 
                BOTCHED.FUNC.DermaQuery( "Are you sure you want to transfer ownership to this player?", "PARTY", "Yes", function()
                    net.Start( "Botched.SendTransferPartyOwnership" )
                        net.WriteEntity( ply )
                    net.SendToServer()
                end, "No" )
            end
        } )
    end

    for k, v in ipairs( actions ) do
        local actionButton = vgui.Create( "DButton", actionPanel )
        actionButton:Dock( LEFT )
        actionButton:SetWide( actionPanel:GetTall() )
        actionButton:DockMargin( 0, 0, 10, 0 )
        actionButton:SetText( "" )
        actionButton.Paint = function( self2, w, h )
            self2:CreateFadeAlpha( false, 75 )

            BSHADOWS.BeginShadow( "partymenu_actionbutton_" .. k )
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )	
            BSHADOWS.EndShadow( "partymenu_actionbutton_" .. k, x, y, 1, 1, 1, 255, 0, 0, false )

            draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 1 ) )
            draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 2, self2.alpha ) )

            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2, 150 ), 8 )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75+(180*(self2.alpha/75)) ) )
            surface.SetMaterial( v.Icon )
            local iconSize = 24
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
        actionButton.DoClick = v.ClickFunc
    end

    statsPanel:SetTall( 27+healthPanel:GetTall()+10+experiencePanel:GetTall()+10+actionPanel:GetTall() )

    self.rightPanel:SizeTo( self.rightPanel:GetWide(), infoPanel:GetTall()+modelPanel:GetTall()+statsPanel:GetTall()+25, 0.2 )
end

function PANEL:Paint( w, h )
    BOTCHED.FUNC.DrawBlur( self, 4, 4 )
end

vgui.Register( "botched_partymenu", PANEL, "DFrame" )