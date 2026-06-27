local PluginManager = {}

function PluginManager:InjectImageToButton(Window, buttonText, decalId)
    task.spawn(function()
        task.wait(1.5) -- Tăng thời gian chờ để chắc chắn UI đã render
        
        -- Tìm kiếm theo TextLabel thay vì .Name
        for _, v in pairs(game:GetService("CoreGui"):GetDescendants()) do
            -- Kiểm tra xem có phải là Button của Rayfield không
            if v:IsA("TextLabel") and v.Text == buttonText then
                local parentButton = v.Parent -- Nút chứa TextLabel
                
                -- Kiểm tra để tránh chèn trùng
                if not parentButton:FindFirstChild("ButtonDecal") then
                    local image = Instance.new("ImageLabel")
                    image.Name = "ButtonDecal"
                    image.Size = UDim2.new(0, 25, 0, 25)
                    image.Position = UDim2.new(0, -30, 0, -2) -- Căn chỉnh lại vị trí
                    image.Image = "rbxassetid://" .. decalId
                    image.BackgroundTransparency = 1
                    image.Parent = parentButton
                    
                    -- Chỉnh lại Padding để chữ không đè lên ảnh
                    v.Position = v.Position + UDim2.new(0, 25, 0, 0)
                end
                break
            end
        end
    end)
end

return PluginManager
