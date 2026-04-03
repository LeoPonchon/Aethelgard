--!nonstrict
-- Notification System for Aethelgard
-- Handles alerts for throne vacancies, relic spawns, and slot openings

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Teams = game:GetService("Teams")

local sharedFolder = ReplicatedStorage:FindFirstChild("Shared")
local TeamData = require(sharedFolder:WaitForChild("TeamData"))
local ShopSystem = require(script.Parent:WaitForChild("ShopSystem"))

local NotificationSystem = {}

local THRONES = {
    { id = "king", name = "King", team = "King" },
    { id = "queen", name = "Queen", team = "Queen" },
    { id = "demon_king", name = "Demon King", team = "Demon King" },
    { id = "demon_queen", name = "Demon Queen", team = "Demon Queen" },
    { id = "princess_sylvestre", name = "Princess Sylvestre", team = "Princess Sylvestre" },
}

local RELICS = {
    { id = "excalibur", name = "Excalibur", description = "The legendary sword of kings" },
    { id = "avalon", name = "Avalon", description = "The scabbard of eternal protection" },
    { id = "holy_grail", name = "Holy Grail", description = "The cup of eternal life" },
}

local SLOTS = {
    { id = "princes", name = "Princes", team = "Princes", maxSlots = 4 },
    { id = "princesses", name = "Princesses", team = "Princesses", maxSlots = 4 },
    { id = "dukes", name = "Dukes", team = "Dukes", maxSlots = 5 },
    { id = "barons", name = "Barons", team = "Barons", maxSlots = 10 },
    { id = "hero", name = "Hero", team = "Hero", maxSlots = 1 },
    { id = "saint", name = "Saint", team = "Saint", maxSlots = 1 },
    { id = "demon_generals", name = "Demon Generals", team = "Demon Generals", maxSlots = 10 },
}

local activeRelics = {}
local throneStatus = {}
local slotStatus = {}

local function getTeamPlayerCount(teamName: string): number
    local team = Teams:FindFirstChild(teamName)
    if not team then return 0 end
    
    local count = 0
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Team == team then
            count = count + 1
        end
    end
    return count
end

local function isThroneVacant(throne: table): boolean
    return getTeamPlayerCount(throne.team) == 0
end

local function getSlotAvailability(slot: table): (boolean, number)
    local currentCount = getTeamPlayerCount(slot.team)
    return currentCount < slot.maxSlots, slot.maxSlots - currentCount
end

local function notifyPlayersWithAlert(alertType: string, alertId: string, message: string, data: table)
    for _, player in ipairs(Players:GetPlayers()) do
        local hasAlert = false
        
        if alertType == "throne" and ShopSystem.ownsItem(player.UserId, "throne_alert") then
            hasAlert = true
        elseif alertType == "relic" and ShopSystem.ownsItem(player.UserId, "relic_alert") then
            hasAlert = true
        elseif alertType == "slot" and ShopSystem.ownsItem(player.UserId, "slot_alert") then
            hasAlert = true
        elseif ShopSystem.ownsItem(player.UserId, "alert_pack") then
            hasAlert = true
        end
        
        if hasAlert then
            local notificationRemote = ReplicatedStorage:FindFirstChild("NotificationEvent")
            if notificationRemote then
                notificationRemote:FireClient(player, {
                    type = alertType,
                    id = alertId,
                    message = message,
                    data = data,
                    timestamp = os.time(),
                })
            end
        end
    end
end

function NotificationSystem.checkThrones()
    for _, throne in ipairs(THRONES) do
        local isVacant = isThroneVacant(throne)
        local wasVacant = throneStatus[throne.id]
        
        if isVacant and wasVacant == false then
            notifyPlayersWithAlert("throne", throne.id, 
                string.format("The %s throne is now vacant!", throne.name),
                { throne = throne }
            )
        end
        
        throneStatus[throne.id] = isVacant
    end
end

function NotificationSystem.checkSlots()
    for _, slot in ipairs(SLOTS) do
        local isAvailable, freeSlots = getSlotAvailability(slot)
        local wasAvailable = slotStatus[slot.id]
        
        if isAvailable and not wasAvailable and freeSlots > 0 then
            notifyPlayersWithAlert("slot", slot.id,
                string.format("%s slot available! (%d/%d)", slot.name, freeSlots, slot.maxSlots),
                { slot = slot, freeSlots = freeSlots }
            )
        end
        
        slotStatus[slot.id] = isAvailable
    end
end

function NotificationSystem.spawnRelic(relicId: string, location: Vector3)
    local relic = nil
    for _, r in ipairs(RELICS) do
        if r.id == relicId then
            relic = r
            break
        end
    end
    
    if not relic then return end
    
    activeRelics[relicId] = {
        relic = relic,
        location = location,
        spawnedAt = os.time(),
    }
    
    notifyPlayersWithAlert("relic", relicId,
        string.format("%s has appeared! %s", relic.name, relic.description),
        { relic = relic, location = location }
    )
end

function NotificationSystem.removeRelic(relicId: string)
    activeRelics[relicId] = nil
end

function NotificationSystem.getActiveRelics(): { [string]: table }
    return activeRelics
end

function NotificationSystem.getThroneStatus(): { [string]: boolean }
    return throneStatus
end

function NotificationSystem.getSlotStatus(): { [string]: boolean }
    return slotStatus
end

function NotificationSystem.init()
    for _, throne in ipairs(THRONES) do
        throneStatus[throne.id] = isThroneVacant(throne)
    end
    
    for _, slot in ipairs(SLOTS) do
        local isAvailable = getSlotAvailability(slot)
        slotStatus[slot.id] = isAvailable
    end
    
    Players.PlayerAdded:Connect(function(player)
        task.wait(1)
        
        for _, throne in ipairs(THRONES) do
            if throneStatus[throne.id] then
                if ShopSystem.ownsItem(player.UserId, "throne_alert") or 
                   ShopSystem.ownsItem(player.UserId, "alert_pack") then
                    local notificationRemote = ReplicatedStorage:FindFirstChild("NotificationEvent")
                    if notificationRemote then
                        notificationRemote:FireClient(player, {
                            type = "throne",
                            id = throne.id,
                            message = string.format("The %s throne is currently vacant!", throne.name),
                            data = { throne = throne },
                            timestamp = os.time(),
                        })
                    end
                end
            end
        end
    end)
    
    spawn(function()
        while true do
            NotificationSystem.checkThrones()
            NotificationSystem.checkSlots()
            task.wait(10)
        end
    end)
    
    print("[NotificationSystem] Initialized")
end

return NotificationSystem
