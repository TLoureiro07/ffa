ESX = nil
zonestate = nil
allcount = 0
time = "18:00"
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('ffa:getuserdata')
AddEventHandler('ffa:getuserdata', function(data)
    local src = source	
    local identifier = ExtractIdentifiers(src)

    MySQL.Async.fetchAll("SELECT * FROM ffa_users WHERE identifier = @identifier", {
            ['@identifier'] = identifier
        }, function(result)
        if #result == 0 then
            --Register Player if not exist
            registerplayer(src)
	    else
            for _, row in pairs(result) do
                if row.identifier == ExtractIdentifiers(src) then
                    TriggerClientEvent("ffa:setuserdata", src, row)
                end
            end 
        end
    end)
end)


RegisterServerEvent('ffa:getChart')
AddEventHandler('ffa:getChart', function(data)
    local src = source

    local chart = '["data",0, 82, 10, 42, 20, 62]'
    local categories = '["x", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"]'
    MySQL.Async.fetchAll("SELECT * FROM ffa_chart", {}, function(result)
        if #result == 0 then
            MySQL.Async.execute("INSERT INTO ffa_chart (chart, categories) VALUES(@chart, @categories) ON DUPLICATE KEY UPDATE chart = @chart, categories = @categories", { 
                ['@categories'] = categories,
                ['@chart'] = chart
            }, function(result)
            end)
            return
        else
            TriggerClientEvent("ffa:setChart", src, result[1])
        end
    end)
end)

CreateThread(function()
	while true do
		Citizen.Wait(59000)
        refreshChartDatabase()
	end
end)

function refreshChartDatabase()
    local date = os.date('%M')
    time = os.date('%H:%M')
    if date == "00" then
        if allcount ~= 0 then
            local chart = '["data",0, 82, 10, 42, 20, 62]'
            local categories = '["x", "12:00", "13:00", "14:00", "15:00", "16:00", "17:00"]'
            MySQL.Async.fetchAll("SELECT * FROM ffa_chart", {}, function(result)
                if #result == 0 then
                    MySQL.Async.execute("INSERT INTO ffa_chart (chart, categories) VALUES(@chart, @categories) ON DUPLICATE KEY UPDATE chart = @chart, categories = @categories", { 
                        ['@categories'] = categories,
                        ['@chart'] = chart
                    }, function(resulttt)
                    end)
                else 
                    MySQL.Async.fetchAll("TRUNCATE TABLE ffa_chart", {}, function(resultt)
                    end)
            
                    MySQL.Async.execute("INSERT INTO ffa_chart (chart, categories) VALUES(@chart, @categories) ON DUPLICATE KEY UPDATE chart = @chart, categories = @categories", { 
                        ['@chart'] = stringtotable(result[1].chart, true),
                        ['@categories'] = stringtotable(result[1].categories, false)
                    }, function(result)
                    end)

                end
            end)
        end
    end
end

function stringtotable(r, bool) 
    local t = {}
    local res = r
    local s
    for word in res:gmatch('[^,%s]+') do
        s = word
        s = s:gsub(']', '')
        s = s:gsub('[[]', '')
        s = s:gsub('"', '')

        table.insert(t, s)
    end
    table.remove(t, 2)
    if bool then
        if t[6] ~= tostring(allcount) then
            table.insert(t, allcount)
        end
    else
        table.insert(t, time)
    end

    return json.encode(t)
end

RegisterServerEvent('ffa:saveChart')
AddEventHandler('ffa:saveChart', function(data)
    local chart = json.encode(data)

    MySQL.Async.execute("TRUNCATE TABLE ffa_chart", {}, function(result)
    end)

    MySQL.Async.execute("INSERT INTO ffa_chart (chart) VALUES(@chart) ON DUPLICATE KEY UPDATE chart = @chart", { 
        ['@chart'] = chart
    }, function(result)
    end)
end)

