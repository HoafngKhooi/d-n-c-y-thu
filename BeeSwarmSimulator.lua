local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local player = game:GetService("Players").LocalPlayer
local workspace = game:GetService("Workspace")

local Window = Rayfield:CreateWindow({Name = "Field Master", Theme = "Default"})
local Tab = Window:CreateTab("Di chuyển", nil)

-- Hàm di chuyển nhân vật
local function teleportToField(fieldName)
    local field = workspace:FindFirstChild("FlowerZones") and workspace.FlowerZones:FindFirstChild(fieldName)
    
    if field and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        -- Lấy tọa độ của field (thường là CFrame của model hoặc part)
        local targetCFrame = field:IsA("Model") and field:GetPrimaryPartCFrame() or field.CFrame
        player.Character.HumanoidRootPart.CFrame = targetCFrame + Vector3.new(0, 5, 0) -- Bay lên 5 đơn vị để tránh kẹt
        
        Rayfield:Notify({
            Title = "Dịch chuyển",
            Content = "Đã đến " .. fieldName,
            Duration = 2,
        })
    else
        Rayfield:Notify({
            Title = "Lỗi",
            Content = "Không tìm thấy Field này!",
            Duration = 2,
        })
    end
end

-- Thêm nút bấm vào Rayfield
Tab:CreateButton({
   Name = "Đến Sunflower Field",
   Callback = function()
      teleportToField("Sunflower Field")
   end,
})
