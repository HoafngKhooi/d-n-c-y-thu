local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local TargetName = "hoafngkhooi"
local IsFollowing = true 
local IsSpammingF = true 

repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

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
            -- Ép tốc độ nhẹ nhàng
            if myHumanoid.WalkSpeed < 22 then myHumanoid.WalkSpeed = 22 end
            
            local dist = (myRoot.Position - targetRoot.Position).Magnitude
            
            -- Xoay mặt về phía mục tiêu để di chuyển đúng hướng
            myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
            
            if dist > 8 then
                -- Bám theo bằng cách giả lập phím W
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game)
                myHumanoid:MoveTo(targetRoot.Position)
            else
                -- Dừng phím W khi đã đến gần
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game)
                myHumanoid:MoveTo(myRoot.Position)
            end
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
