local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local TargetName = "hoafngkhooi"
local IsFollowing = true -- Mặc định bật để bạn test luôn
local IsSpammingF = true -- Mặc định bật để bạn test luôn

-- [VỊ TRÍ GẮN ĐOẠN CHỜ LOAD VÀO ĐÂY]
repeat task.wait() until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
print("Script đã load thành công trong Map!")

local function PressKey(key, state) VirtualInputManager:SendKeyEvent(state, key, false, game) end

local lastPos = Vector3.new(0, 0, 0)
local stuckTime = 0

RunService.Heartbeat:Connect(function(dt)
    if not IsFollowing then return end
    
    local TargetPlayer = Players:FindFirstChild(TargetName)
    local myChar = LocalPlayer.Character
    
    if TargetPlayer and TargetPlayer.Character and myChar then
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHumanoid = myChar:FindFirstChild("Humanoid")
        
        if myRoot and targetRoot and myHumanoid then
            -- 1. Ép tốc độ và Animation
            if myHumanoid.WalkSpeed < 22 then myHumanoid.WalkSpeed = 22 end
            
            local dist = (myRoot.Position - targetRoot.Position).Magnitude
            if dist > 6 then
                local direction = (targetRoot.Position - myRoot.Position).Unit
                
                -- 2. Dịch chuyển CFrame để đi nhanh
                myRoot.CFrame = myRoot.CFrame + (direction * 0.3) -- Tăng lên 0.3 cho mượt hơn
                
                -- 3. QUAN TRỌNG: Gọi lệnh Move để kích hoạt Animation
                myHumanoid:Move(direction, true) 
                
                -- 4. Ép hướng nhìn
                myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
            else
                myHumanoid:Move(Vector3.new(0,0,0), false)
            end
        end
    end
end)

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
