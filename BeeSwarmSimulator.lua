local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local player = game:GetService("Players").LocalPlayer
local workspace = game:GetService("Workspace")

-- Cấu hình Window
local Window = Rayfield:CreateWindow({
    Name = "Field Master", 
    Theme = "Default",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Configs",
        FileName = "DefaultConfig"
    }
})

local Tab = Window:CreateTab("Di chuyển", nil)
local ConfigTab = Window:CreateTab("Config", nil)

-- --- PHẦN DI CHUYỂN ---
local fieldData = {
    ["Bamboo Field"] = 15617807109,
    ["Blue Flower Field"] = 15617806925,
    ["Cactus Field"] = 15617806727,
    ["Clover Field"] = 15617806641,
    ["Coconut Field"] = 15617838168,
    ["Dandelion Field"] = 15617826387,
    ["Mountain Top Field"] = 15617806342,
    ["Mushroom Field"] = 15617806189,
    ["Pepper Patch"] = 15617806096,
    ["Pine Tree Forest"] = 15617805993,
    ["Pineapple Patch"] = 15617805930,
    ["Pumpkin Patch"] = 15617805864,
    ["Rose Field"] = 15617805712,
    ["Spider Field"] = 15617805611,
    ["Strawberry Field"] = 15617805499,
    ["Stump Field"] = 15617805381,
    ["Sunflower Field"] = 15617805255,
}

local function teleportToField(fieldName)
    local flowerZones = workspace:FindFirstChild("FlowerZones")
    local field = flowerZones and flowerZones:FindFirstChild(fieldName)
    
    if field and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = (field:IsA("Model") and field:GetPrimaryPartCFrame() or field.CFrame) + Vector3.new(0, 5, 0)
        Rayfield:Notify({Title = "Dịch chuyển", Content = "Đã đến " .. fieldName, Duration = 2})
    else
        Rayfield:Notify({Title = "Lỗi", Content = "Không tìm thấy " .. fieldName, Duration = 2})
    end
end

-- Sửa lỗi: Duyệt qua fieldData thay vì fieldList
for name, _ in pairs(fieldData) do
    Tab:CreateButton({ 
        Name = "Đến " .. name, 
        Callback = function() teleportToField(name) end 
    })
end

-- --- PHẦN CONFIG ---
ConfigTab:CreateSection("Settings")

local ConfigDropdown = ConfigTab:CreateDropdown({
    Name = "Danh sách Config",
    Options = Rayfield:GetConfigs(),
    CurrentOption = {"DefaultConfig"},
    Flag = "ConfigDropdown",
    Callback = function(Option) end,
})

ConfigTab:CreateInput({
    Name = "Create Config",
    PlaceholderText = "Nhập tên và nhấn Enter...",
    RemoveTextAfterFocusLost = true,
    Callback = function(Text)
        Rayfield:SaveConfiguration(Text)
        ConfigDropdown:Refresh(Rayfield:GetConfigs(), true)
        Rayfield:Notify({Title = "Thành công", Content = "Đã tạo: " .. Text})
    end,
})

ConfigTab:CreateButton({
    Name = "Load Config",
    Callback = function()
        local selected = Rayfield.Flags["ConfigDropdown"].CurrentOption[1]
        Rayfield:LoadConfiguration(selected)
        Rayfield:Notify({Title = "Đã Load", Content = selected})
    end,
})

ConfigTab:CreateButton({
    Name = "Delete Config",
    Callback = function()
        local selected = Rayfield.Flags["ConfigDropdown"].CurrentOption[1]
        if selected ~= "DefaultConfig" then
            delfile("Configs/" .. selected .. ".json")
            ConfigDropdown:Refresh(Rayfield:GetConfigs(), true)
            Rayfield:Notify({Title = "Đã xóa", Content = selected})
        end
    end,
})

ConfigTab:CreateInput({
    Name = "Rename Config (Nhập tên mới rồi Enter)",
    PlaceholderText = "Tên mới...",
    RemoveTextAfterFocusLost = true,
    Callback = function(NewName)
        local oldName = Rayfield.Flags["ConfigDropdown"].CurrentOption[1]
        if oldName ~= "DefaultConfig" and NewName ~= "" then
            Rayfield:SaveConfiguration(NewName)
            delfile("Configs/" .. oldName .. ".json")
            ConfigDropdown:Refresh(Rayfield:GetConfigs(), true)
            Rayfield:Notify({Title = "Đã đổi tên", Content = oldName .. " -> " .. NewName})
        end
    end,
})
