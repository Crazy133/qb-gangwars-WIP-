local QBCore = exports['qb-core']:GetCoreObject()
local drugsHeld
local gunsHeld
local vehiclesHeld
local robberiesHeld
local currentHoldingGang = {}
local currentTerritoryHolders = {}
local TerritoriesOnCooldown = {}
local startingPlayer

QBCore.Functions.CreateCallback('Nemesis:Server:currentHoldingGang', function(source, cb)
    cb(currentHoldingGang) -- fix this
end)

QBCore.Functions.CreateCallback('Nemesis:Server:GlobalCooldowns', function(source, cb)
    cb(TerritoriesOnCooldown) -- cooldown table
end)

RegisterNetEvent('Nemesis:Server:DestroyZones', function(Cancel)
    TriggerClientEvent('Nemesis:Client:DestroyZones', -1)
    Wait(100)
    if startingPlayer and Cancel then
        TriggerClientEvent('Nemesis:Client:CancelTimer', startingPlayer.PlayerData.source)
    end
end)

RegisterNetEvent('Nemesis:Server:SetupCancelTakeover', function()
    print('ALL CLIENTS') -- Remove Later
    TriggerClientEvent('Nemesis:Client:SetupCancelTakeover', -1)
end)

RegisterNetEvent('Nemesis:Server:NotifyGangs', function()
    print('TAKEOVER INTERUPTED')
end)

RegisterNetEvent('Nemesis:Server:PayTakeoverCost', function(Territory, Cost, PlayerGang)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveMoney('cash', Cost, 'Start Takeover') then
        TriggerClientEvent('Nemesis:Client:SetupTerritory', src, Territory, PlayerGang)
        startingPlayer = Player

        TerritoriesOnCooldown[Territory] = Territory
        if PlayerGang ~= 'none' and Config.TakeoverSpots[Territory].gangsOnly then
            local GangLabel = QBCore.Shared.Gangs[PlayerGang].label
            TerritoriesOnCooldown[Territory] = {Gang = GangLabel} -- revert if broken
        end
        
        SetTimeout((Config.TakeoverCooldown * 1000) * 60, function() -- Change back later
            TerritoriesOnCooldown[Territory] = nil
            startingPlayer = nil
        end)
    else
        QBCore.Functions.Notify(src, 'You Don\'t Have Enough Cash!', 'error', 3000)
    end
end)

RegisterNetEvent('Nemesis:Server:CompleteTakeover', function(TerritoryName, SuccessGang)
    local src = source
    local TerritoryData = Config.TakeoverSpots[TerritoryName]
    local Player = QBCore.Functions.GetPlayer(src)

    if TerritoryName == 'Guns' then
        TriggerEvent('Nemesis:Server:AddGunAmmo', src)
    end
    
    if TerritoryData.gangsOnly then
        local PlayerGang = Player.PlayerData.gang
        currentTerritoryHolders[TerritoryName] = SuccessGang
        print('The '..PlayerGang.label..' Captured '..TerritoryName)
    else
        local PlayerName = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname 
        currentTerritoryHolders[TerritoryName] = PlayerName
        print(PlayerName.. ' Captured '..TerritoryName)
    end
end)

-- Guns
RegisterNetEvent('Nemesis:Server:AddGunAmmo', function(source)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local ammoTypes = {
        'pistol_ammo',
        'smg_ammo',
        'rifle_ammo',
        'mg_ammo',
        'snp_ammo'
    }
    
    for _, k in pairs(ammoTypes) do
        Player.Functions.AddItem(k, Config.AmmoRewardAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[k], 'add')
    end
end)

-- Robberies
RegisterNetEvent('qb-storerobbery:server:SafeReward', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerName = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
    local PlayerGang = Player.PlayerData.gang.name


    if (PlayerName or PlayerGang) == currentTerritoryHolders['Robberies'] then
        Player.Functions.AddItem(Config.RobberiesItemReward, Config.RobberiesItemAmount)
        Player.Functions.AddMoney('cash', Config.CustomRobberyCash, 'Holding Territory')
    end
    if Config.BonusForAllRobberies then
        if currentTerritoryHolders['Robberies'] ~= nil then
            print(currentTerritoryHolders['Robberies'])
            exports['qb-management']:AddGangMoney(currentTerritoryHolders['Robberies'], Config.BonusForAllRobberiesAmount)
        end
    end
end)

-- Vehicles
RegisterNetEvent('qb-scrapyard:server:ScrapVehicle', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerName = Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname
    local PlayerGang = Player.PlayerData.gang.name

    if (PlayerName or PlayerGang) == currentTerritoryHolders['Vehicles'] then
        Player.Functions.AddItem(Config.VehiclesItemReward, Config.VehiclesItemAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.VehiclesItemReward], 'add')
    end
end)

-- Drugs
RegisterNetEvent('qb-drugs:server:sellCornerDrugs', function(ignore1, ignore2, price) -- fix this so can be player owned not gang only 
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local PlayerGang = Player.PlayerData.gang.name

    if Config.PercentageOfAllDrugSales then
        if currentTerritoryHolders['Drugs'] ~= nil then
            exports['qb-management']:AddGangMoney(currentTerritoryHolders['Drugs'], math.floor(price / 4))
        end
    end
    if PlayerGang == currentTerritoryHolders['Drugs'] then -- fix this add support for both gangs and players
        if Config.DoubleDrugSale then
            Player.Functions.AddMoney('cash', price, 'Holding Territory')
        else
            if Config.CustomDrugSale ~= 0 then
                Player.Functions.AddMoney('cash', Config.CustomDrugSale, 'Holding Territory')
            end
        end
    end
end)