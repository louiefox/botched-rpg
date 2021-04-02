-- DRAW FUNCTIONS --
function BOTCHED.FUNC.GetTheme( themeNum, alpha )
    local color = BOTCHED.CONFIG.Themes[themeNum] or Color( 255, 255, 255 )
    return alpha and Color( color.r, color.g, color.b, alpha ) or color
end

function BOTCHED.FUNC.ScreenScale( number )
    return number*(ScrW()/2560)
end

local function startStencil()
	render.ClearStencil()
	render.SetStencilEnable( true )

	render.SetStencilWriteMask( 1 )
	render.SetStencilTestMask( 1 )

	render.SetStencilFailOperation( STENCILOPERATION_REPLACE )
	render.SetStencilPassOperation( STENCILOPERATION_ZERO )
	render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )
	render.SetStencilReferenceValue( 1 )
end

local function middleStencil()
	render.SetStencilFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilPassOperation( STENCILOPERATION_REPLACE )
	render.SetStencilZFailOperation( STENCILOPERATION_ZERO )
	render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )
	render.SetStencilReferenceValue( 1 )
end

local function endStencil()
	render.SetStencilEnable( false )
	render.ClearStencil()
end

function BOTCHED.FUNC.DrawPartialRoundedBox( cornerRadius, x, y, w, h, color, roundedBoxW, roundedBoxH, roundedBoxX, roundedBoxY )
	startStencil()

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawRect( x, y, w, h )

	middleStencil()

	draw.RoundedBox( cornerRadius, (roundedBoxX or x), (roundedBoxY or y), (roundedBoxW or w), (roundedBoxH or h), color )

	endStencil()
end

function BOTCHED.FUNC.DrawPartialRoundedBoxEx( cornerRadius, x, y, w, h, color, roundedBoxW, roundedBoxH, roundedBoxX, roundedBoxY, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight )
	startStencil()

	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawRect( x, y, w, h )

	middleStencil()

	draw.RoundedBoxEx( cornerRadius, (roundedBoxX or x), (roundedBoxY or y), (roundedBoxW or w), (roundedBoxH or h), color, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight )

	endStencil()
end

-- Credits: https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/includes/modules/draw.lua, https://gist.github.com/MysteryPancake/e8d367988ef05e59843f669566a9a59f
BOTCHED.MaskMaterial = CreateMaterial("!botched_mask","UnlitGeneric",{
	["$translucent"] = 1,
	["$vertexalpha"] = 1,
	["$alpha"] = 1,
})

local whiteColor = Color( 255, 255, 255 )
local renderTarget
local function drawRoundedMask( cornerRadius, x, y, w, h, drawFunc, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight )
	if( not renderTarget ) then
		renderTarget = GetRenderTargetEx( "BOTCHED_ROUNDEDBOX", ScrW(), ScrH(), RT_SIZE_FULL_FRAME_BUFFER, MATERIAL_RT_DEPTH_NONE, 2, CREATERENDERTARGETFLAGS_UNFILTERABLE_OK, IMAGE_FORMAT_RGBA8888 )
	end

	render.PushRenderTarget( renderTarget )
	render.OverrideAlphaWriteEnable( true, true )
	render.Clear( 0, 0, 0, 0 ) 

	drawFunc()

	render.OverrideBlendFunc( true, BLEND_ZERO, BLEND_SRC_ALPHA, BLEND_DST_ALPHA, BLEND_ZERO )
	draw.RoundedBoxEx( cornerRadius, x, y, w, h, whiteColor, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight )
	render.OverrideBlendFunc( false )
	render.OverrideAlphaWriteEnable( false )
	render.PopRenderTarget() 

	BOTCHED.MaskMaterial:SetTexture( "$basetexture", renderTarget )

	draw.NoTexture()

	surface.SetDrawColor( 255, 255, 255, 255 ) 
	surface.SetMaterial( BOTCHED.MaskMaterial ) 
	render.SetMaterial( BOTCHED.MaskMaterial )
	render.DrawScreenQuad() 
end

function BOTCHED.FUNC.DrawRoundedMask( cornerRadius, x, y, w, h, drawFunc )
	drawRoundedMask( cornerRadius, x, y, w, h, drawFunc, true, true, true, true )
end

