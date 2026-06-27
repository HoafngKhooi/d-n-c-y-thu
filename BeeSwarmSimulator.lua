-- Sử dụng loadstring chuẩn cho Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local isGliderEnabled = false
local canDoubleJump = false

-- Khởi tạo Window (Không cần gọi LoadInterface nữa)
local Window = Rayfield:CreateWindow({
   Name = "Glider Master",
   LoadingTitle = "Đang khởi tạo...",
   Theme = "Default"
})

local Tab = Window:CreateTab("Chức năng", nil)

Tab:CreateToggle({
   Name = "Bật Nhảy Dù (Double Jump)",
   CurrentValue = false,
   Callback = function(Value)
      isGliderEnabled = Value
   end,
})

-- Logic xử lý nhảy kép
UserInputService.JumpRequest:Connect(function()
    if not isGliderEnabled then return end
    
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    
    if humanoid and canDoubleJump then
        canDoubleJump = false 
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        
        -- Thông báo thay vì cố gắng Clone vật phẩm bị game chặn
        Rayfield:Notify({
            Title = "Nhảy kép!",
            Content = "Đã kích hoạt trạng thái dù.",
            Duration = 3,
        })
    end
end)

-- Cập nhật trạng thái khi ở trên không
player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Landed then
            canDoubleJump = false
        elseif newState == Enum.HumanoidStateType.Freefall then
            canDoubleJump = true
        end
    end)
end)
