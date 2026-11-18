-- Brainrot Bazaar: the server entry point. It builds the world, opens the
-- remote events the client talks through, hands every joining player a wallet
-- and a base, and starts the belt, the stealing, the wave and the income
-- tick. All game state lives in the modules; this script only wires them up.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local World = require(script.Parent:WaitForChild("World"))
local Bases = require(script.Parent:WaitForChild("Bases"))
local Economy = require(script.Parent:WaitForChild("Economy"))
local Conveyor = require(script.Parent:WaitForChild("Conveyor"))
local Steal = require(script.Parent:WaitForChild("Steal"))
local Hazard = require(script.Parent:WaitForChild("Hazard"))
local Rebirth = require(script.Parent:WaitForChild("Rebirth"))
local Tour = require(script.Parent:WaitForChild("Tour"))

World.build()

local remotes = Instance.new("Folder")
remotes.Name = "BrainrotRemotes"
remotes.Parent = ReplicatedStorage

local lockRemote = Instance.new("RemoteEvent")
lockRemote.Name = "LockBase"
lockRemote.Parent = remotes

local rebirthRemote = Instance.new("RemoteEvent")
rebirthRemote.Name = "Rebirth"
rebirthRemote.Parent = remotes

local stateRemote = Instance.new("RemoteEvent")
stateRemote.Name = "StateUpdate"
stateRemote.Parent = remotes

local announceRemote = Instance.new("RemoteEvent")
announceRemote.Name = "Announce"
announceRemote.Parent = remotes

-- Send one player their fresh numbers: cash, income, brainrots, rebirths,
-- and where their lock button stands.
local function pushState(player)
	local wallet = Economy.get(player)
	if not wallet then
		return
	end
	stateRemote:FireClient(player, {
		cash = wallet.cash,
		income = Economy.incomePerSecond(player),
		count = Bases.ownedCount(player),
		rebirths = wallet.rebirths,
		lockLeft = math.floor(Bases.lockSecondsLeft(player) + 0.5),
		cooldownLeft = math.floor(Bases.lockCooldownLeft(player) + 0.5),
	})
end

-- Show a banner: to one player when given one, or to everyone when nil.
local function announce(target, text, seconds)
	if target then
		announceRemote:FireClient(target, text, seconds)
	else
		announceRemote:FireAllClients(text, seconds)
	end
end

-- One click on a brainrot means different things by where it stands: on the
-- belt it is a purchase, on someone else's base it is a steal attempt, and
-- on your own base it is just yours.
local function onBrainrotClicked(player, model)
	local state = model:GetAttribute("State")
	local uid = model:GetAttribute("Uid")
	if state == "belt" then
		local ok, message = Conveyor.tryBuy(player, uid)
		announce(player, message, 4)
		if ok then
			pushState(player)
		end
	elseif state == "owned" then
		local ownerId = model:GetAttribute("OwnerUserId")
		if ownerId == player.UserId then
			announce(player, "Itu brainrotmu. Ia menghasilkan uang setiap detik.", 3)
		else
			local ok, message = Steal.trySteal(player, uid)
			announce(player, message, 4)
			if ok then
				pushState(player)
			end
		end
	end
end

-- A joining player gets a wallet, the first free base, and their numbers.
local function onPlayerAdded(player)
	Economy.newPlayer(player)
	local plot = Bases.assignPlot(player)
	pushState(player)
	if plot then
		announce(player, "Selamat datang di Brainrot Bazaar! Klik brainrot di belt untuk membeli.", 6)
	else
		announce(player, "Semua base penuh. Kamu bisa menonton dulu sampai ada yang kosong.", 6)
	end
end

-- A leaving player hands their stolen catch back, empties their base, and
-- gives their plot and wallet up.
local function onPlayerRemoving(player)
	Steal.dropCarried(player)
	Bases.clearBase(player)
	Bases.freePlot(player)
	Economy.removePlayer(player)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end

lockRemote.OnServerEvent:Connect(function(player)
	if Bases.lockBase(player) then
		announce(player, "Basemu terkunci 20 detik. Tidak ada yang bisa mencuri!", 4)
	else
		announce(player, "Tombol kunci masih dingin. Tunggu sebentar.", 3)
	end
	pushState(player)
end)

rebirthRemote.OnServerEvent:Connect(function(player)
	local ok, message = Rebirth.tryRebirth(player)
	announce(player, message, 5)
	pushState(player)
end)

Conveyor.start(onBrainrotClicked)
Steal.start()
Hazard.start(announce)
Economy.startIncomeLoop(pushState)
Tour.init(onBrainrotClicked)

print("Brainrot Bazaar is running.")
