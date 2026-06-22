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

-- Biến theo dõi số Room hiện tại (Sẽ tự tăng khi qua cửa từ Room1 -> Room7)
local CurrentRoomIndex = 1

-- [[ 2.5. CẤU HÌNH DANH SÁCH MAP VÀ QUÁI ]]
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

-- [[ 3. LOGIC HÀM AUTO FARM ]]
local function doAutoFarm()
    while _G.AutoFarm do
        task.wait(0.3) 
        
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            local targetEnemy = nil
            local highestPriority = 999 
            
            -- Bước 1: Quét tìm xem còn quái sống trong map không
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("HumanoidRootPart") then
                    local eHumanoid = enemy:FindFirstChildOfClass("Humanoid")
                    
                    if eHumanoid and eHumanoid.Health > 0 then
                        local priority = isValidEnemy(enemy.Name)
                        if priority and priority < highestPriority then
                            highestPriority = priority
                            targetEnemy = enemy
                        end
                    end
                end
            end
            
            -- Bước 2: Ra quyết định di chuyển
            if targetEnemy then
                -- CÒN QUÁI: Chạy tới đấm quái
                local targetPos = targetEnemy.HumanoidRootPart.Position
                humanoid:MoveTo(targetPos)
                print("Đang di chuyển tới quái: " .. targetEnemy.Name)
            else
                -- HẾT QUÁI: Xử lý Barrier của Room hiện tại để qua màn
                local roomName = "Room" .. tostring(CurrentRoomIndex)
                local roomInfo = workspace:FindFirstChild("roomInformation")
                local currentRoom = roomInfo and roomInfo:FindFirstChild(roomName)
                local barrier = currentRoom and currentRoom:FindFirstChild("barrier")
                
                -- Điều kiện kiểm tra xem Barrier CÒN CHẶN đường hay không
                -- (Còn trong Workspace, chưa tàng hình, và vẫn còn chặn va chạm)
                if barrier and barrier:IsA("BasePart") and barrier.Transparency < 0.5 and barrier.CanCollide == true then
                    -- Cửa chưa mở -> Chạy thẳng tới dí đầu vào cửa đợi sẵn
                    humanoid:MoveTo(barrier.Position)
                    print("Hết quái Room " .. CurrentRoomIndex .. "! Đang đứng chờ mở Barrier...")
                else
                    -- Cửa ĐÃ MỞ (Hoặc bị xóa, hoặc tàng hình, hoặc cho đi xuyên qua)
                    if CurrentRoomIndex < 7 then
                        print("Barrier " .. roomName .. " đã mở! Tiến lên Room " .. (CurrentRoomIndex + 1))
                        
                        -- Nếu cửa mở, ra lệnh cho nhân vật chạy qua vị trí cửa cũ để tiến vào Room mới
                        if barrier then
                            humanoid:MoveTo(barrier.Position)
                        end
                        
                        CurrentRoomIndex = CurrentRoomIndex + 1
                        task.wait(1.5) -- Chờ 1.5 giây để nhân vật kịp chạy qua hẳn phòng mới rồi mới quét quái tiếp
                    end
                end
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
