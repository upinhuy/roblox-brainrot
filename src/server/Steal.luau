-- Brainrot Bazaar: stealing. This module owns the carry: click a brainrot on
-- someone else's open base to lift it, run it home over your head, and drop
-- it on your own plot to keep it. A locked base cannot be stolen from, and a
-- carrier caught outside their own base by the Meme Wave drops the catch.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local Bases = require(script.Parent:WaitForChild("Bases"))
local Conveyor = require(script.Parent:WaitForChild("Conveyor"))

local RunService = game:GetService("RunService")

local Steal = {}
local carrying = {}

-- Lift a brainrot off another player's open base and carry it home. Fails
-- when it is yours, its base is locked, your hands are full, or your base is.
function Steal.trySteal(player, uid)
	local found = Bases.findBrainrot(uid)
	if not found or not found.owner then
		return false, "Brainrot itu sudah tidak di base siapa pun."
	end
	if found.owner == player then
		return false, "Itu brainrotmu sendiri."
	end
	if Bases.isLocked(found.owner) then
		return false, "Base " .. found.owner.DisplayName .. " sedang terkunci!"
	end
	if carrying[player.UserId] then
		return false, "Kamu sudah membawa satu brainrot. Antar dulu ke basemu."
	end
	if not Bases.freeSlotIndex(player) then
		return false, "Basemu penuh. Kosongkan satu slot dulu."
	end
	local entry = Bases.removeFromSlot(found.owner, uid)
	if not entry then
		return false, "Brainrot itu sudah tidak di sana."
	end
	entry.model:SetAttribute("State", "carried")
	carrying[player.UserId] = {
		uid = uid,
		member = entry.member,
		fromUserId = found.owner.UserId,
		model = entry.model,
	}
	return true, "Kamu mencuri " .. entry.member.name .. "! Lari pulang ke basemu!"
end

-- Set a carried brainrot down on the carrier's own base and keep it.
function Steal.tryDeliver(player)
	local load = carrying[player.UserId]
	if not load then
		return false
	end
	local slot = Bases.placeOnSlot(player, load.uid, load.member, load.model)
	if not slot then
		return false
	end
	carrying[player.UserId] = nil
	return true
end

-- Drop what a carrier holds: back to its first owner's free slot, or onto
-- the belt when that base has no room left.
function Steal.dropCarried(player)
	local load = carrying[player.UserId]
	if not load then
		return false
	end
	carrying[player.UserId] = nil
	local owner = game:GetService("Players"):GetPlayerByUserId(load.fromUserId)
	if owner and Bases.placeOnSlot(owner, load.uid, load.member, load.model) then
		return true
	end
	Conveyor.putOnBelt(load.uid, load.member, load.model)
	return true
end

-- True while a player carries a stolen brainrot.
function Steal.isCarrying(player)
	return carrying[player.UserId] ~= nil
end

-- Start the carry loop: hold every carried brainrot over its carrier's head,
-- and set it down the moment the carrier steps onto their own plot. The
-- deliveries are collected first and applied after the sweep, so the table
-- under the loop is never changed while it is read.
function Steal.start()
	RunService.Heartbeat:Connect(function()
		local toDeliver = {}
		for userId, load in pairs(carrying) do
			local player = game:GetService("Players"):GetPlayerByUserId(userId)
			local character = player and player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if root then
				load.model:PivotTo(CFrame.new(root.Position + Vector3.new(0, 5, 0)))
				local plotIndex = Bases.plotOf(player)
				if plotIndex and Config.pointInPlot(root.Position, plotIndex) then
					table.insert(toDeliver, player)
				end
			end
		end
		for _, player in ipairs(toDeliver) do
			Steal.tryDeliver(player)
		end
	end)
end

return Steal
