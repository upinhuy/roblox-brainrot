-- Brainrot Bazaar: builds the little character models that walk the belt and
-- stand on the bases. One job only: turn a cast member into a Model with a
-- body, a head, eyes, a readable label and a ClickDetector. The modules that
-- own the belt and the bases both build through here, so every brainrot in
-- the game looks the same way.

local BrainrotData = require(game:GetService("ReplicatedStorage"):WaitForChild("Shared"):WaitForChild("BrainrotData"))

local BrainrotFactory = {}

-- Build a brainrot model for a cast member and tag it with its identity.
-- The model starts floating at the origin; the caller moves it where it goes.
function BrainrotFactory.build(member, uid)
	local model = Instance.new("Model")
	model.Name = member.name

	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(member.size, member.size, member.size)
	body.Color = member.color
	body.Material = Enum.Material.SmoothPlastic
	body.Anchored = true
	body.CanCollide = false
	body.Parent = model

	local head = Instance.new("Part")
	head.Name = "Head"
	head.Size = Vector3.new(member.size * 0.62, member.size * 0.62, member.size * 0.62)
	head.Color = member.color
	head.Material = Enum.Material.SmoothPlastic
	head.Anchored = true
	head.CanCollide = false
	head.CFrame = CFrame.new(0, member.size * 0.78, 0)
	head.Parent = model

	for _, side in ipairs({ -1, 1 }) do
		local eye = Instance.new("Part")
		eye.Name = "Eye"
		eye.Size = Vector3.new(member.size * 0.14, member.size * 0.2, member.size * 0.1)
		eye.Color = Color3.fromRGB(20, 20, 20)
		eye.Material = Enum.Material.SmoothPlastic
		eye.Anchored = true
		eye.CanCollide = false
		eye.CFrame = CFrame.new(side * member.size * 0.16, member.size * 0.82, member.size * 0.52)
		eye.Parent = model
	end

	local label = Instance.new("BillboardGui")
	label.Name = "Label"
	label.Size = UDim2.fromOffset(240, 64)
	label.ExtentsOffsetWorldSpace = Vector3.new(0, member.size * 0.9 + 1.5, 0)
	label.AlwaysOnTop = true
	label.MaxDistance = 250
	label.Adornee = body
	label.Parent = body

	local text = Instance.new("TextLabel")
	text.Name = "Text"
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
	text.BackgroundTransparency = 0.35
	text.TextColor3 = BrainrotData.RARITY_COLORS[member.rarity]
	text.Font = Enum.Font.GothamBold
	text.TextScaled = true
	text.Text = BrainrotData.labelText(member)
	text.Parent = label

	local clicker = Instance.new("ClickDetector")
	clicker.Name = "ClickDetector"
	clicker.MaxActivationDistance = 32
	clicker.Parent = body

	model.PrimaryPart = body
	model:SetAttribute("Uid", uid)
	model:SetAttribute("MemberId", member.id)
	model:SetAttribute("State", "belt")
	model:SetAttribute("OwnerUserId", 0)
	return model, clicker
end

-- Move a built model so its feet rest on the ground at this point.
function BrainrotFactory.placeOnGround(model, position, member)
	local half = member.size / 2
	model:PivotTo(CFrame.new(position.X, position.Y + half, position.Z))
end

return BrainrotFactory
