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

-- [[ 3. LOGIC HÀM AUTO FARM (SỬ DỤNG MOVETO ĐẢM BẢO KHÔNG TELE) ]]
local function doAutoFarm()
    while _G.AutoFarm do
        task.wait(0.5) 
        
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            local targetEnemy = nil
            
            -- Quét quái
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                if enemy.Name == "Raider Punisher" and enemy:FindFirstChild("HumanoidRootPart") then
                    local eHumanoid = enemy:FindFirstChildOfClass("Humanoid")
                    if eHumanoid and eHumanoid.Health > 0 then
                        targetEnemy = enemy
                        break 
                    end
                end
            end
            
            -- DI CHUYỂN BẰNG MOVETO (KHÔNG DÙNG CFRAME)
            if targetEnemy then
                local targetPos = targetEnemy.HumanoidRootPart.Position
                
                -- Lệnh này khiến nhân vật đi tới vị trí quái
                humanoid:MoveTo(targetPos)
                
                -- Để đảm bảo nhân vật không bị khựng, hãy đảm bảo không có lệnh CFrame nào khác chạy đè lên
                print("Đang di chuyển tới: " .. targetEnemy.Name)
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
