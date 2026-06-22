local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local TargetName = "hoafngkhooi"
local IsFollowing = true 
local IsSpammingF = true 

repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

RunService.Heartbeat:Connect(function(dt)
    if not IsFollowing then return end
    
    local TargetPlayer = Players:FindFirstChild(TargetName)
    local myChar = LocalPlayer.Character
    if not (TargetPlayer and TargetPlayer.Character and myChar) then return end
    
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local targetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myHumanoid = myChar:FindFirstChild("Humanoid")
    
    if myRoot and targetRoot and myHumanoid then
        -- 1. Tính toán vị trí bám sát sau lưng (Offset 3 stud)
        local offset = targetRoot.CFrame.LookVector * -3 
        local targetBehind = targetRoot.Position + offset
        
        -- 2. ĐIỀU KHIỂN CHUẨN (Không dùng CFrame để tránh loạn xạ)
        local dist = (myRoot.Position - targetBehind).Magnitude
        
        if dist > 2 then
            -- Chỉ dùng MoveTo khi khoảng cách > 2 stud để không bị giật
            myHumanoid:MoveTo(targetBehind)
            
            -- Ép tốc độ chạy cao hơn bình thường để bám kịp
            myHumanoid.WalkSpeed = 26
        else
            -- Khi đã tới nơi, dừng MoveTo để nhân vật đứng yên, tránh bị trôi
            myHumanoid:MoveTo(myRoot.Position)
        end
        
        -- 3. Khóa góc nhìn mượt mà (Dùng lerp để không bị giật camera)
        local targetLookAt = CFrame.new(Camera.CFrame.Position, targetRoot.Position)
        Camera.CFrame = Camera.CFrame:Lerp(targetLookAt, 0.1)
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
