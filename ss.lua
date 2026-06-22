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
local PathfindingService = game:GetService("PathfindingService") -- SERVICE TÌM ĐƯỜNG NÉ TƯỜNG
local LocalPlayer = Players.LocalPlayer

local CurrentRoomIndex = 1

local MapConfig = {
    ["Raided Village"] = {
        "The Beast King",               
        "Beastmaster Joe & Abbadon",    
        "Raider Warrior",               
        "Raider Punisher",              
        "Raider Magician"               
    }
}

local CurrentMap = "Raided Village"

local function isValidEnemy(enemyName)
    local mobList = MapConfig[CurrentMap]
    if not mobList then return nil end
    
    for index, name in ipairs(mobList) do
        if enemyName == name then
            return index
        end
    end
    return nil
end

-- [[ 2.8. HÀM TÌM ĐƯỜNG THÔNG MINH (NÉ MAP BARRIERS) ]]
local function walkToTarget(targetPosition)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- Khởi tạo Path với thông số đại diện cho nhân vật (Agent)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true -- Cho phép nhảy nếu gặp vật cản thấp
    })
    
    -- Tính toán đường đi từ vị trí hiện tại đến đích
    local success, errorMessage = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPosition)
    end)
    
    -- Nếu tính toán đường đi thành công và đường đi đó hợp lệ (Không bị bít lối)
    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        
        -- Lấy điểm di chuyển tiếp theo (Thường là waypoint thứ 2 hoặc 3 để mượt)
        if waypoints and #waypoints > 1 then
            local nextWaypoint = waypoints[2]
            
            -- SỬA LỖI TẠI ĐÂY: Thay Enum.PathAction bằng Enum.PathWaypointsAction
            if nextWaypoint.Action == Enum.Enum.PathWaypointsAction.Jump then
                humanoid.Jump = true
            end
            
            -- Di chuyển đến waypoint đó để né tường vô hình
            humanoid:MoveTo(nextWaypoint.Position)
        end
    else
        -- Nếu Pathfinding bị lỗi (do quá gần hoặc lag), dùng MoveTo thẳng để chữa cháy
        humanoid:MoveTo(targetPosition)
    end
end

-- [[ 3. LOGIC HÀM AUTO FARM ]]
local function doAutoFarm()
    while _G.AutoFarm do
        task.wait(0.2) -- Giảm xuống 0.2s để nhân vật cập nhật đường đi liên tục, né tường mượt hơn
        
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            local targetEnemy = nil
            local highestPriority = 999 
            
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
            
            if targetEnemy then
                -- CÒN QUÁI: Gọi hàm đi thông minh né tường
                local targetPos = targetEnemy.HumanoidRootPart.Position
                walkToTarget(targetPos)
                print("AI đang tìm đường né tường để đấm quái: " .. targetEnemy.Name)
            else
                -- HẾT QUÁI: Xử lý Barrier của Room hiện tại để qua màn
                local roomName = "Room" .. tostring(CurrentRoomIndex)
                local roomInfo = workspace:FindFirstChild("roomInformation")
                local currentRoom = roomInfo and roomInfo:FindFirstChild(roomName)
                local barrier = currentRoom and currentRoom:FindFirstChild("barrier")
                
                -- Khi cửa CÒN CHẶN: Dùng Pathfinding để tìm đường đến trước cửa đứng đợi
                if barrier and barrier:IsA("BasePart") and barrier.Transparency < 0.5 and barrier.CanCollide == true then
                    walkToTarget(barrier.Position)
                    print("Hết quái Room " .. CurrentRoomIndex .. "! AI đang tìm đường ra Barrier chờ mở...")
                else
                    -- Khi cửa ĐÃ MỞ: Ép đi thẳng bằng MoveTo và tăng index phòng an toàn
                    if CurrentRoomIndex < 7 then
                        print("Barrier " .. roomName .. " đã mở! Ép nhân vật tiến lên Room " .. (CurrentRoomIndex + 1))
                        
                        -- Lấy một vị trí xa hơn barrier cũ một chút để nhân vật bước hẳn qua phòng mới
                        if barrier then
                            humanoid:MoveTo(barrier.Position + (rootPart.CFrame.LookVector * 5))
                        end
                        
                        CurrentRoomIndex = CurrentRoomIndex + 1
                        task.wait(1.5) -- Giữ nguyên thời gian chờ để nhân vật kịp di chuyển qua hẳn phòng mới
                    end
                end
            end
        end
    end
end

-- [[ 4. THÊM TOGGLE VÀO MENU ]]
MainTab:CreateToggle({
   Name = "Auto Move To Mob (" .. CurrentMap .. ")", 
   CurrentValue = false,
   Flag = "AutoFarmToggle", 
   Callback = function(Value)
      _G.AutoFarm = Value 
      
      if Value then
          CurrentRoomIndex = 1 -- <--- THÊM DÒNG NÀY (Bảo hiểm reset phòng về 1 khi bật farm)
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