function BOTCHED.FUNC.DrawRoundedExMask( cornerRadius, x, y, w, h, drawFunc, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight )
	drawRoundedMask( cornerRadius, x, y, w, h, drawFunc, roundTopLeft, roundTopRight, roundBottomLeft, roundBottomRight )
end

-- CIRCLE/ARC STUFF --
function BOTCHED.FUNC.DrawCircle( x, y, radius, color )
	if( radius <= 0 ) then return end
	
	if( color and istable( color ) and color.r and color.g and color.b ) then
		surface.SetDrawColor( color )
	end
	
	draw.NoTexture()

	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, 45 do
		local a = math.rad( ( i / 45 ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

function BOTCHED.FUNC.PrecachedArc( cx, cy, radius, thickness, startang, endang, roughness )
	local triarc = {}
	-- local deg2rad = math.pi / 180
	
	-- Define step
	local roughness = math.max(roughness or 1, 1)
	local step = roughness
	
	-- Correct start/end ang
	local startang,endang = startang or 0, endang or 0
	
	if startang > endang then
		step = math.abs(step) * -1
	end
	
	-- Create the inner circle's points.
	local inner = {}
	local r = radius - thickness
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx+(math.cos(rad)*r), cy+(-math.sin(rad)*r)
		table.insert(inner, {
			x=ox,
			y=oy,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end	
	
	-- Create the outer circle's points.
	local outer = {}
	for deg=startang, endang, step do
		local rad = math.rad(deg)
		-- local rad = deg2rad * deg
		local ox, oy = cx+(math.cos(rad)*radius), cy+(-math.sin(rad)*radius)
		table.insert(outer, {
			x=ox,
			y=oy,
			u=(ox-cx)/radius + .5,
			v=(oy-cy)/radius + .5,
		})
	end	
	
	-- Triangulize the points.
	for tri=1,#inner*2 do -- twice as many triangles as there are degrees.
		local p1,p2,p3
		p1 = outer[math.floor(tri/2)+1]
		p3 = inner[math.floor((tri+1)/2)+1]
		if tri%2 == 0 then --if the number is even use outer.
			p2 = outer[math.floor((tri+1)/2)]
		else
			p2 = inner[math.floor((tri+1)/2)]
		end
	
		table.insert(triarc, {p1,p2,p3})
	end
	
	-- Return a table of triangles to draw.
	return triarc
end

function BOTCHED.FUNC.DrawCachedArc( arc, color )
	draw.NoTexture()

	if( color ) then
		surface.SetDrawColor( color )
	end

	for k,v in ipairs(arc) do
		surface.DrawPoly(v)
	end
end


function BOTCHED.FUNC.DrawArc( cx, cy, radius, thickness, startang, endang, color )
	BOTCHED.FUNC.DrawCachedArc( BOTCHED.FUNC.PrecachedArc( cx, cy, radius, thickness, startang, endang ), color )
end

local radiusAnim, fadeAnim, endRadius = 0.2, 0.2, 0
function BOTCHED.FUNC.DrawClickCircle( panel, w, h, color, cornerRadius, overrideX, overrideY )
	if( panel:IsDown() and not panel.doClickAnim ) then
		endRadius = math.sqrt( ((w/2)^2)+((h/2)^2) )
		panel.doClickAnimEndTime = CurTime()+radiusAnim+fadeAnim
		panel.doClickAnim = true
	end

	if( panel.doClickAnim ) then
		local timeLeft = (panel.doClickAnimEndTime or 0)-CurTime()
		if( timeLeft <= 0 ) then
			panel.doClickAnimEndTime = nil
			panel.doClickAnim = false
		end

		local radiusTimeLeft = (panel.doClickAnimEndTime or 0)-fadeAnim-CurTime()
		local radius = endRadius*math.Clamp( (radiusAnim-radiusTimeLeft)/radiusAnim, 0, 1 )

		local fade = 1
		if( CurTime() >= (panel.doClickAnimEndTime or 0)-fadeAnim ) then
			fade = math.Clamp( timeLeft/fadeAnim, 0, 1 )
		end

		local x, y = overrideX or w/2, overrideY or h/2

		surface.SetAlphaMultiplier( fade )
		draw.NoTexture()
		surface.SetDrawColor( color )
		if( cornerRadius ) then
			BOTCHED.FUNC.DrawRoundedMask( cornerRadius, 0, 0, w, h, function()
				BOTCHED.FUNC.DrawCircle( x, y, radius, radius )
			end )
		else
			BOTCHED.FUNC.DrawCircle( x, y, radius, radius )
		end
		surface.SetAlphaMultiplier( 1 )

	end
end

local gradientMatR, gradientMatU, gradientMatD = Material("gui/gradient"), Material("gui/gradient_up"), Material("gui/gradient_down")
function BOTCHED.FUNC.DrawGradientBox(x, y, w, h, direction, ...)
	local colors = {...}
	local horizontal = direction != 1
	local secSize = math.ceil( ((horizontal and w) or h)/math.ceil( #colors/2 ) )
	
	local previousPos = (horizontal and x or y)-secSize
	for k, v in pairs( colors ) do
		if( k % 2 != 0 ) then
			previousPos = previousPos+secSize
			surface.SetDrawColor( v )
			surface.DrawRect( (horizontal and previousPos or x), (horizontal and y or previousPos), (horizontal and secSize or w), (horizontal and h or secSize) )
		end
	end

	local previousGradPos = (horizontal and x or y)-secSize
	for k, v in pairs( colors ) do
		if( k % 2 == 0 ) then
			previousGradPos = previousGradPos+secSize
			surface.SetDrawColor( v )
			surface.SetMaterial( horizontal and gradientMatR or gradientMatU )
			if( horizontal ) then
				surface.DrawTexturedRectUV( (horizontal and previousGradPos or x), (horizontal and y or previousGradPos), (horizontal and secSize or w), (horizontal and h or secSize), 1, 0, 0, 1)
			else
				surface.DrawTexturedRect( (horizontal and previousGradPos or x), (horizontal and y or previousGradPos), (horizontal and secSize or w), (horizontal and h or secSize))
			end

			if( colors[k+1] ) then
				surface.SetDrawColor( v )
				surface.SetMaterial( horizontal and gradientMatR or gradientMatD )
				surface.DrawTexturedRect((horizontal and previousGradPos+secSize or x), (horizontal and y or previousGradPos+secSize), (horizontal and secSize or w), (horizontal and h or secSize))
			end
		end
	end
end

local blur = Material("pp/blurscreen")
function BOTCHED.FUNC.DrawBlur( p, a, d )
	local x, y = p:LocalToScreen(0, 0)
	surface.SetDrawColor( 255, 255, 255 )
    surface.SetMaterial( blur )
    
	for i = 1, d do
		blur:SetFloat( "$blur", (i / d ) * ( a ) )
		blur:Recompute()
		if( render ) then render.UpdateScreenEffectTexture() end
		surface.DrawTexturedRect( x * -1, y * -1, ScrW(), ScrH() )
	end
end

BOTCHED.TEMP.ItemSlotLoad = BOTCHED.TEMP.ItemSlotLoad or {}
BOTCHED.TEMP.ModelsLoaded = BOTCHED.TEMP.ModelsLoaded or {}

local function RunModelsLoadQueue()
	local queueItem = BOTCHED.TEMP.ItemSlotLoad[1]
	if( queueItem ) then
		table.remove( BOTCHED.TEMP.ItemSlotLoad, 1 )

		if( IsValid( queueItem[1] ) ) then
			queueItem[2]()
			timer.Create( "BOTCHED.Timer.ItemSlotLoad", 0.1, 1, function()
				RunModelsLoadQueue()
			end )
		else
			RunModelsLoadQueue()
		end
	end
end

function BOTCHED.FUNC.AddSlotToLoad( panel, func )
	table.insert( BOTCHED.TEMP.ItemSlotLoad, { panel, func } )
	
	if( timer.Exists( "BOTCHED.Timer.ItemSlotLoad" ) ) then return end
	RunModelsLoadQueue()
end

local function GetImageFromURL( url, failFunc )
    local CRC = util.CRC( url )
    local Extension = string.Split( url, "." )
    Extension = Extension[#Extension] or "png"

    if( not file.Exists( "botched/images", "DATA" ) ) then
        file.CreateDir( "botched/images" )
    end
    
    if( file.Exists( "botched/images/" .. CRC .. "." .. Extension, "DATA" ) ) then
        BOTCHED.TEMP.CachedMaterials[url] = Material( "data/botched/images/" .. CRC .. "." .. Extension )

        if( failFunc ) then
            failFunc( BOTCHED.TEMP.CachedMaterials[url], key )
        end

        return BOTCHED.TEMP.CachedMaterials[url], key
    else
        http.Fetch( url, function( body )
            file.Write( "botched/images/" .. CRC .. "." .. Extension, body )
            BOTCHED.TEMP.CachedMaterials[url] = Material( "data/botched/images/" .. CRC .. "." .. Extension )

            if( failFunc ) then
                failFunc( BOTCHED.TEMP.CachedMaterials[url], key )
            end
        end )
    end
end

BOTCHED.TEMP.CachedMaterials = {}

function BOTCHED.FUNC.CacheImageFromURL( url, failFunc )
    BOTCHED.TEMP.CachedMaterials[url] = false

    if( not BOTCHED.TEMP.CachedMaterials[url] ) then
        BOTCHED.TEMP.CachedMaterials[url] = GetImageFromURL( url, failFunc )
    end
end

BOTCHED.TEMP.GetImagesQueue = BOTCHED.TEMP.GetImagesQueue or {}
local function RunGetImagesQueue()
	local queueItem = BOTCHED.TEMP.GetImagesQueue[1]
	if( queueItem ) then
		table.remove( BOTCHED.TEMP.GetImagesQueue, 1 )

		local url, onGetFunc = queueItem[1], queueItem[2]
		if( BOTCHED.TEMP.CachedMaterials[url] ) then
			onGetFunc( BOTCHED.TEMP.CachedMaterials[url] )
			RunGetImagesQueue()
		else
			BOTCHED.FUNC.CacheImageFromURL( url, onGetFunc )

			timer.Create( "BOTCHED.Timer.GetImageLoad", 0.2, 1, function()
				RunGetImagesQueue()
			end )
		end
	end
end

function BOTCHED.FUNC.GetImage( url, onGetFunc )
	table.insert( BOTCHED.TEMP.GetImagesQueue, { url, onGetFunc } )
	
	if( timer.Exists( "BOTCHED.Timer.GetImageLoad" ) ) then return end
	RunGetImagesQueue()
end

-- Credits: https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/base/cl_util.lua
local function charWrap(text, remainingWidth, maxWidth)
    local totalWidth = 0

    text = text:gsub(".", function(char)
        totalWidth = totalWidth + surface.GetTextSize(char)

        -- Wrap around when the max width is reached
        if totalWidth >= remainingWidth then
            -- totalWidth needs to include the character width because it's inserted in a new line
            totalWidth = surface.GetTextSize(char)
            remainingWidth = maxWidth
            return "\n" .. char
        end

        return char
    end)

    return text, totalWidth
end

function BOTCHED.FUNC.TextWrap(text, font, maxWidth)
    local totalWidth = 0

    surface.SetFont(font)

    local spaceWidth = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
		local char = string.sub(word, 1, 1)
		if char == "\n" or char == "\t" then
			totalWidth = 0
		end

		local wordlen = surface.GetTextSize(word)
		totalWidth = totalWidth + wordlen

		-- Wrap around when the max width is reached
		if wordlen >= maxWidth then -- Split the word if the word is too big
			local splitWord, splitPoint = charWrap(word, maxWidth - (totalWidth - wordlen), maxWidth)
			totalWidth = splitPoint
			return splitWord
		elseif totalWidth < maxWidth then
			return word
		end

		-- Split before the word
		if char == ' ' then
			totalWidth = wordlen - spaceWidth
			return '\n' .. string.sub(word, 2)
		end

		totalWidth = wordlen
		return '\n' .. word
	end)

    return text, string.len( text )-string.len( string.Replace( text, "\n", "" ) )+1
end

-- Credits: https://github.com/FPtje/DarkRP/blob/master/gamemode/modules/base/cl_drawfunctions.lua
local function safeText(text)
    return string.match(text, "^#([a-zA-Z_]+)$") and text .. " " or text
end

function BOTCHED.FUNC.DrawNonParsedText(text, font, x, y, color, xAlign)
    return draw.DrawText(safeText(text), font, x, y, color, xAlign)
end