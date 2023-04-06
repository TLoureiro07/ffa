ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


local lastZone, currentAction, currentActionMsg, playerCoords
markercoords = nil
timeout = nil

menustate = false

local lastcolor = {255, 255, 255}
selected = {}
local hitmarker = false
local normalrcolor
local normalgcolor
local normalbcolor
local crosshairs = {
	{"+", 0.4955, 0.483},
	{"º", 0.4965, 0.4885},
	{'×', 0.4955, 0.4822},
	{'.', 0.49745, 0.4778},
	{'[  ]', 0.4915, 0.484255},
	{'^', 0.496,0.494},
}

selected.hair = '+'; selected.posx = 0.4955; selected.posy = 0.483; selected.color = {255, 255, 255}; selected.hitmarkercolor = {120, 0, 0}

userdata = nil
alluser = nil

team = nil

local zoneback

killer = nil

playerloadout = {}
playeroptions = {}

streak = 0

zone = nil
zonedata = nil

gamemode = nil
gamemodedata = nil


inGame = false
isDead = false

setloadout = false

local spawn

local jobname

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    jobname = job.name

    for i, blip in pairs(allBlips) do
        RemoveBlip(blip)
    end
    createBlips()
end)

ESX = nil
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getShditioabsaredObjditioabsect', function(obj) ESX = obj end)
		Citizen.Wait(0)

        if ESX.GetPlayerData().job ~= nil then
            jobname = ESX.GetPlayerData().job.name
        end
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer) 
	local data = xPlayer

    jobname = data.job.name
end)


AddEventHandler('ffa:hasEnteredMarker', function(zone)
	currentAction = 'ffa_menu'
	currentActionMsg = Config.FFAMarker[zone].Marker.MSG
end)

AddEventHandler('ffa:hasExitedMarker', function(zone)
	if zone == nil then return end
	-- ESX.UI.Menu.CloseAll()
	currentAction = nil
	local distance = #(playerCoords - Config.FFAMarker[zone].Marker.Coords)
	if distance > 20.0 then
	    menu(false);
	end
end)

RegisterNUICallback('ffa:menu', function(data)
	menu(data.bool)
end)

--Create Blips
allBlips = {}

function createBlips()
	if not inGame then
		for k,v in pairs(Config.FFAMarker) do
			if v.ShowBlip then
                if v.UseJob then
                    if v.Jobname == jobname then
                        local blip = AddBlipForCoord(v.Blip.Coords)
	
                        SetBlipSprite(blip, v.Blip.Sprite)
                        SetBlipDisplay(blip, v.Blip.Display)
                        SetBlipScale(blip, v.Blip.Scale)
                        SetBlipColour(blip, v.Blip.Colour)
            
                        SetBlipAsShortRange(blip, true)
            
                        BeginTextCommandSetBlipName('STRING')
                        AddTextComponentSubstringPlayerName(v.Blip.Name)
                        EndTextCommandSetBlipName(blip)
        
                        table.insert(allBlips, blip)
                    end
                else
                    local blip = AddBlipForCoord(v.Blip.Coords)
	
                    SetBlipSprite(blip, v.Blip.Sprite)
                    SetBlipDisplay(blip, v.Blip.Display)
                    SetBlipScale(blip, v.Blip.Scale)
                    SetBlipColour(blip, v.Blip.Colour)
        
                    SetBlipAsShortRange(blip, true)
        
                    BeginTextCommandSetBlipName('STRING')
                    AddTextComponentSubstringPlayerName(v.Blip.Name)
                    EndTextCommandSetBlipName(blip)
    
                    table.insert(allBlips, blip)
                end
			end
		end
	end
end

CreateThread(function()
	while true do
		Wait(0)
		if inGame then
			for i, blip in pairs(allBlips) do
				RemoveBlip(blip)
			end
		end
	end
end)

function insidePolygon(point, v)
    local oddNodes = false

	for i = 1, 1 do
		local Zone = v.ZoneCoords
		local j = #Zone
		for i = 1, #Zone do
			if (Zone[i][2] < point.y and Zone[j][2] >= point.y or Zone[j][2] < point.y and Zone[i][2] >= point.y) then
				if (Zone[i][1] + ( point[2] - Zone[i][2] ) / (Zone[j][2] - Zone[i][2]) * (Zone[j][1] - Zone[i][1]) < point.x) then
					oddNodes = not oddNodes;
				end
			end
			j = i;
		end
	end

    return oddNodes 
end

