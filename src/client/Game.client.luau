-- Brainrot Bazaar: the client. It draws the HUD over the 3D world: cash and
-- income up top, the lock and rebirth buttons at the bottom, and the event
-- banner in the middle. It never owns game state; the server sends the
-- numbers, and this script only shows them and fires the player's choices.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"))

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("BrainrotRemotes")
local lockRemote = remotes:WaitForChild("LockBase")
local rebirthRemote = remotes:WaitForChild("Rebirth")
local stateRemote = remotes:WaitForChild("StateUpdate")
local announceRemote = remotes:WaitForChild("Announce")

local gui = Instance.new("ScreenGui")
gui.Name = "BrainrotHud"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function money(amount)
	local text = tostring(math.floor(amount))
	local out = ""
	while #text > 3 do
		out = "." .. text:sub(-3) .. out
		text = text:sub(1, -4)
	end
	return "$" .. text .. out
end

-- The bar across the top centre: cash, income a second, rebirth bonus.
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.AnchorPoint = Vector2.new(0.5, 0)
topBar.Position = UDim2.new(0.5, 0, 0, 12)
topBar.Size = UDim2.fromOffset(480, 92)
topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
topBar.BackgroundTransparency = 0.25
topBar.BorderSizePixel = 0
topBar.Parent = gui

local cashLabel = Instance.new("TextLabel")
cashLabel.Name = "Cash"
cashLabel.Size = UDim2.new(1, 0, 0, 44)
cashLabel.BackgroundTransparency = 1
cashLabel.TextColor3 = Color3.fromRGB(255, 220, 60)
cashLabel.Font = Enum.Font.GothamBlack
cashLabel.TextSize = 34
cashLabel.Text = "$100"
cashLabel.Parent = topBar

local incomeLabel = Instance.new("TextLabel")
incomeLabel.Name = "Income"
incomeLabel.Position = UDim2.new(0, 0, 0, 44)
incomeLabel.Size = UDim2.new(1, 0, 0, 24)
incomeLabel.BackgroundTransparency = 1
incomeLabel.TextColor3 = Color3.fromRGB(120, 255, 140)
incomeLabel.Font = Enum.Font.GothamBold
incomeLabel.TextSize = 20
incomeLabel.Text = "+$0/detik"
incomeLabel.Parent = topBar

local rebirthLabel = Instance.new("TextLabel")
rebirthLabel.Name = "Rebirth"
rebirthLabel.Position = UDim2.new(0, 0, 0, 68)
rebirthLabel.Size = UDim2.new(1, 0, 0, 22)
rebirthLabel.BackgroundTransparency = 1
rebirthLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
rebirthLabel.Font = Enum.Font.Gotham
rebirthLabel.TextSize = 16
rebirthLabel.Text = "Rebirth x0  •  +0%"
rebirthLabel.Parent = topBar

-- The banner under the top bar: wave warnings and purchase news.
local banner = Instance.new("TextLabel")
banner.Name = "Banner"
banner.AnchorPoint = Vector2.new(0.5, 0)
banner.Position = UDim2.new(0.5, 0, 0, 116)
banner.Size = UDim2.fromOffset(680, 56)
banner.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
banner.BackgroundTransparency = 0.2
banner.TextColor3 = Color3.fromRGB(255, 255, 255)
banner.Font = Enum.Font.GothamBlack
banner.TextSize = 26
banner.TextWrapped = true
banner.Visible = false
banner.Parent = gui

-- The bar across the bottom centre: lock, rebirth and the base count.
local bottomBar = Instance.new("Frame")
bottomBar.Name = "BottomBar"
bottomBar.AnchorPoint = Vector2.new(0.5, 1)
bottomBar.Position = UDim2.new(0.5, 1, 1, -12)
bottomBar.Size = UDim2.fromOffset(620, 64)
bottomBar.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
bottomBar.BackgroundTransparency = 0.25
bottomBar.BorderSizePixel = 0
bottomBar.Parent = gui

local lockButton = Instance.new("TextButton")
lockButton.Name = "LockButton"
lockButton.Position = UDim2.fromOffset(10, 10)
lockButton.Size = UDim2.fromOffset(180, 44)
lockButton.BackgroundColor3 = Color3.fromRGB(40, 110, 255)
lockButton.TextColor3 = Color3.fromRGB(255, 255, 255)
lockButton.Font = Enum.Font.GothamBold
lockButton.TextSize = 20
lockButton.Text = "KUNCI BASE (L)"
lockButton.Parent = bottomBar

