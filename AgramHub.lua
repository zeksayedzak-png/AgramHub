-- إنشاء الواجهة الأساسية
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Title = Instance.new("TextLabel")
local ButtonsFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local TimerDisplay = Instance.new("TextLabel")

-- إعدادات الواجهة
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "MyProScript"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- لون أسود غامق
MainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 250, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true -- تفعيل السحب للموبايل

UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = MainFrame

Title.Parent = MainFrame
Title.Text = "ATM & TP SYSTEM"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

-- عرض المؤقت
TimerDisplay.Name = "TimerDisplay"
TimerDisplay.Parent = MainFrame
TimerDisplay.Position = UDim2.new(0.05, 0, 0.12, 0)
TimerDisplay.Size = UDim2.new(0.9, 0, 0, 30)
TimerDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TimerDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
TimerDisplay.Text = "Timer: Waiting..."
TimerDisplay.Font = Enum.Font.Gotham
TimerDisplay.TextSize = 14
local TimerCorner = Instance.new("UICorner", TimerDisplay)
TimerCorner.CornerRadius = UDim.new(0, 8)

-- حاوية الأزرار
ButtonsFrame.Parent = MainFrame
ButtonsFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
ButtonsFrame.Size = UDim2.new(0.9, 0, 0.7, 0)
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.CanvasSize = UDim2.new(0, 0, 1.5, 0)
ButtonsFrame.ScrollBarThickness = 3

UIListLayout.Parent = ButtonsFrame
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- دالة إنشاء الأزرار
local function CreateButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = ButtonsFrame
    btn.Size = UDim2.new(0.9, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = name
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 8)
    
    btn.MouseButton1Click:Connect(callback)
end

-- منطق الـ ATM
local visitedATMs = {}

local function TeleportToATM()
    local gizmos = workspace:FindFirstChild("Local") and workspace.Local:FindFirstChild("Gizmos")
    if not gizmos then return end
    
    local found = false
    for _, atmFolder in pairs(gizmos:GetChildren()) do
        if atmFolder.Name == "ATM" and atmFolder:FindFirstChild("Metal") then
            local metalPart = atmFolder.Metal
            if not visitedATMs[metalPart] then
                visitedATMs[metalPart] = true
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = metalPart.CFrame * CFrame.new(0, 5, 0)
                print("Teleported to new ATM")
                found = true
                break
            end
        end
    end
    if not found then
        print("All ATMs visited! Press Reset.")
    end
end

-- أزرار الانتقال (Coordinates)
CreateButton("Next ATM 🏧", TeleportToATM)
CreateButton("Reset ATM Data 🔄", function()
    visitedATMs = {}
    print("ATM History Cleared")
end)

CreateButton("SELLING 💰", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2831.2, 36.9, 1736.4)
end)

CreateButton("Shop Gun 🔫", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2683.8, 39.6, 1495.8)
end)

CreateButton("Bank 🏦", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-517.8, 39.6, -1307.3)
end)

CreateButton("Diamond 💎", function()
    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-559.5, 39.8, -2941.8)
end)

-- مراقبة المؤقت (Timer)
spawn(function()
    while wait(1) do
        pcall(function()
            -- المسار الذي زودتني به
            local timerPart = workspace.Map.Locations.Bank.BankFloors.Regular.StartingFloor.Parts.Part
            -- سنبحث عن أي نص داخل الـ Part (غالباً يكون SurfaceGui أو اسم الـ Part نفسه إذا كان يتغير)
            -- إذا كان المؤقت مخزناً في اسم الـ Part:
            TimerDisplay.Text = "Bank Timer: " .. timerPart.Name 
            -- ملاحظة: إذا كان المؤقت في مكان آخر (مثل نص داخله)، يمكننا تعديل السطر أعلاه.
        end)
    end
end)

print("Script Loaded Successfully!")
