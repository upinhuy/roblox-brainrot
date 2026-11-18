-- Brainrot Bazaar: the Meme Wave. Every couple of minutes a wall of water
-- sweeps the map from one end to the other. A player carrying a stolen
-- brainrot must be home on their own base when the wall reaches them, or the
-- catch slips away and swims back to its first owner.

local Config = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("Config"))
local Bases = require(script.Parent:WaitForChild("Bases"))
local Steal = require(script.Parent:WaitForChild("Steal"))

local RunService = game:GetService("RunService")

local Hazard = {}
local sweeping = false
local announceFn = nil

-- Sweep one wave across the map, dropping every carrier the wall catches
-- outside their own base.
local function runSweep()
	if sweeping then
		return
	end
	sweeping = true

	local wall = Instance.new("Part")
	wall.Name = "MemeWave"
	wall.Size = Vector3.new(140, 14, 4)
	wall.Color = Color3.fromRGB(50, 130, 255)
	wall.Material = Enum.Material.Neon
	wall.Transparency = 0.3
	wall.Anchored = true
	wall.CanCollide = false
	wall.CFrame = CFrame.new(0, 7, Config.WAVE_START_Z)
	wall.Parent = game:GetService("Workspace")

	local startTime = os.clock()
	local connection
	connection = RunService.Heartbeat:Connect(function()
		local passed = os.clock() - startTime
		local progress = math.min(1, passed / Config.WAVE_SWEEP_SECONDS)
		local waveZ = Config.WAVE_START_Z + (Config.WAVE_END_Z - Config.WAVE_START_Z) * progress
		wall.CFrame = CFrame.new(0, 7, waveZ)
		for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
			if not Steal.isCarrying(player) then
				continue
			end
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not root then
				continue
			end
			local plotIndex = Bases.plotOf(player)
			local home = plotIndex and Config.pointInPlot(root.Position, plotIndex)
			if not home and root.Position.Z <= waveZ then
				Steal.dropCarried(player)
				if announceFn then
					announceFn(player, "Gelombang Meme merampas curianmu!", 4)
				end
			end
		end
		if progress >= 1 then
			connection:Disconnect()
			wall:Destroy()
			sweeping = false
			if announceFn then
				announceFn(nil, "Gelombang Meme berlalu. Aman... untuk sekarang.", 4)
			end
		end
	end)
end

-- Start the wave clock: warn the map, then sweep, again and again.
function Hazard.start(announce)
	announceFn = announce
	task.spawn(function()
		while true do
			task.wait(Config.WAVE_EVERY_SECONDS)
			announce(nil, "GELOMBANG MEME DATANG! Lari pulang ke basemu!", Config.WAVE_WARNING_SECONDS)
			task.wait(Config.WAVE_WARNING_SECONDS)
			runSweep()
		end
	end)
end

-- Run one wave right now, for the reviewer tour. Skips the long wait.
function Hazard.startWaveNow()
	task.spawn(function()
		if announceFn then
			announceFn(nil, "GELOMBANG MEME DATANG! Lari pulang ke basemu!", 3)
		end
		task.wait(2)
		runSweep()
	end)
end

return Hazard
