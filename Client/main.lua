local QBCore = exports['qb-core']:GetCoreObject()
local ListenCancel = false
-- local currentHoldingGang = nil
local CurrentCops = 0
local TimerComplete = false
local TimerCanceled = false
local StartCooldown = false

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

-- local function DestroyOnLeave()
--     Territory:destroy()
--     CancelTerritory:destroy()
-- end

RegisterNetEvent('Nemesis:Client:DestroyZones', function() -- All Players
    if Territory then
        Territory:destroy()
    end
    if CancelTerritory then
        CancelTerritory:destroy()
    end
    TimerCanceled = true
end)

RegisterNetEvent('Nemesis:Client:CancelTimer', function() -- For Starting Player
    CancelTimer()
    QBCore.Functions.Notify('Takeover Has Been Interupted!', 'error', 5000)
end)


local function Listen4Cancel()
    ListenCancel = true
    CreateThread(function()
        while ListenCancel do
            if IsControlJustPressed(0, 38) then
                exports['qb-core']:HideText()

                QBCore.Functions.Progressbar('name', 'Text that shows in bar', 3000, false, true, { -- Name | Label | Time | useWhileDead | canCancel
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = 'anim@gangops@facility@servers@',
                    anim = 'hotwire',
                    flags = 16,
                }, {}, {}, function() -- Done
                    ClearPedTasksImmediately(PlayerPedId())
                    -- TriggerServerEvent('Nemesis:Server:NotifyGangs')
                    TriggerServerEvent('Nemesis:Server:DestroyZones', true)
                    ListenCancel = false
                end, function() -- Cancel
                    ListenCancel = false
                    return
                end)

                ListenCancel = false
            end
            Wait(1)
        end    
    end)
end



RegisterNetEvent('Nemesis:Client:SetupCancelTakeover', function()
    print("all clients")
    CancelTerritory = BoxZone:Create(vector3(165.8, -1003.29, 29.35), 2, 2, {
        name = 'CancelTerritory',
        debugPoly = true,
        heading = 0,
        minZ = 28.35,
        maxZ = 30.35,
    })
    CancelTerritory:onPlayerInOut(function(isPointInside)
        if isPointInside then
            exports['qb-core']:DrawText('[E] - Stop Takeover!', 'right')
            Listen4Cancel()
        else
            exports['qb-core']:HideText()
            ListenCancel = false
        end
    end)
end)


RegisterNetEvent('Nemesis:Client:SetupTerritory', function(TerritoryName, Gang) -- Needs to be re-written to accept all territories
    StartCooldown = true
    SetTimeout((Config.TakeoverTimer * 1000) * 60, function()
        StartCooldown = false
    end)    
    local TerritoryData = Config.TakeoverSpots[TerritoryName]
    Territory = CircleZone:Create(TerritoryData.coords, Config.TakeoverSpotsRadius, {
        name = TerritoryName,
        debugPoly = true,
        heading = 0,
        minZ = TerritoryData.coords.z - 1,
        maxZ = TerritoryData.coords.z + 1,
    })
    SetTimeout((Config.TerritoryAutoRemove * 1000) * 60, function()
        if not TimerComplete then
            if not TimerCanceled then
                if enteredTerritory then
                    TriggerServerEvent('Nemesis:Server:DestroyZones')
                    print('timeout')
                    exports['qb-core']:HideText()
                else
                    Territory:destroy()
                end
            else
                print("cancel test")
                TimerCanceled = false
                return
            end
            print('Took Too Long!') -- REMOVE later
        end
    end)
    Territory:onPlayerInOut(function(isPointInside)  -- REVISE THIS LATER
        local Timer = 0
        if isPointInside then
            enteredTerritory = true
            TriggerServerEvent('Nemesis:Server:SetupCancelTakeover')
            CreateThread(function()
                while Timer < 15 do
                    local PlayerData = QBCore.Functions.GetPlayerData()
                    function CancelTimer()
                        Timer = 1000
                        -- exports['qb-core']:HideText() -- Remove This Later?
                        -- TriggerServerEvent('Nemesis:Server:NotifyGangs')
                    end
                    Timer = Timer + 1
                    print(Timer) -- REMOVE later
                    Wait(1000)
                    if Timer == 15 then
                        TriggerServerEvent('Nemesis:Server:CompleteTakeover', TerritoryName, Gang)
                        TriggerServerEvent('Nemesis:Server:DestroyZones')
                        print('complete')
                        TimerComplete = true
                    end
                    if PlayerData.metadata['inlaststand'] or PlayerData.metadata['isdead'] then
                        TimerCanceled = true
                        TriggerServerEvent('Nemesis:Server:DestroyZones', true) -- issue here
                        break -- should fix?
                    end
                    if Timer == 1000 then
                        break
                    end
                end
            end)
        else
            TriggerServerEvent('Nemesis:Server:DestroyZones', true)
            exports['qb-core']:HideText()
        end
    end)
end)

