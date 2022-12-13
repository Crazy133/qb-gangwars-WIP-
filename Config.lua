Config = Config or {}

-- General Stuff
Config.TerritoryAutoRemove = 1 -- In Minutes, How Long Before The Territory Is Removed (To Stop Players From Waiting A Long Time Before Starting The Takeover)
Config.DisplayGangInMenu = true -- If True, Displays The Current Holding(or Attempting) Gang of Territories

-- Start Takeover Stuff
Config.MinimumPoliceToStart = 0 -- How Many Police Are Required To Start The Takeover

Config.StartTakeoverPrice = math.random(5000, 10000) -- The Cost (Cash) To Start The Takeover
Config.TakeoverTimer = 10 -- In Minutes, How Long It Takes To Completely Takeover A Territory

-- After Takeover Stuff
Config.TakeoverCooldown = 1 -- In Minutes, How Long Until The Territory Resets

-- Territory Control Rewards --
-- #Drugs
Config.PercentageOfAllDrugSales = true -- If True, The Holding Gang Will Get A Small Percentage Of ALL Drug Sales (1/4 The Price - Goes Into Gang Funds [qb-managment])
Config.DoubleDrugSale = true -- If True, Will Double The Reward For Each Drug Sale (Seller Must Be In The Gang)
Config.CustomDrugSale = 1000 -- If Above False, Provided Extra Cash Bonus For Each Drug Sale (Seller Must Be In The Holding Gang)

-- #Guns
Config.AmmoRewardAmount = 5

-- #Vehicles
Config.VehiclesItemReward = 'laptop' -- The Bonus Item Reward When A Player Scraps A Vehicle (Must Currently Hold The 'Vehicles' Territory)
Config.VehiclesItemAmount = 1 -- Amount Of Bonus Item To Give

-- #Robberies
Config.BonusForAllRobberies = true -- If True, The Holding Gang Will Get a Bonus From ALL Safe Store Safe Robberies (goes Into Gang Funds [qb-management])
Config.BonusForAllRobberiesAmount = 500 -- If Above = true, Current Gang (Holding) 'Robberies' Will Get Gang Funds [qb-mangement] 
Config.CustomRobberyCash = 1000

Config.RobberiesItemReward = 'goldbar' -- 
Config.RobberiesItemAmount = 1


-- Start Takeover
Config.StartTakeoverLocation = {
    coords = vector3(154.24, -981.62, 30.09),
    length = 5,
    width = 5,
    heading = 0.0
}

-- Territories
Config.TakeoverSpotsRadius = 10 -- How Big The Zone For Territories Are

Config.TakeoverSpots = { -- Randomly Selected Location
    ['Drugs'] = { coords = vector3(146.52, -994.32, 29.36), gangsOnly = true },
    ['Guns'] = { coords = vector3(163.04, -993.55, 29.38),  gangsOnly = true }, 
    ['Vehicles'] = { coords = vector3(146.52, -994.32, 29.36),  gangsOnly = false }, 
    ['Robberies'] = { coords = vector3(146.52, -994.32, 29.36),  gangsOnly = false }, 
}


--[[
TODO://

    - Revise Takeover Timer Shit

    - Revise CancelTimer() function

    - Buff Initial Reward

    - Create Locales folder


    


    SHIT THAT NEEDS TO BE TESTED! V

    - Create Takeover Timeout After Not Entering The Zone Soon Enough (Test This w 2 people) 
    - Test Percentage Of All Drug Sales with 2 people





]]
