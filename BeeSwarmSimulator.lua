-- Tải thư viện Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Thiết lập cửa sổ chính
local Window = Rayfield:CreateWindow({
   Name = "Bee Swarm Movement Pro",
   LoadingTitle = "Initializing...",
   LoadingSubtitle = "by Your Assistant",
})

-- Tab Di chuyển
local MovementTab = Window:CreateTab("Movement")

-- Biến lưu trạng thái
local _G.AutoJumpEnabled = false

-- Logic xử lý nhảy khi chạm đất
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function()
    if _G.AutoJumpEnabled then
        local Character = LocalPlayer.Character
        if Character and Character:FindFirstChild("Humanoid") then
            local Humanoid = Character.Humanoid
            
            -- Kiểm tra nếu chạm đất (Landed)
            if Humanoid:GetState() == Enum.HumanoidStateType.Landed then
                -- Đợi một khoảng cực ngắn để mô phỏng phản xạ người chơi
                task.wait(0.02) 
                
                -- Thực hiện lệnh nhảy
                Humanoid.Jump = true
            end
        end
    end
end)

-- Tạo Toggle trong Rayfield
MovementTab:CreateToggle({
   Name = "Auto-Jump Reset (Paraglide)",
   CurrentValue = false,
   Flag = "AutoJumpToggle",
   Callback = function(Value)
      _G.AutoJumpEnabled = Value
      if Value then
          Rayfield:Notify({Title = "Đã bật", Content = "Script đang tự động reset nhảy khi chạm đất.", Duration = 3})
      end
   end,
})

-- Thông báo khởi tạo xong
Rayfield:Notify({Title = "Success", Content = "Script đã load thành công!", Duration = 5})