function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function DisplayHelpText(text)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringKeyboardDisplay(text)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function drawPoly(isEntityZone, v)
    local iPed = GetPlayerPed(-1)
	for i = 1, #v.ZoneCoords do
		if i < #v.ZoneCoords then
			local p2 = v.ZoneCoords[i+1]
			_drawWall(v.ZoneCoords[i], p2, v)
		end
	end
	if #v.ZoneCoords > 2 then
		local firstPoint = v.ZoneCoords[1]
		local lastPoint = v.ZoneCoords[#v.ZoneCoords]
		_drawWall(firstPoint, lastPoint, v)
	end
end

function _drawWall(p1, p2, v)
	if v.ShowZone then
		local bottomLeft = vector3(p1[1], p1[2], p1[3] - 1.5)
		local topLeft = vector3(p1[1], p1[2],  p1[3] + v.ZoneHeight)
		local bottomRight = vector3(p2[1], p2[2], p2[3] - 1.5)
		local topRight = vector3(p2[1], p2[2], p2[3] + v.ZoneHeight)
		
		DrawPoly(bottomLeft,topLeft,bottomRight, v.ZoneColor.r, v.ZoneColor.g, v.ZoneColor.b, v.ZoneAlpha)
		DrawPoly(topLeft,topRight,bottomRight, v.ZoneColor.r, v.ZoneColor.g, v.ZoneColor.b, v.ZoneAlpha)
		DrawPoly(bottomRight,topRight,topLeft, v.ZoneColor.r, v.ZoneColor.g, v.ZoneColor.b, v.ZoneAlpha)
		DrawPoly(bottomRight,topLeft,bottomLeft, v.ZoneColor.r, v.ZoneColor.g, v.ZoneColor.b, v.ZoneAlpha)
	end
end


-- Enter / Exit marker events and draw marker
CreateThread(function()
	while true do
		Wait(0)
		if not inGame then
			local isInMarker, currentZone, letSleep = nil, nil, true
            local hasjob  
            local usejob
			playerCoords = GetEntityCoords(PlayerPedId())

			for k,v in pairs(Config.FFAMarker) do
				local distance = #(playerCoords - v.Marker.Coords)

				if distance < v.Marker.DrawDistance then
					letSleep = false

					if v.ShowMarker then
                        if v.UseJob then
                            usejob = true
                            if v.Jobname == jobname then
                                hasjob = true
                                DrawMarker(v.Marker.Type, v.Marker.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Marker.Scale, v.Marker.Colour.r, v.Marker.Colour.g, v.Marker.Colour.b, v.Marker.Alpha, false, true, 2, false, nil, nil, false)
                            end
                        else
                            DrawMarker(v.Marker.Type, v.Marker.Coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, v.Marker.Scale, v.Marker.Colour.r, v.Marker.Colour.g, v.Marker.Colour.b, v.Marker.Alpha, false, true, 2, false, nil, nil, false)
                        end
                    end

					if distance < 1.5 then
						markercoords = v.Marker.Coords
						isInMarker, currentZone = true, k
					end
				end
			end

			if isInMarker or (isInMarker and lastZone ~= currentZone) then
				lastZone = currentZone
                if usejob then
                    if hasjob then
                        TriggerEvent('ffa:hasEnteredMarker', currentZone)
                    end
                else
                    TriggerEvent('ffa:hasEnteredMarker', currentZone)
                end
			end

			if not isInMarker then
                if usejob then
                    if hasjob then
                        TriggerEvent('ffa:hasExitedMarker', lastZone)
                    end
                else
                    TriggerEvent('ffa:hasExitedMarker', lastZone)
                end
			end

			if letSleep then
				Wait(500)
			end
		else
			currentAction = nil
		end
	end
end)

-- Key controls
CreateThread(function()
	while true do
		Wait(0)
		if menustate then
			DisableControlAction(0, Config.OpenMenuKey)
		end
		if timeout then 
			Wait(Config.OpenTimeout)
			timeout = false
		end
		if currentAction then
			if not timeout then
				ESX.ShowHelpNotification(currentActionMsg)
			end

			if IsControlJustReleased(0, Config.OpenMenuKey) then
				refreshmenu()
				menu(true);
				currentAction = nil
			end

		else
			Wait(500)
		end
	end
end)

RegisterNUICallback('ffa:setcrosshair', function(data)
	val = data.crosshair
	if val == 'cross' then
		hidehud = true
		selected.hair = crosshairs[1][1]; selected.posx = crosshairs[1][2]; selected.posy = crosshairs[1][3]
	elseif val == 'dot' then
		hidehud = true
		selected.hair = crosshairs[4][1]; selected.posx = crosshairs[4][2]; selected.posy = crosshairs[4][3]
	elseif val == 'default' then
		hidehud = false;
		selected.hair = ''; selected.posx = 0.0; selected.posy = 0.0
	elseif val == 'no' then
		hidehud = true
		selected.hair = ''; selected.posx = 0.0; selected.posy = 0.0
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if playeroptions.crosshair and inGame then
			if IsPedArmed(PlayerPedId(), 6) and IsPedShooting(PlayerPedId()) then
				local hitted, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())
				if hitted then
					if IsEntityAPed(entity) and IsPedAPlayer(entity) then
						hitmarker = true;
						
						posx = math.random(510, 550)
						posy = math.random(470, 500)
						
						Wait(100)
						hitmarker = false;
					end
				else
					hitmarker = false;
				end
			end
		end
	end
end)



