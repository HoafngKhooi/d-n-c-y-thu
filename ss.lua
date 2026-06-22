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
        -- 1. Tính toán vị trí SAU LƯNG mục tiêu 3 stud
        local offset = targetRoot.CFrame.LookVector * -3 
        local targetBehind = targetRoot.Position + offset
        
        -- 2. Ép Camera nhìn về mục tiêu
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
        
        -- 3. Bám sát bằng CFrame (Di chuyển cực nhanh và chuẩn)
        local dist = (myRoot.Position - targetBehind).Magnitude
        if dist > 1 then -- Nếu cách quá 1 stud là bám ngay
            -- Xoay nhân vật về hướng mục tiêu
            myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
            
            -- Ép nhân vật nhích về phía vị trí sau lưng mục tiêu
            local direction = (targetBehind - myRoot.Position).Unit
            myRoot.CFrame = myRoot.CFrame + (direction * 0.5)
            
            -- Gọi Move để giữ Animation
            myHumanoid:Move(direction, true)
        end
        
        -- 4. Ép tốc độ chạy (chỉ để đảm bảo không bị khựng)
        if myHumanoid.WalkSpeed < 26 then myHumanoid.WalkSpeed = 26 end
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
