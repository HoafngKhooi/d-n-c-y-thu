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
local TargetEnemy = nil -- Lưu trữ mục tiêu hiện tại để không quét lại liên tục

local MapConfig = {
    ["Raided Village"] = {
        Enemies = {
            "The Beast King",               
            "Beastmaster Joe & Abbadon",    
            "Raider Warrior",               
            "Raider Punisher",              
            "Raider Magician"               
        },
        -- CHỈ GIỮ LẠI TƯỜNG VÀ VẬT CẢN (XÓA FLOORS ĐI)
        Obstacles = {
            workspace:FindFirstChild("DungeonMap"),
            workspace:FindFirstChild("MapBarriers")
        }
    }
}

local CurrentMap = "Raided Village"

-- [[ HÀM KIỂM TRA VÀ TÌM VÙNG NÉ CHIÊU - ĐÃ TỐI ƯU CHỐNG DROP FPS ]]
local function checkDangerZone()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return nil end

    local dangerNames = { "Hitbox", "Indicator", "Part", "Aftershock" }
    local checkList = {}
    
    -- 1. Quét nhanh ở các vùng bề nổi (Chỉ quét con trực tiếp, không đi sâu vô tận)
    for _, v in pairs(workspace:GetChildren()) do
        if table.find(dangerNames, v.Name) and v:IsA("BasePart") then
            table.insert(checkList, v)
        end
    end
    
    -- 2. Quét các folder hiệu ứng phổ biến nếu có (ông có thể thêm tên folder của game vào đây)
    local fxFolder = workspace:FindFirstChild("Visuals") or workspace:FindFirstChild("Effects") or workspace:FindFirstChild("Camera")
    if fxFolder then
        for _, v in pairs(fxFolder:GetChildren()) do
            if table.find(dangerNames, v.Name) and v:IsA("BasePart") then
                table.insert(checkList, v)
            end
        end
    end
    
    -- 3. Quét vùng lưu trữ Nil ẩn
    if typeof(getnilinstances) == "function" then
        for _, v in pairs(getnilinstances()) do
            if table.find(dangerNames, v.Name) and v:IsA("BasePart") then
                table.insert(checkList, v)
            end
        end
    end

    -- Tính toán khoảng cách né chiêu
    for _, zone in pairs(checkList) do
        local distance = (rootPart.Position - zone.Position).Magnitude
        -- Tự động lấy kích thước lớn nhất của trục X hoặc Z để làm bán kính vùng chiêu
        local zoneRadius = math.max(zone.Size.X, zone.Size.Z) / 2
        
        if distance <= (zoneRadius + 4) then -- Đứng trong tầm chiêu + thêm 4 studs an toàn
            return zone
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

-- [[ 2.8. HÀM TÌM ĐƯỜNG ĐI MỘT MẠCH (ĐÃ TỐI ƯU HOÀN HẢO TÀI NGUYÊN & NÉ VẬT CẢN) ]]
local stuckTime = 0
local globalPath = nil
local lastInitializedMap = nil
-- Thêm một biến local ở trên đầu hàm getSharedPath để lưu số phòng cũ
local lastInitializedRoom = nil

local function getSharedPath()
    if globalPath and lastInitializedMap == CurrentMap and lastInitializedRoom == CurrentRoomIndex then 
        return globalPath 
    end
    
    local mapData = MapConfig[CurrentMap]
    local exclusionList = {}
    
    if mapData and mapData.Obstacles then
        for _, obstacleContainer in pairs(mapData.Obstacles) do
            if obstacleContainer then
                table.insert(exclusionList, obstacleContainer)
                for _, child in pairs(obstacleContainer:GetDescendants()) do
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
            -- Nếu map có khu vực Floor đặt tên riêng, ta set chi phí bằng 1 để AI bám sàn di chuyển mượt nhất
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
    
    -- 1. TÍNH TOÁN TẦM CHÉM THỰC TẾ
    local attackRange = 7 
    local weaponHitbox = workspace:FindFirstChild("SwingHitboxAgony")
    
    if weaponHitbox and weaponHitbox:IsA("BasePart") then
        attackRange = (weaponHitbox.Size.Z / 2) + 2
    end
    
    local pPos = Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z)
    local tPos = Vector3.new(targetPart.Position.X, 0, targetPart.Position.Z)
    local distanceToTarget = (pPos - tPos).Magnitude
    
        -- TỐI ƯU CHỐNG NHẤP CHÂN (ĐÃ SỬA: Không bắt ép đứng im tại chỗ để tránh kẹt vật lý)
    if distanceToTarget <= (attackRange + 1.0) then
        stuckTime = 0
        return
    end
    
    -- 1.5. CƠ CHẾ ANTI-STUCK NHẢY TIẾN (KHÓA ĐÀ TIẾN KHÔNG CHO KHỰNG TẠI CHỖ)
    local groundVelocity = Vector3.new(rootPart.Velocity.X, 0, rootPart.Velocity.Z).Magnitude
    if groundVelocity < 3 then
        stuckTime = stuckTime + 0.05
        if stuckTime >= 0.4 then -- Nếu kẹt quá 0.4 giây
            stuckTime = 0
            
            -- Tính toán hướng lao tới vật cản/mục tiêu
            local jumpDirection = (tPos - pPos).Unit
            
            -- Kích hoạt nhảy phá kẹt
            humanoid.Jump = true
            
            -- Ép nhân vật điên cuồng lao về phía trước (Tạo đà tiến vượt gờ)
            humanoid:MoveTo(rootPart.Position + jumpDirection * 10)
            
            -- KHÓA LUỒNG 0.25 giây để bảo vệ lực quán tính, không cho vòng lặp 0.05s làm mất đà
            task.wait(0.25) 
            return
        end
    else
        stuckTime = math.max(0, stuckTime - 0.02)
    end
    
    -- 2. TÍNH ĐIỂM DỪNG
    local direction = (tPos - pPos).Unit
    local stopPosition = targetPart.Position - (direction * attackRange)
    
    if distanceToTarget < 16 then
        humanoid:MoveTo(stopPosition)
        return
    end
    
    -- 3. ĐIỀU HƯỚNG NÉ TƯỜNG (SỬ DỤNG LẠI PATH CŨ ĐỂ TIẾT KIỆM TÀI NGUYÊN)
    local path = getSharedPath()
    
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

