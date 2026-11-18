-- Brainrot Bazaar: the money. This module owns every player's cash and
-- rebirth count, ticks the income every second, and tells the client the new
-- numbers. It reads what a player owns from Bases, and nothing else owns cash.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local Bases = require(script.Parent:WaitForChild("Bases"))

local Players = game:GetService("Players")

local Economy = {}
local data = {}

-- Give a joining player a fresh wallet and no rebirths.
function Economy.newPlayer(player)
	data[player.UserId] = { cash = Config.START_CASH, rebirths = 0 }
end

-- Forget a leaving player's wallet.
function Economy.removePlayer(player)
	data[player.UserId] = nil
end

-- The wallet table for a player, or nil when the player has none.
function Economy.get(player)
	return data[player.UserId]
end

-- Add cash, for income and for rewards. Never goes below zero by itself.
function Economy.addCash(player, amount)
	local wallet = data[player.UserId]
	if wallet then
		wallet.cash += amount
	end
end

-- Pay an amount when the player can afford it. Returns true when it paid.
function Economy.spendCash(player, amount)
	local wallet = data[player.UserId]
	if not wallet or wallet.cash < amount then
		return false
	end
	wallet.cash -= amount
	return true
end

-- What this player earns every second: every owned brainrot's rate, boosted
-- by the permanent multiplier their rebirths earned.
function Economy.incomePerSecond(player)
	local wallet = data[player.UserId]
	if not wallet then
		return 0
	end
	local total = 0
	for _, member in ipairs(Bases.ownedMembers(player)) do
		total += member.income
	end
	return math.floor(total * Config.rebirthMultiplier(wallet.rebirths) + 0.5)
end

-- Start the one-second tick: pay everyone their income, then push their new
-- numbers to their client through the callback init.server.luau gave us.
function Economy.startIncomeLoop(pushState)
	task.spawn(function()
		while true do
			task.wait(Config.INCOME_TICK_SECONDS)
			for userId, wallet in pairs(data) do
				local player = Players:GetPlayerByUserId(userId)
				if player then
					local income = Economy.incomePerSecond(player)
					wallet.cash += income
					pushState(player)
				end
			end
		end
	end)
end

return Economy
