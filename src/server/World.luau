-- Brainrot Bazaar: the dressing. This module builds the decor the project
-- file does not lay out: trees and lamps around the map, the name signs on
-- each base, and the two big billboards by the spawn. Everything it builds
-- appears when the server starts, before the first player walks in.

local Workspace = game:GetService("Workspace")

local World = {}
local signLabels = {}

local TREE_SPOTS = {
	Vector3.new(-45, 0, -70),
	Vector3.new(-60, 0, -30),
	Vector3.new(-45, 0, 30),
	Vector3.new(-60, 0, 70),
	Vector3.new(45, 0, -70),
	Vector3.new(60, 0, -30),
	Vector3.new(45, 0, 30),
	Vector3.new(60, 0, 70),
	Vector3.new(-35, 0, 88),
	Vector3.new(35, 0, 88),
}

local LAMP_SPOTS = {
	Vector3.new(-10, 0, -50),
	Vector3.new(10, 0, -50),
	Vector3.new(-10, 0, -25),
	Vector3.new(10, 0, -25),
	Vector3.new(-10, 0, 0),
	Vector3.new(10, 0, 0),
	Vector3.new(-10, 0, 25),
	Vector3.new(10, 0, 25),
	Vector3.new(-10, 0, 50),
	Vector3.new(10, 0, 50),
}

-- Grow one tree: a trunk and two round leaf balls.
local function growTree(spot, index)
	local folder = Instance.new("Folder")
	folder.Name = "Tree" .. index
	folder.Parent = Workspace

	local trunk = Instance.new("Part")
	trunk.Name = "Trunk"
	trunk.Size = Vector3.new(1.5, 6, 1.5)
	trunk.Color = Color3.fromRGB(120, 75, 40)
	trunk.Material = Enum.Material.SmoothPlastic
	trunk.Anchored = true
	trunk.CFrame = CFrame.new(spot + Vector3.new(0, 3, 0))
	trunk.Parent = folder

	local leaves = Instance.new("Part")
	leaves.Name = "Leaves"
	leaves.Shape = Enum.PartType.Ball
	leaves.Size = Vector3.new(6, 6, 6)
	if index % 2 == 0 then
		leaves.Color = Color3.fromRGB(30, 130, 200)
	else
		leaves.Color = Color3.fromRGB(40, 160, 70)
	end
	leaves.Material = Enum.Material.SmoothPlastic
	leaves.Anchored = true
	leaves.CFrame = CFrame.new(spot + Vector3.new(0, 8, 0))
	leaves.Parent = folder

	local top = Instance.new("Part")
	top.Name = "TopLeaves"
	top.Shape = Enum.PartType.Ball
	top.Size = Vector3.new(4, 4, 4)
	top.Color = Color3.fromRGB(70, 200, 90)
	top.Material = Enum.Material.SmoothPlastic
	top.Anchored = true
	top.CFrame = CFrame.new(spot + Vector3.new(0, 11, 0))
	top.Parent = folder
end

-- Raise one lamp: a pole with a glowing head.
local function raiseLamp(spot, index)
	local folder = Instance.new("Folder")
	folder.Name = "Lamp" .. index
	folder.Parent = Workspace

	local pole = Instance.new("Part")
	pole.Name = "Pole"
	pole.Size = Vector3.new(0.6, 7, 0.6)
	pole.Color = Color3.fromRGB(60, 60, 70)
	pole.Material = Enum.Material.SmoothPlastic
	pole.Anchored = true
	pole.CFrame = CFrame.new(spot + Vector3.new(0, 3.5, 0))
	pole.Parent = folder

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(2, 1, 2)
	head.Color = Color3.fromRGB(255, 230, 120)
	head.Material = Enum.Material.Neon
	head.Anchored = true
	head.CFrame = CFrame.new(spot + Vector3.new(0, 7.2, 0))
	head.Parent = folder
end

-- Hang a text sign on a part, facing the given side of it.
local function hangSign(part, face, text, textColor)
	local gui = Instance.new("SurfaceGui")
	gui.Name = "SignGui"
	gui.Face = face
	gui.Parent = part
	local label = Instance.new("TextLabel")
	label.Name = "Text"
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.TextColor3 = textColor
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Text = text
	label.Parent = gui
	return label
end

-- Build all the decor: trees, lamps, base signs and billboards.
function World.build()
	for i, spot in ipairs(TREE_SPOTS) do
		growTree(spot, i)
	end
	for i, spot in ipairs(LAMP_SPOTS) do
		raiseLamp(spot, i)
	end
	for plotIndex = 1, 8 do
		local sign = Workspace:FindFirstChild("Plot" .. plotIndex .. "Sign")
		if sign then
			local face = Enum.NormalId.Right
			if plotIndex > 4 then
				face = Enum.NormalId.Left
			end
			signLabels[plotIndex] = hangSign(sign, face, "BASE " .. plotIndex, Color3.fromRGB(20, 20, 20))
		end
	end
	local board1 = Workspace:FindFirstChild("Billboard1Panel")
	if board1 then
		hangSign(board1, Enum.NormalId.Back, "BRAINROT BAZAAR", Color3.fromRGB(255, 220, 60))
	end
	local board2 = Workspace:FindFirstChild("Billboard2Panel")
	if board2 then
		hangSign(board2, Enum.NormalId.Back, "BELI - KUMPUL - CURI - REBIRTH", Color3.fromRGB(255, 255, 255))
	end
end

-- Write a new owner name on a base's sign.
function World.setSignOwner(plotIndex, text)
	local label = signLabels[plotIndex]
	if label then
		label.Text = text
	end
end

return World
