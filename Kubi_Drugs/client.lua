local ESX = exports['es_extended']:getSharedObject()

local isHarvesting = false
local isProcessing = false
local currentAction = nil
local currentActionMsg = ''
local currentActionData = {}
local blips = {}

function createBlip(coords, text)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandSetBlipName(blip)
    return blip
end

function showNotification(msg)
    SetNotificationTextEntry('STRING')
    AddTextComponentSubstringPlayerName(msg)
    DrawNotification(false, true)
end

RegisterNetEvent('drug:startHarvest')
AddEventHandler('drug:startHarvest', function(drugType, location, time)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    if #(playerCoords - location) < 5.0 and not isHarvesting then
        isHarvesting = true
        Citizen.CreateThread(function()
            for i = 1, 100 do
                if not isHarvesting then break end
                
                TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_GARDENER_PLANT', 0, true)
                Citizen.Wait(time * 1000)
                ClearPedTasks(playerPed)
                showNotification('Zebrano ' .. drugType .. ' (' .. i .. '/100)')
                print('Zebrano ' .. drugType .. ' (' .. i .. '/100)')
                TriggerServerEvent('drug:harvestComplete', drugType, 1)
            end
            isHarvesting = false
        end)
    end
end)

RegisterNetEvent('drug:startProcess')
AddEventHandler('drug:startProcess', function(drugType, location, time, explosionChance)
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    
    if #(playerCoords - location) < 5.0 and not isProcessing then
        isProcessing = true
        TaskStartScenarioInPlace(playerPed, Config.Drugs[drugType].processAnimation, 0, true)
        Citizen.Wait(time * 1000)
        ClearPedTasks(playerPed)

        if math.random() < explosionChance then
            TriggerServerEvent('drug:triggerExplosion', playerCoords)
        else
            TriggerServerEvent('drug:processComplete', drugType)
        end
        isProcessing = false
    end
end)

RegisterNetEvent('drug:applyGasEffect')
AddEventHandler('drug:applyGasEffect', function(coords)
    local playerPed = PlayerPedId()
    
    RequestAnimSet('move_m@drunk@slightlydrunk')
    while not HasAnimSetLoaded('move_m@drunk@slightlydrunk') do
        Citizen.Wait(100)
    end
    SetPedMovementClipset(playerPed, 'move_m@drunk@slightlydrunk', 1.0)

    StartScreenEffect('DrugsTrevorClownsFightIn', 0, true)

    local gasCloud = CreateObject(GetHashKey('prop_cs_gascage'), coords.x, coords.y, coords.z, true, true, true)
    SetEntityAlpha(gasCloud, 0.0, false)

    Citizen.CreateThread(function()
        Citizen.Wait(15000)

        DeleteObject(gasCloud)
        
        ClearTimecycleModifier()
        ResetScenarioTypesEnabled()
        ResetPedMovementClipset(playerPed, 0)
        StopScreenEffect('DrugsTrevorClownsFightIn')
    end)
end)

RegisterNetEvent('drug:markProcessLocation')
AddEventHandler('drug:markProcessLocation', function(processLocation)
    SetNewWaypoint(processLocation.x, processLocation.y)
    showNotification('Osiągnąłeś 100 jednostek! Lokalizacja przetwarzania została zaznaczona na mapie.')
end)

Citizen.CreateThread(function()
    for drugType, data in pairs(Config.Drugs) do
        blips[data.harvestLocation] = createBlip(data.harvestLocation, 'Zbieranie ' .. drugType)
        blips[data.processLocation] = createBlip(data.processLocation, 'Przetwarzanie ' .. drugType)
    end

    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for drugType, data in pairs(Config.Drugs) do
            local distanceToHarvest = #(playerCoords - data.harvestLocation)
            local distanceToProcess = #(playerCoords - data.processLocation)

            if distanceToHarvest < 10.0 then
                DrawMarker(1, data.harvestLocation.x, data.harvestLocation.y, data.harvestLocation.z - 1.0, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 0.5, 0, 255, 0, 100, false, true, 2, nil, nil, false)
                if distanceToHarvest < 2.0 then
                    ESX.ShowHelpNotification('Naciśnij ~INPUT_CONTEXT~ aby zbierać ' .. drugType)
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('drug:harvest', drugType)
                    end
                end
            end

            if distanceToProcess < 10.0 then
                DrawMarker(1, data.processLocation.x, data.processLocation.y, data.processLocation.z - 1.0, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 0.5, 0, 255, 0, 100, false, true, 2, nil, nil, false)
                if distanceToProcess < 2.0 then
                    ESX.ShowHelpNotification('Naciśnij ~INPUT_CONTEXT~ aby przetwarzać ' .. drugType)
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('drug:process', drugType)
                    end
                end
            end
        end
    end
end)