Citizen.CreateThread(function()
	while true do
		Wait(0)
		if playeroptions.crosshair and inGame then
			if hidehud == true then
				HideHudComponentThisFrame(14)
			end
			if not menustate then 
				if selected.color == nil then 
					selected.color = {255, 255, 255}
				end
				-- if draw == true then
					cs(selected.hair, selected.posx, selected.posy, selected.color)
				-- end
			end
			-- if IsPedArmed(PlayerPedId(), 6) and (IsControlPressed(0, 92) and not IsPedInAnyVehicle(PlayerPedId()) and not IsEntityPlayingAnim(PlayerPedId(), "amb@medic@standing@tendtodead@idle_a", "idle_a", 3) or IsPlayerFreeAiming(PlayerId())) then
			-- 	if not menustate then 
			-- 		draw = true	
			-- 	end
			-- else
			-- 	draw = false
			-- end
			if hitmarker == true then
				if playeroptions.hitmarker then
					Config.OnHitmarker()
					selected.color = Config.HitMarkerColor;
				end
			else
				selected.color = lastcolor;
			end
		end
	end
end)

RegisterNUICallback('ffa:setCrosshairColor', function(data)
	local r = tonumber(data.Rcolor)
	local g = tonumber(data.Gcolor)
	local b = tonumber(data.Bcolor)

	selected.color = {r, g, b}
	lastcolor = selected.color
	cs(selected.hair, selected.posx, selected.posy, selected.color)
end)


