local hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true
}

hook.Add( "HUDShouldDraw", "Botched.HUDShouldDraw.Hide", function( name )
	if( hide[name] ) then return false end
end )

hook.Add( "DrawDeathNotice", "Botched.DrawDeathNotice.Hide", function()
	return 0, 0
end )

if( IsValid( BOTCHED_HUD ) ) then
    BOTCHED_HUD:Remove()
end

local function createDermaHUD( ply )
    if( IsValid( BOTCHED_HUD ) ) then
        BOTCHED_HUD:Remove()
    end

    BOTCHED_HUD = vgui.Create( "DPanel" )
    BOTCHED_HUD:ParentToHUD()
    BOTCHED_HUD:SetSize( ScrW(), ScrH() )
    BOTCHED_HUD.Think = function( self2 )
        local shouldDraw = hook.Run( "HUDShouldDraw", "CHudGMod" )
        if( not shouldDraw ) then
            self2:Remove()
        end
    end
    BOTCHED_HUD.Paint = function() end

    BOTCHED_HUD.main = vgui.Create( "DPanel", BOTCHED_HUD )
    BOTCHED_HUD.main:SetSize( ScrW()*0.13, 105 )
    BOTCHED_HUD.main:SetPos( 10, ScrH()-10-BOTCHED_HUD.main:GetTall() )
    BOTCHED_HUD.main.Paint = function( self2, w, h )
        BOTCHED.FUNC.DrawBlur( self2, 4, 4 )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, 200 ) )

        local boxSize = BOTCHED_HUD.model:GetTall()
        draw.RoundedBox( 8, (h/2)-(boxSize/2), (h/2)-(boxSize/2), boxSize, boxSize, BOTCHED.FUNC.GetTheme( 1, 100 ) )
    end

    BOTCHED_HUD.model = vgui.Create( "DModelPanel", BOTCHED_HUD.main )
    BOTCHED_HUD.model:SetSize( BOTCHED_HUD.main:GetTall()*0.8, BOTCHED_HUD.main:GetTall()*0.8 )
    BOTCHED_HUD.model:SetPos( (BOTCHED_HUD.main:GetTall()/2)-(BOTCHED_HUD.model:GetTall()/2), (BOTCHED_HUD.main:GetTall()/2)-(BOTCHED_HUD.model:GetTall()/2) )
    BOTCHED_HUD.model:SetModel( "" )
    function BOTCHED_HUD.model:LayoutEntity( Entity ) return end

    local modelDistance = (BOTCHED_HUD.main:GetTall()-BOTCHED_HUD.model:GetTall())/2

    local nameText = ply:Nick()
    surface.SetFont( "MontserratBold30" )
    local nameX, nameY = surface.GetTextSize( nameText )

    BOTCHED_HUD.name = vgui.Create( "DPanel", BOTCHED_HUD.main )
    BOTCHED_HUD.name:SetSize( nameX, nameY-7 )
    BOTCHED_HUD.name:SetPos( modelDistance+BOTCHED_HUD.model:GetWide()+10, modelDistance+10 )
    BOTCHED_HUD.name.Paint = function( self2, w, h )
        nameText = ply:Nick()
        
        BSHADOWS.BeginShadow( "hud_shadow_name" )
        local x, y = self2:LocalToScreen( 0, -5 )
        draw.SimpleText( nameText, "MontserratBold30", x, y, BOTCHED.FUNC.GetTheme( 1 ) )
        BSHADOWS.EndShadow( "hud_shadow_name", x, y, 2, 1, 1, 255, 0, 0, false )

        draw.SimpleText( nameText, "MontserratBold30", 0, -5, BOTCHED.FUNC.GetTheme( 4, 150 ) )
    end

    local namePanelX, namePanelY = BOTCHED_HUD.name:GetPos()

    BOTCHED_HUD.levelTxt = vgui.Create( "DPanel", BOTCHED_HUD.main )
    BOTCHED_HUD.levelTxt.UpdateSize = function( levelX, levelY )
        BOTCHED_HUD.levelTxt:SetSize( levelX, levelY )
        BOTCHED_HUD.levelTxt:SetPos( BOTCHED_HUD.main:GetWide()-10-BOTCHED_HUD.levelTxt:GetWide(), namePanelY+BOTCHED_HUD.name:GetTall()-BOTCHED_HUD.levelTxt:GetTall() )
    end
    BOTCHED_HUD.levelTxt.Paint = function( self2, w, h )
        local levelText = "Lvl. " .. ply:GetLevel()
        surface.SetFont( "MontserratBold22" )
        local levelX, levelY = surface.GetTextSize( levelText )

        if( w != levelX or h != levelY ) then
            self2.UpdateSize( levelX, levelY )
        end

        BSHADOWS.BeginShadow( "hud_shadow_leveltxt" )
        BSHADOWS.SetShadowSize( "hud_shadow_leveltxt", w, h )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.SimpleText( levelText, "MontserratBold22", x, y, BOTCHED.FUNC.GetTheme( 1 ) )
        BSHADOWS.EndShadow( "hud_shadow_leveltxt", x, y, 2, 1, 1, 255, 0, 0, false )

        draw.SimpleText( levelText, "MontserratBold22", 0, 0, BOTCHED.FUNC.GetTheme( 4, 150 ) )
    end

    local rightTextW, healthX, staminaX
    local function RefreshRightTextW()
        surface.SetFont( "MontserratBold25" )
        healthX = surface.GetTextSize( math.max( 0, ply:Health() ) )

        surface.SetFont( "MontserratBold25" )
        staminaX = surface.GetTextSize( math.max( 0, ply:Stamina() ) )

        rightTextW = math.max( healthX, staminaX )
    end
    RefreshRightTextW()

    local progressBarH = 10
    BOTCHED_HUD.stamina = vgui.Create( "DPanel", BOTCHED_HUD.main )
    BOTCHED_HUD.stamina:SetSize( BOTCHED_HUD.main:GetWide()-namePanelX-10, progressBarH )
    BOTCHED_HUD.stamina:SetPos( namePanelX, BOTCHED_HUD.main:GetTall()-modelDistance-BOTCHED_HUD.stamina:GetTall()-10 )
    BOTCHED_HUD.stamina.Paint = function( self2, w, h )
        surface.SetFont( "MontserratBold25" )
        local curStaminaX = surface.GetTextSize( math.max( 0, ply:Stamina() ) )

        if( staminaX != curStaminaX ) then
            RefreshRightTextW()
        end

        local progressBarW = w-rightTextW-5
        draw.RoundedBox( progressBarH/2, 0, 0, progressBarW, progressBarH, BOTCHED.FUNC.GetTheme( 1, 150 ) )

        BOTCHED.FUNC.DrawRoundedMask( progressBarH/2, 0, 0, progressBarW, progressBarH, function()
            surface.SetDrawColor( BOTCHED.CONFIG.Themes.Orange )
            surface.DrawRect( 0, 0, progressBarW*math.Clamp( (ply:Stamina()/ply:GetMaxStamina()), 0, 1 ), progressBarH )
        end )

        BSHADOWS.BeginShadow( "hud_shadow_stamina" )
        BSHADOWS.SetShadowSize( "hud_shadow_stamina", curStaminaX, h )
        local x, y = self2:LocalToScreen( w-(rightTextW/2), h/2-2 )
        draw.SimpleText( math.max( 0, ply:Stamina() ), "MontserratBold25", x, y, BOTCHED.CONFIG.Themes.Orange, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        BSHADOWS.EndShadow( "hud_shadow_stamina", x, y, 1, 1, 1, 255, 0, 0, false )
    end

    local staminaBarX, staminaBarY = BOTCHED_HUD.stamina:GetPos()

    BOTCHED_HUD.health = vgui.Create( "DPanel", BOTCHED_HUD.main )
    BOTCHED_HUD.health:SetSize( BOTCHED_HUD.stamina:GetWide(), progressBarH )
    BOTCHED_HUD.health:SetPos( namePanelX, staminaBarY-BOTCHED_HUD.health:GetTall()-10 )
    BOTCHED_HUD.health.Paint = function( self2, w, h )
        surface.SetFont( "MontserratBold25" )
        local curHealthX = surface.GetTextSize( math.max( 0, ply:Health() ) )

        if( healthX != curHealthX ) then
            RefreshRightTextW()
        end

        local progressBarW = w-rightTextW-5
        draw.RoundedBox( progressBarH/2, 0, 0, progressBarW, progressBarH, BOTCHED.FUNC.GetTheme( 1, 150 ) )

        BOTCHED.FUNC.DrawRoundedMask( progressBarH/2, 0, 0, progressBarW, progressBarH, function()
            surface.SetDrawColor( BOTCHED.CONFIG.Themes.Red )
            surface.DrawRect( 0, 0, progressBarW*math.Clamp( (ply:Health()/ply:GetMaxHealth()), 0, 1 ), progressBarH )
        end )

        BSHADOWS.BeginShadow( "hud_shadow_health" )
        BSHADOWS.SetShadowSize( "hud_shadow_health", curHealthX, h )
        local x, y = self2:LocalToScreen( w-(rightTextW/2), h/2-2 )
        draw.SimpleText( math.max( 0, ply:Health() ), "MontserratBold25", x, y, BOTCHED.CONFIG.Themes.Red, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        BSHADOWS.EndShadow( "hud_shadow_health", x, y, 1, 1, 1, 255, 0, 0, false )
    end

    BOTCHED_HUD.ammo = vgui.Create( "DPanel", BOTCHED_HUD )
    BOTCHED_HUD.ammo:SetSize( ScrW()*0.075, 80 )
    BOTCHED_HUD.ammo:SetPos( ScrW()-10-BOTCHED_HUD.ammo:GetWide(), ScrH()-10-BOTCHED_HUD.ammo:GetTall() )
    BOTCHED_HUD.ammo.Paint = function( self2, w, h )
        local activeWeapon = ply:GetActiveWeapon()
        if( not IsValid( activeWeapon ) or activeWeapon:GetMaxClip1() < 0 ) then return end

        BOTCHED.FUNC.DrawBlur( self2, 4, 4 )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, 200 ) )

        local ammoText = activeWeapon:Clip1() .. "/" .. activeWeapon:GetMaxClip1()
        surface.SetFont( "MontserratBold50" )
        local ammoX, ammoY = surface.GetTextSize( ammoText )

        local reserveText = "RESERVE " .. ply:GetAmmoCount( activeWeapon:GetPrimaryAmmoType() )
        surface.SetFont( "MontserratBold20" )
        local reserveX, reserveY = surface.GetTextSize( reserveText )

        local contentH = ammoY+reserveY-18

        BSHADOWS.BeginShadow( "hud_shadow_ammo_txt" )
        BSHADOWS.SetShadowSize( "hud_shadow_ammo_txt", ammoX, ammoY )
        local x, y = self2:LocalToScreen( w/2, (h/2)-(contentH/2)-10 )
        draw.SimpleText( ammoText, "MontserratBold50", x, y, BOTCHED.FUNC.GetTheme( 4, 150 ), TEXT_ALIGN_CENTER )
        BSHADOWS.EndShadow( "hud_shadow_ammo_txt", x, y, 2, 1, 1, 255, 0, 0, false )

        draw.SimpleText( reserveText, "MontserratBold20", w/2, (h/2)+(contentH/2)+3, BOTCHED.FUNC.GetTheme( 4, 150 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end

    BOTCHED_HUD.level = vgui.Create( "DPanel", BOTCHED_HUD )
    BOTCHED_HUD.level:SetSize( ScrW()*0.5, 70 )
    BOTCHED_HUD.level:SetPos( (ScrW()/2)-(BOTCHED_HUD.level:GetWide()/2), 0 )
    local lerpExperience = 0
    BOTCHED_HUD.level.Paint = function( self2, w, h )
        local level, experience = ply:GetLevel(), ply:GetExperience()
        local nextLevelTable = BOTCHED.CONFIG.Levels[level+1]
        local requiredEXP = (nextLevelTable or {}).RequiredEXP or 1
        lerpExperience = Lerp( RealFrameTime()*2, lerpExperience, experience )

        if( not nextLevelTable or (not IsValid( BOTCHED_SCOREBOARD ) and lerpExperience >= experience-0.5 ) ) then 
            if( self2:GetAlpha() == 255 ) then
                self2:AlphaTo( 0, 0.2 )
            end
        elseif( self2:GetAlpha() == 0 ) then
            self2:AlphaTo( 255, 0.2 )
        end

        BOTCHED.FUNC.DrawBlur( self2, 4, 4 )
        draw.RoundedBoxEx( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, 200 ), false, false, true, true )

        local progressBarW, progressBarH = w-30, 16

        BSHADOWS.BeginShadow( "hud_shadow_level" )
        BSHADOWS.SetShadowSize( "hud_shadow_level", w, h )
        local x, y = self2:LocalToScreen( (w/2)-(progressBarW/2), 15 )
        draw.RoundedBox( 8, x, y, progressBarW, progressBarH, BOTCHED.FUNC.GetTheme( 1 ) )
        BSHADOWS.EndShadow( "hud_shadow_level", x, y, 2, 1, 1, 255, 0, 0, false )

        draw.RoundedBox( 8, (w/2)-(progressBarW/2), 15, progressBarW, progressBarH, BOTCHED.FUNC.GetTheme( 2, 100 ) )

        BOTCHED.FUNC.DrawRoundedMask( 8, (w/2)-(progressBarW/2), 15, progressBarW, progressBarH, function()
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3 ) )
            surface.DrawRect( (w/2)-(progressBarW/2), 15, math.Clamp( progressBarW*(lerpExperience/requiredEXP), 0, progressBarW ), progressBarH )
        end )

        draw.SimpleText( string.Comma( experience ) .. " EXP", "MontserratBold25", 15, h-5, BOTCHED.FUNC.GetTheme( 4, 150 ), 0, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( string.Comma( requiredEXP ) .. " EXP", "MontserratBold25", w-15, h-5, BOTCHED.FUNC.GetTheme( 4, 150 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( "LEVEL " .. ply:GetLevel(), "MontserratBold30", w/2, h-5, BOTCHED.FUNC.GetTheme( 4, 150 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
    end

    local slotSize, slotSpacing = 60, 5

    BOTCHED_HUD.hotbar = vgui.Create( "DPanel", BOTCHED_HUD )
    BOTCHED_HUD.hotbar:SetSize( (9*(slotSize+slotSpacing))+slotSpacing, slotSize+(2*slotSpacing) )
    BOTCHED_HUD.hotbar:SetPos( (ScrW()/2)-(BOTCHED_HUD.hotbar:GetWide()/2), ScrH()-BOTCHED_HUD.hotbar:GetTall()-10 )
    BOTCHED_HUD.hotbar.Paint = function( self2, w, h )
        BOTCHED.FUNC.DrawBlur( self2, 4, 4 )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 1, 200 ) )
    end

    local abilities = ply:GetAbilities()
    local slotBinds = BOTCHED.FUNC.GetSlotBinds()

    local abilityCooldowns = ply:GetAbilityCooldowns()

    local slotPanels = {}
    for i = 1, 9 do
        local abilityKey = abilities[i]
        local abilityConfig = abilityKey and BOTCHED.DEVCONFIG.CharacterAbilities[abilityKey]

        local slotBind = slotBinds[i]
        local slotBindName = input.GetKeyName( slotBind )

        local slotPanel = vgui.Create( "DPanel", BOTCHED_HUD.hotbar )
        slotPanel:Dock( LEFT )
        slotPanel:SetWide( slotSize )
        slotPanel:DockMargin( slotSpacing, slotSpacing, 0, slotSpacing )
        slotPanel.Paint = function( self2, w, h )
            local uniqueID = "hud_shadow_slot_" .. i
            BSHADOWS.BeginShadow( uniqueID )
            local x, y = self2:LocalToScreen( 0, 0 )
            draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
            BSHADOWS.EndShadow( uniqueID, x, y, 1, 1, 1, 255, 0, 0, false )

            draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 1 ) )

            if( abilityConfig ) then
                BOTCHED.FUNC.DrawRoundedMask( 8, 2, 2, w-4, h-4, function()
                    surface.SetMaterial( abilityConfig.Icon )
                    surface.SetDrawColor( 255, 255, 255 )
                    surface.DrawTexturedRect( 2, 2, w-4, h-4 )
                end )
            end

            draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 2, (self2.useAlphaFraction or 0)*125 ) )

            local useTime = abilityCooldowns[abilityKey]
            if( useTime and CurTime() < useTime+abilityConfig.Cooldown ) then
                local x, y = self2:LocalToScreen( 2, 2 )
                render.SetScissorRect( x, y, x+(w-4), y+(h-4), true )
                BOTCHED.FUNC.DrawRoundedMask( 8, 2, 2, w-4, h-4, function()
                    local timeRemaining = (useTime+abilityConfig.Cooldown)-CurTime()

                    local sideRadius = (w-4)/2
                    local radius = math.sqrt( (sideRadius^2)*2 )
                    BOTCHED.FUNC.DrawArc( w/2, h/2, radius, radius, 0, 360*math.Clamp( timeRemaining/abilityConfig.Cooldown, 0, 1 ), BOTCHED.FUNC.GetTheme( 3, 50 ) )

                    draw.SimpleTextOutlined( math.Round( timeRemaining ), "MontserratBold30", w/2, h/2, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, BOTCHED.FUNC.GetTheme( 1 ) )
                end )
                render.SetScissorRect( 0, 0, 0, 0, false )
            end

            if( slotBindName ) then
                draw.SimpleTextOutlined( slotBindName, "MontserratBold25", w-2, h-2, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM, 2, BOTCHED.FUNC.GetTheme( 1 ) )
            end
        end
        slotPanel.AttemptUse = function( self2 )
            local anim = self2:NewAnimation( 0.3, 0, -1 )
            anim.Think = function( anim, pnl, fraction )
                if( fraction <= 0.5 ) then
                    self2.useAlphaFraction = fraction/0.5
                else
                    self2.useAlphaFraction = 1-((fraction-0.5)/0.5)
                end
            end
        end

        slotPanels[i] = slotPanel
    end

    hook.Add( "Botched.Hooks.HotbarSlotAttemptUse", BOTCHED_HUD.hotbar, function( self, slotNum )
        slotPanels[slotNum]:AttemptUse()
    end )

    hook.Add( "Botched.Hooks.HotbarSlotUsed", BOTCHED_HUD.hotbar, function()
        abilityCooldowns = ply:GetAbilityCooldowns()
    end )

    local slotSize, slotSpacing = 30, 10

    BOTCHED_HUD.effects = vgui.Create( "DPanel", BOTCHED_HUD )
    BOTCHED_HUD.effects:SetTall( slotSize )
    BOTCHED_HUD.effects:SetPos( (ScrW()/2)-(BOTCHED_HUD.effects:GetWide()/2), ScrH()-BOTCHED_HUD.hotbar:GetTall()-10-BOTCHED_HUD.effects:GetTall()-10 )
    BOTCHED_HUD.effects.Paint = function( self2, w, h ) end
    BOTCHED_HUD.effects.RefreshEffects = function( self2 )
        BOTCHED_HUD.effects:Clear()
        BOTCHED_HUD.effects:SetWide( 0 )

        local playerEffects = ply:GetPlayerEffects()
        for k, v in pairs( playerEffects ) do
            local effectConfig = BOTCHED.DEVCONFIG.PlayerEffects[k]

            local slotPanel = vgui.Create( "DPanel", self2 )
            slotPanel:Dock( LEFT )
            slotPanel:SetWide( slotSize )
            slotPanel:DockMargin( 0, 0, slotSpacing, 0 )
            slotPanel.Paint = function( self2, w, h )
                local uniqueID = "hud_shadow_effect_" .. k
                BSHADOWS.BeginShadow( uniqueID )
                local x, y = self2:LocalToScreen( 0, 0 )
                draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )
                BSHADOWS.EndShadow( uniqueID, x, y, 1, 1, 1, 255, 0, 0, false )
    
                if( effectConfig ) then
                    BOTCHED.FUNC.DrawRoundedMask( 8, 2, 2, w-4, h-4, function()
                        surface.SetMaterial( effectConfig.Icon )
                        surface.SetDrawColor( 255, 255, 255 )
                        surface.DrawTexturedRect( 2, 2, w-4, h-4 )
                    end )
                end

                local useTime, duration = v[1], v[2]
                if( CurTime() < useTime+duration ) then
                    local x, y = self2:LocalToScreen( 2, 2 )
                    render.SetScissorRect( x, y, x+(w-4), y+(h-4), true )
                    BOTCHED.FUNC.DrawRoundedMask( 8, 2, 2, w-4, h-4, function()
                        local timeRemaining = (useTime+duration)-CurTime()

                        local sideRadius = (w-4)/2
                        local radius = math.sqrt( (sideRadius^2)*2 )
                        BOTCHED.FUNC.DrawArc( w/2, h/2, radius, radius, 0, 360*math.Clamp( timeRemaining/duration, 0, 1 ), BOTCHED.FUNC.GetTheme( 3, 50 ) )
                    end )
                    render.SetScissorRect( 0, 0, 0, 0, false )
                end
            end

            self2:SetWide( self2:GetWide()+slotSize+(self2:GetWide() > 0 and slotSpacing or 0) )
        end

        self2:SetPos( (ScrW()/2)-(self2:GetWide()/2), ScrH()-BOTCHED_HUD.hotbar:GetTall()-10-self2:GetTall()-10 )
    end

    hook.Add( "Botched.Hooks.PlayerEffectAdded", BOTCHED_HUD.effects, BOTCHED_HUD.effects.RefreshEffects )
    hook.Add( "Botched.Hooks.PlayerEffectRemoved", BOTCHED_HUD.effects, BOTCHED_HUD.effects.RefreshEffects )

    BOTCHED_HUD.map = vgui.Create( "botched_hud_map", BOTCHED_HUD )
    BOTCHED_HUD.map:SetPos( 25, 25 )
