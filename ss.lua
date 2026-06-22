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
local LastTargetPos = Vector3.new(0, 0, 0) -- ĐÃ SỬA: Khai báo mốc tọa độ ở đây để tránh lỗi gán giá trị nil

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

-- [[ 2.8. HÀM TÌM ĐƯỜNG THÔNG MINH ĐÃ TỐI ƯU MƯỢT MÀ ]]
local function walkToTarget(targetPosition)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- CƠ CHẾ CHỐNG NHẤP: Nếu mục tiêu dịch chuyển quá ít, đi thẳng luôn cho mượt
    local distanceMoved = (targetPosition - LastTargetPos).Magnitude
    if distanceMoved < 5 then
        humanoid:MoveTo(targetPosition)
        return
    end
    
    -- Cập nhật lại vị trí mốc mới
    LastTargetPos = targetPosition
    
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true
    })
    
    local success, _ = pcall(function()
        path:ComputeAsync(rootPart.Position, targetPosition)
    end)
    
    if success and path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        if waypoints and #waypoints > 1 then
            local nextWaypoint = waypoints[2]
            if nextWaypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
            humanoid:MoveTo(nextWaypoint.Position)
        end
    else
        humanoid:MoveTo(targetPosition)
    end
end

-- [[ 3. LOGIC HÀM AUTO FARM ]]
local function doAutoFarm()
    while _G.AutoFarm do
        task.wait(0.15) -- Tốc độ quét luồng logic nhanh hơn nhưng không lo giật vì đã có bộ lọc khoảng cách
        
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
                -- CÒN QUÁI: Di chuyển thông minh
                walkToTarget(targetEnemy.HumanoidRootPart.Position)
            else
                -- HẾT QUÁI: Xử lý cửa qua màn
                local roomName = "Room" .. tostring(CurrentRoomIndex)
                local roomInfo = workspace:FindFirstChild("roomInformation")
                local currentRoom = roomInfo and roomInfo:FindFirstChild(roomName)
                local barrier = currentRoom and currentRoom:FindFirstChild("barrier")
                
                if barrier and barrier:IsA("BasePart") and barrier.Transparency < 0.5 and barrier.CanCollide == true then
                    -- Cửa chưa mở: Đi thẳng bằng MoveTo ra cửa đứng đợi (Không cần dùng Pathfinding ở đây để tránh giật)
                    humanoid:MoveTo(barrier.Position)
                else
                    if CurrentRoomIndex < 7 then
                        if barrier then
                            humanoid:MoveTo(barrier.Position + (rootPart.CFrame.LookVector * 5))
                        end
                        
                        CurrentRoomIndex = CurrentRoomIndex + 1
                        LastTargetPos = Vector3.new(0,0,0) -- Reset mốc vị trí để phòng sau quét lại từ đầu
                        task.wait(1.5) 
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
