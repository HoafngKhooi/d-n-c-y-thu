local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local player = game:GetService("Players").LocalPlayer
local workspace = game:GetService("Workspace")

local Window = Rayfield:CreateWindow({Name = "Field Master", Theme = "Default"})
local Tab = Window:CreateTab("Di chuyển", nil)

-- Danh sách các Field kèm Icon ID
local fieldList = {
    {Name = "Bamboo Field", Icon = "rbxassetid://15617807109"},
    {Name = "Blue Flower Field", Icon = "rbxassetid://15617806925"},
    {Name = "Cactus Field", Icon = "rbxassetid://15617806727"},
    {Name = "Clover Field", Icon = "rbxassetid://15617806641"},
    {Name = "Coconut Field", Icon = "rbxassetid://15617838168"},
    {Name = "Dandelion Field", Icon = "rbxassetid://15617826387"},
    {Name = "Mountain Top Field", Icon = "rbxassetid://15617806342"},
    {Name = "Mushroom Field", Icon = "rbxassetid://15617806189"},
    {Name = "Pepper Patch", Icon = "rbxassetid://15617806096"},
    {Name = "Pine Tree Forest", Icon = "rbxassetid://15617805993"},
    {Name = "Pineapple Patch", Icon = "rbxassetid://15617805930"},
    {Name = "Pumpkin Patch", Icon = "rbxassetid://15617805864"},
    {Name = "Rose Field", Icon = "rbxassetid://15617805712"},
    {Name = "Spider Field", Icon = "rbxassetid://15617805611"},
    {Name = "Strawberry Field", Icon = "rbxassetid://15617805499"},
    {Name = "Stump Field", Icon = "rbxassetid://15617805381"},
    {Name = "Sunflower Field", Icon = "rbxassetid://15617805255"},
}

-- Hàm di chuyển nhân vật
local function teleportToField(fieldName)
    local flowerZones = workspace:FindFirstChild("FlowerZones")
    local field = flowerZones and flowerZones:FindFirstChild(fieldName)
    
    if field and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local targetCFrame = field:IsA("Model") and field:GetPrimaryPartCFrame() or field.CFrame
        player.Character.HumanoidRootPart.CFrame = targetCFrame + Vector3.new(0, 5, 0)
        
        Rayfield:Notify({
            Title = "Dịch chuyển",
            Content = "Đã đến " .. fieldName,
            Duration = 2,
        })
    else
        Rayfield:Notify({
            Title = "Lỗi",
            Content = "Không tìm thấy " .. fieldName,
            Duration = 2,
        })
    end
end

-- Tự động tạo nút cho danh sách
for _, fieldData in pairs(fieldList) do
    Tab:CreateButton({
       Name = "Đến " .. fieldData.Name,
       Icon = fieldData.Icon,
       Callback = function()
          teleportToField(fieldData.Name)
       end,
    })
end
