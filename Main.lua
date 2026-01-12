-- Serviços
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- CONFIG
local DESTINO_INICIAL = Vector3.new(3313.6, 4.2, 3025.0)
local VELOCIDADE_INICIAL = 100
local VELOCIDADE_NPC = 50
local RAIO_INTERACAO = 15
local DELAY_LOOP = 2 -- tempo entre ciclos

-- Função: Tween até posição
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

-- Função: Interagir com ProximityPrompt mais próximo
local function interactNearestPrompt()
	local nearestPrompt
	local shortest = math.huge

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("ProximityPrompt") and obj.Enabled then
			local part = obj.Parent:IsA("BasePart") and obj.Parent
				or obj.Parent:FindFirstChildWhichIsA("BasePart")

			if part then
				local dist = (hrp.Position - part.Position).Magnitude
				if dist < shortest and dist <= RAIO_INTERACAO then
					shortest = dist
					nearestPrompt = obj
				end
			end
		end
	end

	if nearestPrompt then
		fireproximityprompt(nearestPrompt)
	end
end

-- Função: Encontrar NPC spawnado nas pads
local function getSpawnedNPC()
	local folder = workspace:WaitForChild("Construcoes")
		:WaitForChild("Pizzaria")
		:WaitForChild("OrderCharSpawns")

	for _, pad in ipairs(folder:GetChildren()) do
		for _, model in ipairs(workspace:GetChildren()) do
			if model:IsA("Model") and model:FindFirstChild("Humanoid") then
				local root = model:FindFirstChild("HumanoidRootPart")
				if root and (root.Position - pad.Position).Magnitude < 8 then
					return model
				end
			end
		end
	end
end

-- LOOP PRINCIPAL
while task.wait(DELAY_LOOP) do
	pcall(function()
		-- Atualiza character caso morra
		character = player.Character or player.CharacterAdded:Wait()
		hrp = character:WaitForChild("HumanoidRootPart")

		-- 1️⃣ Ir até posição inicial
		tweenTo(DESTINO_INICIAL, VELOCIDADE_INICIAL)

		task.wait(0.5)

		-- 2️⃣ Interagir com item
		interactNearestPrompt()

		task.wait(1)

		-- 3️⃣ Procurar NPC
		local npc = getSpawnedNPC()

		-- 4️⃣ Ir até o NPC
		if npc and npc:FindFirstChild("HumanoidRootPart") then
			tweenTo(npc.HumanoidRootPart.Position, VELOCIDADE_NPC)
		end
	end)
end
