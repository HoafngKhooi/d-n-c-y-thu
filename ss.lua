-- [[ 1. KHỞI TẠO RAYFIELD UI ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Fabled Legacy - Auto Farm Test",
   LoadingTitle = "Đang tải Script...",
   LoadingSubtitle = "by Bạn Chứ Ai",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- [[ 2. TẠO CÁC TAB VÀ BIẾN MÔI TRƯỜNG ]]
local MainTab = Window:CreateTab("Main Farm", 4483362458)

local _G = _G or {}
_G.AutoFarm = false 

-- Các Service cần thiết
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

local CurrentRoomIndex = 1
local LastTargetPos = Vector3.new(0, 0, 0)
local isMoving = false -- Biến khóa chống spam lệnh di chuyển gây nhấp chân

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
        if enemyName == name then return index end
    end
    return nil
end

-- [[ 2.8. HÀM TÌM ĐƯỜNG THÔNG MINH KHÔNG BỊ GIẬT NHẤP CHÂN ]]
local function walkToTarget(targetPosition)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart then return end
    
    -- Nếu đang di chuyển và quái di chuyển ít (< 6 studs), bỏ qua không tính lại để tránh giật
    local distanceMoved = (targetPosition - LastTargetPos).Magnitude
    if isMoving and distanceMoved < 6 then
        return
    end
    
    LastTargetPos = targetPosition
    
    -- Tính toán đường đi mới
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
        
        -- Kích hoạt luồng chạy mượt đơn lẻ
        if waypoints and #waypoints > 1 then
            task.spawn(function()
                isMoving = true
                -- Chỉ đi 2-3 điểm tiếp theo thay vì đi hết cả map để cập nhật mục tiêu nhạy hơn
                local maxPoints = math.min(#waypoints, 4) 
                for i = 2, maxPoints do
                    if not _G.AutoFarm or (LastTargetPos - targetPosition).Magnitude > 6 then break end
                    
                    local waypoint = waypoints[i]
                    if waypoint.Action == Enum.PathWaypointAction.Jump then
                        humanoid.Jump = true
                    end
                    
                    humanoid:MoveTo(waypoint.Position)
                    -- Đợi nhân vật di chuyển gần tới điểm hiện tại rồi mới đi điểm tiếp theo (Tránh nhấp chân)
                    humanoid.MoveToFinished:Wait() 
                end
                isMoving = false
            end)
        end
    else
        -- Chữa cháy nếu lỗi Pathfinding
        humanoid:MoveTo(targetPosition)
    end
end

-- [[ 3. LOGIC HÀM AUTO FARM ]]
local function doAutoFarm()
    while _G.AutoFarm do
        task.wait(0.15)
        
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
                walkToTarget(targetEnemy.HumanoidRootPart.Position)
            else
                -- HẾT QUÁI: Xử lý cửa qua màn
                isMoving = false -- Giải phóng khóa di chuyển khi hết quái
                local roomName = "Room" .. tostring(CurrentRoomIndex)
                local roomInfo = workspace:FindFirstChild("roomInformation")
                local currentRoom = roomInfo and roomInfo:FindFirstChild(roomName)
                local barrier = currentRoom and currentRoom:FindFirstChild("barrier")
                
                if barrier and barrier:IsA("BasePart") and barrier.Transparency < 0.5 and barrier.CanCollide == true then
                    humanoid:MoveTo(barrier.Position)
                else
                    if CurrentRoomIndex < 7 then
                        if barrier then
                            humanoid:MoveTo(barrier.Position + (rootPart.CFrame.LookVector * 5))
                        end
                        
                        CurrentRoomIndex = CurrentRoomIndex + 1
                        LastTargetPos = Vector3.new(0,0,0)
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
          CurrentRoomIndex = 1 
          LastTargetPos = Vector3.new(0, 0, 0)
          isMoving = false
          task.spawn(doAutoFarm)
          Rayfield:Notify({
             Title = "Auto Farm",
             Content = "Đã BẬT tự động chạy mượt mà không nhấp chân!",
             Duration = 2,
             Image = 4483362458,
          })
      else
          isMoving = false
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
   Content = "Đã sửa hoàn toàn lỗi nhấp chân di chuyển!",
   Duration = 3,
   Image = 4483362458,
})