local rebirthButton = Instance.new("TextButton")
rebirthButton.Name = "RebirthButton"
rebirthButton.Position = UDim2.fromOffset(200, 10)
rebirthButton.Size = UDim2.fromOffset(230, 44)
rebirthButton.BackgroundColor3 = Color3.fromRGB(160, 60, 220)
rebirthButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rebirthButton.Font = Enum.Font.GothamBold
rebirthButton.TextSize = 20
rebirthButton.Text = "REBIRTH (R)"
rebirthButton.Parent = bottomBar

local countLabel = Instance.new("TextLabel")
countLabel.Name = "Count"
countLabel.Position = UDim2.fromOffset(440, 10)
countLabel.Size = UDim2.fromOffset(170, 44)
countLabel.BackgroundTransparency = 1
countLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
countLabel.Font = Enum.Font.GothamBold
countLabel.TextSize = 20
countLabel.Text = "Base: 0/6"
countLabel.Parent = bottomBar

-- A small how-to line along the bottom left, clear of the menu corner.
local helpLabel = Instance.new("TextLabel")
helpLabel.Name = "Help"
helpLabel.AnchorPoint = Vector2.new(0, 1)
helpLabel.Position = UDim2.new(0, 12, 1, -84)
helpLabel.Size = UDim2.fromOffset(560, 44)
helpLabel.BackgroundTransparency = 1
helpLabel.TextXAlignment = Enum.TextXAlignment.Left
helpLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
helpLabel.Font = Enum.Font.Gotham
helpLabel.TextSize = 16
helpLabel.TextWrapped = true
helpLabel.Text = "Klik brainrot di belt untuk membeli. Klik brainrot orang lain untuk mencuri. Lari pulang saat Gelombang Meme datang!"
helpLabel.Parent = gui

-- The how-to line fades away after a while, so it never crowds the screen.
task.delay(20, function()
	helpLabel.Visible = false
end)

local bannerHideAt = 0

-- Show a banner for a few seconds, then hide it again.
local function showBanner(text, seconds)
	banner.Text = text
	banner.Visible = true
	bannerHideAt = os.clock() + seconds
	task.delay(seconds, function()
		if os.clock() >= bannerHideAt then
			banner.Visible = false
		end
	end)
end

stateRemote.OnClientEvent:Connect(function(state)
	cashLabel.Text = money(state.cash)
	incomeLabel.Text = "+" .. money(state.income) .. "/detik"
	local bonus = math.floor(Config.REBIRTH_INCOME_BONUS * state.rebirths * 100 + 0.5)
	rebirthLabel.Text = "Rebirth x" .. state.rebirths .. "  •  +" .. bonus .. "%"
	countLabel.Text = "Base: " .. state.count .. "/" .. Config.SLOTS_PER_BASE
	rebirthButton.Text = "REBIRTH (R) — " .. money(Config.rebirthCost(state.rebirths))
	if state.cash >= Config.rebirthCost(state.rebirths) then
		rebirthButton.BackgroundColor3 = Color3.fromRGB(160, 60, 220)
	else
		rebirthButton.BackgroundColor3 = Color3.fromRGB(90, 90, 110)
	end
	if state.lockLeft > 0 then
		lockButton.Text = "TERKUNCI (" .. state.lockLeft .. "s)"
		lockButton.BackgroundColor3 = Color3.fromRGB(40, 180, 80)
	elseif state.cooldownLeft > 0 then
		lockButton.Text = "KUNCI (" .. state.cooldownLeft .. "s)"
		lockButton.BackgroundColor3 = Color3.fromRGB(90, 90, 110)
	else
		lockButton.Text = "KUNCI BASE (L)"
		lockButton.BackgroundColor3 = Color3.fromRGB(40, 110, 255)
	end
end)

announceRemote.OnClientEvent:Connect(function(text, seconds)
	showBanner(text, seconds)
end)

lockButton.MouseButton1Click:Connect(function()
	lockRemote:FireServer()
end)

rebirthButton.MouseButton1Click:Connect(function()
	rebirthRemote:FireServer()
end)

-- The arrow keys steer the camera and the character in Roblox, so the extra
-- shortcuts use L and R instead, and they never fire while the player is
-- typing in a textbox or a menu has the input.
local function onLockKey(_, inputState, gameProcessed)
	if inputState == Enum.UserInputState.Begin and not gameProcessed then
		lockRemote:FireServer()
	end
end

local function onRebirthKey(_, inputState, gameProcessed)
	if inputState == Enum.UserInputState.Begin and not gameProcessed then
		rebirthRemote:FireServer()
	end
end

ContextActionService:BindAction("BrainrotLock", onLockKey, false, Enum.KeyCode.L)
ContextActionService:BindAction("BrainrotRebirth", onRebirthKey, false, Enum.KeyCode.R)
