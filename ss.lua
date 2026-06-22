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

-- [[ 2.8. HÀM TÌM ĐƯỜNG ĐI MỘT MẠCH (ĐÃ SỬA LỖI GIẬT LẮC KHI TÍNH TOÀN HITBOX) ]]
local function moveToTargetSmooth(targetPart)
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    
    if not humanoid or not rootPart or not targetPart then return end
    
    -- 1. TÍNH TOÁN TẦM CHÉM THỰC TẾ (Mặc định là 7 studs nếu không thấy hitbox)
    local attackRange = 7 
    local weaponHitbox = workspace:FindFirstChild("SwingHitboxAgony")
    
    if weaponHitbox and weaponHitbox:IsA("BasePart") then
        -- Game Roblox thường thiết kế chiều dài vung kiếm theo trục Z của Part Hitbox
        attackRange = (weaponHitbox.Size.Z / 2) + 2
    end
    
    -- Triệt tiêu cao độ Y để tính khoảng cách mặt đất chính xác, tránh quái nhảy làm lệch hướng
    local pPos = Vector3.new(rootPart.Position.X, 0, rootPart.Position.Z)
    local tPos = Vector3.new(targetPart.Position.X, 0, targetPart.Position.Z)
    
    local distanceToTarget = (pPos - tPos).Magnitude
    
    -- TỐI ƯU CHỐNG NHẤP CHÂN: Nếu đã nằm trong tầm chém + sai số nhỏ (1.5 studs), đứng yên chém hoàn toàn
    if distanceToTarget <= (attackRange + 1.5) then
        humanoid:MoveTo(rootPart.Position) 
        return
    end
    
    -- 2. TÍNH ĐIỂM DỪNG (Chỉ tính khi ở ngoài tầm chém)
    local direction = (tPos - pPos).Unit
    local stopPosition = targetPart.Position - (direction * attackRange)
    
    -- Nếu ở khoảng cách cận chiến gần (dưới 16 studs) nhưng chưa tới tầm chém, sấn thẳng tới điểm dừng
    if distanceToTarget < 16 then
        humanoid:MoveTo(stopPosition)
        return
    end
    
    -- 3. ĐIỀU HƯỚNG NÉ TƯỜNG KHI Ở XA
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true
    })
    
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
            -- BƯỚC 1: KIỂM TRA MỤC TIÊU CŨ (Nếu quái cũ còn sống thì tiếp tục đi đấm, không quét lại)
            if TargetEnemy and TargetEnemy:FindFirstChild("HumanoidRootPart") then
                local eHumanoid = TargetEnemy:FindFirstChildOfClass("Humanoid")
                if eHumanoid and eHumanoid.Health > 0 then
                    moveToTargetSmooth(TargetEnemy.HumanoidRootPart)
                    continue -- Bỏ qua đoạn dưới, giữ nguyên mục tiêu này
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
            
            -- BƯỚC 3: XỬ LÝ KHI HẾT QUÁI (CHUYỂN ROOM)
            if not TargetEnemy then
                local roomName = "Room" .. tostring(CurrentRoomIndex)
                local roomInfo = workspace:FindFirstChild("roomInformation")
                local currentRoom = roomInfo and roomInfo:FindFirstChild(roomName)
                local barrier = currentRoom and currentRoom:FindFirstChild("barrier")
                
                if barrier and barrier:IsA("BasePart") and barrier.Transparency < 0.5 and barrier.CanCollide == true then
                    -- Cửa chưa mở: Tiến ra đứng sát cửa chờ
                    humanoid:MoveTo(barrier.Position)
                else
                    -- Cửa mở: Ép bước sâu qua phòng mới
                    if CurrentRoomIndex < 7 then
                        if barrier then
                            humanoid:MoveTo(barrier.Position + (rootPart.CFrame.LookVector * 15)) -- Đi sâu vào trong 15 studs
                        end
                        
                        -- SỬA TẠI ĐÂY: Chờ nhân vật ổn định vị trí và quái phòng mới kịp spawn trước khi tăng mã phòng
                        task.wait(2.5) 
                        CurrentRoomIndex = CurrentRoomIndex + 1 
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
