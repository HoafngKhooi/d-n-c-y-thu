local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = Players.LocalPlayer

local TargetName = "hoafngkhooi"
local IsFollowing = true 
local IsSpammingF = true 

repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

-- [TẮT HỆ THỐNG CỦA GAME]
for _, object in pairs(CollectionService:GetTagged("Movement")) do
    CollectionService:RemoveTag(object, "Movement")
end

local function GetTarget()
    for _, player in pairs(Players:GetPlayers()) do
        if string.find(string.lower(player.Name), string.lower(TargetName)) or 
           string.find(string.lower(player.DisplayName), string.lower(TargetName)) then
            return player
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    if not IsFollowing then return end
    local TargetPlayer = GetTarget()
    local myChar = LocalPlayer.Character
    if TargetPlayer and TargetPlayer.Character and myChar then
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHumanoid = myChar:FindFirstChild("Humanoid")
        if myRoot and targetRoot and myHumanoid then
            -- Giờ đây bạn có toàn quyền kiểm soát vì hệ thống game đã bị "tắt"
            myHumanoid.WalkSpeed = 22
            myHumanoid:MoveTo(targetRoot.Position)
        end
    end
end)

-- Auto F
task.spawn(function()
    while true do
        if IsSpammingF then
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
            task.wait(0.1)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
            task.wait(math.random(4, 8) / 10)
        end
        task.wait(0.1)
    end
end)
