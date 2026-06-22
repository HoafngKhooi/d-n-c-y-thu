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

-- [[ 3. LOGIC HÀM AUTO TELEPORT ]]
local function doAutoFarm()
    while _G.AutoFarm do
        task.wait(0.1) -- Khoảng thời gian delay nhỏ để tránh crash game
        
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if rootPart then
            -- Quét qua tất cả quái trong folder Enemies
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                -- Kiểm tra xem quái có phải là "Raider Punisher" (hoặc bỏ điều kiện Name nếu muốn farm mọi loại quái)
                if enemy.Name == "Raider Punisher" and enemy:FindFirstChild("HumanoidRootPart") then
                    local humanoid = enemy:FindFirstChildOfClass("Humanoid")
                    
                    -- Nếu quái còn sống thì mới bay tới
                    if humanoid and humanoid.Health > 0 then
                        -- Dịch chuyển lên trên đầu quái 5 block để test
                        rootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
                        break -- Chỉ xử lý 1 con tại 1 thời điểm, xong vòng lặp này sẽ quét tiếp
                    end
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
