--[[
    Zone Tracker Pro - V3.0
    المسارات المدعومة:
    - Workspace.LavaHazards
    - Workspace.CaveZones
    - Workspace.FrozenCaves
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "ZoneTracker_V3"
ScreenGui.Parent = game.CoreGui

-- إعدادات الواجهة الرئيسية
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.02, 0, 0.4, 0) -- يسار الشاشة
MainFrame.Size = UDim2.new(0, 220, 0, 200)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Zone Tracker V3 📍"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14

local Container = Instance.new("Frame", MainFrame)
Container.Position = UDim2.new(0, 5, 0, 40)
Container.Size = UDim2.new(1, -10, 1, -45)
Container.BackgroundTransparency = 1

UIListLayout.Parent = Container
UIListLayout.Padding = UDim.new(0, 5)

-- جداول لحفظ الحالة
local ActiveESPs = {
    LavaHazards = false,
    CaveZones = false,
    FrozenCaves = false
}

-- دالة إنشاء الـ ESP والمسافة
local function CreateZoneESP(part, color, category)
    if not part:IsA("BasePart") and not part:IsA("Model") then return end
    
    -- التأكد من وجود جزء أساسي للتعامل معه
    local targetPart = part:IsA("Model") and (part.PrimaryPart or part:FindFirstChildWhichIsA("BasePart")) or part
    if not targetPart then return end

    -- إنشاء الـ Highlight
    local hl = Instance.new("Highlight")
    hl.Name = "ZoneHighlight"
    hl.FillColor = color
    hl.FillTransparency = 0.5
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.Parent = part

    -- إنشاء لوحة المسافة (BillboardGui)
    local bgui = Instance.new("BillboardGui")
    bgui.Name = "ZoneDistance"
    bgui.Adornee = targetPart
    bgui.Size = UDim2.new(0, 100, 0, 50)
    bgui.StudsOffset = Vector3.new(0, 5, 0)
    bgui.AlwaysOnTop = true
    bgui.Parent = targetPart

    local text = Instance.new("TextLabel", bgui)
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = color
    text.TextStrokeTransparency = 0
    text.TextSize = 14

    -- تحديث المسافة بشكل مستمر
    task.spawn(function()
        while bgui and bgui.Parent do
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((char.HumanoidRootPart.Position - targetPart.Position).Magnitude)
                text.Text = "[" .. category .. "]\n" .. dist .. "m"
            end
            task.wait(0.1)
        end
    end)
end

-- دالة مسح الـ ESP
local function ClearESP(folderName)
    local folder = workspace:FindFirstChild(folderName, true) -- البحث في الورك سبيس
    if folder then
        for _, obj in pairs(folder:GetDescendants()) do
            if obj.Name == "ZoneHighlight" or obj.Name == "ZoneDistance" then
                obj:Destroy()
            end
        end
    end
end

-- دالة تحديث المناطق (كل 10 ثواني)
local function UpdateZones()
    for folderName, isActive in pairs(ActiveESPs) do
        if isActive then
            local folder = workspace:FindFirstChild(folderName, true)
            if folder then
                for _, zone in pairs(folder:GetChildren()) do
                    if not zone:FindFirstChild("ZoneHighlight") then
                        local color = folderName == "LavaHazards" and Color3.fromRGB(255, 50, 0) 
                                   or folderName == "CaveZones" and Color3.fromRGB(150, 150, 150)
                                   or Color3.fromRGB(0, 200, 255)
                        CreateZoneESP(zone, color, folderName)
                    end
                end
            end
        end
    end
end

-- إنشاء أزرار التحكم
local function CreateToggleButton(folderName, displayName)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = "Show " .. displayName .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12

    btn.MouseButton1Click:Connect(function()
        ActiveESPs[folderName] = not ActiveESPs[folderName]
        if ActiveESPs[folderName] then
            btn.Text = "Show " .. displayName .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
            UpdateZones() -- تفعيل فوري
        else
            btn.Text = "Show " .. displayName .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            ClearESP(folderName)
        end
    end)
end

-- إضافة الأزرار للواجهة
CreateToggleButton("LavaHazards", "Lava Hazards 🔥")
CreateToggleButton("CaveZones", "Cave Zones 🌑")
CreateToggleButton("FrozenCaves", "Frozen Caves ❄️")

-- حلقة التحديث التلقائي (كل 10 ثواني)
task.spawn(function()
    while true do
        UpdateZones()
        task.wait(10) -- يفحص المجلدات كل 10 ثواني لظهور مناطق جديدة
    end
end)

-- زر الإغلاق
local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0, 20, 0, 20)
Close.Position = UDim2.new(1, -25, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
