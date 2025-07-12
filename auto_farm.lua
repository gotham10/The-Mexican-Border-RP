local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local grillTop = workspace:WaitForChild("Commercial Grill"):WaitForChild("Grill Cooking Top")

local buyToolRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("BuyTool")
local spatulaTemplate = ReplicatedStorage:WaitForChild("Tools"):WaitForChild("Spatula")

local function tweenTo(targetPosition, lookAtPosition)
    local goalCFrame = CFrame.new(targetPosition, lookAtPosition)
    local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = goalCFrame})
    tween:Play()
    tween.Completed:Wait()
end

local function hasSpatula()
    return player.Backpack:FindFirstChild("Spatula") or character:FindFirstChild("Spatula")
end

if grillTop then
    local grillCFrame = grillTop.CFrame
    local targetPosition = grillCFrame.Position + (grillCFrame.LookVector * 5)
    tweenTo(targetPosition, grillCFrame.Position)
end

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

RunService.Heartbeat:Connect(function()
    if not character:FindFirstChild("Spatula") then
        return
    end

    for _, prompt in ipairs(pattyPrompts) do
        fireproximityprompt(prompt)
    end
end)
