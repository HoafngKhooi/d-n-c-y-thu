local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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
      _G.isGliderEnabled = Value
   end,
})

local UIS = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer

UIS.JumpRequest:Connect(function()
    if not _G.isGliderEnabled then return end
    local char = player.Character
    local hum = char and char:FindFirstChild("Humanoid")
    if hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        Rayfield:Notify({Title = "Đã nhảy kép!", Content = "Cơ chế kích hoạt.", Duration = 2})
    end
end)
