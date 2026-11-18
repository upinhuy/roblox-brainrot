-- Brainrot Bazaar: the cast. Ten absurd characters of our own, each with a
-- name, a rarity, a price, the cash it earns every second, a body colour and
-- a size. Nothing here copies another game's characters: a coffee cat and a
-- karate banana are ours, and the ladder runs Common to Secret.

local BrainrotData = {}

BrainrotData.RARITY_ORDER = { "Common", "Rare", "Epic", "Legendary", "Mythic", "Secret" }

BrainrotData.RARITY_COLORS = {
	Common = Color3.fromRGB(180, 180, 180),
	Rare = Color3.fromRGB(64, 160, 255),
	Epic = Color3.fromRGB(178, 102, 255),
	Legendary = Color3.fromRGB(255, 200, 40),
	Mythic = Color3.fromRGB(255, 80, 200),
	Secret = Color3.fromRGB(255, 40, 40),
}

-- How often each rarity rolls off the belt, out of 100.
BrainrotData.RARITY_WEIGHTS = {
	Common = 45,
	Rare = 25,
	Epic = 15,
	Legendary = 9,
	Mythic = 5,
	Secret = 1,
}

BrainrotData.CAST = {
	{
		id = "kucing-kopi",
		name = "Kucing Kopi",
		rarity = "Common",
		price = 50,
		income = 5,
		color = Color3.fromRGB(150, 100, 60),
		size = 2.2,
		joke = "Mengeong sambil menyeduh. Kopinya selalu pahit.",
	},
	{
		id = "pisang-karate",
		name = "Pisang Karate",
		rarity = "Common",
		price = 100,
		income = 8,
		color = Color3.fromRGB(250, 220, 60),
		size = 2.4,
		joke = "Kulitnya licin, tendangannya tidak.",
	},
	{
		id = "ayam-disco",
		name = "Ayam Disco",
		rarity = "Rare",
		price = 300,
		income = 20,
		color = Color3.fromRGB(255, 120, 200),
		size = 2.6,
		joke = "Bertelur di lantai dansa. Telurnya berkilau.",
	},
	{
		id = "bebek-astronot",
		name = "Bebek Astronot",
		rarity = "Rare",
		price = 600,
		income = 35,
		color = Color3.fromRGB(255, 255, 255),
		size = 2.8,
		joke = "Berenang di luar angkasa. Helmnya bocor sedikit.",
	},
	{
		id = "ikan-terbang",
		name = "Ikan Terbang",
		rarity = "Epic",
		price = 1500,
		income = 70,
		color = Color3.fromRGB(80, 180, 255),
		size = 3,
		joke = "Lupa cara berenang, malah belajar terbang.",
	},
	{
		id = "kambing-dj",
		name = "Kambing DJ",
		rarity = "Epic",
		price = 3000,
		income = 120,
		color = Color3.fromRGB(200, 80, 255),
		size = 3.2,
		joke = "Mengembik di 128 BPM. Penontonnya rumput.",
	},
	{
		id = "sapi-balon",
		name = "Sapi Balon",
		rarity = "Legendary",
		price = 8000,
		income = 250,
		color = Color3.fromRGB(255, 150, 150),
		size = 3.6,
		joke = "Sekali melayang, susunya jadi awan.",
	},
	{
		id = "kura-kura-turbo",
		name = "Kura-kura Turbo",
		rarity = "Legendary",
		price = 15000,
		income = 450,
		color = Color3.fromRGB(80, 200, 120),
		size = 3.8,
		joke = "Tempurungnya ada knalpot. Pelan tapi berisik.",
	},
	{
		id = "nasi-goreng-ninja",
		name = "Nasi Goreng Ninja",
		rarity = "Mythic",
		price = 40000,
		income = 900,
		color = Color3.fromRGB(230, 140, 60),
		size = 4.2,
		joke = "Muncul saat lapar, hilang saat kenyang.",
	},
	{
		id = "kentang-presiden",
		name = "Kentang Presiden",
		rarity = "Secret",
		price = 150000,
		income = 2500,
		color = Color3.fromRGB(255, 215, 120),
		size = 4.6,
		joke = "Dipilih 99% kentang. Janjinya: saus gratis.",
	},
}

-- Find one cast member by its id, or nil when no member has it.
function BrainrotData.getById(id)
	for _, member in ipairs(BrainrotData.CAST) do
		if member.id == id then
			return member
		end
	end
	return nil
end

-- Pick a random member of one rarity, for the tour and for rare spawns.
function BrainrotData.randomOfRarity(rarity)
	local ofRarity = {}
	for _, member in ipairs(BrainrotData.CAST) do
		if member.rarity == rarity then
			table.insert(ofRarity, member)
		end
	end
	if #ofRarity == 0 then
		return BrainrotData.CAST[math.random(#BrainrotData.CAST)]
	end
	return ofRarity[math.random(#ofRarity)]
end

-- Roll a rarity from the weights above, then pick a random member of it.
function BrainrotData.rollRandom()
	local roll = math.random(100)
	local running = 0
	local pickedRarity = "Common"
	for _, rarity in ipairs(BrainrotData.RARITY_ORDER) do
		running += BrainrotData.RARITY_WEIGHTS[rarity]
		if roll <= running then
			pickedRarity = rarity
			break
		end
	end
	return BrainrotData.randomOfRarity(pickedRarity)
end

-- One line for the label above a brainrot: name, rarity and dollars a second.
function BrainrotData.labelText(member)
	return member.name .. "  |  " .. member.rarity .. "  |  $" .. member.income .. "/s"
end

return BrainrotData
