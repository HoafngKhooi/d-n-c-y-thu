-- loadstring(game:HttpGet("https://raw.githubusercontent.com/HoafngKhooi/d-n-c-y-thu/refs/heads/bot-discord/ss.lua"))()

-- [[ 1. KHỞI TẠO RAYFIELD UI ]]
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Fabled Legacy - CrossPlatform Optimized",
   LoadingTitle = "Đang cấu hình hệ thống tối ưu...",
   LoadingSubtitle = "by Bạn Chứ Ai",
   ConfigurationSaving = { Enabled = false },
   Discord = { Enabled = false },
   KeySystem = false
})

-- [[ 2. TẠO CÁC TAB VÀ BIẾN MÔI TRƯỜNG ]]
local MainTab = Window:CreateTab("Main Farm", 4483362458)

local _G = _G or {}
_G.AutoFarm = false 

-- Tối ưu hóa biến Local cấp cao (Tăng tốc xử lý trên Mobile)
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local CurrentRoomIndex = 1
local TargetEnemy = nil 
local CurrentMap = "Raided Village"

local MapConfig = {
    ["Raided Village"] = {
        Enemies = {
            "The Beast King",               
            "Beastmaster Joe & Abbadon",    
            "Raider Warrior",               
            "Raider Punisher",              
            "Raider Magician"               
        },
        Obstacles = {} -- Sẽ tự động nạp linh hoạt để tránh lag
    }
}

-- Khởi tạo mảng vật cản an toàn
local mapData = MapConfig[CurrentMap]
if mapData then
    local dbMap = workspace:FindFirstChild("DungeonMap")
    local dbBarrier = workspace:FindFirstChild("MapBarriers")
    if dbMap then table.insert(mapData.Obstacles, dbMap) end
    if dbBarrier then table.insert(mapData.Obstacles, dbBarrier) end
end

-- Biến điều tiết hiệu năng (Performance Throttling)
local lastDangerCheck = 0
local lastEnemyScan = 0
local lastPathComputed = 0
local stuckTime = 0
local globalPath = nil
local lastInitializedMap = nil
local lastInitializedRoom = nil

-- [[ HÀM TÍNH TOÁN ĐỘ TRỄ DI ĐỘNG (DYNAMIC FPS WAIT) ]]
local function getAdaptiveWait()
    local fps = 1 / RunService.Heartbeat:Wait()
    if fps < 30 then
        return 0.15 -- Máy quá lag (Mobile cũ), giãn cách chạy để cứu máy
    elseif fps < 50 then
        return 0.08 -- Máy tầm trung (Mobile mới/PC yếu)
    end
    return 0.03 -- Máy mượt (PC khủng), tối đa hóa tốc độ farm
end

-- [[ HÀM TÌM VÙNG NÉ CHIÊU - GIỚI HẠN TẦN SUẤT QUÉT ]]
local function checkDangerZone()
    local currentTime = os.clock()
    if currentTime - lastDangerCheck < 0.1 then return nil end -- Chặn quét liên tục gây nóng máy
    lastDangerCheck = currentTime

    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local dangerNames = { "Hitbox", "Indicator", "Part", "Aftershock" }
    local fxFolder = workspace:FindFirstChild("Visuals") or workspace:FindFirstChild("Effects") or workspace:FindFirstChild("Camera")
    
    -- Gộp vùng quét gọn gàng nhất có thể
    local sources = {workspace}
    if fxFolder then table.insert(sources, fxFolder) end

    for i = 1, #sources do
        local source = sources[i]
        local children = source:GetChildren()
        for j = 1, #children do
            local v = children[j]
            if v:IsA("BasePart") and table.find(dangerNames, v.Name) then
                local distance = (rootPart.Position - v.Position).Magnitude
                local zoneRadius = math.max(v.Size.X, v.Size.Z) / 2
                if distance <= (zoneRadius + 4) then 
                    return v
                end
            end
        end
    end
    return nil
end

local function isValidEnemy(enemyName)
    local data = MapConfig[CurrentMap]
    if not data or not data.Enemies then return nil end
    for index, name in ipairs(data.Enemies) do
        if enemyName == name then return index end
    end
    return nil
end

