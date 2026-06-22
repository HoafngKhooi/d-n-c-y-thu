local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local TargetName = "hoafngkhooi"
local IsFollowing = true 
local IsSpammingF = true 

repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

RunService.RenderStepped:Connect(function()
    if not IsFollowing then return end
    
    local TargetPlayer = Players:FindFirstChild(TargetName)
    local myChar = LocalPlayer.Character
    if not (TargetPlayer and TargetPlayer.Character and myChar) then return end
    
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myHumanoid = myChar:FindFirstChild("Humanoid")
    
    if myRoot and targetRoot and myHumanoid then
        -- 1. KHÓA GÓC NHÌN (Lock Camera)
        -- Tự động xoay Camera theo mục tiêu
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
        
        -- 2. ĐI BỘ NHANH (Bypass tốc độ)
        if myHumanoid.WalkSpeed < 24 then myHumanoid.WalkSpeed = 24 end
        
        -- 3. DI CHUYỂN TỰ NHIÊN (Giữ nguyên Animation)
        local dist = (myRoot.Position - targetRoot.Position).Magnitude
        if dist > 6 then
            -- Ép nhân vật nhìn về phía mục tiêu
            myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
            -- Lệnh MoveTo chuẩn giữ animation
            myHumanoid:MoveTo(targetRoot.Position)
        else
            myHumanoid:MoveTo(myRoot.Position)
        end
    end
end)

-- Auto F giữ nguyên
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
