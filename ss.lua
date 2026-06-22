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

-- Cập nhật lại phần khai báo Dropdown
local Dropdown = Tab:CreateDropdown({
    Name = "Chọn mục tiêu",
    Options = {"Đang tải..."}, -- Khởi tạo giá trị mặc định để tránh lỗi rỗng
    CurrentOption = nil,
    Callback = function(Option)
        -- Kiểm tra xem Option có phải là string không trước khi dùng
        if type(Option) == "string" then
            TargetPlayer = Players:FindFirstChild(Option)
        end
    end,
})

-- Hàm làm mới (Fix lỗi table)
local function UpdateDropdown()
    local newList = RefreshPlayerList()
    if #newList > 0 then
        Dropdown:Refresh(newList, true) -- Cập nhật danh sách mới
    else
        Dropdown:Refresh({"Không tìm thấy ai"}, false) -- Tránh truyền table trống
    end
end

-- Thay đổi Nút cập nhật thành:
Tab:CreateButton({
    Name = "Cập nhật danh sách",
    Callback = function()
        UpdateDropdown()
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
    if IsFollowing and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHumanoid = myChar and myChar:FindFirstChild("Humanoid")
        local targetRoot = TargetPlayer.Character.HumanoidRootPart
        
        if myRoot and myHumanoid then
            -- 1. Bỏ qua ma sát bằng cách tắt va chạm tạm thời
            for _, part in pairs(myChar:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0) -- Không ma sát, không nảy
                end
            end
            
            -- 2. Tính hướng và khoảng cách
            local diff = targetRoot.Position - myRoot.Position
            local direction = diff.Unit
            
            -- 3. Di chuyển bằng cách kết hợp Velocity và thay đổi hướng nhìn
            if diff.Magnitude > 5 then
                myRoot.AssemblyLinearVelocity = Vector3.new(direction.X * 30, myRoot.AssemblyLinearVelocity.Y, direction.Z * 30)
                myHumanoid.AutoRotate = false -- Tắt tự xoay để không bị giật khi di chuyển
                myRoot.CFrame = CFrame.new(myRoot.Position, Vector3.new(targetRoot.Position.X, myRoot.Position.Y, targetRoot.Position.Z))
            else
                myRoot.AssemblyLinearVelocity = Vector3.new(0, myRoot.AssemblyLinearVelocity.Y, 0)
                myHumanoid.AutoRotate = true
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
