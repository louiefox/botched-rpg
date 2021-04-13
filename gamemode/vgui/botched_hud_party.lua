local PANEL = {}

function PANEL:Init()
    self:SetSize( ScrW()*0.1, 0 )
    self:SetPos( 25, 25+BOTCHED_HUD.map:GetTall()+25 )
    self:ParentToHUD()

    hook.Add( "Botched.Hooks.PartyIDUpdated", self, self.Refresh )
    hook.Add( "Botched.Hooks.PartyTableUpdated", self, self.Refresh )
end

function PANEL:Refresh()
    self:Clear()
    self:SetTall( 0 )

    local partyID = LocalPlayer():GetPartyID()
    if( partyID == 0 ) then return end

    local partyTable = BOTCHED.FUNC.GetPartyTable( partyID )
    if( not partyTable ) then return end

    local leaderMat = Material( "materials/botched/icons/crown_24.png" )
    for k, v in ipairs( partyTable.Members ) do
        surface.SetFont( "MontserratBold25" )
        local nameY = select( 2, surface.GetTextSize( v:Nick() ) )

        surface.SetFont( "MontserratBold20" )
        local levelY = select( 2, surface.GetTextSize( "Level " .. v:GetLevel() ) )

        local contentH = nameY+levelY-5

        local memberEntry = vgui.Create( "DPanel", self )
        memberEntry:Dock( TOP )
        memberEntry:SetTall( BOTCHED.FUNC.ScreenScale( 70 ) )
        memberEntry:DockMargin( 0, 0, 0, 10 )
        local healthBarH = BOTCHED.FUNC.ScreenScale( 8 )
        memberEntry.Paint = function( self2, w, h )
            if( not IsValid( v ) ) then return end

            BOTCHED.FUNC.DrawBlur( self2, 4, 4 )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, 200 ) )
    
            draw.SimpleText( v:Nick(), "MontserratBold25", h, ((h-healthBarH)/2)-(contentH/2), BOTCHED.FUNC.GetTheme( 4 ) )

            local levelText = "Level " .. v:GetLevel()
            draw.SimpleText( levelText, "MontserratBold20", h, ((h-healthBarH)/2)+(contentH/2), BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_BOTTOM )

            BOTCHED.FUNC.DrawPartialRoundedBox( 8, 0, h-healthBarH, w, healthBarH, BOTCHED.FUNC.GetTheme( 1 ), w, healthBarH*2, 0, h-(2*healthBarH) )

            BOTCHED.FUNC.DrawRoundedMask( 8, 0, h-(2*healthBarH), w, healthBarH*2, function()
                surface.SetDrawColor( BOTCHED.CONFIG.Themes.DarkRed )
                surface.DrawRect( 0, h-healthBarH, w*math.Clamp( (v:Health()/v:GetMaxHealth()), 0, 1 ), healthBarH )
            end )

            draw.SimpleText( math.max( 0, v:Health() ) .. " HP", "MontserratBold20", w-10, h-healthBarH-5, BOTCHED.CONFIG.Themes.DarkRed, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

            if( partyTable.Leader == v ) then
                surface.SetDrawColor( 243, 156, 18 )
                surface.SetMaterial( leaderMat )
                local iconSize = 24
                surface.DrawTexturedRect( w-10-iconSize, 5, iconSize, iconSize )
            end
        end
    
        memberEntry.model = vgui.Create( "DModelPanel", memberEntry )
        memberEntry.model:SetSize( memberEntry:GetTall()-healthBarH, memberEntry:GetTall()-healthBarH )
        memberEntry.model:SetModel( "" )
        memberEntry.model.Think = function( self2 )
            if( IsValid( v ) and v:GetModel() != self2:GetModel() ) then
                self2:SetModel( v:GetModel() )
                local bone = self2.Entity:LookupBone( "ValveBiped.Bip01_Head1" )
                if( bone ) then
                    local headpos = self2.Entity:GetBonePosition( bone )
                    self2:SetLookAt( headpos )
                    self2:SetCamPos( headpos-Vector( -25, 0, 0 ) )
                end
            end
        end
        function memberEntry.model:LayoutEntity( Entity ) return end
        modelDistance = (memberEntry:GetTall()-memberEntry.model:GetTall())/2

        self:SetTall( self:GetTall()+memberEntry:GetTall()+((self:GetTall() > 0 and 10) or 0) )
    end
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_hud_party", PANEL, "DPanel" )