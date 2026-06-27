local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Khởi tạo MasterControl
local MasterControl = require(player:WaitForChild("PlayerScripts"):WaitForChild("ControlScript"):WaitForChild("MasterControl"))

-- Biến điều khiển
_G.DoubleJumpEnabled = false
local canDoubleJump = false

-- 1. Setup UI Rayfield
local Window = Rayfield:CreateWindow({
   Name = "Glider Master Pro",
   LoadingTitle = "Đang tải hệ thống...",
   Theme = "Default"
})

local Tab = Window:CreateTab("Chức năng", nil)

Tab:CreateToggle({
   Name = "Bật Nhảy Kép (Double Jump)",
   CurrentValue = false,
   Callback = function(Value)
      _G.DoubleJumpEnabled = Value
   end,
})

-- 2. Logic Nhảy kép
UserInputService.JumpRequest:Connect(function()
    if not _G.DoubleJumpEnabled then return end
    
    local humanoid = MasterControl:GetHumanoid()
    if not humanoid then return end

    if humanoid:GetState() == Enum.HumanoidStateType.Freefall and canDoubleJump then
        canDoubleJump = false 
        MasterControl:DoJump() 
        
        Rayfield:Notify({
            Title = "Thành công",
            Content = "Đã thực hiện Double Jump!",
            Duration = 2,
        })
    end
end)

-- 3. Reset trạng thái khi tiếp đất
local function setupCharacter(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Landed then
            canDoubleJump = true 
        end
    end)
end

-- Đăng ký sự kiện nhân vật
player.CharacterAdded:Connect(setupCharacter)
if player.Character then setupCharacter(player.Character) end

Rayfield:Notify({
    Title = "Hệ thống sẵn sàng",
    Content = "Hãy bật toggle để bắt đầu nhảy kép.",
    Duration = 5,
})
