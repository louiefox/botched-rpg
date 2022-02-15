AddCSLuaFile()

if CLIENT then
    SWEP.PrintName = "Admin Toolgun"
    SWEP.Slot = 5
    SWEP.SlotPos = 1
    SWEP.DrawAmmo = false
    SWEP.DrawCrosshair = true
end

SWEP.Author = "Brickwall"
SWEP.Instructions = "Magic?!?!?!"
SWEP.Contact = ""
SWEP.Purpose = "To use magic!"

SWEP.WorldModel = ""
SWEP.ViewModelFOV = 62
SWEP.ViewModelFlip = false
SWEP.AnimPrefix = "rpg"
SWEP.UseHands = true

SWEP.Category = "Admin"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.Options = {
	[1] = { 
		Name = "Monster Spawner", 
		ReqInfo = {
			[1] = { "Combo", "Monster Class", function()
				local options = {}
				for k, v in pairs( BOTCHED.CONFIG.Monsters ) do
					table.insert( options, { v.Name, k } )
				end

				return options
			end },
			[2] = { "Integer", "Respawn Time" }
		},
		PrimaryAttackName = "Place Spawn",
		PrimaryAttack = function( ply, trace, monsterClass, respawnTime )
			local monsterConfig = BOTCHED.CONFIG.Monsters[monsterClass]
			if( not trace.HitPos or not trace.HitNormal or not monsterConfig ) then return end

			local key = table.insert( BOTCHED.MonsterSpawns, {
				MonsterClass = monsterClass,
				RespawnTime = respawnTime or 60,
				Pos = trace.HitPos,
				Angles = Angle( trace.HitNormal )
			} )
	
			BOTCHED.FUNC.SendAdminsMonsterSpawns()
			BOTCHED.FUNC.SaveMonsterSpawns()
			BOTCHED.FUNC.SpawnMonster( key )
		end,
		SecondaryAttackName = "Remove Spawn",
		SecondaryAttack = function( ply, trace )
			for k, v in pairs( BOTCHED.MonsterSpawns ) do
				if( trace.HitPos:DistToSqr( v.Pos ) < 4000 ) then
					if( timer.Exists( "BOTCHED.Timer.MonsterSpawn_" .. k ) ) then
						timer.Remove( "BOTCHED.Timer.MonsterSpawn_" .. k )
					end

					if( BOTCHED.TEMP.SpawnedMonsters[k] and IsValid( BOTCHED.TEMP.SpawnedMonsters[k] ) ) then
						BOTCHED.TEMP.SpawnedMonsters[k]:Remove()
					end

					BOTCHED.MonsterSpawns[k] = nil
		
					BOTCHED.FUNC.SendAdminsMonsterSpawns()
					BOTCHED.FUNC.SaveMonsterSpawns()
					break
				end
			end	
		end,
		OnDeploy = function( ply )
			if( not SERVER ) then return end
			ply:SendMonsterSpawns()
		end,
		OnHolster = function( ply )
			if( not CLIENT ) then return end
			for k, v in pairs( BOTCHED.TEMP.ClientsideMonsterSpawns or {} ) do
				if( not IsValid( v ) ) then continue end
				v:Remove()
			end
		end,
		DrawHUD = function()
			for k, v in pairs( BOTCHED.MonsterSpawns or {} ) do
				local monsterConfig = BOTCHED.CONFIG.Monsters[v.MonsterClass] or {}

				local pos2d = Vector( v.Pos.x, v.Pos.y, v.Pos.z+40 ):ToScreen()
				local timeTable = string.FormattedTime( v.RespawnTime or 60 )
				draw.SimpleTextOutlined( (monsterConfig.Name or "NIL") .. " (#" .. k .. ") (" .. timeTable.m .. "m " .. timeTable.s .. "s)", "MontserratMedium33", pos2d.x, pos2d.y, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, BOTCHED.FUNC.GetTheme( 1 ) )
			end
		end
	},
	[2] = { 
		Name = "Resource Placer", 
		ReqInfo = {
			[1] = { "Combo", "Resource Type", function()
				local options = {}
				for k, v in pairs( BOTCHED.DEVCONFIG.ResourceTypes ) do
					table.insert( options, { v.Name, k } )
				end

				return options
			end }
		},
		PrimaryAttackName = "Place Tree",
		PrimaryAttack = function( ply, trace, resourceType )
			local typeConfig = BOTCHED.DEVCONFIG.ResourceTypes[resourceType]
			if( not trace.HitPos or not trace.HitNormal or not typeConfig ) then return end

			table.insert( BOTCHED.ResourceSpawns, {
				Type = resourceType,
				Pos = trace.HitPos,
				Angles = Angle( trace.HitNormal )
			} )
	
			BOTCHED.FUNC.SendAdminsResourceSpawns()
			BOTCHED.FUNC.SaveResourceSpawns()
		end,
		SecondaryAttackName = "Remove Tree",
		SecondaryAttack = function( ply, trace )
			for k, v in pairs( BOTCHED.ResourceSpawns ) do
				if( trace.HitPos:DistToSqr( v.Pos ) < 4000 ) then
					BOTCHED.ResourceSpawns[k] = nil
		
					BOTCHED.FUNC.SendAdminsResourceSpawns()
					BOTCHED.FUNC.SaveResourceSpawns()
					break
				end
			end	
		end,
		OnDeploy = function( ply )
			if( not SERVER ) then return end
			ply:SendResourceSpawns()
		end,
		OnHolster = function( ply )
			if( not CLIENT ) then return end
			for k, v in pairs( BOTCHED.TEMP.ClientsideResourceSpawns or {} ) do
				if( not IsValid( v ) ) then continue end
				v:Remove()
			end
		end,
		DrawHUD = function()
			for k, v in pairs( BOTCHED.ResourceSpawns or {} ) do
				local typeConfig = BOTCHED.DEVCONFIG.ResourceTypes[v.Type] or {}

				local pos2d = Vector( v.Pos.x, v.Pos.y, v.Pos.z+40 ):ToScreen()
				draw.SimpleTextOutlined( (typeConfig.Name or "NIL") .. " (#" .. k .. ")", "MontserratMedium33", pos2d.x, pos2d.y, BOTCHED.FUNC.GetTheme( 4 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, BOTCHED.FUNC.GetTheme( 1 ) )
			end
		end
	}
}

function SWEP:Initialize()
	self:SetHoldType( "normal" )
end

function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "ModeKey" )

	self:NetworkVarNotify( "ModeKey", function( ent, name, old, new ) 
		if( CLIENT ) then
			if( not IsValid( self.popupPanel ) ) then return end
			timer.Simple( 0, function() self.popupPanel.RefreshReqInfo() end )
		end

		local ply = self:GetOwner()

		if( self.Options[old] and self.Options[old].OnHolster ) then
			self.Options[old].OnHolster( ply )
		end

		if( self.Options[new].OnDeploy ) then
			self.Options[new].OnDeploy( ply )
		end
	end )
