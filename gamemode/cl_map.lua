local function RebuildMapImage( updateFunc, finishFunc )
    local scrW, scrH = ScrW(), ScrH()

    local mapTable = BOTCHED.TEMP.Map
    if( not mapTable.SizeHeight or not mapTable.SizeW or not mapTable.SizeE or not mapTable.SizeS or not mapTable.SizeN ) then return end
    
    local folderPath = "botched/mapimages/" .. game.GetMap()
    if( not file.IsDir( folderPath, "DATA" ) ) then
        file.CreateDir( folderPath )
    end

    for k, v in ipairs( file.Find( folderPath .. "/*", "DATA" ) ) do
        file.Delete( folderPath .. "/" .. v  )
    end

    local totalW, totalH = 27500, 27500

    local splitSizeW = 11500
    local splitSizeH = (scrH/scrW)*splitSizeW

    local capturesWide, capturesTall = math.ceil( totalW/splitSizeW ), math.ceil( totalH/splitSizeH )
    
    local origins = {}
    for row = 1, capturesTall do
        origins[row] = {}
        for column = 1, capturesWide do
            origins[row][column] = Vector( mapTable.SizeW+((column-1)*splitSizeW)+(splitSizeW/2), mapTable.SizeN-((row-1)*splitSizeH)-(splitSizeH/2), mapTable.SizeHeight-1000 )
        end
    end

    local data = {
        angles = Angle(90, 90, 0),
        x = 0,
        y = 0,
        w = scrW,
        h = scrH,
        drawviewmodel = false
    }

    local totalCount = 0
    for row, columns in ipairs( origins ) do
        for column, vector in ipairs( columns ) do
            totalCount = totalCount+1
        end
    end

    local captureCount, previousSizeH = 0, 0
    for row, columns in ipairs( origins ) do
        previousSizeH = previousSizeH+splitSizeH
        local curPreviousSizeH = previousSizeH

        local previousSizeW = 0
        for column, vector in ipairs( columns ) do
            previousSizeW = previousSizeW+splitSizeW
            local curPreviousSizeW = previousSizeW

            captureCount = captureCount+1
            local curCaptureCount = captureCount

            timer.Simple( 0.3*curCaptureCount, function()
                print( "MAP BUILDING - " .. math.floor( (curCaptureCount/totalCount)*100 ) .. "%", "ROW " .. row, "COLUMN " .. column )

                updateFunc( curCaptureCount, totalCount )

                local dataCopy = table.Copy( data )
                dataCopy.origin = vector
                dataCopy.ortho = {
                    left = -(splitSizeW/2),
                    right = (splitSizeW/2),
                    top = -(splitSizeH/2),
                    bottom =  (splitSizeH/2)
                }

                render.ClearStencil()
                render.SetStencilEnable(true)

                render.SetStencilWriteMask(255)
                render.SetStencilTestMask(255)
                render.SetStencilReferenceValue(255)
                render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
                render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
                render.SetStencilPassOperation(STENCILOPERATION_REPLACE)
                render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)

                render.SuppressEngineLighting(true)
                render.SetColorModulation(0, 1, 0)
                render.SetBlend(0.4)

                render.RenderView(dataCopy)

                local hOffset = 0
                if( curPreviousSizeH > totalH ) then
                    hOffset = ((curPreviousSizeH-totalH)/splitSizeH)*scrH
                end

                local wOffset = 0
                if( curPreviousSizeW > totalW ) then
                    wOffset = ((curPreviousSizeW-totalW)/splitSizeW)*scrW
                end

                local tbl = render.Capture({
                    format = "jpeg",
                    quality = 100,
                    w = scrW-wOffset, 
                    h = scrH-hOffset,
                    x = 0,
                    y = 0
                })

                render.SuppressEngineLighting(false)
                render.SetColorModulation(1, 1, 1)
                render.SetBlend(1)

                render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
                render.SetStencilEnable(false)

                local image = file.Open( folderPath .. string.format( "/row%02dcolumn%02d", row, column ) .. "_" .. os.time() .. ".jpg", "wb", "DATA" )
                image:Write( tbl )
                image:Close()

                if( curCaptureCount == totalCount ) then
                    finishFunc()
                end
            end )
        end
    end
end

net.Receive( "Botched.SendMapSize", function()
    local shouldOpenMap = net.ReadBool()

    BOTCHED.TEMP.Map = net.ReadTable()

    local curCaptureCount, totalCount = 0, 1
    local popup = BOTCHED.FUNC.DermaProgressBar( "WORLD MAP", function() 
        return "Building map section " .. curCaptureCount .. "/" .. totalCount
    end, function()
        return curCaptureCount/totalCount
    end )

    RebuildMapImage( function( nCurCaptureCount, nTotalCount )
        curCaptureCount, totalCount = nCurCaptureCount, nTotalCount
    end, function()
        if( IsValid( popup ) ) then
            popup:Close()
        end

        if( shouldOpenMap ) then
            if( IsValid( BOTCHED_MAPMENU ) ) then
                BOTCHED_MAPMENU:Remove()
            end
        
            BOTCHED_MAPMENU = vgui.Create( "botched_popup_map" )
        end

        if( IsValid( BOTCHED_HUD ) ) then
            if( IsValid( BOTCHED_HUD.map ) ) then
                BOTCHED_HUD.map:Remove()
            end
        
            BOTCHED_HUD.map = vgui.Create( "botched_hud_map", BOTCHED_HUD )
            BOTCHED_HUD.map:SetPos( 25, 25 )
        end
    end )
end )

net.Receive( "Botched.SendOpenMap", function()
    local mapTable = BOTCHED.TEMP.Map
    if( not mapTable or not mapTable.SizeHeight or not mapTable.SizeW or not mapTable.SizeE or not mapTable.SizeS or not mapTable.SizeN ) then 
        net.Start( "Botched.RequestMapSize" )
            net.WriteBool( true )
        net.SendToServer()
        return 
    end

    if( IsValid( BOTCHED_MAPMENU ) ) then
        BOTCHED_MAPMENU:Remove()
        return
    end

    BOTCHED_MAPMENU = vgui.Create( "botched_popup_map" )

    BOTCHED.FUNC.CompleteTutorialStep( 3, 4 )
end )

net.Receive( "Botched.SendMapTeleport", function()
    local teleportKey = net.ReadUInt( 4 )
    local endTime = net.ReadUInt( 22 )

    local teleportConfig = BOTCHED.CONFIG.Map.Teleports[teleportKey]

    if( IsValid( BOTCHED_MAPMENU ) ) then
        BOTCHED_MAPMENU:Remove()
    end

    local popup = BOTCHED.FUNC.DermaProgressBar( "WORLD MAP", function() 
        return "Teleporting in " .. BOTCHED.FUNC.FormatLetterTime( math.max( 0, endTime-CurTime() ) )
    end, function()
        return (teleportConfig.Duration-(endTime-CurTime()))/teleportConfig.Duration
    end )

    timer.Simple( endTime-CurTime(), function()
        if( not IsValid( popup ) ) then return end
        popup:Close()
    end )

    if( teleportKey == 3 ) then
        BOTCHED.FUNC.CompleteTutorialStep( 3, 6 )
    end
end )