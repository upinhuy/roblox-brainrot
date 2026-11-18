-- Brainrot Bazaar: the reviewer tour. TOUR.json names these functions so a
-- reviewer in Studio can jump straight to each screenshot: a rare brainrot
-- on the belt, the Meme Wave sweeping in, and a rich endgame base. They only
-- ever run when the tour calls them; the game itself never does.

local BrainrotData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("BrainrotData"))
local BrainrotFactory = require(script.Parent:WaitForChild("BrainrotFactory"))
local Bases = require(script.Parent:WaitForChild("Bases"))
local Conveyor = require(script.Parent:WaitForChild("Conveyor"))
local Economy = require(script.Parent:WaitForChild("Economy"))
local Hazard = require(script.Parent:WaitForChild("Hazard"))

local HttpService = game:GetService("HttpService")

local Tour = {}
local clickCallback = nil

-- Remember the click dispatch so tour-spawned brainrots can be bought too.
function Tour.init(onClicked)
	clickCallback = onClicked
end

-- Roll a brainrot of the named rarity onto the belt, for the play screenshot.
function Tour.spawnBrainrot(rarity)
	local member = BrainrotData.randomOfRarity(rarity)
	Conveyor.spawnBrainrot(member, clickCallback)
	return member.name
end

-- Bring the Meme Wave in now, for the hazard screenshot.
function Tour.startWave()
	Hazard.startWaveNow()
	return "wave"
end

-- Make the first player in the game rich: a pile of cash and three Legendary
-- brainrots standing on their base, for the end screenshot.
function Tour.grantRebirth(_arg)
	local players = game:GetService("Players"):GetPlayers()
	local player = players[1]
	if not player then
		return "nobody here"
	end
	Economy.addCash(player, 100000)
	local legends = {}
	for _, member in ipairs(BrainrotData.CAST) do
		if member.rarity == "Legendary" then
			table.insert(legends, member)
		end
	end
	for i = 1, 3 do
		local member = legends[((i - 1) % #legends) + 1]
		local uid = HttpService:GenerateGUID(false)
		local model = BrainrotFactory.build(member, uid)
		model.Parent = game:GetService("Workspace")
		Bases.placeOnSlot(player, uid, member, model)
	end
	return "rich"
end

return Tour