RegisterNetEvent('Nemesis:Client:PreTerritorySetup', function(data)
    startingPlayer = GetPlayerServerId(PlayerPedId())
    local PlayerGang = QBCore.Functions.GetPlayerData().gang.name
    if not Config.TakeoverSpots[data.Territory].gangsOnly then
        TriggerServerEvent('Nemesis:Server:PayTakeoverCost', data.Territory, data.Price)
    else
        if PlayerGang ~= 'none' then
            TriggerServerEvent('Nemesis:Server:PayTakeoverCost', data.Territory, data.Price, PlayerGang)
        else
            QBCore.Functions.Notify('You Must Be In A Gang', 'error', 2000)
        end
    end
end)

local function OpenTerritoryMenu()
    QBCore.Functions.TriggerCallback('Nemesis:Server:GlobalCooldowns', function(BlockedTerritorys)
        local Cost = Config.StartTakeoverPrice
        local takeoverMenu = {
            {
                header = 'Select A Territory',
                txt = '$'..Cost,
                isMenuHeader = true
            }
        }
        for terri in pairs(Config.TakeoverSpots) do
            if Config.TakeoverSpots[terri].gangsOnly then
                text = "Gangs Only"
            else
                text = "Public"
            end
            if BlockedTerritorys[terri] then
                bool = true
                if Config.DisplayGangInMenu then
                    text = BlockedTerritorys[terri].Gang
                end
            else
                bool = false
            end
            takeoverMenu[#takeoverMenu+1] = {
                header = terri,
                txt = text,
                disabled = bool,
                params = {
                    event = "Nemesis:Client:PreTerritorySetup",
                    args = {
                        Territory = terri,
                        Price = Cost
                    }
                }
            }
        end

        takeoverMenu[#takeoverMenu+1] = {
            header = "Close Menu",
            params = {
                event = "qb-menu:client:closeMenu"
            }
        }

        exports['qb-menu']:openMenu(takeoverMenu)
    end)
end

CreateThread(function()
    local price = Config.StartTakeoverPrice
    local startTerr = BoxZone:Create(Config.StartTakeoverLocation.coords, Config.StartTakeoverLocation.length, Config.StartTakeoverLocation.width, {
        name = 'startTerr',
        debugPoly = true,
        heading = Config.StartTakeoverLocation.heading,
        minZ = Config.StartTakeoverLocation.coords.z - 1,
        maxZ = Config.StartTakeoverLocation.coords.z + 1,
    })
    startTerr:onPlayerInOut(function(isPointInside)
        if isPointInside then
            if not StartCooldown then
                local PlayerGang = QBCore.Functions.GetPlayerData().gang.name
                if CurrentCops >= Config.MinimumPoliceToStart then
                    OpenTerritoryMenu()
                else
                    QBCore.Functions.Notify('Not Enough Cops', 'error', 3000)
                end
            else
                QBCore.Functions.Notify('You Have Already Selected A Territory, Come Back Later', 'error', 3000)
            end
        else
            exports['qb-menu']:closeMenu()
        end
    end)
end)