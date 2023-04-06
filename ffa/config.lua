Config = {}
Config.Debug = true

Config.ServerName 		= "Loureiro"
Config.SavePlayerTime 	= 60000 --Saves player data every minute, if player is in a zone

--https://docs.fivem.net/docs/game-references/controls/
Config.OpenMenuKey 		= 38
Config.OpenTimeout 		= 500 --Prevent database spamming / miliseconds

--https://i.imgur.com/zpLJp98.png
Config.RespawnScreen	= true
Config.RespawnCountdown = 4 --Seconds!
Config.RespawnInstant 	= false

--Prevents respawning in the same coords two times in a row
Config.SameRespawnCoords = false

--https://i.imgur.com/nqU6H5t.png
Config.OutZoneScreen	= true
Config.OutZoneCountdown = 5 --Seconds!
Config.OutZoneRespawnInstant = false

--https://i.imgur.com/9XV34Sy.png
Config.IngameHud = true

--https://i.imgur.com/gU9RdcG.png
--Sets the player options on player register
Config.DefaultPlayerOptions = {
	notifications = true,
    anonym = false,
    hud = true,
    fullplaytime = true,
    nametags = true,
	crosshair = false,
	hitmarker = false
}

Config.NametagDistance = 30
Config.LeaderboardMaxPlayers = 99

-----------------------------------------------------------------------------------------

--GLOBALE VARIABLES: streak, started, gamemodedata, zonedata, inGame, isDeath, killer

Config.Notification = function(text)
	TriggerEvent('esx:showNotification', text)
end

--If you want to use another notification then usual when you get a killstreak. For example send a announce
Config.KillStreakNotification = function(streak)
	TriggerEvent('esx:showNotification', "KILLSTREAK: " .. streak)

	--You can give the player a weapon for example
	if streak == 12 then
		GiveWeaponToPed(PlayerPedId(), GetHashKey("WEAPON_ASSAULTRIFLE"))
	end
end

--You can trigger you own events on kill or death
Config.onKill = function()
	SetPedArmour(PlayerPedId(), 100)
	SetEntityHealth(PlayerPedId(), 100.0)

	--Example add another reward besides the Config.Gamemode.KillReward
end

Config.onDeath = function()
	if gamemodedata.Name == "Hardcore" then
		TriggerServerEvent("ffa:removeMoney", "all")
		--TriggerServer("ffa:removeMoney", "1000")
		
		--Its RECOMMEND to use your own event!!
	end
end

Config.onQuit = function()
	TriggerEvent('esx:showNotification', Config.Locals.quitffa)
end

--Can be used for example spawn protection
Config.onSpawn = function()
	SetPlayerInvincible(PlayerId(), true)
	Citizen.Wait(2000)
	SetPlayerInvincible(PlayerId(), false)
	TriggerEvent("esx:showNotification", Config.Locals.spawnprotection)
end

--Simply sends the Config.KillStreakNotification notification when you get a killstreak
Config.KillStreak = {
	3,
	6,
	12,
	18,
	24,
	30,
	36,
	42,
	48,
	54,
	60,
}

Config.HitMarkerColor =	{120, 0, 0}
--You can also play a sound on hit if you want to
Config.OnHitmarker = function()
	--Please notice that you need to install https://forum.cfx.re/t/release-play-custom-sounds-for-interactions/8282 to use this event!

	--TriggerEvent('InteractSound_CL:PlayOnOne', 'hitmarker', 1)
end

-----------------------------------------------------------------------------------------

Config.Locals = {
	quitffa = "Saiu do ffa com sucesso!", 
	spawnprotection = "A proteção de spawn expirou!",
	notenoughmoney = "Não há dinheiro suficiente",
	zonefull = "A zona está cheia!"
}

-----------------------------------------------------------------------------------------

