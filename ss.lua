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
local MainTab = Window:CreateTab("Main Farm", 4483362458)

local _G = _G or {}
_G.AutoFarm = false 

-- Các Service cần thiết
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- [[ 2.5. CẤU HÌNH DANH SÁCH MAP VÀ QUÁI ]]
-- Sau này nếu bạn mở thêm map mới, chỉ cần copy cấu trúc này điền xuống dưới là xong, rất gọn!
local MapConfig = {
    ["Raided Village"] = {
        -- Sắp xếp theo thứ tự ưu tiên farm từ trên xuống dưới
        "The Beast King",               -- Boss
        "Beastmaster Joe & Abbadon",    -- Mini Boss
        "Raider Warrior",               -- Quái thường 1
        "Raider Punisher",              -- Quái thường 2
        "Raider Magician"               -- Quái thường 3
    }
}

-- Chọn map hiện tại để chạy
local CurrentMap = "Raided Village"

-- Hàm kiểm tra xem tên quái có nằm trong danh sách farm không
local function isValidEnemy(enemyName)
    local mobList = MapConfig[CurrentMap]
    if not mobList then return nil end
    
    for index, name in ipairs(mobList) do
        if enemyName == name then
            return index -- Trả về vị trí ưu tiên (số càng nhỏ ưu tiên càng cao)
        end
    end
    return nil
end

-- [[ 3. LOGIC HÀM AUTO FARM (SỬ DỤNG MOVETO) ]]
local function doAutoFarm()
    while _G.AutoFarm do
        task.wait(0.3) -- Giảm delay một chút xuống 0.3s để nhận diện quái mượt hơn
        
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            local targetEnemy = nil
            local highestPriority = 999 -- Số càng nhỏ độ ưu tiên càng cao
            
            -- Quét qua toàn bộ thực thể trong folder Enemies
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("HumanoidRootPart") then
                    local eHumanoid = enemy:FindFirstChildOfClass("Humanoid")
                    
                    -- Kiểm tra nếu quái còn sống
                    if eHumanoid and eHumanoid.Health > 0 then
                        -- Kiểm tra quái này có nằm trong danh sách map hiện tại không
                        local priority = isValidEnemy(enemy.Name)
                        
                        -- Nếu có và độ ưu tiên cao hơn quái cũ (số nhỏ hơn)
                        if priority and priority < highestPriority then
                            highestPriority = priority
                            targetEnemy = enemy
                        end
                    end
                end
            end
            
            -- DI CHUYỂN ĐẾN MỤC TIÊU ĐÃ CHỌN
            if targetEnemy then
                local targetPos = targetEnemy.HumanoidRootPart.Position
                humanoid:MoveTo(targetPos)
                print("Đang di chuyển tới [" .. CurrentMap .. "]: " .. targetEnemy.Name)
            end
        end
    end
end

-- [[ 4. THÊM TOGGLE VÀO MENU ]]
MainTab:CreateToggle({
   Name = "Auto Move To Mob (" .. CurrentMap .. ")", -- Hiển thị luôn tên map ngoài menu
   CurrentValue = false,
   Flag = "AutoFarmToggle", 
   Callback = function(Value)
      _G.AutoFarm = Value 
      
      if Value then
          task.spawn(doAutoFarm)
          Rayfield:Notify({
             Title = "Auto Farm",
             Content = "Đã BẬT tự động chạy tới quái map " .. CurrentMap,
             Duration = 2,
             Image = 4483362458,
          })
      else
          Rayfield:Notify({
             Title = "Auto Farm",
             Content = "Đã TẮT tự động di chuyển.",
             Duration = 2,
             Image = 4483362458,
          })
      end
   end,
})

-- Thông báo sẵn sàng
Rayfield:Notify({
   Title = "Thành Công!",
   Content = "Đã tải xong danh sách quái cho " .. CurrentMap,
   Duration = 3,
   Image = 4483362458,
})
