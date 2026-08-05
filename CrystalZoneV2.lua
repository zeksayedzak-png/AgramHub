--[[
    Zone Tracker Pro - V3.1
    المسارات المدعومة:
    - Workspace.LavaHazards
    - Workspace.CaveZones
    - Workspace.FrozenCaves
    - Workspace.BombveinMarkerAnchor.BombveinBB (الجديد)
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local UIListLayout = Instance.new("UIListLayout")
local UICorner = Instance.new("UICorner")

ScreenGui.Name = "ZoneTracker_V3_1"
ScreenGui.Parent = game.CoreGui

-- إعدادات الواجهة الرئيسية
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.02, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 250) -- زدنا الطول شوي عشان الزر الجديد
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Zone Tracker V3.1 📍"
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
    FrozenCaves = false,
    BombveinBB = false -- الحالة الافتراضية
}

-- دالة إنشاء الـ ESP والمسافة
local function CreateZoneESP(part, color, category)
    if not part:IsA("BasePart") and not part:IsA("Model") then return end
    
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
    bgui.StudsOffset = Vector3.new(0, 3, 0)
    bgui.AlwaysOnTop = true
    bgui.Parent = targetPart

    local text = Instance.new("TextLabel", bgui)
    text.BackgroundTransparency = 1
    text.Size = UDim2.new(1, 0, 1, 0)
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = color
    text.TextStrokeTransparency = 0
    text.TextSize = 14

    task.spawn(function()
        while bgui and bgui.Parent do
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((char.HumanoidRootPart.Position - targetPart.Position).Magnitude)
                text.Text = "[" .. category .. "]\n[" .. dist .. "m]"
            end
            task.wait(0.1)
        end
    end)
end

-- دالة مسح الـ ESP
local function ClearESP(folderName)
    -- للبحث في كل مكان (بما في ذلك المسارات العميقة مثل Bombvein)
    for _, obj in pairs(workspace:GetDescendants()) do
        if (obj.Name == "ZoneHighlight" or obj.Name == "ZoneDistance") and obj:GetAttribute("Category") == folderName then
            obj:Destroy()
        end
    end
end

-- دالة تحديث المناطق
local function UpdateZones()
    for folderName, isActive in pairs(ActiveESPs) do
        if isActive then
            local targets = {}
            
            -- التعامل الخاص مع Bombvein بسبب مساره المختلف
            if folderName == "BombveinBB" then
                local anchor = workspace:FindFirstChild("BombveinMarkerAnchor", true)
                if anchor then
                    for _, child in pairs(anchor:GetChildren()) do
                        if child.Name == "BombveinBB" then
                            table.insert(targets, child)
                        end
                    end
                end
            else
                -- المناطق العادية
                local folder = workspace:FindFirstChild(folderName, true)
                if folder then
                    targets = folder:GetChildren()
                end
            end

            -- تطبيق الـ ESP
            for _, zone in pairs(targets) do
                if not zone:FindFirstChild("ZoneHighlight") then
                    local color = folderName == "LavaHazards" and Color3.fromRGB(255, 50, 0) 
                               or folderName == "CaveZones" and Color3.fromRGB(150, 150, 150)
                               or folderName == "FrozenCaves" and Color3.fromRGB(0, 200, 255)
                               or Color3.fromRGB(255, 0, 255) -- لون بنفسجي للـ Bombvein
                    
                    CreateZoneESP(zone, color, folderName)
                    -- تعليم الـ ESP عشان المسح
                    if zone:FindFirstChild("ZoneHighlight") then
                        zone.ZoneHighlight:SetAttribute("Category", folderName)
                    end
                    if zone:FindFirstChild("ZoneDistance") then
                        zone.ZoneDistance:SetAttribute("Category", folderName)
                    end
                end
            end
        end
    end
end

-- إنشاء أزرار التحكم
local function CreateToggleButton(folderName, displayName)
    local btn = Instance.new("TextButton", Container)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.Text = "Show " .. displayName .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

    btn.MouseButton1Click:Connect(function()
        ActiveESPs[folderName] = not ActiveESPs[folderName]
        if ActiveESPs[folderName] then
            btn.Text = "Show " .. displayName .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
            UpdateZones()
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
CreateToggleButton("BombveinBB", "Bomb Veins 💣") -- الزر الجديد

-- حلقة التحديث التلقائي
task.spawn(function()
    while true do
        UpdateZones()
        task.wait(5) -- فحص كل 5 ثواني
    end
end)

-- زر الإغلاق
local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0, 20, 0, 20)
Close.Position = UDim2.new(1, -25, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", Close)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
