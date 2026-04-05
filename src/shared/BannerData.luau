--!nonstrict
-- Banner display data for Aethelgard Gacha UI

export type BannerDisplayInfo = {
	id: string,
	bannerName: string,
	bannerType: string,
	featuredItemName: string,
	featuredItemDescription: string,
	featuredItemRarity: string,
	guaranteeInfo: string,
	timeLimited: boolean,
	boostedDropRate: boolean,
	endTime: number,
}

local BannerData = {}

BannerData.DISPLAY_INFO = {
	standard_aura = {
		id = "standard_aura",
		bannerName = "Royal Essence",
		bannerType = "aura",
		featuredItemName = "Golden Aura",
		featuredItemDescription = "A majestic golden glow that surrounds your character with divine light. This legendary aura marks you as one chosen by the gods themselves.",
		featuredItemRarity = "legendary",
		guaranteeInfo = "Every 10 wishes guarantees at least one Epic or higher aura.",
		timeLimited = false,
		boostedDropRate = true,
		endTime = os.time() + (19 * 24 * 60 * 60) + (18 * 60 * 60) + (28 * 60),
	},
	standard_accessory = {
		id = "standard_accessory",
		bannerName = "Divine Regalia",
		bannerType = "accessory",
		featuredItemName = "Royal Crown",
		featuredItemDescription = "A crown fit for true royalty. Wearing this legendary accessory grants you an air of supreme authority and commands respect from all who gaze upon you.",
		featuredItemRarity = "legendary",
		guaranteeInfo = "Every 10 wishes guarantees at least one Epic or higher accessory.",
		timeLimited = false,
		boostedDropRate = true,
		endTime = os.time() + (19 * 24 * 60 * 60) + (18 * 60 * 60) + (28 * 60),
	},
}

function BannerData.getDisplayInfo(bannerId)
	return BannerData.DISPLAY_INFO[bannerId]
end

function BannerData.getFeaturedItemDisplayName(bannerId)
	local info = BannerData.DISPLAY_INFO[bannerId]
	if info then
		return info.featuredItemName
	end
	return "Unknown"
end

function BannerData.getBannerDisplayName(bannerId)
	local info = BannerData.DISPLAY_INFO[bannerId]
	if info then
		return info.bannerName
	end
	return "Unknown Banner"
end

function BannerData.getRemainingTime(bannerId)
	local info = BannerData.DISPLAY_INFO[bannerId]
	if info and info.endTime then
		local remaining = info.endTime - os.time()
		if remaining < 0 then
			return 0
		end
		return remaining
	end
	return 0
end

function BannerData.formatTime(seconds)
	local days = math.floor(seconds / (24 * 60 * 60))
	local hours = math.floor((seconds % (24 * 60 * 60)) / (60 * 60))
	local minutes = math.floor((seconds % (60 * 60)) / 60)
	return string.format("%d day(s) %d hour(s) %d minute(s)", days, hours, minutes)
end

function BannerData.getAllBannerIds()
	local ids = {}
	for id, _ in pairs(BannerData.DISPLAY_INFO) do
		table.insert(ids, id)
	end
	return ids
end

return BannerData
