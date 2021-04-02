local PANEL = {}

function PANEL:Init()

end

function PANEL:FillPanel()
    self.leftPanel = vgui.Create( "DPanel", self )
    self.leftPanel:Dock( LEFT )
    self.leftPanel:DockMargin( 25, 25, 25, 20 )
    self.leftPanel:SetSize( ((self:GetWide()-50)/2)-25, self:GetTall()-50 )
    self.leftPanel.Paint = function() end

    surface.SetFont( "MontserratMedium20" )
    local textX, textY = surface.GetTextSize( "CHANGE MODEL" )

    local iconSize = 16
    local contentW = textX+iconSize+5

    local changeModel = vgui.Create( "DButton", self.leftPanel )
    changeModel:SetSize( contentW+35, 40 )
    changeModel:SetPos( (self.leftPanel:GetWide()/2)-(changeModel:GetWide()/2), self.leftPanel:GetTall()-changeModel:GetTall() )
    changeModel:SetText( "" )
    local alpha = 0
    local iconMat = Material( "materials/botched/icons/edit_16.png" )
    changeModel.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+10, 0, 75 )
        else
            alpha = math.Clamp( alpha-10, 0, 75 )
        end

        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, alpha ) )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )

        local textColor = BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) )
        surface.SetDrawColor( textColor )
        surface.SetMaterial( iconMat )
        surface.DrawTexturedRect( (w/2)-(contentW/2), (h/2)-(iconSize/2), iconSize, iconSize )

        draw.SimpleText( "CHANGE MODEL", "MontserratMedium20", (w/2)+(contentW/2), h/2, textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    end
    changeModel.DoClick = function()
        self:SetRightPage( "model_selector" )
    end

    self.playerModel = vgui.Create( "DModelPanel", self.leftPanel )
    self.playerModel:Dock( FILL )
    self.playerModel:DockMargin( 0, 0, 0, changeModel:GetTall()+25 )
    self.playerModel.rotation = 30
    self.playerModel.LayoutEntity = function( self2, ent )
        if( self2:IsDown() ) then
            if( not self2.mouseXStart or not self2.startRotation ) then
                self2.mouseXStart = gui.MouseX()
                self2.startRotation = self2.rotation
            end

            self2.rotation = self2.startRotation+((gui.MouseX()-self2.mouseXStart)*0.4)
        elseif( self2.mouseXStart or self2.startRotation ) then
            self2.mouseXStart = nil
            self2.startRotation = nil
        end

        ent:SetAngles( Angle( 0, self2.rotation,  0 ) )
    end

    self.rightPanel = vgui.Create( "DPanel", self )
    self.rightPanel:Dock( RIGHT )
    self.rightPanel:DockMargin( 0, 0, 0, 0 )
    self.rightPanel:SetSize( (self:GetWide()-50)/2, self:GetTall() )
    self.rightPanel.screenX, self.rightPanel.screenY = 0, 0
    self.rightPanel.Paint = function( self2, w, h ) 
        self.rightPanel.screenX, self.rightPanel.screenY = self2:LocalToScreen( 0, 0 )

        if( BOTCHED_MAINMENU.FullyOpened ) then
            local x, y = self2:LocalToScreen( 0, 0 )

            BSHADOWS.BeginShadow( "character_sidepanel", 0, y, ScrW(), y+h )
            BSHADOWS.SetShadowSize( "character_sidepanel", w, h-4 )
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
            surface.DrawRect( x, y, w, h )
            BSHADOWS.EndShadow( "character_sidepanel", x, y, 1, 2, 2, 255, 0, 0, true )
        end

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
        surface.DrawRect( 0, 0, w, h )
    end

    self.navigationPanel = vgui.Create( "DPanel", self.rightPanel )
    self.navigationPanel:Dock( LEFT )
    self.navigationPanel:SetSize( 50, self.rightPanel:GetTall() )
    self.navigationPanel.Paint = function( self2, w, h ) end

    self.navigationContent = vgui.Create( "DPanel", self.rightPanel )
    self.navigationContent:Dock( FILL )
    self.navigationContent:SetSize( self.rightPanel:GetWide()-self.navigationPanel:GetWide(), self.rightPanel:GetTall() )
    self.navigationContent.Paint = function( self2, w, h ) 
        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 35 ) )
        surface.DrawRect( 0, 0, w, h )
    end

    self.rightPages, self.activePage = {}, ""
    self:CreateRightPages()

    self:SetRightPage( "main" )

    self:RefreshCharacter()
    self:CreateEquipmentButtons()

    hook.Add( "Botched.Hooks.ChosenCharacterChanged", self, function()
        self:RefreshCharacter()
    end )

    hook.Add( "Botched.Hooks.CharacterUpdated", self, function()
        if( self.rightPages["model_selector"] ) then
            self.rightPages["model_selector"]:Refresh()
        end
    end )

    local function equipmentUpdate( hookName )
        for k, v in pairs( self.rightPages ) do
            if( not string.StartWith( k, "equipment_" ) ) then continue end
            v:Refresh()
        end

        self:CreateEquipmentButtons()
    end

    hook.Add( "Botched.Hooks.ChosenEquipmentUpdated", self, function()
        equipmentUpdate()
    end )
    
    hook.Add( "Botched.Hooks.EquipmentUpdated", self, function()
        equipmentUpdate()
    end )