RegisterServerEvent('ffa:playerDied')
AddEventHandler('ffa:playerDied', function(killer, DeathReason)
    local death = DeathReason
    local src = source
    local srcidentifier = ExtractIdentifiers(src)

    if death == "gestorben" then
        TriggerClientEvent("ffa:playerDied", src, death, srcidentifier)
    elseif death == "killed" then
        TriggerClientEvent("ffa:playerDied", src, GetPlayerName(killer), srcidentifier)
        local identifier = ExtractIdentifiers(killer)
        TriggerClientEvent("ffa:playerKilled", killer, identifier, GetPlayerName(src))
    end
end)

RegisterServerEvent('ffa:getalluserdata')
AddEventHandler('ffa:getalluserdata', function(data)
    local src = source	

    MySQL.Async.fetchAll("SELECT * FROM ffa_users", {}, function(result)
        if #result == 0 then
            return	    
        else
            for idx, row in pairs(result) do
                if row.identifier == ExtractIdentifiers(src) then
                    row.self = 1
                else
                    row.self = 0
                end
                if row.options ~= "[]" then
                    local s = row.options
                    local t = {}
                    local n = 0
                
                    for k, v in s:gmatch("(%w+)%s*:(%w+)%s*") do
                        n = n + 1
                        t[v] = k
                        t[k] = v
                    end

                    row.options = t
                end
            end 
            TriggerClientEvent("ffa:setalluserdata", src, result)
        end
    end)
end)

RegisterServerEvent('ffa:init')
AddEventHandler('ffa:init', function()
    local src = source
    local identifier = ExtractIdentifiers(src)
    local name = GetPlayerName(src)

    MySQL.Async.fetchAll("SELECT * FROM ffa_users WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    }, function(result1)
        if #result1 == 0 then
            --Register Player if not exist
            registerplayer(src)
        else 
            MySQL.Async.fetchAll("SELECT * FROM ffa_users", {}, function(result2)
                if #result2 == 0 then
                    return
                else
                    for _, row in pairs(result2) do
                        if row.identifier == ExtractIdentifiers(src) then
                            row.self = 1
                        else
                            row.self = 0
                        end
                        if row.options ~= "[]" then
                            local s = row.options
                            local t = {}
                            local n = 0
                        
                            for k, v in s:gmatch("(%w+)%s*:(%w+)%s*") do
                                n = n + 1
                                t[v] = k
                                t[k] = v
                            end

                            row.options = t
                        end
                        if row.steamname ~= name then
                            MySQL.Async.execute("UPDATE ffa_users SET steamname = @steamname WHERE identifier = @identifier", { 
                                ['@identifier'] = identifier,
                                ['@steamname'] = name,
                            }, function(result)
                            end)
                        end
                        if row.loadout ~= "[]" then
                            TriggerClientEvent("ffa:getloadout", src)
                        end
                    end

                    TriggerClientEvent("ffa:initmenu", src, result1[1], result2)
                end
            end)
        end
    end)
end)

function registerplayer(src) 
    local options = Config.DefaultPlayerOptions

    local identifier = ExtractIdentifiers(src)
    local name = GetPlayerName(src)

    local s = json.encode(options):gsub('{', '[')
    s = s:gsub('}', ']')
    s = s:gsub('"', '')
    s = '"'..s..'"'

    options = s

    MySQL.Async.execute("INSERT INTO ffa_users (identifier, steamname, name, options) VALUES(@identifier, @steamname, @name, @options) ON DUPLICATE KEY UPDATE identifier = @identifier, name = @name", { 
        ['@identifier'] = identifier,
        ['@steamname'] = name,
        ['@name'] = name,
        ['@options'] = options,
    }, function(result)
    end)
    TriggerClientEvent("ffa:refreshmenu", src)
end

RegisterServerEvent('ffa:getIdentifier')
AddEventHandler('ffa:getIdentifier', function(id)
    local src = source
    local identifier = ExtractIdentifiers(id)

    TriggerClientEvent("ffa:setIdentifier", src, identifier)

end)

RegisterServerEvent('ffa:kill')
AddEventHandler('ffa:kill', function(data)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local reward = data.KillReward

    xPlayer.addAccountMoney('bank', reward)
end)

