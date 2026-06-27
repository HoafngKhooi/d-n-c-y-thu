-- Bỏ qua giao diện, chỉ test logic nhảy
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")

print("--- Test Auto Jump Start ---")

RunService.RenderStepped:Connect(function()
    local Char = LocalPlayer.Character
    if Char and Char:FindFirstChild("Humanoid") then
        local H = Char.Humanoid
        -- Nếu trạng thái là Landed, thực hiện nhảy
        if H:GetState() == Enum.HumanoidStateType.Landed then
            H.Jump = true
            print("Đã phát hiện chạm đất và thực hiện nhảy!")
        end
    end
end)
