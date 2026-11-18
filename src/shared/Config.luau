-- Brainrot Bazaar: every number the game balances on, in one place.
-- Server and client both read this module, so a tweak here retunes the
-- whole game instead of hunting the same number through many scripts.

local Config = {}

Config.GAME_NAME = "Brainrot Bazaar"
Config.START_CASH = 100
Config.SLOTS_PER_BASE = 6

-- The eight base plots, matching the pads laid out in default.project.json.
-- Each plot is 14 by 14 studs; its wall sits on the far side from the belt.
Config.PLOTS = {
	{ x = -20, z = -45, wall = Color3.fromRGB(217, 38, 51) },
	{ x = -20, z = -15, wall = Color3.fromRGB(242, 128, 26) },
	{ x = -20, z = 15, wall = Color3.fromRGB(242, 217, 38) },
	{ x = -20, z = 45, wall = Color3.fromRGB(38, 191, 64) },
	{ x = 20, z = -45, wall = Color3.fromRGB(38, 102, 242) },
	{ x = 20, z = -15, wall = Color3.fromRGB(153, 64, 230) },
	{ x = 20, z = 15, wall = Color3.fromRGB(242, 102, 179) },
	{ x = 20, z = 45, wall = Color3.fromRGB(38, 204, 217) },
}

-- Where an owned brainrot stands on its plot, relative to the plot centre.
-- Six pads in two rows of three, matching the slot parts in the project.
Config.SLOT_OFFSETS = {
	Vector3.new(-3.5, 0, -2.5),
	Vector3.new(0, 0, -2.5),
	Vector3.new(3.5, 0, -2.5),
	Vector3.new(-3.5, 0, 2.5),
	Vector3.new(0, 0, 2.5),
	Vector3.new(3.5, 0, 2.5),
}

-- The conveyor belt the brainrots walk along, from the green gate to the red.
Config.BELT_START_Z = -55
Config.BELT_END_Z = 55
Config.BELT_TOP_Y = 1
Config.BELT_WALK_SPEED = 4
Config.SPAWN_EVERY_SECONDS = 6
Config.MAX_ON_BELT = 8

-- Cash ticks once a second for every owned brainrot.
Config.INCOME_TICK_SECONDS = 1

-- Stealing: a base lock lasts this long, then the button needs this cooldown.
Config.LOCK_SECONDS = 20
Config.LOCK_COOLDOWN_SECONDS = 60

-- The Meme Wave: a warning, then a wall of water sweeps the map.
Config.WAVE_EVERY_SECONDS = 100
Config.WAVE_WARNING_SECONDS = 10
Config.WAVE_SWEEP_SECONDS = 9
Config.WAVE_START_Z = -70
Config.WAVE_END_Z = 70

-- Rebirth: pay cash, lose your brainrots, keep a permanent income boost.
Config.REBIRTH_BASE_COST = 25000
Config.REBIRTH_COST_GROWTH = 2
Config.REBIRTH_INCOME_BONUS = 0.25

-- How much cash a rebirth of this count costs.
function Config.rebirthCost(rebirths)
	return Config.REBIRTH_BASE_COST * (Config.REBIRTH_COST_GROWTH ^ rebirths)
end

-- The income multiplier a player keeps after this many rebirths.
function Config.rebirthMultiplier(rebirths)
	return 1 + Config.REBIRTH_INCOME_BONUS * rebirths
end

-- The centre of a plot, as a point on the ground.
function Config.plotCenter(plotIndex)
	local plot = Config.PLOTS[plotIndex]
	return Vector3.new(plot.x, 1, plot.z)
end

-- True when a point stands inside a plot's square.
function Config.pointInPlot(point, plotIndex)
	local plot = Config.PLOTS[plotIndex]
	return math.abs(point.X - plot.x) <= 7 and math.abs(point.Z - plot.z) <= 7
end

return Config
