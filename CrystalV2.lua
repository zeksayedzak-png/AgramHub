--[[
    Crystal Manager Pro - V3 (Advanced ESP Update)
    Features: Smart ESP (Nearest 5), Distance, X-ray, Bring All, Teleport
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- إعدادات الواجهة
ScreenGui.Name = "CrystalHunter_V3"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -135, 0.5, -150)
MainFrame.Size = UDim2.new(0, 270, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "Crystal Manager V3 💎"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4

UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

-- جداول الحالة
local LastUsedIndex = {}
local ActiveESP = {} -- لتخزين الأنواع التي تم تفعيل ESP لها

-- دالة إنشاء العلامة (Tag/Xray)
local function CreateTag(target, color)
    if target:FindFirstChild("CrystalTag") then return end
    
    -- Highlight (X-Ray Effect)
    local hl = Instance.new("Highlight")
    hl.Name = "CrystalHighlight"
    hl.Parent = target
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5

    -- BillboardGui (Distance & Name)
    local bg = Instance.new("BillboardGui")
    bg.Name = "CrystalTag"
    bg.Parent = target
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 100, 0, 50)
    bg.ExtentsOffset = Vector3.new(0, 3, 0)

    local tl = Instance.new("TextLabel")
    tl.Parent = bg
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = Color3.fromRGB(255, 255, 255)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 12
    tl.TextStrokeTransparency = 0
    
    return tl, hl
end

-- دالة تنظيف الـ ESP
local function ClearESP(crystalName)
    local path = workspace.Things.Crystals
    for _, v in pairs(path:GetChildren()) do
        if v.Name == crystalName then
            if v:FindFirstChild("CrystalTag") then v.CrystalTag:Destroy() end
            if v:FindFirstChild("CrystalHighlight") then v.CrystalHighlight:Destroy() end
        end
    end
end

-- حلقة تحديث الـ ESP (أقرب 5)
task.spawn(function()
    while task.wait(0.5) do -- تحديث كل نصف ثانية لتوفير الأداء
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local myPos = char.HumanoidRootPart.Position

        for crystalName, isActive in pairs(ActiveESP) do
            if isActive then
                local allOfThisType = {}
                local path = workspace.Things.Crystals:GetChildren()

                -- جمع كل الجواهر من هذا النوع وحساب المسافة
                for _, v in pairs(path) do
                    if v.Name == crystalName and v:IsA("BasePart") then
                        local dist = (v.Position - myPos).Magnitude
                        table.insert(allOfThisType, {part = v, dist = dist})
                        -- مسح العلامات القديمة مؤقتاً
                        if v:FindFirstChild("CrystalTag") then v.CrystalTag.Enabled = false end
                        if v:FindFirstChild("CrystalHighlight") then v.CrystalHighlight.Enabled = false end
                    end
                end

                -- ترتيب حسب الأقرب
                table.sort(allOfThisType, function(a, b) return a.dist < b.dist end)

                -- تفعيل الـ ESP لأقرب 5 فقط
                for i = 1, math.min(5, #allOfThisType) do
                    local crystal = allOfThisType[i].part
                    local distance = math.floor(allOfThisType[i].dist)
                    
                    local label, highlight = CreateTag(crystal, Color3.fromRGB(0, 255, 255))
                    if label then
                        label.Parent.Enabled = true
                        highlight.Enabled = true
                        label.Text = crystalName .. "\n[" .. distance .. "m]"
                    end
                end
            end
        end
    end
end)

-- دالة جلب الجواهر (Bring All)
local function BringCrystals(crystalName)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local path = workspace.Things.Crystals
        for _, v in pairs(path:GetChildren()) do
            if v.Name == crystalName and v:IsA("BasePart") then
                v.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 7, 0)
                v.Anchored = false
            end
        end
    end
end

-- دالة التنقل (Teleport to Next)
local function TeleportToNext(crystalName)
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local allCrystals = {}
    for _, v in pairs(workspace.Things.Crystals:GetChildren()) do
        if v.Name == crystalName and v:IsA("BasePart") then
            table.insert(allCrystals, v)
        end
    end
    
    if #allCrystals == 0 then return end
    
    if not LastUsedIndex[crystalName] or LastUsedIndex[crystalName] >= #allCrystals then
        LastUsedIndex[crystalName] = 1
    else
        LastUsedIndex[crystalName] = LastUsedIndex[crystalName] + 1
    end
    
    char.HumanoidRootPart.CFrame = allCrystals[LastUsedIndex[crystalName]].CFrame + Vector3.new(0, 3, 0)
end

-- إنشاء أزرار التحكم
local function CreateCrystalControl(name)
    local Frame = Instance.new("Frame")
    local Label = Instance.new("TextLabel")
    local ESPBtn = Instance.new("TextButton")
    local BringBtn = Instance.new("TextButton")
    local TPNextBtn = Instance.new("TextButton")

    Frame.Size = UDim2.new(0.95, 0, 0, 90)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.Parent = ScrollFrame

    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.Text = "Type: " .. name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Frame

    -- زر ESP الذكي
    ESPBtn.Size = UDim2.new(0.3, 0, 0, 50)
    ESPBtn.Position = UDim2.new(0.02, 0, 0, 30)
    ESPBtn.Text = "Smart ESP"
    ESPBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    ESPBtn.TextColor3 = Color3.fromRGB(255,255,255)
    ESPBtn.Font = Enum.Font.Gotham
    ESPBtn.Parent = Frame

    ESPBtn.MouseButton1Click:Connect(function()
        ActiveESP[name] = not ActiveESP[name]
        if not ActiveESP[name] then
            ClearESP(name)
            ESPBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        else
            ESPBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
        end
    end)

    -- زر Bring
    BringBtn.Size = UDim2.new(0.3, 0, 0, 50)
    BringBtn.Position = UDim2.new(0.35, 0, 0, 30)
    BringBtn.Text = "Bring"
    BringBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
    BringBtn.TextColor3 = Color3.fromRGB(255,255,255)
    BringBtn.Font = Enum.Font.Gotham
    BringBtn.Parent = Frame
    BringBtn.MouseButton1Click:Connect(function() BringCrystals(name) end)

    -- زر TP Next
    TPNextBtn.Size = UDim2.new(0.3, 0, 0, 50)
    TPNextBtn.Position = UDim2.new(0.68, 0, 0, 30)
    TPNextBtn.Text = "TP Next"
    TPNextBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
    TPNextBtn.TextColor3 = Color3.fromRGB(255,255,255)
    TPNextBtn.Font = Enum.Font.GothamBold
    TPNextBtn.Parent = Frame
    TPNextBtn.MouseButton1Click:Connect(function() TeleportToNext(name) end)

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end

-- فحص الأنواع
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
Close.TextColor3 = Color3.fromRGB(255,255,255)
Close.MouseButton1Click:Connect(function() 
    ActiveESP = {} -- إيقاف كل الـ ESP
    ScreenGui:Destroy() 
end)
