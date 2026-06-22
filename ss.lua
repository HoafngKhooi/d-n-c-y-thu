Local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({Name = "Helper Script - Pro Edition", LoadingTitle = "Khởi tạo...", LoadingSubtitle = "by Gemini"})
local Tab = Window:CreateTab("Chức năng chính", nil)

local TargetName = "hoafngkhooi" -- Tên người bạn muốn bám theo cố định
local IsFollowing = false
local IsSpammingF = false

-- Hàm nhấn phím
local function PressKey(key, state) VirtualInputManager:SendKeyEvent(state, key, false, game) end

-- Logic bám theo cố định
RunService.Heartbeat:Connect(function()
    if not IsFollowing then 
        PressKey(Enum.KeyCode.W, false) -- Thả phím W khi tắt Follow
        return 
    end
    
    local TargetPlayer = Players:FindFirstChild(TargetName)
    local myChar = LocalPlayer.Character
        
    if TargetPlayer and TargetPlayer.Character and myChar then
        local myRoot = myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHumanoid = myChar:FindFirstChild("Humanoid")
        
        if myRoot and targetRoot and myHumanoid then
            -- 1. Bật xuyên người
            for _, part in pairs(myChar:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            
            -- 2. Tính toán và di chuyển
            local targetPos = targetRoot.Position
            local dist = (myRoot.Position - targetPos).Magnitude
            
            if dist > 6 then
                -- Xoay hướng
                myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z))
                -- Di chuyển
                local dir = (targetPos - myRoot.Position).Unit
                myHumanoid:Move(dir, true)
                -- Chống kẹt
                if myHumanoid.MoveDirection.Magnitude == 0 then myHumanoid.Jump = true end
            else
                myHumanoid:Move(Vector3.new(0,0,0), false)
            end
        end
    end
end)

-- Giao diện đơn giản hóa
Tab:CreateToggle({
    Name = "Theo dõi hoafngkhooi",
    CurrentValue = false,
    Callback = function(Value) IsFollowing = Value end,
})

-- Cơ chế nhấn F (Đã tối ưu)
Tab:CreateToggle({
    Name = "Tự động nhấn F",
    CurrentValue = false,
    Callback = function(Value)
        IsSpammingF = Value
        if IsSpammingF then
            task.spawn(function()
                while IsSpammingF do
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    task.wait(0.1)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                    task.wait(math.random(4, 8) / 10) -- Random delay giúp giống người thật hơn
                end
            end)
        end
    end,
})