function cs(C, x, y, co)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(0.0, 0.4)
	SetTextDropshadow(1, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextColour(co[1], co[2], co[3], 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(C)
	DrawText(x,y)
end 

function menu(bool)
	if not bool then timeout = true end
	menustate = bool
	if bool then
		TriggerServerEvent('ffa:setcounts')
	end
	SetNuiFocus(bool, bool)
	SendNUIMessage({
		type = "menu",
		status = bool
	})
end

function debug(text)
	if Config.Debug then
		print(text)
	end
end

-----------------------------------------------------------------------

function initmenu() 

    local newgamemodes = {}

    for k,v in pairs(Config.Gamemode) do
        if v.UseJob then
            if v.Jobname == jobname then
                -- print(json.encode(k))
                -- print(json.encode(Config.Gamemode[k]))
                newgamemodes[k] = Config.Gamemode[k]
                -- print(json.encode(newgamemodes))
            else
                -- Config.Gamemode[k] = ""
            end
            -- print(json.encode(newgamemodes))
        else
            newgamemodes[k] = Config.Gamemode[k]
        end
    end

    SendNUIMessage({
        type = "menudata",
        servername = Config.ServerName,
        gamemodes = newgamemodes,
        zones = Config.Zones,
        allusers = alluser,
        respawncountdown = Config.RespawnCountdown,
        outzonecountdown = Config.OutZoneCountdown,
        options = Config.DefaultPlayerOptions,
        leaderboardmaxplayer = Config.LeaderboardMaxPlayers
	})
end

CreateThread(function()
	while true do
		Wait(0)
		if inGame then
            --print(json.encode(userdata.options))
		end
	end
end)

-- RegisterNetEvent('ffa:refreshChart') 
-- AddEventHandler('ffa:refreshChart', function(data, time, category)
--     SendNUIMessage({
--         type = "refreshchart",
--         newadd = data,
--         time = time, 
--         category = category
-- 	}) 
-- end)

function refreshmenu()
    TriggerServerEvent('ffa:getuserdata')
    TriggerServerEvent('ffa:getalluserdata')
    TriggerServerEvent('ffa:getChart')
end

RegisterNetEvent('ffa:setalluserdata') 
AddEventHandler('ffa:setalluserdata', function(data)
	alluser = data

    local newgamemodes = {}

    for k,v in pairs(Config.Gamemode) do
        if v.UseJob then
            if v.Jobname == jobname then
                print("yes")
                -- print(json.encode(k))
                -- print(json.encode(Config.Gamemode[k]))
                newgamemodes[k] = Config.Gamemode[k]
                print(json.encode(newgamemodes))
            else
                -- Config.Gamemode[k] = ""
            end
            -- print(json.encode(newgamemodes))
        else
            newgamemodes[k] = Config.Gamemode[k]
        end
    end


    SendNUIMessage({
        type = "refreshmenu",
        allusers = alluser,
        defaultoptions = Config.DefaultPlayerOptions,
        gamemodes = newgamemodes
	})
end)

RegisterNetEvent('ffa:zonefull') 
AddEventHandler('ffa:zonefull', function(data)
	Config.Notification(Config.Locals.zonefull)
end)

RegisterNetEvent('ffa:notenoughmoney') 
AddEventHandler('ffa:notenoughmoney', function(data)
	Config.Notification(Config.Locals.notenoughmoney)
end)

RegisterNetEvent('ffa:setuserdata') 
AddEventHandler('ffa:setuserdata', function(data)
	userdata = data
end)

RegisterNetEvent('ffa:initmenu') 
AddEventHandler('ffa:initmenu', function(data, data2)
    userdata = data
	alluser = data2
    initmenu()
end)

RegisterNetEvent('ffa:refreshmenu') 
AddEventHandler('ffa:refreshmenu', function(data)
    refreshmenu()
end)

RegisterNUICallback('ffa:setoptionstodatabase', function(data)
    userdata.options = data.options
    TriggerServerEvent('ffa:updateoptions', userdata)
end)

RegisterNUICallback('ffa:updateprofilepicture', function(data)
    userdata.url = data.picture
    TriggerServerEvent('ffa:updateplayer', userdata)
end)

RegisterNUICallback('ffa:updateplayerdata', function(data)
    userdata = data.playerdata
    TriggerServerEvent('ffa:updateplayer', userdata)
end)

RegisterNUICallback('ffa:updateusername', function(data)
    userdata.name = data.name
    TriggerServerEvent('ffa:updateplayer', userdata)
end)

RegisterNUICallback('ffa:started', function(data)
    createBlips()
    debug("SUCCESFULLY INIT FFA!")
end)

RegisterNUICallback('ffa:saveChart', function(data)
    TriggerServerEvent('ffa:saveChart', data.columns)
end)

RegisterNetEvent('ffa:setChart') 
AddEventHandler('ffa:setChart', function(data)
    local rs = data.chart
    local category = data.categories
    local s
    local s2
    for word in rs:gmatch('[^,%s]+') do
        s = word
        s = s:gsub(']', '')
        s = s:gsub('[[]', '')
        s = s:gsub('"', '')

        SendNUIMessage({
            type = "setchart",
            columns = s
        })
    end

    for word2 in category:gmatch('[^,%s]+') do
        s2 = word2
        s2 = s2:gsub(']', '')
        s2 = s2:gsub('[[]', '')
        s2 = s2:gsub('"', '')

        SendNUIMessage({
            type = "setcategory",
            category = s2
        })
    end
end)

RegisterNetEvent('ffa:setallcount')
AddEventHandler('ffa:setallcount', function(data)
    SendNUIMessage({
        type = "setallcount",
        count = data
    })
end)

RegisterNetEvent('ffa:setcount')
AddEventHandler('ffa:setcount', function(count, name)
    local max = 0

    for k,v in pairs(Config.Zones) do 
        if v.Name == name then
            max = v.MaxPlayers
        end
    end

    if inGame and zonedata.Name == name then
        SendNUIMessage({
            type = "setCount",
            count = count,
            name = name,
            max = max
        })
    else
        SendNUIMessage({
            type = "setCount2",
            count = count,
            name = name,
            max = max
        })
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer) 
    Wait(250)
    TriggerServerEvent('ffa:routingbucket', 0)
    TriggerServerEvent('ffa:init')
end)

--for restart purpose only
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        debug("STARTING FFA / RESTART SCRIPT / SERVER IF IT TAKES TOO LONG!")
        Wait(250)
        TriggerServerEvent('ffa:routingbucket', 0)
        TriggerServerEvent('ffa:init')
    end
end)

CreateThread(function()
	while true do
		Wait(1000)
        if inGame then
            for k,v in pairs(zonedata.BlacklistedVehicle) do
                if not zonedata.BlacklistAll then
                    for vehicle in EnumerateVehicles() do
                        if GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)) == v then 
                            SetEntityAsMissionEntity(vehicle, false, false) 
                            if DoesEntityExist(vehicle) then 
                                local point = GetEntityCoords(vehicle, true)
                                local inZone = insidePolygon(point, zonedata)
                                if inZone then
                                    DeleteVehicle(vehicle) 
                                end
                            end
                        end
                    end
                else
                    for vehicle in EnumerateVehicles() do
                        SetEntityAsMissionEntity(vehicle, false, false) 
                        if DoesEntityExist(vehicle) then 
                            local point = GetEntityCoords(vehicle, true)
                            local inZone = insidePolygon(point, zonedata)
                            if inZone then
                                DeleteVehicle(vehicle) 
                            end
                        end
                    end
                end
            end
        end
	end
