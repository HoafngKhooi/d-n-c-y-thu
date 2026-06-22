-- [[ 1. KHỞI TẠO RAYFIELD UI ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Fabled Legacy - Auto Farm Test",
   LoadingTitle = "Đang tải Script...",
   LoadingSubtitle = "by Bạn Chứ Ai",
   ConfigurationSaving = {
      Enabled = false
   },
   Discord = {
      Enabled = false
   },
   KeySystem = false
})

-- [[ 2. TẠO CÁC TAB VÀ BIẾN MÔI TRƯỜNG ]]
local MainTab = Window:CreateTab("Main Farm", 4483362458) -- Icon mặc định

local _G = _G or {}
_G.AutoFarm = false -- Biến toàn cục để kiểm soát vòng lặp farm

-- Các Service cần thiết
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ 3. LOGIC HÀM AUTO FARM (MOVE TO) ]]
local function doAutoFarm()
    while _G.AutoFarm do
        task.wait(0.5) -- Tăng thời gian chờ một chút để tránh spam lệnh liên tục làm nhân vật bị khựng
        
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChild("Humanoid")
        
        if rootPart and humanoid then
            local targetEnemy = nil
            
            -- Tìm quái gần nhất (hoặc bất kỳ con nào còn sống)
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                if enemy.Name == "Raider Punisher" and enemy:FindFirstChild("HumanoidRootPart") then
                    local eHumanoid = enemy:FindFirstChildOfClass("Humanoid")
                    if eHumanoid and eHumanoid.Health > 0 then
                        targetEnemy = enemy
                        break 
                    end
                end
            end
            
            -- Nếu tìm thấy quái thì di chuyển tới
            if targetEnemy then
                humanoid:MoveTo(targetEnemy.HumanoidRootPart.Position)
                
                -- Tùy chọn: Nếu muốn dừng lại khi đã đủ gần (ví dụ cách 5 đơn vị)
                local distance = (rootPart.Position - targetEnemy.HumanoidRootPart.Position).Magnitude
                if distance < 5 then
                    humanoid:MoveTo(rootPart.Position) -- Dừng di chuyển
                end
            end
        end
    end
end

-- [[ 4. THÊM TOGGLE VÀO MENU ]]
MainTab:CreateToggle({
   Name = "Auto Teleport To Mob",
   CurrentValue = false,
   Flag = "AutoFarmToggle", 
   Callback = function(Value)
      _G.AutoFarm = Value -- Gán giá trị true/false từ nút bấm vào biến
      
      if Value then
          -- Nếu bật Toggle thì chạy hàm farm trong một luồng riêng (coroutine) để không làm đơ UI
          task.spawn(doAutoFarm)
          Rayfield:Notify({
             Title = "Auto Farm",
             Content = "Đã BẬT tự động dịch chuyển!",
             Duration = 2,
             Image = 4483362458,
          })
      else
          Rayfield:Notify({
             Title = "Auto Farm",
             Content = "Đã TẮT tự động dịch chuyển.",
             Duration = 2,
             Image = 4483362458,
          })
      end
   end,
})

-- Thông báo cho người dùng biết script đã sẵn sàng
Rayfield:Notify({
   Title = "Thành Công!",
   Content = "Menu Rayfield đã load xong, chiến thôi!",
   Duration = 3,
   Image = 4483362458,
})
