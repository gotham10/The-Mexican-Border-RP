local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local farmPosition = Vector3.new(-154, 14, 575)
local buyToolRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyTool")
local spatulaTemplate = ReplicatedStorage:WaitForChild("Tools"):WaitForChild("Spatula")

local farmingConnection = nil

local function startFarmingProcess(character)
    if farmingConnection then
        farmingConnection:Disconnect()
        farmingConnection = nil
    end

    local humanoid = character:WaitForChild("Humanoid")
    local rootPart = character:WaitForChild("HumanoidRootPart")

    humanoid.Seated:Connect(function(isSeated)
        if isSeated then
            humanoid.Sit = false
        end
    end)

    humanoid.Died:Connect(function()
        task.wait(12)
        local newCharacter = player.CharacterAdded:Wait()
        startFarmingProcess(newCharacter)
    end)

    local function tweenTo(targetPosition, lookAtPosition)
        if not rootPart or not rootPart.Parent then return end
        local goalCFrame = CFrame.new(targetPosition, lookAtPosition)
        local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = goalCFrame })
        tween:Play()
        tween.Completed:Wait()
    end

    local function hasSpatula()
        return player.Backpack:FindFirstChild("Spatula") or character:FindFirstChild("Spatula")
    end

    tweenTo(farmPosition, farmPosition - Vector3.new(0, 0, 1))

    if not hasSpatula() then
        buyToolRemote:FireServer(5, spatulaTemplate)
        player.Backpack:WaitForChild("Spatula", 10)
    end

    local spatulaTool = player.Backpack:FindFirstChild("Spatula")
    if spatulaTool then
        humanoid:EquipTool(spatulaTool)
    end

    local equippedSpatula = character:WaitForChild("Spatula", 10)
    if not equippedSpatula then
        return
    end

    local pattyPrompts = {}
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant:IsA("ProximityPrompt") and descendant.ObjectText == "Patty" then
            table.insert(pattyPrompts, descendant)
        end
    end

    farmingConnection = RunService.Heartbeat:Connect(function()
        if not character or not character.Parent or not character:FindFirstChild("Humanoid") or character:FindFirstChild("Humanoid").Health <= 0 then
            if farmingConnection then
                farmingConnection:Disconnect()
                farmingConnection = nil
            end
            return
        end
        
        if not character:FindFirstChild("Spatula") then
            return
        end

        for _, prompt in ipairs(pattyPrompts) do
            fireproximityprompt(prompt)
        end
    end)
end

local currentCharacter = player.Character or player.CharacterAdded:Wait()
startFarmingProcess(currentCharacter)
