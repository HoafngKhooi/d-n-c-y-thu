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
                myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z))
                local dir = (targetPos - myRoot.Position).Unit
                myHumanoid:Move(dir, true)
                if myHumanoid.MoveDirection.Magnitude == 0 then myHumanoid.Jump = true end
            else
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