end

local function createDermaDeathHUD( ply )
    if( IsValid( BOTCHED_DEATH_HUD ) ) then
        BOTCHED_DEATH_HUD:Remove()
    end

    local startTime = CurTime()
    local duration = 5

    timer.Simple( duration, function()
        if( not IsValid( BOTCHED_DEATH_HUD ) ) then return end
        BOTCHED_DEATH_HUD:SetKeyboardInputEnabled( false )
        BOTCHED_DEATH_HUD:SetMouseInputEnabled( false )
    end )

    BOTCHED_DEATH_HUD = vgui.Create( "DFrame" )
    BOTCHED_DEATH_HUD:SetSize( ScrW(), ScrH() )
    BOTCHED_DEATH_HUD:MakePopup()
    BOTCHED_DEATH_HUD:SetTitle( "" )
    BOTCHED_DEATH_HUD:ShowCloseButton( false )
    BOTCHED_DEATH_HUD.Think = function( self2 )
        local shouldDraw = hook.Run( "HUDShouldDraw", "CHudGMod" )
        if( not shouldDraw and self2:IsVisible() ) then
            self2:SetVisible( false )
        elseif( shouldDraw and not self2:IsVisible() ) then
            self2:SetVisible( true )
        end
    end
    BOTCHED_DEATH_HUD.Paint = function( self2, w, h ) 
        BOTCHED.FUNC.DrawBlur( self2, 4, 4 )

        draw.SimpleTextOutlined( "YOU DIED", "MontserratBold120", w/2, h/4, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, BOTCHED.FUNC.GetTheme( 1 ) )

        if( math.max( 0, (startTime+duration)-CurTime() ) == 0 ) then
            draw.SimpleTextOutlined( "Press SPACE to respawn!", "MontserratBold40", w/2, h/2, BOTCHED.FUNC.GetTheme( 4, 150 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, BOTCHED.FUNC.GetTheme( 1 ) )
        end
    end

    local timePanel = vgui.Create( "DPanel", BOTCHED_DEATH_HUD )
    timePanel:SetSize( ScrW()*0.2, 100 )
    timePanel:SetPos( (BOTCHED_DEATH_HUD:GetWide()/2)-(timePanel:GetWide()/2), BOTCHED_DEATH_HUD:GetTall()-timePanel:GetTall()-50 )
    timePanel.Paint = function( self2, w, h )
        BSHADOWS.BeginShadow( "hud_shadow_deathtime" )
        BSHADOWS.SetShadowSize( "hud_shadow_deathtime", w, h )
        local x, y = self2:LocalToScreen( 0, 0 )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 1 ) )
        BSHADOWS.EndShadow( "hud_shadow_deathtime", x, y, 2, 1, 1, 255, 0, 0, false )

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )

        local timeLeft = math.max( 0, (startTime+duration)-CurTime() )

        local progressBarW, progressBarH = w, 10
        BOTCHED.FUNC.DrawRoundedMask( 8, (w/2)-(progressBarW/2), h-(progressBarH*2), progressBarW, progressBarH*2, function()
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
            surface.DrawRect( (w/2)-(progressBarW/2), h-progressBarH, progressBarW, progressBarH )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3 ) )
            surface.DrawRect( (w/2)-(progressBarW/2), h-progressBarH, math.Clamp( progressBarW*(timeLeft/duration), 0, progressBarW ), progressBarH )
        end )

        draw.SimpleText( "RESPAWN IN", "MontserratBold30", w/2, h/2+4, BOTCHED.FUNC.GetTheme( 4, 150 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        draw.SimpleText( BOTCHED.FUNC.FormatLetterTime( timeLeft ), "MontserratBold25", w/2, h/2-4, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, 0 )
    end
end

hook.Add( "HUDPaint", "Botched.HUDPaint.MainHUD", function() 
    local ply = LocalPlayer()
    local scrW, scrH = ScrW(), ScrH()

    if( IsValid( BOTCHED_HUD ) ) then
        if( ply:GetModel() != BOTCHED_HUD.model:GetModel() ) then
            BOTCHED_HUD.model:SetModel( ply:GetModel() )
            local bone = BOTCHED_HUD.model.Entity:LookupBone( "ValveBiped.Bip01_Head1" )
            if( bone ) then
                local headpos = BOTCHED_HUD.model.Entity:GetBonePosition( bone )
                BOTCHED_HUD.model:SetLookAt( headpos )
                BOTCHED_HUD.model:SetCamPos( headpos-Vector( -25, 0, 0 ) )
            end
        end
    else
        createDermaHUD( ply )
    end

    if( ply:Alive() and BOTCHED_DEATH_HUD_CREATED ) then
        BOTCHED_DEATH_HUD_CREATED = false

        if( IsValid( BOTCHED_DEATH_HUD ) ) then
            BOTCHED_DEATH_HUD:Remove()
        end
    end

    if( not ply:Alive() and not BOTCHED_DEATH_HUD_CREATED ) then
        createDermaDeathHUD( ply )
        BOTCHED_DEATH_HUD_CREATED = true
    end
end )

-- CREDITS: https://steamcommunity.com/sharedfiles/filedetails/?id=207948202
local delayPos, viewPos
hook.Add( "CalcView", "Botched.CalcView.3rdPerson", function( ply, pos, angles, fov )
    if( not IsValid( ply ) ) then return end
    
    if delayPos == nil then
        delayPos = ply:EyePos()
    end
    
    if viewPos == nil then
        viewPos = ply:EyePos()
    end

    local view = {}

    local Forward = 100
    
    delayPos = delayPos + (ply:GetVelocity() * (FrameTime() / 10))
    delayPos.x = math.Approach(delayPos.x, pos.x, math.abs(delayPos.x - pos.x) * 0.3)
    delayPos.y = math.Approach(delayPos.y, pos.y, math.abs(delayPos.y - pos.y) * 0.3)
    delayPos.z = math.Approach(delayPos.z, pos.z, math.abs(delayPos.z - pos.z) * 0.3)

    local traceData = {}
    traceData.start = delayPos
    traceData.endpos = traceData.start + angles:Forward() * -Forward
    traceData.endpos = traceData.endpos + angles:Right()
    traceData.endpos = traceData.endpos + angles:Up()
    traceData.filter = ply
    
    local trace = util.TraceLine(traceData)
    
    pos = trace.HitPos
    
    if trace.Fraction < 1.0 then
        pos = pos + trace.HitNormal * 5
    end
    
    view.origin = pos

    view.angles = angles
    view.fov = fov
    view.drawviewer = true
    
    return view
end )

local speakingMat = Material( "materials/botched/icons/speaking.png" )
local typingMat = Material( "materials/botched/icons/chat.png" )
hook.Add( "PostDrawOpaqueRenderables", "Botched.PostDrawOpaqueRenderables.HUD", function()
    local localPly = LocalPlayer()
    for k, ply in ipairs( player.GetAll() ) do
        if( not IsValid( ply ) or not ply:Alive() or ply == localPly ) then continue end

        local distance = localPly:GetPos():DistToSqr( ply:GetPos() )
        if( distance > 100000 ) then continue end

        local ang = localPly:EyeAngles()
        local pos = ply:GetPos()+Vector( 0, 0, ply:OBBMaxs().z+5 )

        ang:RotateAroundAxis( ang:Forward(), 90 )
        ang:RotateAroundAxis( ang:Right(), 90 )

        surface.SetFont( "MontserratBold70" )
        local nameX, nameY = surface.GetTextSize( ply:Nick() )

        local levelText = "Level " .. ply:GetLevel()

        surface.SetFont( "MontserratBold40" )
        local levelX, levelY = surface.GetTextSize( levelText )

        local w, h = nameX, nameY+levelY-15
        local x, y = -(w/2), -h

        local iconMat
        if( ply:IsSpeaking() ) then
            iconMat = speakingMat
        elseif( ply:IsTyping() ) then
            iconMat = typingMat
        end
        
        cam.Start3D2D( pos, Angle( 0, ang.y, 90 ), 0.1 )
            surface.SetAlphaMultiplier( 1-(distance/100000) )

            if( iconMat ) then
                local iconSize = 64
                surface.SetMaterial( iconMat )

                surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
                surface.DrawTexturedRect( x+(w/2)-(iconSize/2)-2, y-5-iconSize-2, iconSize+4, iconSize+4 )

                surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4 ) )
                surface.DrawTexturedRect( x+(w/2)-(iconSize/2), y-5-iconSize, iconSize, iconSize )
            end

            draw.SimpleTextOutlined( ply:Nick(), "MontserratBold70", 0, y, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0, 2, BOTCHED.FUNC.GetTheme( 1 ) )
            draw.SimpleTextOutlined( levelText, "MontserratBold40", 0, y+h, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM, 2, BOTCHED.FUNC.GetTheme( 1 ) )
            
            surface.SetAlphaMultiplier( 1 )
        cam.End3D2D()
    end
end )