end

function PANEL:SetRightPage( identifier )
    if( self.rightPages[self.activePage] ) then
        self.rightPages[self.activePage]:SetVisible( false )
    end

    self.activePage = identifier
    self.rightPages[identifier]:SetVisible( true )

    if( not self.rightPages[identifier].Filled ) then
        self.rightPages[identifier].Filled = true
        self.rightPages[identifier].FillPage()
    end
end

function PANEL:CreateRightPage( identifier, iconMat, panelFunc )
    local page = vgui.Create( "DPanel", self.navigationContent )
    page:Dock( FILL )
    page:SetSize( self.navigationContent:GetSize() )
    page.Paint = function() end
    page.FillPage = function() 
        panelFunc( page )
    end

    page:SetVisible( false )

    self.rightPages[identifier] = page

    local pageButton = vgui.Create( "DButton", self.navigationPanel )
    pageButton:Dock( TOP )
    pageButton:SetTall( self.navigationPanel:GetWide() )
    pageButton:SetText( "" )
    pageButton.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( false, 100, false, false, self.activePage == identifier, 35 )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, self2.alpha ) )
        surface.DrawRect( 0, 0, w, h )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ) )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75+((self2.alpha/100)*180) ) )
        surface.SetMaterial( iconMat )
        local iconSize = 24
        surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
    end
    pageButton.DoClick = function()
        self:SetRightPage( identifier )
    end
end

