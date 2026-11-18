-- Brainrot Bazaar: the conveyor belt. This module rolls new brainrots out of
-- the green gate, walks them down the middle of the map, and sells them to
-- the first player who clicks one and can pay. A brainrot that reaches the
-- red gate without a buyer walks off and is gone.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local BrainrotData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("BrainrotData"))
local BrainrotFactory = require(script.Parent:WaitForChild("BrainrotFactory"))
local Economy = require(script.Parent:WaitForChild("Economy"))
local Bases = require(script.Parent:WaitForChild("Bases"))

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Conveyor = {}
local belt = {}
local folder = nil
local clickCallback = nil

-- Roll a fresh brainrot onto the belt at the green gate and hook its click
-- up to the dispatch init.server.luau gave us. Returns its id.
function Conveyor.spawnBrainrot(member, onClicked)
	local uid = HttpService:GenerateGUID(false)
	local model, detector = BrainrotFactory.build(member, uid)
	BrainrotFactory.placeOnGround(model, Vector3.new(0, Config.BELT_TOP_Y, Config.BELT_START_Z), member)
	model.Parent = folder
	detector.MouseClick:Connect(function(clickingPlayer)
		onClicked(clickingPlayer, model)
	end)
	belt[uid] = { member = member, model = model, z = Config.BELT_START_Z }
	return uid
end

-- Put a brainrot that fell off a base back on the belt, walking from the gate.
function Conveyor.putOnBelt(uid, member, model)
	model:SetAttribute("State", "belt")
	model:SetAttribute("OwnerUserId", 0)
	BrainrotFactory.placeOnGround(model, Vector3.new(0, Config.BELT_TOP_Y, Config.BELT_START_Z), member)
	model.Parent = folder
	belt[uid] = { member = member, model = model, z = Config.BELT_START_Z }
end

-- Sell the brainrot on the belt to a player who clicks it. Fails when the
-- brainrot is gone, the player is broke, or their base is full.
function Conveyor.tryBuy(player, uid)
	local entry = belt[uid]
	if not entry then
		return false, "Brainrot itu sudah pergi."
	end
	local member = entry.member
	if not Economy.spendCash(player, member.price) then
		return false, "Uangmu tidak cukup untuk " .. member.name .. " ($" .. member.price .. ")."
	end
	if not Bases.freeSlotIndex(player) then
		Economy.addCash(player, member.price)
		return false, "Basemu penuh. Kosongkan satu slot dulu."
	end
	belt[uid] = nil
	local slot = Bases.placeOnSlot(player, uid, member, entry.model)
	if not slot then
		Economy.addCash(player, member.price)
		return false, "Basemu penuh."
	end
	return true, "Kamu membeli " .. member.name .. " seharga $" .. member.price .. "!"
end

-- Start the belt: roll a new brainrot out every few seconds, and walk every
-- brainrot on it toward the red gate until it is bought or walks off.
function Conveyor.start(onClicked)
	clickCallback = onClicked
	folder = Instance.new("Folder")
	folder.Name = "BeltBrainrots"
	folder.Parent = game:GetService("Workspace")

	task.spawn(function()
		while true do
			task.wait(Config.SPAWN_EVERY_SECONDS)
			local count = 0
			for _ in pairs(belt) do
				count += 1
			end
			if count < Config.MAX_ON_BELT then
				Conveyor.spawnBrainrot(BrainrotData.rollRandom(), clickCallback)
			end
		end
	end)

	RunService.Heartbeat:Connect(function(dt)
		for uid, entry in pairs(belt) do
			entry.z += Config.BELT_WALK_SPEED * dt
			if entry.z >= Config.BELT_END_Z then
				entry.model:Destroy()
				belt[uid] = nil
			else
				entry.model:PivotTo(CFrame.new(0, Config.BELT_TOP_Y + entry.member.size / 2, entry.z))
			end
		end
	end)
end

return Conveyor
