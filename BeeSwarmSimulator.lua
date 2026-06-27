local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local canDoubleJump = false
local isGliderEnabled = false

-- 1. Setup Giao diện Rayfield
local Window = Rayfield:CreateWindow({
   Name = "Glider Master",
   LoadingTitle = "Đang khởi tạo...",
   Theme = "Default"
})

local Tab = Window:CreateTab("Chức năng", nil)

Tab:CreateToggle({
   Name = "Bật Nhảy Dù (Double Jump)",
   CurrentValue = false,
   Callback = function(Value)
      isGliderEnabled = Value
   end,
})

-- 2. Hàm Gắn dù vào nhân vật
local function equipGlider()
    local character = player.Character
    if not character then return end
    
    -- Kiểm tra nếu đã có dù thì không tạo thêm
    if character:FindFirstChild("Glider") then return end
    
    local gliderTemplate = ReplicatedStorage:FindFirstChild("Glider")
    if gliderTemplate then
        local clone = gliderTemplate:Clone()
        -- Gắn vào lưng hoặc HumanoidRootPart
        local weld = Instance.new("WeldConstraint")
        weld.Part0 = clone
        weld.Part1 = character:WaitForChild("HumanoidRootPart")
        clone.Parent = character
        weld.Parent = clone
        
        -- Căn chỉnh tọa độ dù (chỉnh sửa Vector3 nếu dù bị lệch)
        clone.CFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 0.5, 0.5)
    end
end

-- 3. Logic Nhảy kép
UserInputService.JumpRequest:Connect(function()
    if not isGliderEnabled then return end
    
    local character = player.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    
    if humanoid and canDoubleJump then
        canDoubleJump = false -- Reset trạng thái
        equipGlider()         -- Gọi hàm gắn dù
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Theo dõi trạng thái nhảy
player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Landed then
            canDoubleJump = false
        elseif newState == Enum.HumanoidStateType.Freefall then
            canDoubleJump = true
        end
    end)
end)

-- Khởi tạo lần đầu
if player.Character then
    local humanoid = player.Character:FindFirstChild("Humanoid")
    if humanoid then
        humanoid.StateChanged:Connect(function(_, newState)
            if newState == Enum.HumanoidStateType.Landed then
                canDoubleJump = false
            elseif newState == Enum.HumanoidStateType.Freefall then
                canDoubleJump = true
            end
        end)
    end
end

Rayfield:LoadInterface()
