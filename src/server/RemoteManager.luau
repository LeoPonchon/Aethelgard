--!nonstrict
-- Remote Manager for Server
-- Creates and manages all RemoteEvents and RemoteFunctions

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteManager = {}

local remotes = {}

local REMOTE_CONFIG = {
	{ name = "NPCInteraction", type = "Function" },
	{ name = "PlayEmote", type = "Event" },
	{ name = "NPCDialogue", type = "Event" },
	{ name = "PlayerData", type = "Function" },
	{ name = "GachaRemote", type = "Function" },
	{ name = "GachaEvent", type = "Event" },
	{ name = "ShopRemote", type = "Function" },
	{ name = "NotificationEvent", type = "Event" },
	{ name = "CurrencyNotification", type = "Event" },
	{ name = "AuraRemote", type = "Function" },
	{ name = "AuraEvent", type = "Event" },
}

function RemoteManager.init()
	for _, config in ipairs(REMOTE_CONFIG) do
		local existing = ReplicatedStorage:FindFirstChild(config.name)
		if existing then
			remotes[config.name] = existing
		else
			local remote
			if config.type == "Function" then
				remote = Instance.new("RemoteFunction")
			else
				remote = Instance.new("RemoteEvent")
			end
			remote.Name = config.name
			remote.Parent = ReplicatedStorage
			remotes[config.name] = remote
		end
	end

	print("[RemoteManager] All remotes created")
end

function RemoteManager.get(name)
	return remotes[name]
end

function RemoteManager.getAll()
	return remotes
end

return RemoteManager
