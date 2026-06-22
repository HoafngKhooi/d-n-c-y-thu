local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local TargetName = "hoafngkhooi"
local IsFollowing = true 
local IsSpammingF = true 

-- Chờ character sẵn sàng
repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

local function GetTarget()
    for _, player in pairs(Players:GetPlayers()) do
        -- Kiểm tra cả Name (Username) và DisplayName
        if string.find(string.lower(player.Name), string.lower(TargetName)) or 
           string.find(string.lower(player.DisplayName), string.lower(TargetName)) then
            return player
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    if not IsFollowing then return end
    
    local TargetPlayer = GetTarget() -- Dùng hàm tìm kiếm thông minh
    local myChar = LocalPlayer.Character
    
    if TargetPlayer and TargetPlayer.Character and myChar then
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHumanoid = myChar:FindFirstChild("Humanoid")
        
        if myRoot and targetRoot and myHumanoid then
            -- Tăng WalkSpeed nhẹ nhàng (22 là mức an toàn tuyệt đối cho mọi game)
            if myHumanoid.WalkSpeed < 22 then myHumanoid.WalkSpeed = 22 end
            
            -- Tính khoảng cách
            local dist = (myRoot.Position - targetRoot.Position).Magnitude
            
            -- Chỉ di chuyển nếu cách xa quá 8 stud (khoảng cách đi bộ mặc định)
            if dist > 8 then
                myHumanoid:MoveTo(targetRoot.Position)
            else
                -- Khi đã gần, không gọi MoveTo liên tục để tránh bị "trượt"
                myHumanoid:MoveTo(myRoot.Position)
            end
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
