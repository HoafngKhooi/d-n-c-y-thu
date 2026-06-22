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
        -- 1. Tính toán vị trí "Sau lưng" (Offset)
        -- Nhân vật đứng sau lưng đối phương 3 stud
        local offset = targetRoot.CFrame.LookVector * -3 
        local behindPos = targetRoot.Position + offset
        
        -- 2. Khóa góc nhìn vào đối phương
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
        
        -- 3. Ép tốc độ
        if myHumanoid.WalkSpeed < 24 then myHumanoid.WalkSpeed = 24 end
        
        -- 4. Di chuyển bám theo vị trí bù (behindPos)
        local dist = (myRoot.Position - behindPos).Magnitude
        if dist > 2 then -- Chỉ đi khi khoảng cách lớn hơn 2 stud để tránh bị rung giật
            myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
            myHumanoid:MoveTo(behindPos)
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
