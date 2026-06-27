local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Events = require(game:GetService("ReplicatedStorage"):WaitForChild("Events")) -- Đường dẫn đến module Events bạn vừa tìm

local Window = Rayfield:CreateWindow({Name = "Glider Master", Theme = "Default"})
local Tab = Window:CreateTab("Chức năng", nil)

Tab:CreateToggle({
   Name = "Kích hoạt Dù (Sử dụng Remote)",
   CurrentValue = false,
   Callback = function(Value)
      _G.GliderEnabled = Value
   end,
})

-- Logic Nhảy: Thay vì gọi DoJump(), ta gọi qua Events module
local UserInputService = game:GetService("UserInputService")
local player = game:GetService("Players").LocalPlayer

UserInputService.JumpRequest:Connect(function()
    if not _G.GliderEnabled then return end
    
    -- Gửi tín hiệu qua RemoteEvent
    -- Lưu ý: Bạn cần thay "TênEventDù" bằng tên thật bạn thấy trong Dex (VD: "Glider", "UseItem")
    pcall(function()
        Events.ClientCall("Glider", "Equip") -- Thử gọi với tham số "Equip"
    end)
end)