end)
  
local entityEnumerator = {
    __gc = function(enum)
      if enum.destructor and enum.handle then
        enum.destructor(enum.handle)
      end
      enum.destructor = nil
      enum.handle = nil
    end
  }
  
local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
		disposeFunc(iter)
		return
		end
		
		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
		
		local next = true
		repeat
		coroutine.yield(id)
		next, id = moveFunc(iter)
		until not next
		
		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end
  
function EnumerateObjects()
	return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

function EnumeratePeds()
	return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

function EnumeratePickups()
	return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end

----------------------------------------------------------------------------------

RegisterNetEvent('ffa:checkquit') 
AddEventHandler('ffa:checkquit', function(data)
    if inGame and not isDead then
        TriggerServerEvent('ffa:quit', zonedata)
    end
end)

RegisterNetEvent('ffa:quitffa') 
AddEventHandler('ffa:quitffa', function(data)
    if inGame then
        if not zonedata.OwnWeapons then
            RemoveAllPedWeapons(PlayerPedId())
        end
        for k,v in pairs(zonedata.Weapons) do
            SetPedInfiniteAmmo(PlayerPedId(), false, GetHashKey(v))
        end
        TriggerServerEvent('ffa:getloadout')
        inGame = false
        zone = nil
        hud(false)
        Config.onQuit()
        SendNUIMessage({
            type = "quitffa"
        })
        createBlips()
        SetEntityCoordsNoOffset(PlayerPedId(), markercoords[1], markercoords[2], markercoords[3], false, false, false, true)
    end
end)

CreateThread(function()
	while true do
        Citizen.Wait(0)
        if inGame then
            if zone == zonedata.Name then
                Citizen.Wait(Config.SavePlayerTime)
                debug("SAVING PLAYER... ")
                SendNUIMessage({
                    type = "getplayerdata"
                })
            end
        end
	end
end)

RegisterNetEvent('ffa:menu') 
AddEventHandler('ffa:menu', function(data)
    menu(data)
end)

RegisterNetEvent('ffa:joinzone') 
AddEventHandler('ffa:joinzone', function()
    saveloadout()

    playeroptions = userdata.options

    if Config.IngameHud then
        if playeroptions.hud then
            hud(true)
        end
    end
    inGame = true
    if zonedata.Dimension then
        TriggerServerEvent('ffa:routingbucket', zonedata.DimensionID)
    end

end)

RegisterNetEvent('ffa:getloadout')
AddEventHandler('ffa:getloadout', function(loadout)
    TriggerServerEvent("ffa:getloadout")
end)

RegisterNetEvent('ffa:setloadout')
AddEventHandler('ffa:setloadout', function(loadout)
    local s = loadout
    local t = {}
    local n = 0

    for k, v in s:gmatch("(%w+)%s*_%s*(%w+)_%s*(%w+)") do
        n = n + 1
        t[n] = k .."_".. v .. "_MK2"
    end

    for k, v in s:gmatch("(%w+)%s*_%s*(%w+)") do
        n = n + 1
        t[n] = k .."_".. v
    end

    for k,v in pairs(t) do
        SetPedInfiniteAmmo(PlayerPedId(), false, GetHashKey(v))
        GiveWeaponToPed(PlayerPedId(), GetHashKey(v))
        SetPedAmmo(PlayerPedId(), GetHashKey(v), 5000)
    end
    userdata.loadout = "[]"
    TriggerServerEvent('ffa:updateplayer', userdata)
end)

function saveloadout() 
    for k,v in pairs(weaponlists) do
        if HasPedGotWeapon(PlayerPedId(), GetHashKey(v), false) then
            table.insert(playerloadout, v)
        end
    end

    playerloadout = {}
    for k,v in pairs(weaponlists) do
        if HasPedGotWeapon(PlayerPedId(), GetHashKey(v), false) then
            table.insert(playerloadout, v)
        end
    end


    if not zonedata.OwnWeapons then
        local s = json.encode(playerloadout):gsub('"', '')
        s = '"'..s..'"'
        userdata.loadout = s
        TriggerServerEvent('ffa:updateplayer', userdata)
    end
    spawnplayer(zonedata)
end

RegisterNUICallback('ffa:joinzone', function(data)
    zone = data.zone
    gamemode = data.gamemode

    for k,v in pairs(Config.Zones) do
        if v.Name == data.zone then
            zonedata = v
        end
    end
    for k,v in pairs(Config.Gamemode) do
        if v.Name == data.gamemode then
            gamemodedata = v
        end
    end
    TriggerServerEvent('ffa:joinzone', gamemodedata, zonedata, userdata)
end)

function hud(bool)
	SendNUIMessage({
		type = "hud",
		status = bool
	})
