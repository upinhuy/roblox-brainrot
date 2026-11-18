-- Brainrot Bazaar: the bases. This module owns the eight plots, who stands on
-- which one, the six slots of each plot, and the lock that guards a base from
-- thieves. Every brainrot a player owns lives in a slot here, so income,
-- stealing and rebirth all read the same table.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local World = require(script.Parent:WaitForChild("World"))

local Bases = {}
local playerPlot = {}
local slots = {}
local locks = {}

for i = 1, #Config.PLOTS do
	slots[i] = {}
end

-- Hand a joining player the first empty plot. Returns its number, or nil
-- when all eight plots are taken.
function Bases.assignPlot(player)
	for i = 1, #Config.PLOTS do
		local taken = false
		for _, plotIndex in pairs(playerPlot) do
			if plotIndex == i then
				taken = true
				break
			end
		end
		if not taken then
			playerPlot[player.UserId] = i
			World.setSignOwner(i, player.DisplayName)
			return i
		end
	end
	return nil
end

-- Give a leaving player's plot back, clearing its sign.
function Bases.freePlot(player)
	local plotIndex = playerPlot[player.UserId]
	if plotIndex then
		playerPlot[player.UserId] = nil
		World.setSignOwner(plotIndex, "BASE " .. plotIndex)
	end
end

-- The plot number a player owns, or nil when they own none.
function Bases.plotOf(player)
	return playerPlot[player.UserId]
end

-- The first empty slot number on a player's plot, or nil when it is full.
function Bases.freeSlotIndex(player)
	local plotIndex = playerPlot[player.UserId]
	if not plotIndex then
		return nil
	end
	for i = 1, Config.SLOTS_PER_BASE do
		if not slots[plotIndex][i] then
			return i
		end
	end
	return nil
end

-- The ground point of a slot, where a brainrot's feet rest.
function Bases.slotPosition(plotIndex, slotIndex, member)
	local plot = Config.PLOTS[plotIndex]
	local offset = Config.SLOT_OFFSETS[slotIndex]
	return Vector3.new(plot.x + offset.X, 1.3, plot.z + offset.Z)
end

-- Set a brainrot down on a player's first free slot and mark it owned.
-- Returns the slot number, or nil when the player has no plot or no room.
function Bases.placeOnSlot(player, uid, member, model)
	local plotIndex = playerPlot[player.UserId]
	if not plotIndex then
		return nil
	end
	local slotIndex = Bases.freeSlotIndex(player)
	if not slotIndex then
		return nil
	end
	local ground = Bases.slotPosition(plotIndex, slotIndex, member)
	model:PivotTo(CFrame.new(ground.X, ground.Y + member.size / 2, ground.Z))
	model:SetAttribute("State", "owned")
	model:SetAttribute("OwnerUserId", player.UserId)
	slots[plotIndex][slotIndex] = { uid = uid, member = member, model = model, ownerUserId = player.UserId }
	return slotIndex
end

-- Lift a brainrot out of a player's slot and hand its member and model back.
-- Returns nil when that brainrot is not on this player's base.
function Bases.removeFromSlot(player, uid)
	local plotIndex = playerPlot[player.UserId]
	if not plotIndex then
		return nil
	end
	for i = 1, Config.SLOTS_PER_BASE do
		local entry = slots[plotIndex][i]
		if entry and entry.uid == uid then
			slots[plotIndex][i] = nil
			return entry
		end
	end
	return nil
end

-- Find a brainrot by its id on any base, with its owner and slot.
function Bases.findBrainrot(uid)
	for plotIndex = 1, #Config.PLOTS do
		for slotIndex = 1, Config.SLOTS_PER_BASE do
			local entry = slots[plotIndex][slotIndex]
			if entry and entry.uid == uid then
				local owner = game:GetService("Players"):GetPlayerByUserId(entry.ownerUserId)
				return { owner = owner, plotIndex = plotIndex, slotIndex = slotIndex, member = entry.member, model = entry.model }
			end
		end
	end
	return nil
end

-- Every cast member standing on a player's base.
function Bases.ownedMembers(player)
	local found = {}
	local plotIndex = playerPlot[player.UserId]
	if not plotIndex then
		return found
	end
	for i = 1, Config.SLOTS_PER_BASE do
		local entry = slots[plotIndex][i]
		if entry then
			table.insert(found, entry.member)
		end
	end
	return found
end

-- How many brainrots stand on a player's base.
function Bases.ownedCount(player)
	return #Bases.ownedMembers(player)
end

-- Destroy every brainrot on a player's base, for a rebirth or a goodbye.
function Bases.clearBase(player)
	local plotIndex = playerPlot[player.UserId]
	if not plotIndex then
		return
	end
	for i = 1, Config.SLOTS_PER_BASE do
		local entry = slots[plotIndex][i]
		if entry then
			entry.model:Destroy()
			slots[plotIndex][i] = nil
		end
	end
end

-- Lock a player's base against thieves. Fails while the button cools down.
function Bases.lockBase(player)
	local now = os.clock()
	local lock = locks[player.UserId]
	if lock and now < lock.cooldownUntil then
		return false
	end
	locks[player.UserId] = {
		lockedUntil = now + Config.LOCK_SECONDS,
		cooldownUntil = now + Config.LOCK_SECONDS + Config.LOCK_COOLDOWN_SECONDS,
	}
	return true
end

-- True while a base's lock is still up.
function Bases.isLocked(player)
	local lock = locks[player.UserId]
	return lock ~= nil and os.clock() < lock.lockedUntil
end

-- Seconds of lock left, or zero when the base stands open.
function Bases.lockSecondsLeft(player)
	local lock = locks[player.UserId]
	if not lock then
		return 0
	end
	return math.max(0, lock.lockedUntil - os.clock())
end

-- Seconds before the lock button works again, or zero when it is ready.
function Bases.lockCooldownLeft(player)
	local lock = locks[player.UserId]
	if not lock then
		return 0
	end
	return math.max(0, lock.cooldownUntil - os.clock())
end

return Bases
