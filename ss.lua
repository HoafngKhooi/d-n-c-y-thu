-- loadstring(game:HttpGet("https://raw.githubusercontent.com/HoafngKhooi/d-n-c-y-thu/refs/heads/bot-discord/ss.lua"))()

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

-- Các Service cần thiết (Sử dụng các biến local tối ưu tốc độ)
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local LocalPlayer = Players.LocalPlayer

local CurrentRoomIndex = 1
local TargetEnemy = nil 

local MapConfig = {
    ["Raided Village"] = {
        Enemies = {
            "The Beast King",               
            "Beastmaster Joe & Abbadon",    
            "Raider Warrior",               
            "Raider Punisher",              
            "Raider Magician"               
        },
        Obstacles = {
            workspace:FindFirstChild("DungeonMap"),
            workspace:FindFirstChild("MapBarriers")
        }
    }
}

local CurrentMap = "Raided Village"

-- [[ HÀM KIỂM TRA VÀ TÌM VÙNG NÉ CHIÊU - ĐÃ BỎ NIL INSTANCES GÂY CRASH ]]
local function checkDangerZone()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local dangerNames = { "Hitbox", "Indicator", "Part", "Aftershock" }
    local checkList = {}
    
    -- Quét nhanh ở Workspace
    for _, v in ipairs(workspace:GetChildren()) do
        if table.find(dangerNames, v.Name) and v:IsA("BasePart") then
            table.insert(checkList, v)
        end
    end
    
    -- Quét folder hiệu ứng phổ biến
    local fxFolder = workspace:FindFirstChild("Visuals") or workspace:FindFirstChild("Effects") or workspace:FindFirstChild("Camera")
    if fxFolder then
        for _, v in ipairs(fxFolder:GetChildren()) do
            if table.find(dangerNames, v.Name) and v:IsA("BasePart") then
                table.insert(checkList, v)
            end
        end
    end

    -- Tính toán khoảng cách né chiêu an toàn
    for _, zone in ipairs(checkList) do
        if zone and zone:IsA("BasePart") then
            local distance = (rootPart.Position - zone.Position).Magnitude
            local zoneRadius = math.max(zone.Size.X, zone.Size.Z) / 2
            
            if distance <= (zoneRadius + 4) then 
                return zone
            end
        end
    end
    return nil
end

-- Sửa lại hàm check quái một chút để khớp với cấu trúc mới
local function isValidEnemy(enemyName)
    local mapData = MapConfig[CurrentMap]
    if not mapData or not mapData.Enemies then return nil end
    
    for index, name in ipairs(mapData.Enemies) do
        if enemyName == name then return index end
    end
    return nil
end

-- [[ HÀM TÌM ĐƯỜNG ĐI (ĐÃ FIX KHÔNG BỊ RÒ RỈ BỘ NHỚ) ]]
local stuckTime = 0
local globalPath = nil
local lastInitializedMap = nil
local lastInitializedRoom = nil
local lastPathComputed = 0 -- Biến chặn spam ComputeAsync

local function getSharedPath()
    if globalPath and lastInitializedMap == CurrentMap and lastInitializedRoom == CurrentRoomIndex then 
        return globalPath 
    end
    
    -- Xóa path cũ nếu có để tránh tràn bộ nhớ
    if globalPath then
        globalPath:Destroy()
        globalPath = nil
    end
    
    local mapData = MapConfig[CurrentMap]
    local exclusionList = {}
    
    if mapData and mapData.Obstacles then
        for _, obstacleContainer in ipairs(mapData.Obstacles) do
            if obstacleContainer then
                table.insert(exclusionList, obstacleContainer)
                for _, child in ipairs(obstacleContainer:GetDescendants()) do
                    if child:IsA("BasePart") or child:IsA("Model") then
                        table.insert(exclusionList, child)
                    end
                end
            end
        end
    end
    
    local agentParams = {
        AgentRadius = 2.5,
        AgentHeight = 5,
        AgentCanJump = true,
        Costs = {
            ["Part"] = 1,
            ["Floor"] = 1
        },
        Excludes = exclusionList
    }
    
    globalPath = PathfindingService:CreatePath(agentParams)
    lastInitializedMap = CurrentMap
    lastInitializedRoom = CurrentRoomIndex 
    return globalPath
end

