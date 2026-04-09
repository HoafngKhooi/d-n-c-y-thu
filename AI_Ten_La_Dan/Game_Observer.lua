local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
local GATEWAY_URL = "https://organic-space-fishstick-wr66v5gpjvjwhgj5r-5000.app.github.dev/update_state" -- Thay link vào đây

RunService.Heartbeat:Connect(function()
    local Character = Player.Character
    if not Character then
        return
    end

    -- Giả sử quả bóng trong Blade Ball tên là "Ball"
    local Ball = workspace:FindFirstChild("Ball")
    if Ball then
        local distance = (Ball.Position - Character.HumanoidRootPart.Position).Magnitude
        local velocity = Ball.AssemblyLinearVelocity.Magnitude

        -- Gửi dữ liệu toán học về cho Bộ não
        local data = {
            distance = distance,
            velocity = velocity,
        }

        pcall(function()
            HttpService:PostAsync(GATEWAY_URL, HttpService:JSONEncode(data))
        end)
    end
end)
                                                                                                                                        