function PANEL:CreateRightPages()
    self:CreateRightPage( "main", Material( "materials/botched/icons/profile.png" ), function( page ) 
        local scrollPanel = vgui.Create( "botched_scrollpanel", page )
        scrollPanel:Dock( FILL )
        scrollPanel:GetVBar():SetWide( 0 )
        scrollPanel.Paint = function() end

        surface.SetFont( "MontserratBold40" )
        local topTextX, topTextY = surface.GetTextSize( string.upper( LocalPlayer():Nick() ) )

        surface.SetFont( "MontserratBold30" )
        local bottomTextX, bottomTextY = surface.GetTextSize( "Level " .. LocalPlayer():GetLevel() )

        local contentH = topTextY+bottomTextY-28

        local playerTitle = vgui.Create( "DPanel", scrollPanel )
        playerTitle:Dock( TOP )
        playerTitle:SetTall( contentH )
        playerTitle:DockMargin( 0, 50, 0, 50 )
        playerTitle.Paint = function( self2, w, h )
            draw.SimpleText( string.upper( LocalPlayer():Nick() ), "MontserratBold40", w/2, (h/2)-(contentH/2)-11, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0 )
            draw.SimpleText( "Level " .. LocalPlayer():GetLevel(), "MontserratBold30", w/2, (h/2)+(contentH/2)+5, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
        end

        local gridWide = page:GetWide()-50
        local slotsWide = 2
        local spacing = 10
        local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

        local infoGrid = vgui.Create( "DIconLayout", scrollPanel )
        infoGrid:Dock( TOP )
        infoGrid:DockMargin( 25, 0, 25, 10 )
        infoGrid:SetSpaceY( spacing )
        infoGrid:SetSpaceX( spacing )
        infoGrid.AddInfoEntry = function( self2, topText, bottomText, iconMat )
            surface.SetFont( "MontserratBold30" )
            local topTextY = select( 2, surface.GetTextSize( topText() ) )

            surface.SetFont( "MontserratBold18" )
            local bottomTextY = select( 2, surface.GetTextSize( bottomText ) )

            local contentH = topTextY+bottomTextY-15

            local infoPanel = vgui.Create( "DPanel", self2 )
            infoPanel:SetSize( slotSize, 50 )
            infoPanel.Paint = function( self2, w, h )
                local x, y = self2:LocalToScreen( 0, 0 )

                if( BOTCHED_MAINMENU.FullyOpened ) then
                    local uniqueID = "character_info_" .. bottomText
                    BSHADOWS.BeginShadow( uniqueID, 0, self.rightPanel.screenY, ScrW(), self.rightPanel.screenY+self.rightPanel:GetTall()-25 )
                    draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
                    BSHADOWS.EndShadow( uniqueID, x, y, 1, 1, 1, 255, 0, 0, false )
                end

                draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 1 ) )

                surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
                surface.SetMaterial( iconMat )
                local iconSize = 24
                surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

                draw.SimpleText( topText(), "MontserratBold30", w/2, (h/2)-(contentH/2)-8, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0 )
                draw.SimpleText( bottomText, "MontserratBold18", w/2, (h/2)+(contentH/2)+3, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            end
        end

        infoGrid:AddInfoEntry( function() return BOTCHED.FUNC.FormatLetterTime( LocalPlayer():GetTimePlayed() ) end, "TIME PLAYED", Material( "materials/botched/icons/time_played.png" ) )
        infoGrid:AddInfoEntry( function() 
            local days = LocalPlayer():GetLoginRewardStreak()
            return days .. " Day" .. (days != 1 and "s" or "") 
        end, "LOGIN STREAK", Material( "materials/botched/icons/streak.png" ) )

        local experiencePanel = vgui.Create( "DPanel", scrollPanel )
        experiencePanel:Dock( TOP )
        experiencePanel:SetTall( 50 )
        experiencePanel:DockMargin( 25, 0, 25, 10 )
        local iconMat = Material( "materials/botched/icons/exp_bottle.png" )
        experiencePanel.Paint = function( self2, w, h )
            local level, experience = LocalPlayer():GetLevel(), LocalPlayer():GetExperience()
            local nextLevelTable = BOTCHED.CONFIG.Levels[level+1]
            local requiredEXP = (nextLevelTable or {}).RequiredEXP or 1
            
            if( BOTCHED_MAINMENU.FullyOpened ) then
                local x, y = self2:LocalToScreen( 0, 0 )
                BSHADOWS.BeginShadow( "character_experience", 0, self.rightPanel.screenY, ScrW(), self.rightPanel.screenY+self.rightPanel:GetTall()-25 )
                draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
                BSHADOWS.EndShadow( "character_experience", x, y, 1, 1, 1, 255, 0, 0, false )
            end

            draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 1 ) )

            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
            surface.SetMaterial( iconMat )
            local iconSize = 24
            surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

            draw.SimpleText( "EXP", "MontserratBold40", h, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), 0, TEXT_ALIGN_CENTER )

            draw.SimpleText( math.Round( math.Clamp( experience/requiredEXP, 0, 1 )*100, 2 ) .. "%", "MontserratBold30", w-15, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

            draw.SimpleText( string.Comma( experience ) .. "/" .. string.Comma( requiredEXP ), "MontserratMedium20", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end

        local statGrid = vgui.Create( "DIconLayout", scrollPanel )
        statGrid:Dock( TOP )
        statGrid:DockMargin( 25, 0, 25, 0 )
        statGrid:SetSpaceY( spacing )
        statGrid:SetSpaceX( spacing )

        local stats = {
            {
                Title = "HEALTH",
                Icon = Material( "materials/botched/icons/heart.png" ),
                GetFunc = function() return LocalPlayer():GetMaxHealth() end
            },
            {
                Title = "HEALING",
                Icon = Material( "materials/botched/icons/regeneration.png" ),
                GetFunc = function() return LocalPlayer():GetHealthRegenAmount() end
            },
            {
                Title = "STAMINA",
                Icon = Material( "materials/botched/icons/stamina_32.png" ),
                GetFunc = function() return LocalPlayer():GetMaxStamina() end
            },
        }

        for k, v in ipairs( stats ) do
            surface.SetFont( "MontserratBold40" )
            local topTextX, topTextY = surface.GetTextSize( string.Comma( v.GetFunc() ) )

            surface.SetFont( "MontserratBold20" )
            local bottomTextX, bottomTextY = surface.GetTextSize( v.Title )

            local contentH = topTextY+bottomTextY-23

            local statPanel = vgui.Create( "DPanel", statGrid )
            statPanel:SetSize( slotSize, 65 )
            statPanel.Paint = function( self2, w, h )
                local x, y = self2:LocalToScreen( 0, 0 )

                if( BOTCHED_MAINMENU.FullyOpened ) then
                    local uniqueID = "character_stat_" .. k
                    BSHADOWS.BeginShadow( uniqueID, 0, self.rightPanel.screenY, ScrW(), self.rightPanel.screenY+self.rightPanel:GetTall()-25 )
                    draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
                    BSHADOWS.EndShadow( uniqueID, x, y, 1, 1, 1, 255, 0, 0, false )
                end

                draw.RoundedBox( 8, 2, 2, w-4, h-4, BOTCHED.FUNC.GetTheme( 1 ) )

                surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75 ) )
                surface.SetMaterial( v.Icon )
                local iconSize = 32
                surface.DrawTexturedRect( (h/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )

                draw.SimpleText( string.Comma( v.GetFunc() ), "MontserratBold40", w/2, (h/2)-(contentH/2)-11, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, 0 )
                draw.SimpleText( v.Title, "MontserratBold20", w/2, (h/2)+(contentH/2)+3, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
            end
        end
    end )

    self:CreateRightPage( "model_selector", Material( "materials/botched/icons/characters.png" ), function( page ) 
        local scrollPanel = vgui.Create( "botched_scrollpanel", page )
        scrollPanel:Dock( FILL )
        scrollPanel:DockMargin( 25, 25, 25, 25 )
        scrollPanel.Paint = function() end

        local gridWide = page:GetWide()-50-20
        local slotsWide = math.floor( gridWide/BOTCHED.FUNC.ScreenScale( 175 ) )
        local spacing = 10
        local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

        local ownedGridHeader = vgui.Create( "DPanel", scrollPanel )
        ownedGridHeader:Dock( TOP )
        ownedGridHeader:SetTall( 15 )
        ownedGridHeader.Paint = function( self2, w, h )
            draw.SimpleText( "OWNED", "MontserratBold25", 0, h/2-1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_CENTER )
        end

        local ownedGrid = vgui.Create( "DIconLayout", scrollPanel )
        ownedGrid:Dock( TOP )
        ownedGrid:DockMargin( 0, spacing, 0, 0 )
        ownedGrid:SetSpaceY( spacing )
        ownedGrid:SetSpaceX( spacing )

        local unOwnedGridHeader = vgui.Create( "DPanel", scrollPanel )
        unOwnedGridHeader:Dock( TOP )
        unOwnedGridHeader:DockMargin( 0, 25, 0, 0 )
        unOwnedGridHeader:SetTall( 15 )
        unOwnedGridHeader.Paint = function( self2, w, h )
            draw.SimpleText( "UNOWNED", "MontserratBold25", 0, h/2, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_CENTER )
        end

        local unOwnedGrid = vgui.Create( "DIconLayout", scrollPanel )
        unOwnedGrid:Dock( TOP )
        unOwnedGrid:DockMargin( 0, spacing, 0, 0 )
        unOwnedGrid:SetSpaceY( spacing )
        unOwnedGrid:SetSpaceX( spacing )

        local previouslyLoaded = false
        local previousAdded, curCharacter = 0, 0

        local chosenModel, character = LocalPlayer():GetChosenCharacter()
        local ownedCharacters = LocalPlayer():GetOwnedCharacters()
        local function addModelChoice( parent, characterKey, modelTable, popup )
            local function createPanel()
                if( not IsValid( parent ) ) then return end

                local ownedModelTable = ownedCharacters[characterKey] or {}

                local modelPanel = parent:Add( "botched_equipment_slot" )
                modelPanel:SetSize( slotSize, slotSize*1.2 )
                modelPanel:SetItemInfo( modelTable.Name, modelTable.Model, (ownedModelTable.Stars or modelTable.Stars), (ownedModelTable.Rank or 1), function()
                    if( character == characterKey ) then return end

                    net.Start( "Botched.RequestChooseModel" )
                        net.WriteString( characterKey )
                    net.SendToServer()
                end, true )
                modelPanel:SetShadowScissor( 0, self.rightPanel.screenY+25, ScrW(), self.rightPanel.screenY+25+page:GetTall()-50 )
                modelPanel:SetBorder( (BOTCHED.CONFIG.CharacterRanks[ownedModelTable.Rank or 1] or {}).Border )
            end

            if( not previouslyLoaded ) then
                previousAdded = previousAdded+1

                local currentNum = previousAdded
                timer.Simple( 0.05*previousAdded, function()
                    curCharacter = currentNum
                    if( curCharacter == previousAdded and IsValid( popup ) ) then
                        popup:Remove()
                    end

                    createPanel()
                end )
            else
                createPanel()
            end
        end

        function page.Refresh()
            ownedGrid:Clear()
            unOwnedGrid:Clear()
            chosenModel, character = LocalPlayer():GetChosenCharacter()
            ownedCharacters = LocalPlayer():GetOwnedCharacters()

            local popup
            if( not previouslyLoaded ) then
                curCharacter = 0
                popup = BOTCHED.FUNC.DermaProgressBar( "CHARACTERS", function() 
                    return "Loading characters " .. curCharacter .. "/" .. previousAdded
                end, function()
                    return curCharacter/previousAdded
                end )
            end

            for k, v in pairs( BOTCHED.CONFIG.Characters ) do
                if( not ownedCharacters[k] ) then continue end
                addModelChoice( ownedGrid, k, v, popup )
            end

            for k, v in pairs( BOTCHED.CONFIG.Characters ) do
                if( ownedCharacters[k] ) then continue end
                addModelChoice( unOwnedGrid, k, v, popup )
            end

            previouslyLoaded = true
        end
        page.Refresh()
    end )

    local equipmentPages = {
        { "Pickaxe", "pickaxe", Material( "materials/botched/icons/pickaxe.png" ) },
        { "Hatchet", "hatchet", Material( "materials/botched/icons/hatchet.png" ) },
        { "Primary", "primaryWeapon", Material( "materials/botched/icons/sword.png" ) },
        { "Secondary", "secondaryWeapon", Material( "materials/botched/icons/bow.png" ) },
        { "Trinket 1", "trinket1", Material( "materials/botched/icons/book.png" ) },
        { "Trinket 2", "trinket2", Material( "materials/botched/icons/ring.png" ) },
        { "Armour", "armour", Material( "materials/botched/icons/armor.png" ) }
    }

    for k, v in ipairs( equipmentPages ) do
        self:CreateRightPage( "equipment_" .. v[2], v[3], function( page ) 
            self:CreateEquipmentListPage( v[1], v[2], page )
        end )
    end
end

function PANEL:RefreshCharacter()
    self.playerModel:SetModel( LocalPlayer():GetChosenCharacter() )

    if( self.rightPages["model_selector"] ) then
        self.rightPages["model_selector"]:Refresh()
    end
end

function PANEL:CreateEquipmentButton( title, equipmentType )
    local equipmentSlot = vgui.Create( "botched_equipment_slot", self.leftPanel )
    equipmentSlot:SetSize( BOTCHED.FUNC.ScreenScale( 100 ), BOTCHED.FUNC.ScreenScale( 100 ) )
    equipmentSlot:DisableText( true )
    equipmentSlot:SetBorderSize( 2 )

    local openFunc = function()
        self:SetRightPage( "equipment_" .. equipmentType )
    end

    local equipmentKey = LocalPlayer():GetChosenEquipment()[equipmentType] or 0
    local equipmentConfig = BOTCHED.CONFIG.Equipment[equipmentKey]
    if( equipmentConfig ) then
        local equipment = LocalPlayer():GetEquipment()
        local ownedEquipment = equipment[equipmentKey] or {}

        equipmentSlot:SetItemInfo( equipmentConfig.Name, equipmentConfig.Model, (ownedEquipment.Stars or equipmentConfig.Stars), (ownedEquipment.Rank or 1), openFunc )
        equipmentSlot:SetBorder( (BOTCHED.CONFIG.CharacterRanks[ownedEquipment.Rank or 1] or {}).Border )
        if( equipmentConfig.RankColors and equipmentConfig.RankColors[ownedEquipment.Rank or 1] ) then
            equipmentSlot:SetModelColor( equipmentConfig.RankColors[ownedEquipment.Rank or 1] )
        end
    else
        equipmentSlot:SetItemInfo( title, false, false, false, openFunc )
    end

    table.insert( self.leftPanel.equipmentSlots, equipmentSlot )

    return equipmentSlot
end

function PANEL:CreateEquipmentListPage( title, equipmentType, page )
    local scrollPanel = vgui.Create( "botched_scrollpanel", page )
    scrollPanel:Dock( FILL )
    scrollPanel:DockMargin( 25, 25, 25, 25 )
    scrollPanel:GetVBar():SetWide( 0 )
    scrollPanel.Paint = function() end

    local gridWide = page:GetWide()-50
    local slotsWide = math.floor( gridWide/BOTCHED.FUNC.ScreenScale( 175 ) )
    local spacing = 10
    local slotSize = (gridWide-((slotsWide-1)*spacing))/slotsWide

    local gridHeader = vgui.Create( "DPanel", scrollPanel )
    gridHeader:Dock( TOP )
    gridHeader:SetTall( 15 )
    gridHeader.Paint = function( self2, w, h )
        draw.SimpleText( string.upper( title ), "MontserratBold25", 0, h/2-1, BOTCHED.FUNC.GetTheme( 3 ), 0, TEXT_ALIGN_CENTER )
    end

    local grid = vgui.Create( "DIconLayout", scrollPanel )
    grid:Dock( TOP )
    grid:DockMargin( 0, spacing, 0, 0 )
    grid:SetSpaceY( spacing )
    grid:SetSpaceX( spacing )

    local popupPanel = vgui.Create( "DPanel", page )
    popupPanel:SetSize( page:GetWide(), page:GetTall() )
    popupPanel:SetPos( 0, page:GetTall()-40 )
    popupPanel:SetZPos( 100 )
    popupPanel.Paint = function( self2, w, h )
        local x, y = self2:LocalToScreen( 0, 0 )

        if( BOTCHED_MAINMENU.FullyOpened ) then
            local uniqueID = "character_" .. equipmentType .. "_popup"
            BSHADOWS.BeginShadow( uniqueID, 0, self.rightPanel.screenY, ScrW(), self.rightPanel.screenY+self.rightPanel:GetTall() )
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
            surface.DrawRect( x+6, y, w-12, h )
            BSHADOWS.EndShadow( uniqueID, x, y, 1, 2, 2, 255, 0, 0, true )
        end

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 25 ) )
        surface.DrawRect( 0, 0, w, h )
    end

    local popupButton = vgui.Create( "DButton", popupPanel )
    popupButton:Dock( TOP )
    popupButton:SetTall( 40 )
    popupButton:SetText( "" )
    local iconMat = Material( "materials/botched/icons/up-arrow.png" )
    popupButton.textureRotation = 0
    popupButton.Paint = function( self2, w, h )
        self2:CreateFadeAlpha( false, 100 )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, 25 ) )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 2, self2.alpha ) )
        surface.DrawRect( 0, 0, w, h )

        BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ) )

        surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 4, 75+((self2.alpha/100)*180) ) )
        surface.SetMaterial( iconMat )
        surface.DrawTexturedRectRotated( w/2, h/2, 24, 24, self2.textureRotation )
    end
    popupButton.DoAnim = function( expanding )
        local anim = popupButton:NewAnimation( 0.2, 0, -1 )
    
        anim.Think = function( anim, pnl, fraction )
            if( expanding ) then
                popupButton.textureRotation = fraction*180
            else
                popupButton.textureRotation = (1-fraction)*180
            end
        end
    end
    popupButton.ToggleOpen = function()
        if( not popupPanel.opened ) then
            popupPanel.opened = true
            popupPanel:MoveTo( 0, page:GetTall()-popupPanel:GetTall(), 0.2 )
            popupButton.DoAnim( true )
        else
            popupPanel.opened = false
            popupPanel:MoveTo( 0, page:GetTall()-40, 0.2 )
            popupButton.DoAnim( false )
        end
    end
    popupButton.DoClick = popupButton.ToggleOpen

    local popupContent = vgui.Create( "DPanel", popupPanel )
    popupContent:Dock( FILL )
    popupContent:SetSize( page:GetWide(), popupPanel:GetTall()-popupButton:GetTall() )
    popupContent.Paint = function( self2, w, h ) end

    local function OpenEquipmentPage( equipmentKey )
        popupContent:Clear()
        self:CreateEquipmentPage( equipmentKey, popupContent )

        if( not popupPanel.opened ) then
            popupButton.ToggleOpen()
        end
    end

    function page.Refresh()
        grid:Clear()

        local function addEquipmentPanel( equipmentKey, equipmentTable, equipmentConfig )
            local rank = equipmentTable.Rank or 1

            local equipmentPanel = grid:Add( "botched_equipment_slot" )
            equipmentPanel:SetSize( slotSize, slotSize*1.2 )
            equipmentPanel:SetItemInfo( equipmentConfig.Name, equipmentConfig.Model, (equipmentTable.Stars or equipmentConfig.Stars), rank, function()
                OpenEquipmentPage( equipmentKey )
            end )
            equipmentPanel:SetShadowScissor( 0, self.rightPanel.screenY, ScrW(), self.rightPanel.screenY+self.rightPanel:GetTall() )
            equipmentPanel:SetBorder( (BOTCHED.CONFIG.EquipmentRanks[rank] or {}).Border )

            if( equipmentConfig.RankColors and equipmentConfig.RankColors[rank] ) then
                equipmentPanel:SetModelColor( equipmentConfig.RankColors[rank] )
            end
        end

        for k, v in pairs( LocalPlayer():GetEquipment() ) do
            local equipmentConfig = BOTCHED.CONFIG.Equipment[k]

            if( not equipmentConfig or equipmentConfig.Type != equipmentType ) then continue end

            addEquipmentPanel( k, v, equipmentConfig )
        end

        if( popupContent.RefreshStats ) then
            popupContent.RefreshStats()
        end
    end
    page.Refresh()