RegisterServerEvent('ffa:getloadout')
AddEventHandler('ffa:getloadout', function()
    local src = source
    local identifier = ExtractIdentifiers(src)
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll("SELECT * FROM ffa_users WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    }, function(result)
        if #result == 0 then
            return
        else 
            for _, row in pairs(result) do
                if row.identifier == ExtractIdentifiers(src) then
                    if row.loadout == "[]" then
                        return
                    end
                    TriggerClientEvent("ffa:setloadout", src, row.loadout)
                end
            end 
        end
    end)
end)

RegisterServerEvent('ffa:removeMoney')
AddEventHandler('ffa:removeMoney', function(money)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if money == "all" then
        xPlayer.removeMoney(xPlayer.getMoney())
    else
        xPlayer.removeMoney(money)
    end

    xPlayer.removeMoney(money)
end)

counts = {}
players = {}

AddEventHandler('playerDropped', function(reason)
    local src = source

    for k, v in pairs(players) do
        if players[k]:find(GetPlayerName(src)) then
            players[k] = players[k]:gsub("%"..GetPlayerName(src), "")

            if counts[k] == nil then
                counts[k] = 0
            else
                counts[k] = counts[k] - 1
            end

            TriggerClientEvent("ffa:setcount", -1, counts[k], k)

            allcount = allcount - 1
            TriggerClientEvent('ffa:setallcount', -1, allcount)
        end
    end
end)

RegisterServerEvent('ffa:joinzone')
AddEventHandler('ffa:joinzone', function(data, zonedata, data2)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local price = data.JoinPrice

    if xPlayer.getMoney() >= price then
        if counts[zonedata.Name] == nil then
            counts[zonedata.Name] = 0
        end
        if counts[zonedata.Name] == zonedata.MaxPlayers then
            TriggerClientEvent('ffa:zonefull', src)
            TriggerClientEvent("ffa:menu", src, false)
        else
            xPlayer.removeMoney(price)
            TriggerClientEvent('ffa:joinzone', src)
    
            allcount = allcount + 1
            TriggerClientEvent('ffa:setallcount', -1, allcount)

            if players[zonedata.Name] == nil then
                players[zonedata.Name] = data2.steamname
            else
                players[zonedata.Name] = players[zonedata.Name] .. "" .. data2.steamname
            end

            if counts[zonedata.Name] == nil then
                counts[zonedata.Name] = 1
            else
                counts[zonedata.Name] = counts[zonedata.Name] + 1
            end

            TriggerClientEvent("ffa:setcount", -1, counts[zonedata.Name], zonedata.Name)
        end
    else
        TriggerClientEvent('ffa:notenoughmoney', src)
        TriggerClientEvent("ffa:menu", src, false)
    end
end)

RegisterServerEvent('ffa:routingbucket')
AddEventHandler('ffa:routingbucket', function(data)
    local src = source
    SetPlayerRoutingBucket(src, data)
end)

RegisterServerEvent('ffa:updateprofilepicture')
AddEventHandler('ffa:updateprofilepicture', function(profile)
    local src = source
    local identifier = ExtractIdentifiers(src)

    if profile == nil or profile == '' or profile == ' ' then return end
    MySQL.Async.fetchAll("UPDATE ffa_users SET url = @profilepicture WHERE identifier = @identifier", { 
            ['@profilepicture'] = profile,
            ['@identifier'] = identifier
        }, function(result)
    end)
end)

RegisterServerEvent('ffa:updateusername')
AddEventHandler('ffa:updateusername', function(name)
    local src = source
    local identifier = ExtractIdentifiers(src)

    if name == nil or name == '' or name == ' ' then return end
    MySQL.Async.fetchAll("UPDATE ffa_users SET name = @username WHERE identifier = @identifier", { 
            ['@username'] = name,
            ['@identifier'] = identifier
        }, function(result)
    end)
end)

