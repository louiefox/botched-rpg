function BOTCHED.FUNC.DermaMessage( text, title, buttonText, buttonFunc )
    buttonText = buttonText or "OK"
    title = title or "MESSAGE"

	local popup = vgui.Create( "botched_popup_base" )
	popup:SetHeader( title )

    surface.SetFont( "MontserratMedium20" )
	local textX, textY = surface.GetTextSize( text )

	popup:SetPopupWide( math.max( ScrW()*0.15, textX+30 ) )

	local textArea = vgui.Create( "DPanel", popup )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 0, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( text, "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    local bottomButton = vgui.Create( "DButton", popup )
    bottomButton:Dock( BOTTOM )
    bottomButton:DockMargin( 10, 0, 10, 10 )
    bottomButton:SetTall( 40 )
    bottomButton:SetText( "" )
    local alpha = 0
    bottomButton.Paint = function( self2, w, h )
        if( self2:IsHovered() ) then
            alpha = math.Clamp( alpha+5, 0, 75 )
        else
            alpha = math.Clamp( alpha-5, 0, 75 )
        end
        
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ) )

        draw.SimpleText( buttonText, "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
    end
    bottomButton.DoClick = function()
		if( buttonFunc ) then
			buttonFunc()
		end
		
		popup:Close()
    end

	popup:SetExtraHeight( textArea:GetTall()+25+bottomButton:GetTall()+10 )
end

function BOTCHED.FUNC.DermaQuery( text, title, ... )
    local buttonsToCreate = { ... }

	local popup = vgui.Create( "botched_popup_base" )
	popup:SetHeader( title )

    surface.SetFont( "MontserratMedium20" )
	local textX, textY = surface.GetTextSize( text )

	popup:SetPopupWide( math.max( ScrW()*0.15, textX+30 ) )

	local textArea = vgui.Create( "DPanel", popup )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 0, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( text, "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    local buttonBack = vgui.Create( "DPanel", popup )
	buttonBack:Dock( BOTTOM )
	buttonBack:DockMargin( 10, 0, 10, 10 )
	buttonBack:SetTall( 40 )
	buttonBack.Paint = function() end

    local buttons = {}
    local function createButton( text, func )
        local button = vgui.Create( "DButton", buttonBack )
        button:Dock( LEFT )
        button:DockMargin( 0, 0, 10, 0 )
        button:SetText( "" )
        local alpha = 0
        button.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 75 )
            else
                alpha = math.Clamp( alpha-5, 0, 75 )
            end
            
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ) )

            draw.SimpleText( text, "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
        end
        button.DoClick = function()
            if( func ) then
                func()
            end
            
            popup:Close()
        end

        table.insert( buttons, button )

        for k, v in ipairs( buttons ) do
            v:SetWide( (popup:GetPopupWide()-20-((#buttons-1)*10))/#buttons )
        end
    end

    for k, v in ipairs( buttonsToCreate ) do
        if( k % 2 == 0 ) then continue end

        createButton( v, buttonsToCreate[k+1] )
    end

	popup:SetExtraHeight( textArea:GetTall()+25+buttonBack:GetTall()+10 )
end

function BOTCHED.FUNC.DermaStringRequest( text, title, default, confirmText, confirmFunc, cancelText, cancelFunc )
    default = default or ""
    confirmText = confirmText or "OK"
    cancelText = cancelText or "Cancel"
    title = title or "REQUEST"

	local popup = vgui.Create( "botched_popup_base" )
	popup:SetHeader( title )

    surface.SetFont( "MontserratMedium20" )
	local textX, textY = surface.GetTextSize( text )

	popup:SetPopupWide( math.max( ScrW()*0.15, textX+30 ) )

	local textArea = vgui.Create( "DPanel", popup )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 0, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( text, "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    local textEntry = vgui.Create( "botched_textentry", popup )
	textEntry:Dock( TOP )
	textEntry:DockMargin( 10, 0, 10, 0 )
	textEntry:SetTall( 40 )
	textEntry:SetValue( default )

    local buttonBack = vgui.Create( "DPanel", popup )
	buttonBack:Dock( BOTTOM )
	buttonBack:DockMargin( 10, 0, 10, 10 )
	buttonBack:SetTall( 40 )
	buttonBack.Paint = function() end

    local buttons = {}
    local function createButton( text, func )
        local button = vgui.Create( "DButton", buttonBack )
        button:Dock( LEFT )
        button:DockMargin( 0, 0, 10, 0 )
        button:SetText( "" )
        local alpha = 0
        button.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 75 )
            else
                alpha = math.Clamp( alpha-5, 0, 75 )
            end
            
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ) )

            draw.SimpleText( text, "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
        end
        button.DoClick = function()
            if( func ) then
                func( textEntry:GetValue() )
            end
            
            popup:Close()
        end

        table.insert( buttons, button )

        for k, v in ipairs( buttons ) do
            v:SetWide( (popup:GetPopupWide()-20-((#buttons-1)*10))/#buttons )
        end
    end

    createButton( confirmText, confirmFunc )
    createButton( cancelText, cancelFunc )

	popup:SetExtraHeight( textArea:GetTall()+25+textEntry:GetTall()+buttonBack:GetTall()+10 )
end

function BOTCHED.FUNC.DermaNumberRequest( text, title, default, confirmText, confirmFunc, cancelText, cancelFunc )
    default = default or 0
    confirmText = confirmText or "OK"
    cancelText = cancelText or "Cancel"
    title = title or "REQUEST"

	local popup = vgui.Create( "botched_popup_base" )
	popup:SetHeader( title )

    surface.SetFont( "MontserratMedium20" )
	local textX, textY = surface.GetTextSize( text )

	popup:SetPopupWide( math.max( ScrW()*0.15, textX+30 ) )

	local textArea = vgui.Create( "DPanel", popup )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 0, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( text, "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    local numberWang = vgui.Create( "botched_numberwang", popup )
	numberWang:Dock( TOP )
	numberWang:DockMargin( 10, 0, 10, 0 )
	numberWang:SetTall( 40 )
	numberWang:SetValue( default )

    local buttonBack = vgui.Create( "DPanel", popup )
	buttonBack:Dock( BOTTOM )
	buttonBack:DockMargin( 10, 0, 10, 10 )
	buttonBack:SetTall( 40 )
	buttonBack.Paint = function() end

    local buttons = {}
    local function createButton( text, func )
        local button = vgui.Create( "DButton", buttonBack )
        button:Dock( LEFT )
        button:DockMargin( 0, 0, 10, 0 )
        button:SetText( "" )
        local alpha = 0
        button.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 75 )
            else
                alpha = math.Clamp( alpha-5, 0, 75 )
            end
            
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ) )

            draw.SimpleText( text, "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
        end
        button.DoClick = function()
            if( func ) then
                func( numberWang:GetValue() )
            end
            
            popup:Close()
        end

        table.insert( buttons, button )

        for k, v in ipairs( buttons ) do
            v:SetWide( (popup:GetPopupWide()-20-((#buttons-1)*10))/#buttons )
        end
    end

    createButton( confirmText, confirmFunc )
    createButton( cancelText, cancelFunc )

	popup:SetExtraHeight( textArea:GetTall()+25+numberWang:GetTall()+buttonBack:GetTall()+10 )
end

function BOTCHED.FUNC.DermaComboRequest( text, title, options, default, searchSelect, confirmText, confirmFunc, cancelText, cancelFunc )
    default = default or ""
    confirmText = confirmText or "OK"
    cancelText = cancelText or "Cancel"
    title = title or "REQUEST"

	local popup = vgui.Create( "botched_popup_base" )
	popup:SetHeader( title )

    surface.SetFont( "MontserratMedium20" )
	local textX, textY = surface.GetTextSize( text )

	popup:SetPopupWide( math.max( ScrW()*0.15, textX+30 ) )

	local textArea = vgui.Create( "DPanel", popup )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 0, 10, 0 )
	textArea:SetTall( 30 )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( text, "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    local comboEntry = vgui.Create( searchSelect and "botched_combosearch" or "botched_combo", popup )
	comboEntry:Dock( TOP )
	comboEntry:DockMargin( 10, 0, 10, 0 )
	comboEntry:SetTall( 40 )
	comboEntry:SetValue( "Select Option" )
	for k, v in pairs( options ) do
		comboEntry:AddChoice( v, k, default == k or default == v )
	end

    local buttonBack = vgui.Create( "DPanel", popup )
	buttonBack:Dock( BOTTOM )
	buttonBack:DockMargin( 10, 0, 10, 10 )
	buttonBack:SetTall( 40 )
	buttonBack.Paint = function() end

    local buttons = {}
    local function createButton( text, func )
        local button = vgui.Create( "DButton", buttonBack )
        button:Dock( LEFT )
        button:DockMargin( 0, 0, 10, 0 )
        button:SetText( "" )
        local alpha = 0
        button.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 75 )
            else
                alpha = math.Clamp( alpha-5, 0, 75 )
            end
            
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ) )

            draw.SimpleText( text, "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
        end
        button.DoClick = function()
            if( func ) then
                func()
            end
            
            popup:Close()
        end

        table.insert( buttons, button )

        for k, v in ipairs( buttons ) do
            v:SetWide( (popup:GetPopupWide()-20-((#buttons-1)*10))/#buttons )
        end
    end

    createButton( confirmText, function()
        local value, data = comboEntry:GetSelected()
		if( value and data ) then
            if( confirmFunc ) then confirmFunc( value, data ) end
		else
			notification.AddLegacy( "You need to select a value!", 1, 3 )
		end
    end )
    createButton( cancelText, cancelFunc )

	popup:SetExtraHeight( textArea:GetTall()+25+comboEntry:GetTall()+buttonBack:GetTall()+10 )
end

function BOTCHED.FUNC.DermaProgressBar( title, textFunc, percentFunc, cancelFunc )
	local popup = vgui.Create( "botched_popup_base" )
	popup:SetHeader( title )
	popup:SetPopupWide( ScrW()*0.15 )
    popup.backButton:Remove()

    surface.SetFont( "MontserratMedium20" )

    local textArea = vgui.Create( "DPanel", popup )
	textArea:Dock( TOP )
	textArea:DockMargin( 10, 0, 10, 20 )
	textArea:SetTall( select( 2, surface.GetTextSize( textFunc() ) ) )
	textArea.Paint = function( self2, w, h ) 
		draw.SimpleText( textFunc(), "MontserratMedium20", w/2, h/2, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

	local progressArea = vgui.Create( "DPanel", popup )
	progressArea:Dock( TOP )
	progressArea:DockMargin( 10, 0, 10, 0 )
	progressArea:SetTall( 40 )
	progressArea.Paint = function( self2, w, h )
        draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )

        local percent = math.Clamp( percentFunc(), 0, 1 )
        BOTCHED.FUNC.DrawRoundedMask( 8, 0, 0, w, h, function()
            surface.SetDrawColor( BOTCHED.FUNC.GetTheme( 3, 100 ) )
            surface.DrawRect( 0, 0, w*percent, h )
        end )

		draw.SimpleText( math.floor( percent*100 ) .. "%", "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	end

    if( cancelFunc ) then
        local bottomButton = vgui.Create( "DButton", popup )
        bottomButton:Dock( BOTTOM )
        bottomButton:DockMargin( 10, 0, 10, 10 )
        bottomButton:SetTall( 40 )
        bottomButton:SetText( "" )
        local alpha = 0
        bottomButton.Paint = function( self2, w, h )
            if( self2:IsHovered() ) then
                alpha = math.Clamp( alpha+5, 0, 75 )
            else
                alpha = math.Clamp( alpha-5, 0, 75 )
            end
            
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
            draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, alpha ) )

            draw.SimpleText( "Cancel", "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(alpha/75)) ), 1, 1 )
        end
        bottomButton.DoClick = function()
            popup:Close()
        end

        popup:SetExtraHeight( textArea:GetTall()+20+progressArea:GetTall()+25+bottomButton:GetTall()+10 )
    else
        popup:SetExtraHeight( textArea:GetTall()+20+progressArea:GetTall()+10 )
    end

    return popup
end

function BOTCHED.FUNC.DermaCreateGemStore()
    BOTCHED.FUNC.DermaMessage( "The gem store is not available at the moment.", "STORE", "Continue" )

    --vgui.Create( "botched_popup_gemstore" )
end