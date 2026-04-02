--!nonstrict
-- Emote System for Aethelgard
-- Handles RP animations and emotes for social interaction

local EmoteSystem = {}

export type EmoteDefinition = {
	id: string,
	name: string,
	description: string,
	category: string,
	animationId: string?,
	duration: number,
	looped: boolean,
	cooldown: number,
	chatCommand: string,
}

local EMOTE_DEFINITIONS: {[string]: EmoteDefinition} = {
	["wave"] = {
		id = "wave",
		name = "Wave",
		description = "Give a friendly wave.",
		category = "Greeting",
		animationId = "rbxassetid://507776028",
		duration = 2,
		looped = false,
		cooldown = 1,
		chatCommand = "/wave",
	},
	["bow"] = {
		id = "bow",
		name = "Bow",
		description = "Perform a respectful bow.",
		category = "Greeting",
		animationId = "rbxassetid://507770000",
		duration = 2,
		looped = false,
		cooldown = 1,
		chatCommand = "/bow",
	},
	["dance"] = {
		id = "dance",
		name = "Dance",
		description = "Dance joyfully.",
		category = "Dance",
		animationId = "rbxassetid://507771000",
		duration = 5,
		looped = true,
		cooldown = 1,
		chatCommand = "/dance",
	},
	["cheer"] = {
		id = "cheer",
		name = "Cheer",
		description = "Cheer enthusiastically.",
		category = "Social",
		animationId = "rbxassetid://507770000",
		duration = 3,
		looped = false,
		cooldown = 2,
		chatCommand = "/cheer",
	},
	["clap"] = {
		id = "clap",
		name = "Clap",
		description = "Clap your hands.",
		category = "Social",
		animationId = "rbxassetid://507770000",
		duration = 3,
		looped = false,
		cooldown = 2,
		chatCommand = "/clap",
	},
}

local playerEmoteStates: {[number]: {currentEmote: string?, startTime: number}} = {}
local playerCooldowns: {[number]: {[string]: number}} = {}

local function getPlayerCooldowns(playerId: number)
	if not playerCooldowns[playerId] then
		playerCooldowns[playerId] = {}
	end
	return playerCooldowns[playerId]
end

local function isOnCooldown(playerId: number, emoteId: string): boolean
	local cooldowns = getPlayerCooldowns(playerId)
	local emote = EMOTE_DEFINITIONS[emoteId]
	if not emote then return false end

	local cooldownEnd = cooldowns[emoteId]
	if cooldownEnd and os.time() < cooldownEnd then
		return true
	end

	return false
end

local function setCooldown(playerId: number, emoteId: string, duration: number)
	local cooldowns = getPlayerCooldowns(playerId)
	cooldowns[emoteId] = os.time() + duration
end

function EmoteSystem.getEmote(emoteId: string): EmoteDefinition?
	return EMOTE_DEFINITIONS[emoteId]
end

function EmoteSystem.getAllEmotes(): {[string]: EmoteDefinition}
	return EMOTE_DEFINITIONS
end

function EmoteSystem.canUseEmote(playerId: number, emoteId: string, playerClass: string?, playerFaction: string?): (boolean, string?)
	local emote = EMOTE_DEFINITIONS[emoteId]
	if not emote then
		return false, "Emote not found"
	end

	if isOnCooldown(playerId, emoteId) then
		return false, "On cooldown"
	end

	return true, nil
end

function EmoteSystem.playEmote(playerId: number, emoteId: string)
	local emote = EMOTE_DEFINITIONS[emoteId]
	if not emote then return nil end

	setCooldown(playerId, emoteId, emote.cooldown)

	playerEmoteStates[playerId] = {
		currentEmote = emoteId,
		startTime = os.time(),
	}

	return {
		emote = emote,
		animationId = emote.animationId,
		duration = emote.duration,
		looped = emote.looped,
	}
end

function EmoteSystem.parseChatCommand(message: string): string?
	if message:sub(1, 1) ~= "/" then return nil end

	for emoteId, emote in pairs(EMOTE_DEFINITIONS) do
		if message:lower() == emote.chatCommand:lower() then
			return emoteId
		end
	end

	return nil
end

print("[EmoteSystem] Module loaded")
return EmoteSystem