end

function SWEP:Deploy()
	local ply = self:GetOwner()

	if( not self:GetModeKey() or not self.Options[self:GetModeKey() or 0] ) then
		self:SetModeKey( 1 )
	end

	local modeTable = self.Options[self:GetModeKey() or 0]
	if( modeTable ) then
		if( modeTable.OnHolster ) then
			modeTable.OnHolster( ply )
		end

		if( modeTable.OnDeploy ) then
			modeTable.OnDeploy( ply )
		end
	end

    if( SERVER ) then 
		ply:DrawWorldModel( false )
	end

    return true
end

function SWEP:Holster()
	local modeTable = self.Options[self:GetModeKey() or 0]
	if( modeTable ) then
		if( modeTable.OnHolster ) then
			modeTable.OnHolster( self:GetOwner() )
		end

		if( modeTable.OnDeploy ) then
			modeTable.OnDeploy( self:GetOwner() )
		end
	end

    return true
end

function SWEP:PreDrawViewModel()
    return true
end

function SWEP:Think()

end

function SWEP:PrimaryAttack()
	if( not SERVER ) then return end

	local ply = self:GetOwner()
	
	if( not IsValid( ply ) or not ply:HasAdminPrivilege() or not ply:GetEyeTrace() ) then return end

	local trace = ply:GetEyeTrace()

	local optionTable = self.Options[self:GetModeKey()] or self.Options[1]
	if( optionTable.PrimaryAttack ) then
		local reqInfo = self.modeReqInfo
		if( optionTable.ReqInfo and (not reqInfo or #optionTable.ReqInfo != #reqInfo) ) then
			ply:SendNotification( 1, 3, "You haven't selected required variables!" )
			return
		end

		optionTable.PrimaryAttack( ply, trace, unpack( reqInfo ) )
	end
end

function SWEP:SecondaryAttack()
	if( not SERVER ) then return end

	local ply = self:GetOwner()
	
	if( not IsValid( ply ) or not ply:HasAdminPrivilege() or not ply:GetEyeTrace() ) then return end

	local trace = ply:GetEyeTrace()

	local optionTable = self.Options[self:GetModeKey()] or self.Options[1]
	if( optionTable.SecondaryAttack ) then
		optionTable.SecondaryAttack( ply, trace )
	end
end

function SWEP:Reload()
	if( not CLIENT or not LocalPlayer():HasAdminPrivilege() ) then return end

	if( IsValid( self.popupPanel ) ) then return end

	self.popupPanel = vgui.Create( "botched_popup_base" )
	self.popupPanel:SetHeader( "ADMIN TOOLGUN" )

	local modeSelectPanel = vgui.Create( "DPanel", self.popupPanel )
	modeSelectPanel:Dock( TOP )
	modeSelectPanel:DockMargin( 10, 0, 10, 0 )
	modeSelectPanel:SetTall( 65 )
	modeSelectPanel.Paint = function( self2, w, h )
		draw.SimpleText( "TOOL MODE", "MontserratBold22", 0, 0, BOTCHED.FUNC.GetTheme( 3 ), 0, 0 )
	end

	modeSelectPanel.entry = vgui.Create( "botched_combo", modeSelectPanel )
	modeSelectPanel.entry:Dock( BOTTOM )
	modeSelectPanel.entry:SetTall( 40 )
	modeSelectPanel.entry:SetValue( "Select Mode" )
	for k, v in ipairs( self.Options ) do
		modeSelectPanel.entry:AddChoice( v.Name, k, self:GetModeKey() == k )
	end
	modeSelectPanel.entry.OnSelect = function( self2, index, value, data )
		net.Start( "Botched.SendAdminToolMode" )
			net.WriteUInt( data, 8 )
		net.SendToServer()
	end

	local closeButton = vgui.Create( "DButton", self.popupPanel )
	closeButton:Dock( BOTTOM )
	closeButton:SetTall( 40 )
	closeButton:DockMargin( 10, 0, 10, 10 )
	closeButton:SetText( "" )
	closeButton.Paint = function( self2, w, h )
		self2:CreateFadeAlpha( false, 75 )
		
		draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 2, 100 ) )
		draw.RoundedBox( 8, 0, 0, w, h, BOTCHED.FUNC.GetTheme( 3, self2.alpha ) )

		draw.SimpleText( "Close", "MontserratBold25", w/2, h/2-1, BOTCHED.FUNC.GetTheme( 4, 75+(180*(self2.alpha/75)) ), 1, 1 )
	end
	closeButton.DoClick = function()
		self.popupPanel:Close()
	end

	local reqInfoEntries = {}
	self.popupPanel.RefreshReqInfo = function()
		if( not self.modeReqInfo ) then
			self.modeReqInfo = {}
			for k, v in ipairs( self.Options[self:GetModeKey()].ReqInfo or {} ) do
				if( v[1] == "Combo" ) then
					self.modeReqInfo[k] = (v[3]()[1] or {})[2]
				else
					self.modeReqInfo[k] = v[3]
				end
			end
		end

		for k, v in ipairs( reqInfoEntries ) do
			v:Remove()
		end

		reqInfoEntries = {}
		for k, v in pairs( self.Options[self:GetModeKey()].ReqInfo or {} ) do
			local reqInfoPanel = vgui.Create( "DPanel", self.popupPanel )
			reqInfoPanel:Dock( TOP )
			reqInfoPanel:DockMargin( 10, 10, 10, 0 )
			reqInfoPanel:SetTall( 65 )
			reqInfoPanel.Paint = function( self2, w, h )
				draw.SimpleText( string.upper( v[2] ), "MontserratBold22", 0, 0, BOTCHED.FUNC.GetTheme( 3 ), 0, 0 )
			end
			reqInfoPanel.EntryChanged = function( value )
				self.modeReqInfo = self.modeReqInfo or {}
				self.modeReqInfo[k] = value

				net.Start( "Botched.SendAdminToolReqInfo" )
					net.WriteUInt( k, 8 )
					if( v[1] == "Integer" ) then
						net.WriteInt( value, 32 )
					else
						net.WriteString( value )
					end
				net.SendToServer()
			end

			if( v[1] == "Integer" ) then
				reqInfoPanel.entry = vgui.Create( "botched_numberwang", reqInfoPanel )
				reqInfoPanel.entry:Dock( BOTTOM )
				reqInfoPanel.entry:SetTall( 40 )
				reqInfoPanel.entry:SetValue( self.modeReqInfo[k] or v[3] or 0 )
				reqInfoPanel.entry.OnChange = function()
					reqInfoPanel.EntryChanged( reqInfoPanel.entry:GetValue() )
				end
			elseif( v[1] == "Combo" ) then
				reqInfoPanel.entry = vgui.Create( "botched_combo", reqInfoPanel )
				reqInfoPanel.entry:Dock( BOTTOM )
				reqInfoPanel.entry:SetTall( 40 )
				reqInfoPanel.entry:SetValue( "" )
				for key, val in ipairs( v[3]() ) do
					reqInfoPanel.entry:AddChoice( val[1], val[2], self.modeReqInfo[k] == val[2] )
				end
				reqInfoPanel.entry.OnSelect = function( self2, index, value, data )
					reqInfoPanel.EntryChanged( data )
				end
			else
				reqInfoPanel.entry = vgui.Create( "botched_textentry", reqInfoPanel )
				reqInfoPanel.entry:Dock( BOTTOM )
				reqInfoPanel.entry:SetTall( 40 )
				reqInfoPanel.entry:SetValue( self.modeReqInfo[k] or v[3] or "" )
				reqInfoPanel.entry.OnChange = function()
					reqInfoPanel.EntryChanged( reqInfoPanel.entry:GetValue() )
				end
			end

			table.insert( reqInfoEntries, reqInfoPanel )
		end

		self.popupPanel:SetExtraHeight( modeSelectPanel:GetTall()+10+(#reqInfoEntries*75)+closeButton:GetTall()+25 )
	end
	self.popupPanel.RefreshReqInfo()
end

if( CLIENT ) then
	local topBarH = 30
	local w, h = ScrW()*0.15, 75+topBarH
	local x, y = (ScrW()/2)-(w/2), ScrH()-h-50
	function SWEP:DrawHUD()
		BSHADOWS.BeginShadow( "admin_toolgun" )
        draw.RoundedBox( 8, x, y, w, h, BOTCHED.FUNC.GetTheme( 2 ) )
		BSHADOWS.EndShadow( "admin_toolgun", x, y, 1, 2, 2, 255, 0, 0, false )

		draw.RoundedBoxEx( 8, x, y, w, topBarH, BOTCHED.FUNC.GetTheme( 1, 150 ), true, true, false, false )
		BOTCHED.FUNC.DrawPartialRoundedBoxEx( 8, x, y+h-10, w, 10, BOTCHED.FUNC.GetTheme( 3 ), false, y+h-16, false, 16, false, false, true, true )

		local optionTable = self.Options[self:GetModeKey()] or self.Options[1]
		draw.SimpleText( optionTable.Name or "None", "MontserratMedium20", x+w/2, y+topBarH/2-1, BOTCHED.FUNC.GetTheme( 3 ), 1, 1 )

		if( optionTable.PrimaryAttackName ) then
			draw.SimpleText( "LeftClick - " .. optionTable.PrimaryAttackName, "MontserratMedium20", x+w/2, y+topBarH+(h-topBarH-10)/2-2, BOTCHED.FUNC.GetTheme( 4 ), 1, optionTable.SecondaryAttackName and TEXT_ALIGN_BOTTOM or 1 )
		end

		if( optionTable.SecondaryAttackName ) then
			draw.SimpleText( "RightClick - " .. optionTable.SecondaryAttackName, "MontserratMedium20", x+w/2, y+topBarH+(h-topBarH-10)/2-2, BOTCHED.FUNC.GetTheme( 4 ), 1, optionTable.PrimaryAttackName and 0 or 1 )
		end

		if( optionTable.DrawHUD ) then
			optionTable.DrawHUD()
		end
	end
elseif( SERVER ) then
	util.AddNetworkString( "Botched.SendAdminToolMode" )
	net.Receive( "Botched.SendAdminToolMode", function( len, ply )
		if( not ply:HasAdminPrivilege() ) then return end

		local modeKey = net.ReadUInt( 8 )
		local adminTool = ply:GetWeapon( "weapon_admin_toolgun" )

		if( IsValid( adminTool ) ) then
			adminTool:SetModeKey( math.Clamp( modeKey, 1, #adminTool.Options ) )

			adminTool.modeReqInfo = {}

			local modeTable = adminTool.Options[modeKey]
			for k, v in ipairs( modeTable.ReqInfo or {} ) do
				if( v[1] == "Combo" ) then
					adminTool.modeReqInfo[k] = (v[3]()[1] or {})[2]
				else
					adminTool.modeReqInfo[k] = v[3]
				end
			end
		end
	end )

	util.AddNetworkString( "Botched.SendAdminToolReqInfo" )
	net.Receive( "Botched.SendAdminToolReqInfo", function( len, ply )
		if( not ply:HasAdminPrivilege() ) then return end

		local reqInfoKey = net.ReadUInt( 8 )
		local adminTool = ply:GetWeapon( "weapon_admin_toolgun" )

		if( IsValid( adminTool ) ) then
			local modeTable = adminTool.Options[adminTool:GetModeKey()]
			local reqInfoTable = modeTable.ReqInfo[reqInfoKey]

			if( reqInfoTable ) then
				local value = reqInfoTable[1] == "Integer" and net.ReadInt( 32 ) or net.ReadString()
				adminTool.modeReqInfo = adminTool.modeReqInfo or {}
				adminTool.modeReqInfo[reqInfoKey] = value
			end
		end
	end )
end