-- [[ 3. LOGIC HÀM AUTO FARM TỐI ƯU QUÉT 1 LẦN ]]
local function doAutoFarm()
    while _G.AutoFarm do
        task.wait(0.05) -- Tốc độ phản hồi cực nhanh nhưng không gây lag vì có khóa Target
        
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChild("Humanoid")
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        
        if humanoid and rootPart then
            -- BƯỚC 1: KIỂM TRA NÉ CHIÊU TRƯỚC, SAU ĐÓ MỚI ĐÁNH QUÁI
            local dangerZone = checkDangerZone()
            if dangerZone then
                -- Tính toán hướng né: Di chuyển ngược hướng từ tâm chiêu thức lao ra ngoài
                local dodgeDirection = (rootPart.Position - dangerZone.Position).Unit
                local escapePosition = rootPart.Position + (dodgeDirection * 15) -- Giật lùi ra xa 15 studs
                
                humanoid:MoveTo(escapePosition)
                -- Nếu vận tốc bằng 0 (bị khựng mép vùng chiêu), kích hoạt nhảy rướn để thoát
                if rootPart.Velocity.Magnitude < 3 then
                    humanoid.Jump = true
                end
                continue -- Khóa mục tiêu đánh, ưu tiên sống sót chạy ra ngoài
            end

            -- KIỂM TRA MỤC TIÊU CŨ (Nếu quái cũ còn sống và không có chiêu thì tiếp tục đấm)
            if TargetEnemy and TargetEnemy:FindFirstChild("HumanoidRootPart") then
                local eHumanoid = TargetEnemy:FindFirstChildOfClass("Humanoid")
                if eHumanoid and eHumanoid.Health > 0 then
                    moveToTargetSmooth(TargetEnemy.HumanoidRootPart)
                    continue 
                end
            end
            
           -- BƯỚC 2: QUÉT QUÁI MỚI (Tối ưu tuyệt đối cho mọi loại Map lớn nhỏ)
            TargetEnemy = nil
            local highestPriority = 999 
            
            -- Lấy vị trí của cửa chặn phòng hiện tại (nếu có) để làm mốc giới hạn
            local roomName = "Room" .. tostring(CurrentRoomIndex)
            local roomInfo = workspace:FindFirstChild("roomInformation")
            local currentRoom = roomInfo and roomInfo:FindFirstChild(roomName)
            local barrier = currentRoom and currentRoom:FindFirstChild("barrier")
            
            for _, enemy in pairs(workspace.Enemies:GetChildren()) do
                if enemy:FindFirstChild("HumanoidRootPart") then
                    local eHumanoid = enemy:FindFirstChildOfClass("Humanoid")
                    if eHumanoid and eHumanoid.Health > 0 then
                        
                        -- BIỆN PHÁP CHỐNG QUÉT XUYÊN PHÒNG:
                        -- Nếu phòng có cửa chặn, và quái nằm ĐẰNG SAU cái cửa đó (khoảng cách từ nhân vật tới quái lớn hơn khoảng cách tới cửa) -> Bỏ qua quái đó!
                        local distToEnemy = (rootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
                        local canAttack = true
                        
                        if barrier and barrier:IsA("BasePart") and barrier.CanCollide == true then
                            local distToBarrier = (rootPart.Position - barrier.Position).Magnitude
                            if distToEnemy > distToBarrier + 10 then 
                                canAttack = false -- Quái này thuộc phòng sau rồi, không thèm quét!
                            end
                        end
                        
                        -- Nếu quái hợp lệ hoặc map mở (để khoảng cách tối đa là 350 cho an toàn)
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
            
                        -- BƯỚC 3: XỬ LÝ KHI HẾT QUÁI (ĐÃ SỬA: Chống nhảy số phòng liên tục do loop 0.05s)
            if not TargetEnemy then
                if barrier and barrier:IsA("BasePart") then
                    if barrier.CanCollide == true and barrier.Transparency < 0.5 then
                        humanoid:MoveTo(barrier.Position)
                    else
                        if CurrentRoomIndex < 7 then
                            local dashPosition = barrier.Position + (rootPart.CFrame.LookVector * 25)
                            
                            -- Tăng số phòng và khóa luồng bằng cách tạo thời gian chờ nhân vật di chuyển qua cửa
                            CurrentRoomIndex = CurrentRoomIndex + 1
                            TargetEnemy = nil
                            
                            task.spawn(function()
                                humanoid:MoveTo(dashPosition)
                            end)
                            
                            task.wait(1.5) -- Chờ 1.5 giây để nhân vật chạy hẳn qua phòng mới rồi mới tiếp tục quét quái
                        end
                    end
                else
                    if CurrentRoomIndex < 7 then
                        CurrentRoomIndex = CurrentRoomIndex + 1
                        task.wait(1.5) -- Khóa đuôi thời gian chờ nếu map không có barrier cụ thể
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
          TargetEnemy = nil -- Xóa mục tiêu cũ khi khởi động lại
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

-- Thông báo sẵn sàng
Rayfield:Notify({
   Title = "Thành Công!",
   Content = "Đã cập nhật thuật toán khóa mục tiêu mượt mà!",
   Duration = 3,
   Image = 4483362458,
})