Config.FFAMarker = {
	FFA1 = {

		ShowMarker	= true,
		ShowBlip	= true,

		UseJob		= false,
		Jobname 	= 'police',

		--https://docs.fivem.net/docs/game-references/markers/
		Marker = {
			Coords  	  = vector3(-419.98492431641, 1139.0109863281, 325.1985168457),
			DrawDistance  = 100.0,
			Scale	 	  = vector3(1.5, 1.5, 1.0),
			Colour   	  = {r = 102, g = 102, b = 204},
			Alpha 		  = 100,
			Type    	  = 1,
			MSG 	  	  = "Pressione ~INPUT_CONTEXT~ para abrir o menu",
		},

		--https://docs.fivem.net/docs/game-references/blips/
		Blip = {
			Coords  = vector3(-419.98492431641, 1139.0109863281, 325.1985168457),
			Sprite  = 175,
			Display = 4,
			Scale   = 1.0,
			Colour  = 2,
			Name 	= "FFA",
		},

	},

	FFA2 = {

		ShowMarker	= true,
		ShowBlip	= true,

		UseJob		= false,
		Jobname 	= 'police',

		--https://docs.fivem.net/docs/game-references/markers/
		Marker = {
			Coords  	  = vector3(208.00997924805, -922.00244140625, 30.691999435425),
			DrawDistance  = 100.0,
			Scale	 	  = vector3(1.5, 1.5, 1.0),
			Colour   	  = {r = 102, g = 102, b = 204},
			Alpha 		  = 100,
			Type    	  = 1,
			MSG 	  	  = "Pressione ~INPUT_CONTEXT~ para abrir o menu"
		},

		--https://docs.fivem.net/docs/game-references/blips/
		Blip = {
			Coords  = vector3(208.00997924805, -922.00244140625, 30.691999435425),
			Sprite  = 175,
			Display = 4,
			Scale   = 1.0,
			Colour  = 2,
			Name 	= "FFA",
		},

	},

	FFA3 = {

		ShowMarker	= true,
		ShowBlip	= true,

		UseJob		= true,
		Jobname 	= 'donator',

		--https://docs.fivem.net/docs/game-references/markers/
		Marker = {
			Coords  	  = vector3(689.4462, 601.1604, 127.9128),
			DrawDistance  = 100.0,
			Scale	 	  = vector3(1.5, 1.5, 1.0),
			Colour   	  = {r = 102, g = 102, b = 204},
			Alpha 		  = 100,
			Type    	  = 1,
			MSG 	  	  = "Pressione ~INPUT_CONTEXT~ para abrir o menu"
		},

		--https://docs.fivem.net/docs/game-references/blips/
		Blip = {
			Coords  = vector3(689.4462, 601.1604, 128.9128),
			Sprite  = 175,
			Display = 4,
			Scale   = 1.0,
			Colour  = 2,
			Name 	= "FFA",
		},

	},
}

