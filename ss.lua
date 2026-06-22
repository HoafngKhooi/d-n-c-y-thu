local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local TargetName = "hoafngkhooi"
local IsFollowing = true -- Mặc định bật để bạn test luôn
local IsSpammingF = true -- Mặc định bật để bạn test luôn

local function PressKey(key, state) VirtualInputManager:SendKeyEvent(state, key, false, game) end

-- Logic bám theo
RunService.Heartbeat:Connect(function()
    if not IsFollowing then return end
    
    local TargetPlayer = Players:FindFirstChild(TargetName)
    local myChar = LocalPlayer.Character
    if TargetPlayer and TargetPlayer.Character and myChar then
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHumanoid = myChar:FindFirstChild("Humanoid")
        
        if myRoot and targetRoot and myHumanoid then
            for _, part in pairs(myChar:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            
            local targetPos = targetRoot.Position
            local dist = (myRoot.Position - targetPos).Magnitude
            if dist > 6 then
                -- 1. Xoay hướng
                myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z))
                
                -- 2. Ép WalkSpeed (Đây là cách tăng tốc độ nhân vật nhanh nhất)
                if myHumanoid.WalkSpeed < 50 then 
                    myHumanoid.WalkSpeed = 50 -- Ép tốc độ chạy (Đừng để quá 100)
                end
                
                -- 3. Đẩy vận tốc cực đại
                local dir = (targetPos - myRoot.Position).Unit
                local speed = 60 -- Mức tối đa thử nghiệm
                myRoot.AssemblyLinearVelocity = Vector3.new(dir.X * speed, myRoot.AssemblyLinearVelocity.Y, dir.Z * speed)
                
                -- Ép Humanoid di chuyển
                myHumanoid:Move(dir, true)
                
                -- 4. Chống kẹt
                if myHumanoid.MoveDirection.Magnitude == 0 and dist > 6 then 
                    myHumanoid.Jump = true 
                end
            else
                -- Reset WalkSpeed về bình thường khi dừng
                if myHumanoid.WalkSpeed > 16 then myHumanoid.WalkSpeed = 16 end
                myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                myHumanoid:Move(Vector3.new(0,0,0), false)
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
