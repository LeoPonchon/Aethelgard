--!nonstrict
-- Client initialization script for Aethelgard
-- Orchestrates all client-side systems

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteHelper = require(script:WaitForChild("RemoteHelper"))
local EmoteClient = require(script:WaitForChild("EmoteClient"))
local NPCDialogueClient = require(script:WaitForChild("NPCDialogueClient"))
local AuraSystem = require(script:WaitForChild("AuraSystem"))

local remotes = RemoteHelper.waitForRemotes({
	"PlayEmote",
	"NPCDialogue",
	"NotificationEvent",
	"CurrencyNotification",
}, 10)

EmoteClient.init(remotes["PlayEmote"])

local DebugUI = script:FindFirstChild("DebugUI")
if DebugUI then
	DebugUI = require(DebugUI)
else
	local parent = script.Parent
	if parent then
		DebugUI = parent:FindFirstChild("DebugUI")
		if DebugUI then
			DebugUI = require(DebugUI)
		end
	end
end

local GachaClient = script:FindFirstChild("GachaClient")
if GachaClient then
	GachaClient = require(GachaClient)
else
	local parent = script.Parent
	if parent then
		GachaClient = parent:FindFirstChild("GachaClient")
		if GachaClient then
			GachaClient = require(GachaClient)
		end
	end
end

local ShopClient = script:FindFirstChild("ShopClient")
if ShopClient then
	ShopClient = require(ShopClient)
else
	local parent = script.Parent
	if parent then
		ShopClient = parent:FindFirstChild("ShopClient")
		if ShopClient then
			ShopClient = require(ShopClient)
		end
	end
end

if DebugUI then
	DebugUI.mount()
end

if GachaClient then
    GachaClient.init()

    if DebugUI and DebugUI.setGachaToggle then
        DebugUI.setGachaToggle(function(show)
            if show then
                GachaClient.show()
            else
                GachaClient.hide()
            end
        end)
    end

    if DebugUI and DebugUI.setGachaIsVisible then
        DebugUI.setGachaIsVisible(function()
            return GachaClient.isVisible()
        end)
    end

    GachaClient.setOnVisibilityChanged(function(visible)
        if DebugUI and DebugUI.forceUpdateGachaButton then
            DebugUI.forceUpdateGachaButton()
        end
    end)

    local gachaRemote = ReplicatedStorage:FindFirstChild("GachaRemote")
    AuraSystem.init(gachaRemote)

	GachaClient.setOnItemEquipped(function(item)
		print("[Aura] Item equipped:", item.id, "type:", item.type, "rarity:", item.rarity)
		AuraSystem.setEquippedAura(item.id, item.rarity)
	end)
	print("[Client] setOnItemEquipped callback registered")

	if DebugUI and DebugUI.setSetAura then
		DebugUI.setSetAura(function(auraId, rarity)
			AuraSystem.setEquippedAura(auraId, rarity)
		end)
	end

    _G.GachaClient = GachaClient
end

if ShopClient then
	ShopClient.init()

	if DebugUI and DebugUI.setShopToggle then
		DebugUI.setShopToggle(function(show)
			if show then
				ShopClient.show()
			else
				ShopClient.hide()
			end
		end)
	end

	if DebugUI and DebugUI.setShopIsVisible then
		DebugUI.setShopIsVisible(function()
			return ShopClient.isVisible()
		end)
	end

	ShopClient.setOnVisibilityChanged(function(visible)
		if DebugUI and DebugUI.forceUpdateShopButton then
			DebugUI.forceUpdateShopButton()
		end
	end)

	_G.ShopClient = ShopClient
end

local notificationEvent = remotes["NotificationEvent"]
if notificationEvent then
	notificationEvent.OnClientEvent:Connect(function(data)
		print(string.format("[Notification] %s: %s", data.type, data.message))
	end)
end

local currencyNotification = remotes["CurrencyNotification"]
if currencyNotification then
	currencyNotification.OnClientEvent:Connect(function(data)
		if data.type == "purchase" then
			print(string.format("[Currency] Purchased %d gems! Total: %d", data.amount, data.total))
			if GachaClient then
				GachaClient.updateCurrencyDisplay()
			end
		end
	end)
end

local npcDialogueEvent = remotes["NPCDialogue"]
if npcDialogueEvent then
	npcDialogueEvent.OnClientEvent:Connect(function(data)
		if data.npcId and NPCDialogueClient then
			NPCDialogueClient.startConversation(data.npcId)
		end
	end)
end

print("[Client] Aethelgard client initialized")
