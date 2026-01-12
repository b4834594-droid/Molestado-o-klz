-- Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- CONFIG
local DESTINO_INICIAL = Vector3.new(3313.6, 4.2, 3025.0)
local VELOCIDADE_INICIAL = 100
local VELOCIDADE_NPC = 50
local DELAY_LOOP = 2

-- Atualizar personagem
local function getCharacter()
	local char = player.Character or player.CharacterAdded:Wait()
	local hum = char:WaitForChild("Humanoid")
	local hrp = char:WaitForChild("HumanoidRootPart")
	return char, hum, hrp
end

local character, humanoid, hrp = getCharacter()

-- 🔒 ANTI-SIT
local function antiSit(hum)
	hum.Sit = false
	hum:GetPropertyChangedSignal("Sit"):Connect(function()
		if hum.Sit then
			hum.Sit = false
		end
	end)
end

antiSit(humanoid)

player.CharacterAdded:Connect(function(char)
	task.wait(1)
	antiSit(char:WaitForChild("Humanoid"))
end)

-- Tween
local function tweenTo(pos, speed)
	local distance = (hrp.Position - pos).Magnitude
	local time = distance / speed

	local tween = TweenService:Create(
		hrp,
		TweenInfo.new(time, Enum.EasingStyle.Linear),
		{CFrame = CFrame.new(pos)}
	)

	tween:Play()
	tween.Completed:Wait()
end

-- 🔍 Detectar OrderChar spawnado
local function getSpawnedNPC()
	local spawnsFolder = workspace
		:WaitForChild("Construcoes")
		:WaitForChild("Pizzaria")
		:WaitForChild("OrderCharSpawns")

	for _, pad in ipairs(spawnsFolder:GetChildren()) do
		local orderChar = pad:FindFirstChild("OrderChar")
		if orderChar and orderChar:IsA("Model") then
			local hum = orderChar:FindFirstChild("Humanoid")
			local root = orderChar:FindFirstChild("HumanoidRootPart")

			if hum and root and hum.Health > 0 then
				return orderChar
			end
		end
	end
end

-- 🖐️ Interagir com ProximityPrompt do NPC
local function interactNPC(npc)
	for _, obj in ipairs(npc:GetDescendants()) do
		if obj:IsA("ProximityPrompt") and obj.Enabled then
			fireproximityprompt(obj)
			return true
		end
	end
	return false
end

-- 🔁 LOOP
while task.wait(DELAY_LOOP) do
	pcall(function()
		character, humanoid, hrp = getCharacter()
		humanoid.Sit = false

		-- 1️⃣ Ir até posição inicial
		tweenTo(DESTINO_INICIAL, VELOCIDADE_INICIAL)
		task.wait(0.5)

		-- 2️⃣ Detectar NPC
		local npc = getSpawnedNPC()
		if not npc then return end

		-- 3️⃣ Ir até NPC
		tweenTo(npc.HumanoidRootPart.Position, VELOCIDADE_NPC)
		task.wait(0.4)

		-- 4️⃣ Interagir com NPC
		interactNPC(npc)
	end)
end
