RegisterNetEvent('drug:harvest')
AddEventHandler('drug:harvest', function(drugType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if Config.Drugs[drugType] then
        local harvestLocation = Config.Drugs[drugType].harvestLocation
        TriggerClientEvent('drug:startHarvest', src, drugType, harvestLocation, Config.Drugs[drugType].harvestTime)
    end
end)

RegisterNetEvent('drug:process')
AddEventHandler('drug:process', function(drugType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if Config.Drugs[drugType] then
        local processLocation = Config.Drugs[drugType].processLocation
        TriggerClientEvent('drug:startProcess', src, drugType, processLocation, Config.Drugs[drugType].processTime, Config.Drugs[drugType].explosionChance)
    end
end)

RegisterNetEvent('drug:harvestComplete')
AddEventHandler('drug:harvestComplete', function(drugType, quantity)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if Config.Drugs[drugType] then
        xPlayer.addInventoryItem(Config.Drugs[drugType].harvestItem, quantity)
        
        local drugCount = xPlayer.getInventoryItem(Config.Drugs[drugType].harvestItem).count
        if drugCount >= 100 then
            TriggerClientEvent('drug:markProcessLocation', src, Config.Drugs[drugType].processLocation)
        end
    end
end)

RegisterNetEvent('drug:processComplete')
AddEventHandler('drug:processComplete', function(drugType)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    if Config.Drugs[drugType] then
        xPlayer.removeInventoryItem(Config.Drugs[drugType].harvestItem, 10)
        xPlayer.addInventoryItem(Config.Drugs[drugType].processedItem, 1)
    end
end)

RegisterNetEvent('drug:triggerExplosion')
AddEventHandler('drug:triggerExplosion', function(coords)
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        
        if #(playerCoords - coords) < 15.0 then
            TriggerClientEvent('drug:applyGasEffect', playerId, coords)
        end
    end
end)