end

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(0)
        if inGame then
            if zone == zonedata.Name then
                local point = GetEntityCoords(PlayerPedId(), true)
                local inZone = insidePolygon(point, zonedata)
                drawPoly(inZone, zonedata)
                if not inZone and isDead then
                    inzoneout(true)
                    isDead = false
                end
                if inZone and not zoneback then
                    zoneback = inZone
                    inzoneout(zoneback)
                elseif not inZone and zoneback then
                    zoneback = inZone
                    inzoneout(zoneback)
                end
            end
        end
    end 
end)


function inzoneout(bool) 
    if Config.OutZoneRespawnInstant then
        spawnplayer(zonedata)
        return
    end
    if Config.OutZoneScreen then
        SendNUIMessage({
            type = "inzoneout",
            state = bool
        })
    end
end

local lastcoords = nil

function spawnplayercoords(data)
    local coords
    if Config.SameRespawnCoords then
        coords = data.Spawnpoints[math.random(#data.Spawnpoints)]
    else
        coords = data.Spawnpoints[math.random(#data.Spawnpoints)]
        if not lastcoords == nil then
            if lastcoords == coords then
                spawnplayercoords(data)
                return
            end
        else
            lastcoords = coords
        end
    end
    return coords
end

function spawnplayer(data)
    isDead = false
    menu(false)

    local coords = spawnplayercoords(data)

    StopScreenEffect('DeathFailOut')
    TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
    TriggerServerEvent('esx:onPlayerSpawn')
	TriggerEvent('esx:onPlayerSpawn')
	TriggerEvent('playerSpawned')

	SetEntityCoordsNoOffset(PlayerPedId(), coords[1], coords[2], coords[3], false, false, false, true)
	NetworkResurrectLocalPlayer(coords[1], coords[2], coords[3], GetEntityHeading(PlayerPedId()), true, false)

	SetPlayerInvincible(PlayerPedId(), false)
	ClearPedBloodDamage(PlayerPedId())

    FreezeEntityPosition(PlayerPedId(), false)
    SetPedArmour(PlayerPedId(), 100)
    SetEntityHealth(PlayerPedId(), 100.0)

    if not data.OwnWeapons then
        RemoveAllPedWeapons(PlayerPedId())
        for k,v in pairs(data.Weapons) do
            GiveWeaponToPed(PlayerPedId(), GetHashKey(v))
            SetPedAmmo(PlayerPedId(), GetHashKey(v), 5000)
            SetPedInfiniteAmmo(PlayerPedId(), true, GetHashKey(v))
        end
    end

    spawn = true
end

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(0)
        if spawn then
            Config.onSpawn()
            spawn = false
        end
	end
end)

Citizen.CreateThread(function()
	local DeathReason, DeathCauseHash
	while true do
		Citizen.Wait(0)
        if inGame then
            if zone == zonedata.Name then
                if not isDead then
                    if IsEntityDead(PlayerPedId()) then
                        isDead = true
                        Citizen.Wait(0)

                        local PedKiller = GetPedSourceOfDeath(PlayerPedId())
                        DeathCauseHash = GetPedCauseOfDeath(PlayerPedId())
            
                        if IsEntityAPed(PedKiller) and IsPedAPlayer(PedKiller) then
                            killer = NetworkGetPlayerIndexFromPed(PedKiller)
                        elseif IsEntityAVehicle(PedKiller) and IsEntityAPed(GetPedInVehicleSeat(PedKiller, -1)) and IsPedAPlayer(GetPedInVehicleSeat(PedKiller, -1)) then
                            killer = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(PedKiller, -1))
                        end
            
                        if PlayerPedId() == PedKiller then
                            DeathReason = 'gestorben'
                        elseif PedKiller == 0 then
                            DeathReason = 'gestorben'
                        else
                            DeathReason = 'killed'
                        end

                        if DeathReason == 'gestorben'then
                            TriggerServerEvent('ffa:playerDied', 0, DeathReason)
                        else
                            TriggerServerEvent('ffa:playerDied', GetPlayerServerId(killer), DeathReason)
                        end
            
                        killer = nil
                        DeathReason = nil
                        DeathCauseHash = nil
                    else
                        isDead = false
                    end
                end
                while IsEntityDead(PlayerPedId()) do
                    Citizen.Wait(0)
                end
            end
        end
	end
end)

RegisterNetEvent('ffa:playerKilled') 
AddEventHandler('ffa:playerKilled', function(identifier, name)
    Config.onKill()
    for k,v in pairs(alluser) do
        if name == v.steamname then
            if v.options.anonym == "true" then
                name = "Anonym #" .. math.random(1000, 9999)
            else
                name = v.name
            end
        end
    end
    if playeroptions.notifications then
        Config.Notification("Du hast " .. name .. " getötet!")
    end
    TriggerServerEvent('ffa:kill', gamemodedata)
    killstreak()
    SendNUIMessage({
        type = "addKill",
        identifier = identifier
    })
end)

RegisterNetEvent('ffa:playerDied') 
AddEventHandler('ffa:playerDied', function(name, identifier)
    for k,v in pairs(alluser) do
        if name == v.steamname then
            if v.options.anonym == "true" then
                name = "Anonym #" .. math.random(1000, 9999)
            else
                name = v.name
            end
        end
    end
    TriggerServerEvent('esx_ambulancejob:setDeathStatus', false)
    if Config.RespawnInstant then
        spawnplayer(zonedata)
        return
    end
    Config.onDeath()

    SendNUIMessage({
        type = "addDeath",
        identifier = identifier
    })
    streak = 0

    if Config.RespawnScreen then
        StartScreenEffect('DeathFailOut')

        SendNUIMessage({
            type = "respawn",
            DeathReason = name
        })
    end
end)

RegisterNUICallback('ffa:respawn', function(data)
    SendNUIMessage({
        type = "closerespawn"
    })
    spawnplayer(zonedata)
end)

RegisterNUICallback('ffa:sendNotification', function(data)
    if playeroptions.notifications then
        Config.Notification(data.text)
    end
end)

local playerlocalname 

RegisterNetEvent('ffa:sendNotification') 
AddEventHandler('ffa:sendNotification', function(data)
    Config.Notification(data)
end)

function killstreak()
	streak = streak + 1
    for k,v in pairs(Config.KillStreak) do
		if v == streak then
            if playeroptions.notifications then
                Config.KillStreakNotification(streak)
            end
		end
	end
end

function ShowNotification(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(false, false)
end

playerDistances = {}

function getPlayerName(player)
    for k,v in pairs(alluser) do
        if GetPlayerName(player) == v.steamname then
            if v.options.anonym == "true" then
                return "Anonym #" .. math.random(1000, 9999)
            else
                return v.name
            end
        end
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        if playeroptions.nametags and inGame then
            for _, player in ipairs(GetActivePlayers()) do
                local ped = GetPlayerPed(player)
                if GetPlayerPed(player) ~= GetPlayerPed(-1) then
                    if playerDistances[player] ~= nil and playerDistances[player] < Config.NametagDistance then
                        x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(player), true))
                        DrawText3D(x2, y2, z2+1, '~r~' .. GetPlayerServerId(player) .. ' ~c~| ~w~' .. getPlayerName(player))
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        for _, player in ipairs(GetActivePlayers()) do
            if GetPlayerPed(player) ~= GetPlayerPed(-1) then
                x1, y1, z1 = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
                x2, y2, z2 = table.unpack(GetEntityCoords(GetPlayerPed(player), true))
                distance = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))
                playerDistances[player] = distance
            end
        end
        Citizen.Wait(1000)
    end
