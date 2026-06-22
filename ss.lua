local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local TargetName = "hoafngkhooi"
local IsFollowing = true -- Mặc định bật để bạn test luôn
local IsSpammingF = true -- Mặc định bật để bạn test luôn

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
            -- Ép tốc độ
            if myHumanoid.WalkSpeed < 22 then myHumanoid.WalkSpeed = 22 end
            
            -- Tắt va chạm
            for _, part in pairs(myChar:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            
            local dist = (myRoot.Position - targetRoot.Position).Magnitude
            if dist > 6 then
                myHumanoid:MoveTo(targetRoot.Position)
                
                -- Logic chống kẹt thông minh (dùng delta time dt)
                if (myRoot.Position - lastPos).Magnitude < 0.5 then
                    stuckTime = stuckTime + dt
                else
                    stuckTime = 0
                end
                
                if stuckTime > 2 then -- Nếu kẹt quá 2 giây
                    myHumanoid.Jump = true
                    stuckTime = 0
                end
                lastPos = myRoot.Position
            else
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