end

function PANEL:CreateEquipmentPage( equipmentKey, parent )
    local equipmentConfig = BOTCHED.CONFIG.Equipment[equipmentKey]

    if( not equipmentConfig ) then return end

    local equipment = LocalPlayer():GetEquipment()
    local stars = (equipment[equipmentKey] and equipment[equipmentKey].Stars) or equipmentConfig.Stars
    local starConfig = BOTCHED.CONFIG.EquipmentStars[stars]
    local rank = (equipment[equipmentKey] and equipment[equipmentKey].Rank) or 1
    local rankConfig = BOTCHED.CONFIG.EquipmentRanks[rank]

    surface.SetFont( "MontserratBold40" )
    local textX, textY = surface.GetTextSize( string.upper( equipmentConfig.Name ) )

    surface.SetFont( "MontserratMedium20" )
    local text2X, text2Y = surface.GetTextSize( "Rank " .. rank )

    local title = vgui.Create( "DPanel", parent )
    title:Dock( TOP )
    title:DockMargin( 0, 25, 0, 0 )
    title:SetTall( textY+text2Y-7+5+33 )
    local starMat = Material( "materials/botched/icons/star_32.png" )
    title.Paint = function( self2, w, h )
        draw.SimpleText( string.upper( equipmentConfig.Name ), "MontserratBold40", w/2, 0, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, 0 )
        draw.SimpleText( "Rank " .. rank, "MontserratMedium20", w/2, textY-7, BOTCHED.FUNC.GetTheme( 4, 75 ), TEXT_ALIGN_CENTER, 0 )

        local iconSize, starSpacing = 32, 5
        surface.SetMaterial( starMat )

        local starTotalW = (5*(iconSize+starSpacing))-starSpacing

        for i = 1, 5 do
            local starXPos, starYPos = ((w/2)-(starTotalW/2))+((i-1)*(iconSize+starSpacing)), (textY+text2Y-7)+5

            surface.SetDrawColor( 0, 0, 0 )
            surface.DrawTexturedRect( starXPos+1, starYPos+1, iconSize, iconSize )

            if( i <= stars ) then
                surface.SetDrawColor( 255, 255, 255 )
                surface.DrawTexturedRect( starXPos, starYPos, iconSize, iconSize )
            else
                surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 1 ) )
                surface.DrawTexturedRect( starXPos, starYPos, iconSize, iconSize )
            end
        end
    end

    local buttonPanel = vgui.Create( "DPanel", parent )
    buttonPanel:Dock( BOTTOM )
    buttonPanel:DockMargin( 25, 0, 25, 25 )
    buttonPanel:SetTall( 40 )
    buttonPanel.Paint = function() end
    buttonPanel.buttons = {}
    buttonPanel.AddButton = function( text, iconMat, doClick )
        surface.SetFont( "MontserratMedium20" )
        local textX, textY = surface.GetTextSize( text )
    
        local iconSize = 16
        local contentW = textX+iconSize+5
    
        local buttonEntry = vgui.Create( "DButton", buttonPanel )
        buttonEntry:Dock( LEFT )
        buttonEntry:DockMargin( 0, 0, 10, 0 )
        buttonEntry:SetText( "" )
        local alpha = 0
        buttonEntry.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+10, 0, 75 )
            else
                alpha = math.Clamp( alpha-10, 0, 75 )
            end
    
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, alpha ) )
    
            BOTCHED.FUNC.DrawClickCircle( self2, w, h, BOTCHED.FUNC.GetTheme( 2 ), 8 )
    
            local textColor = BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) )
            surface.SetDrawColor( textColor )
            surface.SetMaterial( iconMat )
            surface.DrawTexturedRect( (w/2)-(contentW/2), (h/2)-(iconSize/2), iconSize, iconSize )
    
            draw.SimpleText( text, "MontserratMedium20", (w/2)+(contentW/2), h/2, textColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
        end
        buttonEntry.DoClick = doClick

        table.insert( buttonPanel.buttons, buttonEntry )

        for k, v in ipairs( buttonPanel.buttons ) do
            v:SetWide( (parent:GetWide()-50-((#buttonPanel.buttons-1)*10))/#buttonPanel.buttons )
        end
    end
    buttonPanel.RefreshButtons = function()
        buttonPanel.buttons = {}
        buttonPanel:Clear()

        if( rank < #BOTCHED.CONFIG.EquipmentRanks ) then
            buttonPanel.AddButton( "RANK UP", Material( "materials/botched/icons/upgrade_16.png" ), function() 
                if( rank >= #BOTCHED.CONFIG.EquipmentRanks or IsValid( self.popupPanel ) ) then return end
    
                self.popupPanel = vgui.Create( "botched_popup_rankup" )
                self.popupPanel:SetInfo( rank, rank+1, equipmentKey )
            end )
        end
    
        if( stars < 5 ) then
            buttonPanel.AddButton( "REFINE", Material( "materials/botched/icons/star_white.png" ), function() 
                if( stars >= 5 or IsValid( self.popupPanel ) ) then return end
    
                self.popupPanel = vgui.Create( "botched_popup_refine" )
                self.popupPanel:SetInfo( stars, stars+1, equipmentKey, rank )
            end )
        end

        local chosenEquipment = LocalPlayer():GetChosenEquipment()
        local isEquipped = (chosenEquipment[equipmentConfig.Type] or 0) == equipmentKey

        if( not isEquipped ) then
            buttonPanel.AddButton( "EQUIP", Material( "materials/botched/icons/equip_16.png" ), function() 
                net.Start( "Botched.RequestChooseEquipment" )
                    net.WriteString( equipmentKey )
                net.SendToServer()
            end )
        else
            buttonPanel.AddButton( "UNEQUIP", Material( "materials/botched/icons/equip_16.png" ), function() 
                net.Start( "Botched.RequestUnChooseEquipment" )
                    net.WriteString( equipmentKey )
                net.SendToServer()
            end )
        end
    end

    surface.SetFont( "MontserratBold25" )
    local topTextX, topTextY = surface.GetTextSize( "STATISTICS" )

    local mainSection = vgui.Create( "DPanel", parent )
    mainSection:Dock( BOTTOM )
    mainSection:SetTall( topTextY+(table.Count( equipmentConfig.Stats )*(30)) )
    mainSection:DockMargin( 25, 0, 25, 50 )
    mainSection:DockPadding( 0, topTextY, 0, 0 )
    mainSection.Paint = function( self2, w, h ) 
        draw.SimpleText( "STATISTICS", "MontserratBold25", w/2, 0, rankConfig.Color or BOTCHED.FUNC.GetTheme( 4, 100 ), TEXT_ALIGN_CENTER )
    end

    for k, v in pairs( equipmentConfig.Stats ) do
        local devConfigTable = BOTCHED.DEVCONFIG.EquipmentStats[k]

        local statEntry = vgui.Create( "DPanel", mainSection )
        statEntry:Dock( TOP )
        statEntry:SetTall( 30 )
        statEntry.Paint = function( self2, w, h )
            draw.SimpleText( devConfigTable.Name, "MontserratMedium20", 0, h/2, BOTCHED.FUNC.GetTheme( 4, 100 ), 0, TEXT_ALIGN_CENTER )

            draw.SimpleText( math.Round( v+(v*(rankConfig.StatMultiplier or 0))+(v*(starConfig.StatMultiplier or 0)), 2 ), "MontserratBold22", w/2, h/2, BOTCHED.FUNC.GetTheme( 3 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        end
    end

    local model
    if( string.EndsWith( equipmentConfig.Model, ".mdl" ) ) then
        model = vgui.Create( "DModelPanel", parent )
        model:Dock( FILL )
        model:SetModel( equipmentConfig.Model )
        model.LayoutEntity = function() end

        if( IsValid( model.Entity ) ) then
            local mn, mx = model.Entity:GetRenderBounds()
            local size = 0
            size = math.max( size, math.abs(mn.x) + math.abs(mx.x) )
            size = math.max( size, math.abs(mn.y) + math.abs(mx.y) )
            size = math.max( size, math.abs(mn.z) + math.abs(mx.z) )

            model:SetFOV( 70 )
            model:SetCamPos( Vector( size, size, size ) )
            model:SetLookAt( (mn + mx) * 0.5 )
        end
    elseif( string.EndsWith( equipmentConfig.Model, ".png" ) or string.EndsWith( equipmentConfig.Model, ".jpg" ) ) then
        local iconMat = Material( equipmentConfig.Model )

        local iconDisplay = vgui.Create( "DPanel", parent )
        iconDisplay:Dock( FILL )
        iconDisplay.Paint = function( self2, w, h ) 
            local iconSize = h*0.6
            surface.SetDrawColor( 255, 255, 255 )
            surface.SetMaterial( iconMat )
            surface.DrawTexturedRect( (w/2)-(iconSize/2), (h/2)-(iconSize/2), iconSize, iconSize )
        end
    end

    function parent.RefreshStats()
        equipment = LocalPlayer():GetEquipment()
        stars = (equipment[equipmentKey] and equipment[equipmentKey].Stars) or equipmentConfig.Stars
        starConfig = BOTCHED.CONFIG.EquipmentStars[stars]
        rank = (equipment[equipmentKey] and equipment[equipmentKey].Rank) or 1
        rankConfig = BOTCHED.CONFIG.EquipmentRanks[rank]

        if( IsValid( model ) and equipmentConfig.RankColors and equipmentConfig.RankColors[rank] ) then
            model:SetColor( equipmentConfig.RankColors[rank] )
        end

        buttonPanel.RefreshButtons()
    end
    parent.RefreshStats()
end

function PANEL:CreateEquipmentButtons()
    for k, v in ipairs( self.leftPanel.equipmentSlots or {} ) do
        v:Remove()
    end

    self.leftPanel.equipmentSlots = {}

    local pickaxeSlot = self:CreateEquipmentButton( "Pickaxe", "pickaxe" )
    pickaxeSlot:SetPos( 0, 0 )

    local hatchetSlot = self:CreateEquipmentButton( "Hatchet", "hatchet" )
    hatchetSlot:SetPos( 0, pickaxeSlot:GetTall()+25 )

    local primarySlot = self:CreateEquipmentButton( "Primary", "primaryWeapon" )
    primarySlot:SetPos( self.leftPanel:GetWide()-primarySlot:GetWide(), 0 )

    local secondarySlot = self:CreateEquipmentButton( "Secondary", "secondaryWeapon" )
    secondarySlot:SetPos( self.leftPanel:GetWide()-secondarySlot:GetWide(), primarySlot:GetTall()+25 )

    local trinket1Slot = self:CreateEquipmentButton( "Trinket 1", "trinket1" )
    trinket1Slot:SetPos( 0, self.leftPanel:GetTall()-trinket1Slot:GetTall() )

    local trinket2Slot = self:CreateEquipmentButton( "Trinket 2", "trinket2" )
    trinket2Slot:SetPos( self.leftPanel:GetWide()-trinket2Slot:GetWide(), self.leftPanel:GetTall()-trinket1Slot:GetTall() )

    local armourSlot = self:CreateEquipmentButton( "Armour", "armour" )
    local leftTopTall = pickaxeSlot:GetTall()+25+hatchetSlot:GetTall()
    armourSlot:SetPos( 0, (leftTopTall+(self.leftPanel:GetTall()-leftTopTall-trinket1Slot:GetTall())/2)-(armourSlot:GetTall()/2) )
end

function PANEL:Paint( w, h )

end

vgui.Register( "botched_mainmenu_character", PANEL, "DPanel" )