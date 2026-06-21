local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "My Helper Script",
    LoadingTitle = "Đang khởi tạo...",
    LoadingSubtitle = "by Gemini",
})

local Tab = Window:CreateTab("Chức năng chính", nil)

-- 1. Biến quản lý
local TargetPlayer = nil
local IsFollowing = false
local IsSpammingF = false

-- 2. Lấy danh sách người chơi
local PlayerList = {}
for _, player in pairs(game.Players:GetPlayers()) do
    if player.Name ~= game.Players.LocalPlayer.Name then
        table.insert(PlayerList, player.Name)
    end
end

-- 3. Menu chọn người chơi
local Dropdown = Tab:CreateDropdown({
    Name = "Chọn người chơi để theo dõi",
    Options = PlayerList,
    CurrentOption = nil,
    Callback = function(Option)
        TargetPlayer = game.Players:FindFirstChild(Option)
    end,
})

Tab:CreateToggle({
    Name = "Bật/Tắt chế độ Đi theo",
    CurrentValue = false,
    Callback = function(Value)
        IsFollowing = Value
    end,
})

-- 4. Cơ chế Đi theo (Cập nhật liên tục)
game:GetService("RunService").RenderStepped:Connect(function()
    if IsFollowing and TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myChar = game.Players.LocalPlayer.Character
        if myChar then
            myChar.HumanoidRootPart.CFrame = TargetPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end)

-- 5. Cơ chế nhấn phím F liên tục (Giả lập input)
Tab:CreateToggle({
    Name = "Tự động nhấn phím F",
    CurrentValue = false,
    Callback = function(Value)
        IsSpammingF = Value
        task.spawn(function()
            while IsSpammingF do
                game:GetService("VirtualInputManager"):SendKeyEvent(true, Enum.KeyCode.F, false, game)
                task.wait(0.1) -- Thời gian nghỉ để tránh bị lag server
                game:GetService("VirtualInputManager"):SendKeyEvent(false, Enum.KeyCode.F, false, game)
                task.wait(0.5) -- Tùy chỉnh tốc độ nhấn tại đây
            end
        end)
    end,
})