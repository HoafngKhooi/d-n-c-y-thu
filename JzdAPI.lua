local PluginManager = {}

-- Hàm Inject: Tìm Button có tên chỉ định và chèn Image vào
function PluginManager:InjectImageToButton(Window, buttonName, decalId)
    -- Duyệt qua toàn bộ nội dung của Window để tìm Button khớp với tên
    task.spawn(function()
        -- Chờ một chút để UI render xong
        task.wait(1) 
        
        local targetButton = nil
        -- Tìm kiếm button trong CoreGui của Rayfield
        for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
            if v:IsA("TextButton") and v.Name == buttonName then
                targetButton = v
                break
            end
        end

        if targetButton then
            -- Tạo ImageLabel và chèn vào Button
            local image = Instance.new("ImageLabel")
            image.Name = "ButtonDecal"
            image.Size = UDim2.new(0, 25, 0, 25) -- Kích thước phù hợp
            image.Position = UDim2.new(0, 5, 0.5, -12.5)
            image.Image = "rbxassetid://" .. decalId
            image.BackgroundTransparency = 1
            image.Parent = targetButton
            
            -- Chỉnh lại Padding cho Text để không đè lên ảnh
            if targetButton:FindFirstChild("TextLabel") then
                targetButton.TextLabel.Position = UDim2.new(0, 35, 0, 0)
            end
        end
    end)
end

return PluginManager