end)

function DrawText3D(x,y,z, text) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
 
    local scale = (1/dist)*5
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
   
    if onScreen then
        SetTextScale(0.0*scale, 0.22*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end


weaponlists = {
    KEY0 = "WEAPON_UNARMED",

    KEY1 = "WEAPON_DAGGER",
    KEY2 = "WEAPON_BAT",
    KEY3 = "WEAPON_BOTTLE",
    KEY4 = "WEAPON_CROWBAR",
    KEY5 = "WEAPON_FLASHLIGHT",
    KEY6 = "WEAPON_GOLFCLUB",
    KEY7 = "WEAPON_HAMMER",
    KEY8 = "WEAPON_HATCHET",
    KEY9 = "WEAPON_KNUCKLE",
    KEY10 = "WEAPON_KNIFE",
    KEY11 = "WEAPON_MACHETE",
    KEY12 = "WEAPON_SWITCHBLADE",
    KEY13 = "WEAPON_NIGHTSTICK",
    KEY14 = "WEAPON_WRENCH",
    KEY15 = "WEAPON_BATTLEAXE",
    KEY16 = "WEAPON_POOLCUE",
    KEY17 = "WEAPON_STONE_HATCHET",

    KEY18 = "WEAPON_PISTOL",
    KEY19 = "WEAPON_PISTOL_MK2",
    KEY20 = "WEAPON_COMBATPISTOL",
    KEY21 = "WEAPON_APPISTOL",
    KEY22 = "WEAPON_STUNGUN",
    KEY23 = "WEAPON_PISTOL50",
    KEY24 = "WEAPON_SNSPISTOL",
    KEY25 = "WEAPON_SNSPISTOL_MK2",
    KEY26 = "WEAPON_HEAVYPISTOL",
    KEY27 = "WEAPON_VINTAGEPISTOL",
    KEY28 = "WEAPON_FLAREGUN",
    KEY29 = "WEAPON_MARKSMANPISTOL",
    KEY30 = "WEAPON_REVOLVER",
    KEY31 = "WEAPON_REVOLVER_MK2",
    KEY32 = "WEAPON_DOUBLEACTION",
    KEY33 = "WEAPON_RAYPISTOL",
    KEY34 = "WEAPON_CERAMICPISTOL",
    KEY35 = "WEAPON_NAVYREVOLVER",
    KEY36 = "WEAPON_GADGETPISTOL",
    KEY37 = "WEAPON_STUNGUN_MP",

    KEY38 = "WEAPON_MICROSMG",
    KEY39 = "WEAPON_SMG",
    KEY40 = "WEAPON_SMG_MK2",
    KEY41 = "WEAPON_ASSAULTMSG",
    KEY42 = "WEAPON_COMBATPDW",
    KEY43 = "WEAPON_MACHINEPISTOL",
    KEY44 = "WEAPON_MINISMG",
    KEY45 = "WEAPON_RAYCARBINE",

    KEY46 = "WEAPON_PUMPSHOTGUN",
    KEY47 = "WEAPON_PUMPSHOTGUN_MK2",
    KEY48 = "WEAPON_SAWNOFFSHOTGUN",
    KEY49 = "WEAPON_ASSAULTSHOTGUN",
    KEY50 = "WEAPON_BULLPUPSHOTGUN",
    KEY51 = "WEAPON_MUSKET",
    KEY52 = "WEAPON_HEAVYSHOTGUN",
    KEY53 = "WEAPON_DBSHOTGUN",
    KEY54 = "WEAPON_AUTOSHOTGUN",
    KEY55 = "WEAPON_COMBATSHOTGUN",

    KEY56 = "WEAPON_ASSAULTRIFLE",
    KEY57 = "WEAPON_ASSAULTRIFLE_MK2",
    KEY58 = "WEAPON_CARBINERIFLE",
    KEY59 = "WEAPON_CARBINERIFLE_MK2",
    KEY60 = "WEAPON_ADVANCEDRIFLE",
    KEY61 = "WEAPON_SPECIALCARBINE",
    KEY62 = "WEAPON_SPECIALCARBINE_MK2",
    KEY63 = "WEAPON_BULLPUPRIFLE",
    KEY64 = "WEAPON_BULLPUPRIFLE_MK2",
    KEY65 = "WEAPON_COMPACTRIFLE",
    KEY66 = "WEAPON_MILITARYRIFLE",
    KEY67 = "WEAPON_HEAVYRIFLE",

    KEY68 = "WEAPON_MG",
    KEY69 = "WEAPON_COMBATMG",
    KEY70 = "WEAPON_COMBATMG_MK2",
    KEY71 = "WEAPON_GUSENBERG",

    KEY72 = "WEAPON_SNIPERRIFLE",
    KEY73 = "WEAPON_HEAVYSNIPER",
    KEY74 = "WEAPON_HEAVYSNIPER_MK2",
    KEY75 = "WEAPON_MARKSMANRIFLE",
    KEY76 = "WEAPON_MARKSMANRIFLE_MK2",
    
    KEY77 = "WEAPON_RPG",
    KEY78 = "WEAPON_GRENADELAUNCHER",
    KEY79 = "WEAPON_GRENADELAUNCHER_SMOKE",
    KEY80 = "WEAPON_MINIGUN",
    KEY81 = "WEAPON_FIREWORK",
    KEY82 = "WEAPON_RAILGUN",
    KEY83 = "WEAPON_HOMINGLAUNCHER",
    KEY84 = "WEAPON_COMPACTLAUNCHER",
    KEY85 = "WEAPON_RAYMINIGUN",
    KEY86 = "WEAPON_EMPLAUNCHER",

    KEY87 = "WEAPON_GRENADE",
    KEY88 = "WEAPON_BZGAS",
    KEY89 = "WEAPON_MOLOTOV",
    KEY90 = "WEAPON_STICKYBOMB",
    KEY91 = "WEAPON_PROXMINE",
    KEY92 = "WEAPON_SNOWBALL",
    KEY93 = "WEAPON_PIPEBOMB",
    KEY94 = "WEAPON_BALL",
    KEY95 = "WEAPON_SMOKEGRENADE",
    KEY96 = "WEAPON_FLARE",

    KEY97 = "WEAPON_PETROLCAN",
    KEY98 = "GADGET_PARACHUTE",
    KEY99 = "WEAPON_FIREEXTINGUISHER",
    KEY100 = "WEAPON_HAZARDCAN",
    KEY101 = "WEAPON_FERTILIZERCAN"
}