Config.Zones = {
	Zone0 = {
		Name 		= "Only Pistol",
		Desc 		= "Choose to play in the Only Pistol Zone FFA with this card.",
		AddedDate	= "29.06.2022",

		MaxPlayers 	= 10,

		--OneSync must be set to "infnity" in server settings!
		Dimension 	= true,
		DimensionID = 10000, --IMPORT TO CHANGE WHEN CREATING A NEW ZONE! <<<<<<--------

		ShowZone 	= true,
		ZoneHeight 	= 25,
		ZoneAlpha 	= 90,
		ZoneColor   = {r = 69, g = 255, b = 141},

		ZoneCoords = {
			{-154.50605773926, -937.58984375, 253.3971862793},
			{-157.92643737793, -948.24786376953, 252.89315795898},
			{-162.26533508301, -946.7685546875, 252.89315795898},
			{-168.97314453125, -964.44616699219, 253.3971862793},

			{-176.78015136719, -961.36590576172, 253.3971862793},
			{-196.49926757813, -1013.7241821289, 253.3971862793},
			{-151.77670288086, -1030.2932128906, 253.33418273926},
			{-132.67620849609, -977.74255371094, 253.33418273926},

			{-137.07427978516, -976.23345947266, 253.33418273926},
			{-129.50109863281, -955.68560791016, 253.33418273926},
			{-135.46151733398, -953.85028076172, 253.33418273926},
			{-132.71960449219, -945.95690917969, 253.33418273926},
		},

		Spawnpoints = {
			{-159.85989379883, -990.80316162109, 254.13130187988},
			{-185.45248413086, -1008.3400268555, 254.33544921875},
			{-149.4659576416, -946.77642822266, 254.14801025391},

			{-145.21778869629, -947.94635009766, 269.11868286133},
			{-154.05239868164, -980.57952880859, 269.21032714844},
			{-147.44667053223, -992.9580078125, 261.84518432617},
		},

		BlacklistAll = true,
		--https://wiki.rage.mp/index.php?title=Vehicles
		BlacklistedVehicle = {
			"RHINO",
			"T20"
		},

		OwnWeapons 	= false,
		--https://wiki.rage.mp/index.php?title=Weapons
		Weapons 	= {
			"WEAPON_PISTOL",
			"WEAPON_PISTOL_MK2",
			"WEAPON_COMBATPISTOL",
			"WEAPON_PISTOL50",
			"WEAPON_SNSPISTOL",
			"WEAPON_SNSPISTOL_MK2",
			"WEAPON_HEAVYPISTOL",
			"WEAPON_VINTAGEPISTOL",
		},

	},

	Zone1 = {
		Name 		= "Cube park",
		Desc 		= "Select with this card that you want to play in the dice park zone FFA.",
		AddedDate	= "19.07.2021",

		MaxPlayers 	= 20,

		--OneSync must be set to "infnity" in server settings!
		Dimension 	= true,
		DimensionID = 10001, --IMPORT TO CHANGE WHEN CREATING A NEW ZONE! <<<<<<--------

		ShowZone 	= true,
		ZoneHeight 	= 10,
		ZoneAlpha 	= 90,
		ZoneColor   = {r = 255, g = 255, b = 141},

		ZoneCoords = {
			{107.23777770996, -1003.2484130859, 29.40472984314},
			{170.03587341309, -819.34228515625, 31.176509857178},
			{290.53610229492, -858.66943359375, 29.24479675293},
			{225.74273681641, -1038.6241455078, 29.359869003296},
		},

		Spawnpoints = {
			{236.90498352051, -879.6025390625, 30.492111206055},
			{173.76466369629, -919.04986572266, 30.670347213745},
			{229.20983886719, -956.81567382813, 29.337562561035},
			{202.58497619629, -998.02258300781, 30.108287811279},
			{133.78994750977, -990.29925537109, 29.348255157471},
			{150.9521484375, -963.29431152344, 30.098808288574},
			{261.30218505859, -874.74243164063, 29.177373886108},
			{187.93125915527, -853.60638427734, 31.369457244873},
		},

		BlacklistAll = false,
		--https://wiki.rage.mp/index.php?title=Vehicles
		BlacklistedVehicle = {
			"RHINO",
			"T20"
		},

		OwnWeapons 	= false,
		--https://wiki.rage.mp/index.php?title=Weapons
		Weapons 	= {
			"WEAPON_PISTOL",
			"WEAPON_ASSAULTRIFLE",
		},

	},

	Zone2 = {
		Name 		= "Observatório",
		Desc 		= "Escolhendo esta opção jogará no Observatório FFA.",
		AddedDate	= "19.07.2021",

		MaxPlayers 	= 20,

		--OneSync must be set to "infnity" in server settings!
		Dimension 	= true,
		DimensionID = 10002, --IMPORT TO CHANGE WHEN CREATING A NEW ZONE! <<<<<<--------

		ShowZone 	= true,
		ZoneHeight 	= 10,
		ZoneAlpha 	= 50,
		ZoneColor   = {r = 255, g = 255, b = 141},

		--Credits: https://github.com/prefech/JD_SafeZone
		ZoneCoords 	= {
			{-484.13290405273, 1099.4439697266, 325.44760131836},
			{-403.48867797852, 1079.1002197266, 325.44760131836},
			{-367.90661621094, 1230.1385498047, 325.44760131836},
			{-442.13290405273, 1255.0555419922, 325.44760131836},
		},

		Spawnpoints = {
			{-414.14004516602, 1135.4301757813, 325.9045715332},
			{-435.78497314453, 1138.2543945313, 325.9045715332},
			{-413.11117553711, 1233.4633789063, 325.90438842773},
			{-375.32080078125, 1228.6291503906, 325.90438842773},
			{-437.88909912109, 1208.4266357422, 325.90438842773},
			{-397.75546264648, 1128.2397460938, 322.97259521484},
		},

		BlacklistAll = false,
		--https://wiki.rage.mp/index.php?title=Vehicles
		BlacklistedVehicle = {
			"RHINO",
			"T20"
		},

		OwnWeapons 	= false,
		--https://wiki.rage.mp/index.php?title=Weapons
		Weapons 	= {
			"WEAPON_PISTOL",
			"WEAPON_ASSAULTRIFLE",
		},

	},

	
}

Config.Gamemode = {
	
	Gamemode1 = {
		Name 		= "Hardcore",
		Desc 		= "The same rules apply as in normal game mode, if you die you lose <span>ALL</span> your <span>MONEY</span> what you have with you! For every elimination you achieve, you'll get <span>$90,000</span> credited to your account!",
		Death 		= "Lose all money",
		
		JoinPrice 	= 20000,
		KillReward 	= 90000,

		UseJob		= false,
		Jobname 	= 'police',
	},

	Gamemode2 = {
		Name 		= "Normal",
		Desc 		= "Typical FFA rules apply! You can earn awards by playing FFA. Completing awards gives you more rewards!",
		Death 		= "Nothing at all :)",

		JoinPrice 	= 10000,
		KillReward 	= 35000,

		UseJob		= false,
		Jobname 	= 'police',
	},

	Gamemode3 = {
		Name 		= "Donator",
		Desc 		= "Typical FFA rules apply! You can earn awards by playing FFA. Completing awards gives you more rewards!",
		Death 		= "Nothing at all :)",

		JoinPrice 	= 500,
		KillReward 	= 35000,

		UseJob		= true,
		Jobname 	= 'donator',
	},

}