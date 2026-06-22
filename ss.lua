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

local TweenService = game:GetService("TweenService")

-- Hàm Teleport giả lập (Đi bộ mượt)
local function TeleportToPlayer(target)
    if not target or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local targetPos = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    
    -- Tính toán tốc độ: quãng đường càng xa thì thời gian di chuyển càng lâu
    local distance = (myRoot.Position - targetPos.Position).Magnitude
    local speed = 50 -- Tốc độ di chuyển (studs/giây), chỉnh số này để tăng/giảm tốc độ
    local timeToTravel = distance / speed
    
    local tweenInfo = TweenInfo.new(
        timeToTravel, 
        Enum.EasingStyle.Linear, 
        Enum.EasingDirection.Out
    )
    
    local tween = TweenService:Create(myRoot, tweenInfo, {CFrame = targetPos})
    tween:Play()
end

-- Sử dụng nó trong vòng lặp (giữ cập nhật mỗi 0.5s để đuổi theo)
task.spawn(function()
    while true do
        task.wait(0.5) 
        if IsFollowing and TargetPlayer then
            TeleportToPlayer(TargetPlayer)
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