RegisterServerEvent('ffa:updateplayer')
AddEventHandler('ffa:updateplayer', function(data)
    local src = source
    local identifier = ExtractIdentifiers(src)

    local s = json.encode(data.options):gsub('{', '[')
    s = s:gsub('}', ']')
    s = s:gsub('"', '')
    s = '"'..s..'"'

    data.options = s

    MySQL.Async.execute("UPDATE ffa_users SET url = @url, name = @name, steamname = @steamname, kills = @kills, deaths = @deaths, playtime = @playtime, loadout = @loadout, options = @options WHERE identifier = @identifier", { 
            ['@url'] = data.url,
            ['@name'] = data.name,
            ['@steamname'] = data.steamname,
            ['@kills'] = data.kills,
            ['@deaths'] = data.deaths,
            ['@playtime'] = data.playtime,
            ['@identifier'] = identifier,
            ['@loadout'] = data.loadout,
            ['@options'] = data.options,
        }, function(result)
    end)
end)

RegisterServerEvent('ffa:updateoptions')
AddEventHandler('ffa:updateoptions', function(data)
    local src = source
    local identifier = ExtractIdentifiers(src)

    local s = json.encode(data.options):gsub('{', '[')
    s = s:gsub('}', ']')
    s = s:gsub('"', '')
    s = '"'..s..'"'

    data.options = s

    MySQL.Async.execute("UPDATE ffa_users SET options = @options WHERE identifier = @identifier", { 
            ['@identifier'] = identifier,
            ['@options'] = data.options,
        }, function(result)
    end)
end)


function ExtractIdentifiers(src)
    local steamIdentifier

    for v, label in pairs(GetPlayerIdentifiers(src)) do
        if string.find(v, "steam") then
            steamIdentifier = label
        end
        return label
    end
end

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local src = source
    local steamIdentifier
    local identifiers = GetPlayerIdentifiers(src)
    deferrals.defer()

    for _, v in pairs(identifiers) do
        if string.find(v, "steam") then
            steamIdentifier = v
            break
        end
    end

    if not steamIdentifier then
        deferrals.done("Please open steam and restart!")
    else
        deferrals.done()
    end
end)

RegisterCommand("ffaquit", function(source, args, rawCommand)
    local src = source
    if src > 0 then
        leaveffa(src)
    else
        print("You are not able to use this command in the console!")
    end
end, false) 

RegisterCommand("leaveffa", function(source, args, rawCommand)
    local src = source
    if src > 0 then
        leaveffa(src)
    else
        print("You are not able to use this command in the console!")
    end
end, false) 

RegisterCommand("ffaleave", function(source, args, rawCommand)
    local src = source
    if src > 0 then
        leaveffa(src)
    else
        print("You are not able to use this command in the console!")
    end
end, false)

RegisterServerEvent('ffa:setcounts')
AddEventHandler('ffa:setcounts', function()
    local src = source

    local zones = Config.Zones

    for k,v in pairs(zones) do
        if counts[v.Name] == nil then
            counts[v.Name] = 0
        end

        TriggerClientEvent("ffa:setcount", src, counts[v.Name], v.Name)
    end

    TriggerClientEvent('ffa:setallcount', src, allcount)
end)

RegisterServerEvent('ffa:quit')
AddEventHandler('ffa:quit', function(zonedata)
    local src = source
    SetPlayerRoutingBucket(src, 0)

    if players[zonedata.Name]:find(GetPlayerName(src)) then
        players[zonedata.Name] = players[zonedata.Name]:gsub("%"..GetPlayerName(src), "")

        if zonedata ~= nil then
            if counts[zonedata.Name] == nil then
                counts[zonedata.Name] = 0
            else
                counts[zonedata.Name] = counts[zonedata.Name] - 1
            end
        end

    end
    TriggerClientEvent("ffa:setcount", -1, counts[zonedata.Name], zonedata.Name)

    allcount = allcount - 1
    TriggerClientEvent('ffa:setallcount', -1, allcount)

    TriggerClientEvent("ffa:quitffa", src)
end)

function leaveffa(src) 
    TriggerClientEvent("ffa:checkquit", src)
end