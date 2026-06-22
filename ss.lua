local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Window = Rayfield:CreateWindow({Name = "Helper Script - Pro Edition", LoadingTitle = "Khởi tạo...", LoadingSubtitle = "by Gemini"})
local Tab = Window:CreateTab("Chức năng chính", nil)

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

-- Hàm hỗ trợ
local function PressKey(key, state) VirtualInputManager:SendKeyEvent(state, key, false, game) end

-- Logic RenderStepped đã tối ưu (Thêm cơ chế chống kẹt)
RunService.RenderStepped:Connect(function()
    if IsFollowing and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local targetRoot = TargetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local myHumanoid = myChar and myChar:FindFirstChild("Humanoid")

        if myRoot and targetRoot and myHumanoid then
            -- 1. Bật xuyên người (Tắt va chạm với người chơi khác) để đi theo không bị đẩy
            for _, part in pairs(myChar:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end

            -- 2. Xoay và Di chuyển
            local targetPos = targetRoot.Position
            local lookAt = CFrame.new(myRoot.Position, Vector3.new(targetPos.X, myRoot.Position.Y, targetPos.Z))
            myRoot.CFrame = myRoot.CFrame:Lerp(lookAt, 0.2)

            local distance = (myRoot.Position - targetPos).Magnitude
            
            -- Thay phần if distance > 6 ở trên thành:
            if distance > 6 then
                PressKey(Enum.KeyCode.W, true)
                if myHumanoid.MoveDirection.Magnitude == 0 then myHumanoid.Jump = true end
            else
                PressKey(Enum.KeyCode.W, false)
                -- Khi đủ gần, xóa lực di chuyển để nhân vật đứng yên thay vì trôi
                myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0) 
            end
        end
    else
        PressKey(Enum.KeyCode.W, false)
    end
end)

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
