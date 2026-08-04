--[[
    Crystal Manager Pro - V2.2 (Timing Bypass Update)
    التعديل: إضافة تأخير 0.3 ثانية بعد الضغط على زر التأكيد لضمان نجاح البايباس
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- إعدادات الواجهة
ScreenGui.Name = "CrystalHunter_V2"
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
Title.Text = "Crystal Manager V2.2 💎"
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

local LastUsedIndex = {}

-- دالة الـ ESP
local function ToggleESP(crystalName, state)
    local path = workspace.Things.Crystals
    for _, v in pairs(path:GetChildren()) do
        if v.Name == crystalName and v:IsA("BasePart") then
            if state then
                if not v:FindFirstChild("Highlight") then
                    Instance.new("Highlight", v).FillColor = Color3.fromRGB(255, 0, 0)
                end
            else
                if v:FindFirstChild("Highlight") then v.Highlight:Destroy() end
            end
        end
    end
end

-- دالة جلب الجواهر
local function BringCrystals(crystalName)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        for _, v in pairs(workspace.Things.Crystals:GetChildren()) do
            if v.Name == crystalName and v:IsA("BasePart") then
                v.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 7, 0)
                v.Anchored = false
            end
        end
    end
end

-- دالة الضغط على الزر (Bypass)
local function PressBypassButton()
    pcall(function()
        local player = game.Players.LocalPlayer
        local btn = player.PlayerGui.ExplorerHud.ConfirmHome.Yes
        
        -- محاكاة الضغط
        if btn then
            -- استخدام الكود المناسب للمحقنات لتفعيل الأزرار
            if firesignal then
                firesignal(btn.MouseButton1Click)
                firesignal(btn.Activated)
            else
                -- طريقة احتياطية إذا كان المحقن لا يدعم firesignal
                for _, connection in pairs(getconnections(btn.MouseButton1Click)) do
                    connection:Fire()
                end
            end
        end
    end)
end

-- دالة التنقل الذكية مع التأخير المطلوب
local function TeleportToNext(crystalName)
    local char = game.Players.LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local path = workspace.Things.Crystals
    local allCrystals = {}
    
    for _, v in pairs(path:GetChildren()) do
        if v.Name == crystalName and v:IsA("BasePart") then
            table.insert(allCrystals, v)
        end
    end
    
    if #allCrystals == 0 then return end
    
    -- اختيار الكريستالة التالية
    if not LastUsedIndex[crystalName] or LastUsedIndex[crystalName] >= #allCrystals then
        LastUsedIndex[crystalName] = 1
    else
        LastUsedIndex[crystalName] = LastUsedIndex[crystalName] + 1
    end
    
    local target = allCrystals[LastUsedIndex[crystalName]]
    
    -- [الخطوة 1] الضغط على الزر أولاً
    PressBypassButton()
    
    -- [الخطوة 2] الانتظار 0.3 ثانية (لحل مشكلة التأخير في اللعبة)
    task.wait(0.3)
    
    -- [الخطوة 3] الانتقال للكريستالة
    char.HumanoidRootPart.CFrame = target.CFrame + Vector3.new(0, 3, 0)
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

    ESPBtn.Size = UDim2.new(0.3, 0, 0, 50)
    ESPBtn.Position = UDim2.new(0.02, 0, 0, 30)
    ESPBtn.Text = "ESP"
    ESPBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    ESPBtn.TextColor3 = Color3.fromRGB(255,255,255)
    ESPBtn.Parent = Frame
    local espActive = false
    ESPBtn.MouseButton1Click:Connect(function()
        espActive = not espActive
        ToggleESP(name, espActive)
        ESPBtn.BackgroundColor3 = espActive and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    end)

    BringBtn.Size = UDim2.new(0.3, 0, 0, 50)
    BringBtn.Position = UDim2.new(0.35, 0, 0, 30)
    BringBtn.Text = "Bring"
    BringBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
    BringBtn.TextColor3 = Color3.fromRGB(255,255,255)
    BringBtn.Parent = Frame
    BringBtn.MouseButton1Click:Connect(function() BringCrystals(name) end)

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
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