-- [[ HÀM TÌM ĐƯỜNG ĐI (GIẢM TẢI BỘ NHỚ GIÚP MOBILE KHÔNG CRASH) ]]
local function getSharedPath()
    if globalPath and lastInitializedMap == CurrentMap and lastInitializedRoom == CurrentRoomIndex then 
        return globalPath 
    end
    
    if globalPath then
        globalPath:Destroy()
        globalPath = nil
    end
    
    local data = MapConfig[CurrentMap]
    local exclusionList = {}
    
    if data and data.Obstacles then
        for _, obstacleContainer in ipairs(data.Obstacles) do
            if obstacleContainer then
                table.insert(exclusionList, obstacleContainer)
                local descendants = obstacleContainer:GetDescendants()
                for i = 1, #descendants do
                    local child = descendants[i]
                    if child:IsA("BasePart") or child:IsA("Model") then
                        table.insert(exclusionList, child)
                    end
                end
            end
        end
    end
    
    globalPath = PathfindingService:CreatePath({
        AgentRadius = 2.5,
        AgentHeight = 5,
        AgentCanJump = true,
        Costs = { ["Part"] = 1, ["Floor"] = 1 },
        Excludes = exclusionList
    })
    
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
    
    -- CƠ CHẾ CHỐNG KẸT LUÂN PHIÊN
    if rootPart.Velocity.Magnitude < 3 then
        stuckTime = stuckTime + 0.05
        if stuckTime >= 0.4 then 
            stuckTime = 0
            humanoid.Jump = true
            humanoid:MoveTo(rootPart.Position + (tPos - pPos).Unit * 10)
            task.wait(0.2) 
            return
        end
    else
        stuckTime = math.max(0, stuckTime - 0.02)
    end
    
    local stopPosition = targetPart.Position - ((tPos - pPos).Unit * attackRange)
    if distanceToTarget < 16 then
        humanoid:MoveTo(stopPosition)
        return
    end
    
    -- KIỂM SOÁT THỜI GIAN TÍNH ĐƯỜNG ĐI (DỰA VÀO CẤU HÌNH MÁY)
    local currentTime = os.clock()
    local pathDelay = (rootPart.Velocity.Magnitude < 5) and 0.15 or 0.35 -- Nếu đứng im tính toán nhanh hơn để gỡ kẹt
    
    if currentTime - lastPathComputed > pathDelay then
        lastPathComputed = currentTime
        local path = getSharedPath()
        local success, _ = pcall(function() path:ComputeAsync(rootPart.Position, stopPosition) end)
        
        if success and path.Status == Enum.PathStatus.Success then
            local waypoints = path:GetWaypoints()
            if waypoints and #waypoints > 1 then
                local waypoint = waypoints[2]
                if waypoint.Action == Enum.PathWaypointAction.Jump then humanoid.Jump = true end
                humanoid:MoveTo(waypoint.Position)
            end
        else
            humanoid:MoveTo(stopPosition)
        end
    end
end

-- [[ 3. VÒNG LẶP CHÍNH ĐIỀU TIẾT THÔNG MINH ]]
local function doAutoFarm()
    while _G.AutoFarm do
        task.wait(getAdaptiveWait()) -- Tự co giãn thời gian chờ chống nóng máy Mobile
        
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            -- 1. ƯU TIÊN SỐNG SÓT: NÉ CHIÊU Boss
            local dangerZone = checkDangerZone()
            if dangerZone then
                local escapePosition = rootPart.Position + ((rootPart.Position - dangerZone.Position).Unit * 15) 
                humanoid:MoveTo(escapePosition)
                if rootPart.Velocity.Magnitude < 3 then humanoid.Jump = true end
                continue 
            end

            -- 2. DUY TRÌ MỤC TIÊU CŨ ĐỂ TIẾT KIỆM TÀI NGUYÊN
            if TargetEnemy and TargetEnemy:FindFirstChild("HumanoidRootPart") then
                local eHumanoid = TargetEnemy:FindFirstChildOfClass("Humanoid")
                if eHumanoid and eHumanoid.Health > 0 then
                    moveToTargetSmooth(TargetEnemy.HumanoidRootPart)
                    continue 
                end
            end
            
            -- 3. QUÉT QUÁI MỚI THEO CHU KỲ (CHỐNG SPAM TRÊN MOBILE)
            local now = os.clock()
            if now - lastEnemyScan > 0.15 or not TargetEnemy then
                lastEnemyScan = now
                TargetEnemy = nil
                local highestPriority = 999 
                
                local roomInfo = workspace:FindFirstChild("roomInformation")
                local currentRoom = roomInfo and roomInfo:FindFirstChild("Room" .. tostring(CurrentRoomIndex))
                local barrier = currentRoom and currentRoom:FindFirstChild("barrier")
                local enemiesFolder = workspace:FindFirstChild("Enemies")
                
                if enemiesFolder then
                    local enemies = enemiesFolder:GetChildren()
                    for i = 1, #enemies do
                        local enemy = enemies[i]
                        if enemy:FindFirstChild("HumanoidRootPart") then
                            local eHumanoid = enemy:FindFirstChildOfClass("Humanoid")
                            if eHumanoid and eHumanoid.Health > 0 then
                                local distToEnemy = (rootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                                local canAttack = true
                                
                                if barrier and barrier:IsA("BasePart") and barrier.CanCollide == true then
                                    if distToEnemy > (rootPart.Position - barrier.Position).Magnitude + 10 then 
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
            end
            
            -- 4. CHUYỂN PHÒNG
            if not TargetEnemy then
                local roomInfo = workspace:FindFirstChild("roomInformation")
                local currentRoom = roomInfo and roomInfo:FindFirstChild("Room" .. tostring(CurrentRoomIndex))
                local barrier = currentRoom and currentRoom:FindFirstChild("barrier")

                if barrier and barrier:IsA("BasePart") then
                    if barrier.CanCollide == true and barrier.Transparency < 0.5 then
                        humanoid:MoveTo(barrier.Position)
                    else
                        if CurrentRoomIndex < 7 then
                            local dashPosition = barrier.Position + (rootPart.CFrame.LookVector * 25)
                            CurrentRoomIndex = CurrentRoomIndex + 1
                            TargetEnemy = nil
                            task.spawn(function() humanoid:MoveTo(dashPosition) end)
                            task.wait(1.2) 
                        end
                    end
                else
                    if CurrentRoomIndex < 7 then
                        CurrentRoomIndex = CurrentRoomIndex + 1
                        task.wait(1.2) 
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
             Content = "Hệ thống tối ưu đa nền tảng (PC/Mobile) khởi động!",
             Duration = 2,
             Image = 4483362458,
          })
      else
          TargetEnemy = nil
      end
   end,
})
