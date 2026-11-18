-- Brainrot Bazaar: rebirth. Pay a growing pile of cash to start over richer:
-- your wallet resets to the starting cash, your base empties, and every
-- brainrot you ever buy after earns a permanent bonus. The ladder never ends.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local Economy = require(script.Parent:WaitForChild("Economy"))
local Bases = require(script.Parent:WaitForChild("Bases"))

local Rebirth = {}

-- Try to rebirth a player. Returns true and a message when it worked, or
-- false and the reason when the player cannot afford it yet.
function Rebirth.tryRebirth(player)
	local wallet = Economy.get(player)
	if not wallet then
		return false, "Kamu belum punya dompet."
	end
	local cost = Config.rebirthCost(wallet.rebirths)
	if wallet.cash < cost then
		return false, "Rebirth butuh $" .. cost .. ". Kamu punya $" .. wallet.cash .. "."
	end
	Economy.spendCash(player, cost)
	Bases.clearBase(player)
	wallet.cash = Config.START_CASH
	wallet.rebirths += 1
	local bonus = math.floor(Config.REBIRTH_INCOME_BONUS * wallet.rebirths * 100 + 0.5)
	return true, "REBIRTH #" .. wallet.rebirths .. "! Semua brainrotmu menghasilkan +" .. bonus .. "% selamanya."
end

return Rebirth
