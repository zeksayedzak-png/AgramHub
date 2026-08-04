--[[
    Crystal Manager Pro - V4.0 (Heavy Weight/Size Update)
    Features: Target Largest, Auto-Stay, Smooth Travel, Speed Control
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local SideFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- إعدادات الحالة
_G.TravelSpeed = 50 
local CurrentTarget = nil -- لتخزين الكريستال الحالي
local IsMoving = false

-- إعدادات الواجهة
ScreenGui.Name = "CrystalHunter_V4"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -135, 0.5, -150)
MainFrame.Size = UDim2.new(0, 270, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

-- اللوحة الجانبية لإعدادات السرعة
SideFrame.Name = "SideFrame"
SideFrame.Parent = MainFrame
SideFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SideFrame.Position = UDim2.new(0, -110, 0, 0)
SideFrame.Size = UDim2.new(0, 105, 0, 150)
SideFrame.BorderSizePixel = 0

local SideTitle = Instance.new("TextLabel", SideFrame)
SideTitle.Size = UDim2.new(1, 0, 0, 30)
SideTitle.Text = "Settings"
SideTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SideTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SideTitle.Font = Enum.Font.GothamBold
SideTitle.TextSize = 14

local SpeedLabel = Instance.new("TextLabel", SideFrame)
SpeedLabel.Size = UDim2.new(1, 0, 0, 40)
SpeedLabel.Position = UDim2.new(0, 0, 0, 35)
SpeedLabel.Text = "Travel Speed:\n" .. _G.TravelSpeed
SpeedLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextSize = 12

local function CreateSpeedBtn(text, pos, delta)
    local btn = Instance.new("TextButton", SideFrame)
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.MouseButton1Click:Connect(function()
        _G.TravelSpeed = math.max(10, _G.TravelSpeed + delta)
        SpeedLabel.Text = "Travel Speed:\n" .. _G.TravelSpeed
    end)
end

CreateSpeedBtn("+", UDim2.new(0, 55, 0, 85), 5)
CreateSpeedBtn("-", UDim2.new(0, 10, 0, 85), -5)

-- دالة البحث عن أكبر كريستال من النوع المحدد
local function FindLargestCrystal(crystalName)
    local path = workspace.Things.Crystals:GetChildren()
    local largest = nil
    local maxVolume = 0

    for _, v in pairs(path) do
        if v.Name == crystalName and v:IsA("BasePart") then
            -- حساب الحجم (الطول * العرض * الارتفاع)
            local volume = v.Size.X * v.Size.Y * v.Size.Z
            if volume > maxVolume then
                maxVolume = volume
                largest = v
            end
        end
    end
    return largest
end

-- دالة الحركة السلسة
local function SmoothMoveTo(target)
    if not target or IsMoving then return end
    IsMoving = true
    
    local char = game.Players.LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    
    while target and target.Parent and target:IsDescendantOf(workspace) do
        local dist = (hrp.Position - target.Position).Magnitude
        if dist < 5 then 
            hrp.CFrame = target.CFrame + Vector3.new(0, 3, 0)
            break 
        end
        
        -- تحريك تدريجي نحو الهدف
        local direction = (target.Position - hrp.Position).Unit
        hrp.Velocity = direction * _G.TravelSpeed
        hrp.CFrame = CFrame.lookAt(hrp.Position, target.Position)
        
        task.wait()
    end
    
    hrp.Velocity = Vector3.new(0,0,0)
    IsMoving = false
end

-- زر التحكم في الكريستال
local function CreateCrystalControl(name)
    local Frame = Instance.new("Frame", ScrollFrame)
    Frame.Size = UDim2.new(0.95, 0, 0, 90)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.Text = "Type: " .. name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold

    -- زر البحث والذهاب للأكبر
    local GoBtn = Instance.new("TextButton", Frame)
    GoBtn.Size = UDim2.new(0.9, 0, 0, 45)
    GoBtn.Position = UDim2.new(0.05, 0, 0, 35)
    GoBtn.Text = "Go to Largest 💎"
    GoBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    GoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GoBtn.Font = Enum.Font.GothamBold

    GoBtn.MouseButton1Click:Connect(function()
        local target = FindLargestCrystal(name)
        if target then
            CurrentTarget = target
            task.spawn(function()
                SmoothMoveTo(target)
                -- بعد الوصول، إذا اختفت، يبحث عن الكبيرة التالية تلقائياً
                while CurrentTarget == target and (not target or not target.Parent) do
                    task.wait(1)
                    local nextBig = FindLargestCrystal(name)
                    if nextBig then
                        target = nextBig
                        SmoothMoveTo(target)
                    end
                end
            end)
        end
    end)
end

-- واجهة العناوين والسكروول
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "Crystal Manager V4.0 💎"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 4
UIListLayout.Parent = ScrollFrame
UIListLayout.Padding = UDim.new(0, 10)

-- فحص الأنواع الموجودة في الماب
local function Scan()
    local path = workspace:WaitForChild("Things"):WaitForChild("Crystals")
    local found = {}
    for _, v in pairs(path:GetChildren()) do
        if not found[v.Name] then
            found[v.Name] = true
            CreateCrystalControl(v.Name)
        end
    end
end
Scan()

-- زر الإغلاق
local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -30, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
