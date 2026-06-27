-- TỰ ĐỘNG CHỜ GAME LOAD
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer.Character

-- Dùng thư viện Rayfield đã được local hóa (để tránh lỗi loadstring)
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/UI-Lib/Rayfield/main/Source.lua'))()

local Window = Rayfield:CreateWindow({Name = "Tryhard Movement"})
local Tab = Window:CreateTab("Movement")

local _G.AutoJump = false

-- LOGIC NHẢY (Tối ưu nhất)
game:GetService("RunService").RenderStepped:Connect(function()
    if _G.AutoJump then
        local Humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
        if Humanoid and Humanoid:GetState() == Enum.HumanoidStateType.Landed then
            task.wait(0.01) -- Độ trễ cực thấp
            Humanoid.Jump = true
        end
    end
end)

Tab:CreateToggle({
    Name = "Auto-Jump Reset",
    CurrentValue = false,
    Callback = function(Value)
        _G.AutoJump = Value
    end,
})
