local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
-- QUAN TRỌNG: Thay link Public từ tab Cổng (Ports) của bạn vào đây
local GATEWAY_URL = "https://symmetrical-doodle-wr66v5gpjv7wh9vx7-5000.app.github.dev/update_state" 

RunService.Heartbeat:Connect(function()
    -- Lấy dữ liệu tiền để AI biết nó có đang farm hiệu quả không
    local leaderstats = Player:FindFirstChild("leaderstats")
    local gold = leaderstats and leaderstats:FindFirstChild("Gold") and leaderstats.Gold.Value or 0
    
    -- Gửi dữ liệu về cho Bộ não
    local data = {
        gold = gold,
        status = "farming"
    }

    pcall(function()
        HttpService:PostAsync(GATEWAY_URL, HttpService:JSONEncode(data))
    end)
end)                                    