local function moveToTargetSmooth(targetPart)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart or not targetPart then return end
    
    local attackRange = 7 
    local weaponHitbox = workspace:FindFirstChild("SwingHitboxAgony")
    
    if weaponHitbox and weaponHitbox:IsA("BasePart") then
        attackRange = (weaponHitbox.Size.Z / 2) + 2
    end
    
    local pPos = Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z)
    local tPos = Vector3.new(targetPart.Position.X, 0, targetPart.Position.Z)
    local distanceToTarget = (pPos - tPos).Magnitude
    
    if distanceToTarget <= (attackRange + 1.0) then
        stuckTime = 0
        return
    end
    
    -- CƠ CHẾ ANTI-STUCK NHẢY TIẾN
    local groundVelocity = Vector3.new(rootPart.Velocity.X, 0, rootPart.Velocity.Z).Magnitude
    if groundVelocity < 3 then
        stuckTime = stuckTime + 0.05
        if stuckTime >= 0.4 then 
            stuckTime = 0
            local jumpDirection = (tPos - pPos).Unit
            humanoid.Jump = true
            humanoid:MoveTo(rootPart.Position + jumpDirection * 10)
            task.wait(0.25) 
            return
        end
    else
        stuckTime = math.max(0, stuckTime - 0.02)
    end
    
    local direction = (tPos - pPos).Unit
    local stopPosition = targetPart.Position - (direction * attackRange)
    
    if distanceToTarget < 16 then
        humanoid:MoveTo(stopPosition)
        return
    end
    
    -- ĐIỀU HƯỚNG NÉ TƯỜNG (CHỈ TÍNH TOÁN KHI QUÁ TỐI THIỂU 0.2 GIÂY TRÁNH SPAM)
    local path = getSharedPath()
    local currentTime = os.clock()
    
    if currentTime - lastPathComputed > 0.2 then
        lastPathComputed = currentTime
        local success, _ = pcall(function()
            path:ComputeAsync(rootPart.Position, stopPosition)
        end)
        
        if success and path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            if waypoints and #waypoints > 1 then
                local waypoint = waypoints[2]
                if waypoint.Action == Enum.PathWaypointAction.Jump then
                    humanoid.Jump = true
                end
                humanoid:MoveTo(waypoint.Position)
            end
        else
            humanoid:MoveTo(stopPosition)
        end
    end
end

-- [[ 3. LOGIC HÀM AUTO FARM TỐI ƯU ]]
local function doAutoFarm()
    while _G.AutoFarm do
        task.wait(0.05) 
        
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            -- BƯỚC 1: KIỂM TRA NÉ CHIÊU
            local dangerZone = checkDangerZone()
            if dangerZone then
                local dodgeDirection = (rootPart.Position - dangerZone.Position).Unit
                local escapePosition = rootPart.Position + (dodgeDirection * 15) 
                
                humanoid:MoveTo(escapePosition)
                if rootPart.Velocity.Magnitude < 3 then
                    humanoid.Jump = true
                end
                continue 
            end

            -- KIỂM TRA MỤC TIÊU CŨ
            if TargetEnemy and TargetEnemy:FindFirstChild("HumanoidRootPart") then
                local eHumanoid = TargetEnemy:FindFirstChildOfClass("Humanoid")
                if eHumanoid and eHumanoid.Health > 0 then
                    moveToTargetSmooth(TargetEnemy.HumanoidRootPart)
                    continue 
                end
            end
            
            -- BƯỚC 2: QUÉT QUÁI MỚI
            TargetEnemy = nil
            local highestPriority = 999 
            
            local roomName = "Room" .. tostring(CurrentRoomIndex)
            local roomInfo = workspace:FindFirstChild("roomInformation")
            local currentRoom = roomInfo and roomInfo:FindFirstChild(roomName)
            local barrier = currentRoom and currentRoom:FindFirstChild("barrier")
            
            local enemiesFolder = workspace:FindFirstChild("Enemies")
            if enemiesFolder then
                for _, enemy in ipairs(enemiesFolder:GetChildren()) do
                    if enemy:FindFirstChild("HumanoidRootPart") then
                        local eHumanoid = enemy:FindFirstChildOfClass("Humanoid")
                        if eHumanoid and eHumanoid.Health > 0 then
                            
                            local distToEnemy = (rootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                            local canAttack = true
                            
                            if barrier and barrier:IsA("BasePart") and barrier.CanCollide == true then
                                local distToBarrier = (rootPart.Position - barrier.Position).Magnitude
                                if distToEnemy > distToBarrier + 10 then 
                                    canAttack = false 
                                end
                            end
                            
                            if canAttack and distToEnemy < 350 then 
                                local priority = isValidEnemy(enemy.Name)
                                if priority and priority < highestPriority then
                                    highestPriority = priority
                                    TargetEnemy = enemy
                                end
                            end
                        end
                    end
                end
            end
            
            -- BƯỚC 3: XỬ LÝ KHI HẾT QUÁI
            if not TargetEnemy then
                if barrier and barrier:IsA("BasePart") then
                    if barrier.CanCollide == true and barrier.Transparency < 0.5 then
                        humanoid:MoveTo(barrier.Position)
                    else
                        if CurrentRoomIndex < 7 then
                            local dashPosition = barrier.Position + (rootPart.CFrame.LookVector * 25)
                            CurrentRoomIndex = CurrentRoomIndex + 1
                            TargetEnemy = nil
                            
                            task.spawn(function()
                                humanoid:MoveTo(dashPosition)
                            end)
                            task.wait(1.5) 
                        end
                    end
                else
                    if CurrentRoomIndex < 7 then
                        CurrentRoomIndex = CurrentRoomIndex + 1
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
          TargetEnemy = nil 
          task.spawn(doAutoFarm)
          Rayfield:Notify({
             Title = "Auto Farm",
             Content = "Đã bật hệ thống Auto Farm mượt không gián đoạn!",
             Duration = 2,
             Image = 4483362458,
          })
      else
          TargetEnemy = nil
          Rayfield:Notify({
             Title = "Auto Farm",
             Content = "Đã TẮT tự động di chuyển.",
             Duration = 2,
             Image = 4483362458,
          })
      end
   end,
})

Rayfield:Notify({
   Title = "Thành Công!",
   Content = "Đã cập nhật thuật toán tối ưu chống crash!",
   Duration = 3,
   Image = 4483362458,
})
