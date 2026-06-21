local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Helper Script - Pro Edition",
    LoadingTitle = "Đang khởi tạo...",
    LoadingSubtitle = "by Gemini",
})

local Tab = Window:CreateTab("Chức năng chính", nil)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local TargetPlayer = nil
local IsFollowing = false
local IsSpammingF = false

-- Hàm lấy danh sách người chơi
local function RefreshPlayerList()
    local list = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    return list
end

local Dropdown = Tab:CreateDropdown({
    Name = "Chọn mục tiêu",
    Options = RefreshPlayerList(),
    Callback = function(Option)
        TargetPlayer = Players:FindFirstChild(Option)
    end,
})

Tab:CreateButton({
    Name = "Cập nhật danh sách",
    Callback = function()
        Dropdown:Refresh(RefreshPlayerList(), true)
    end,
})

Tab:CreateToggle({
    Name = "Theo dõi mục tiêu",
    CurrentValue = false,
    Callback = function(Value)
        IsFollowing = Value
    end,
})

RunService.Heartbeat:Connect(function()
    if IsFollowing and TargetPlayer and TargetPlayer.Character then
        local targetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if targetRoot and myRoot then
            -- Tính toán hướng đi tới mục tiêu
            local direction = (targetRoot.Position - myRoot.Position).Unit
            local distance = (targetRoot.Position - myRoot.Position).Magnitude
            
            if distance > 4 then
                -- Cách 1: Dùng Velocity (tác động lực đẩy nhân vật)
                -- Cách này giúp nhân vật "lao" tới mục tiêu ngay cả khi bị khóa CFrame
                myRoot.AssemblyLinearVelocity = direction * 30 -- Số 30 là tốc độ, bạn có thể tăng lên nếu muốn nhanh hơn
            else
                -- Khi sát mục tiêu thì dừng lại để không bị đè lên nhau
                myRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)

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
