--[[
    Crystal Manager Pro - V2.3 (Smart Tracking & Reset Update)
    التحديثات:
    1. نظام الحفظ: عدم تكرار الكريستالات التي تمت زيارتها.
    2. زر Reset: مسح ذاكرة الكريستالات المزارة.
    3. زر ResTer: تكرار النقل لآخر كريستالة تم الوقوف عليها.
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- جداول حفظ الحالة
local VisitedCrystals = {} -- لحفظ الكريستالات التي تم زيارتها
local LastCrystalRef = {}   -- لحفظ آخر كريستالة تم الانتقال إليها لكل نوع

-- إعدادات الواجهة
ScreenGui.Name = "CrystalHunter_V2_3"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -150)
MainFrame.Size = UDim2.new(0, 300, 0, 350)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "Crystal Manager V2.3 💎"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14

-- زر ريست العام (في الأعلى يسار)
local ResetAllBtn = Instance.new("TextButton", MainFrame)
ResetAllBtn.Size = UDim2.new(0, 60, 0, 25)
ResetAllBtn.Position = UDim2.new(0, 5, 0, 5)
ResetAllBtn.Text = "Reset All"
ResetAllBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
ResetAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetAllBtn.Font = Enum.Font.GothamBold
ResetAllBtn.TextSize = 10
ResetAllBtn.MouseButton1Click:Connect(function()
    VisitedCrystals = {}
    LastCrystalRef = {}
    print("Memory Cleared!")
end)

ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Position = UDim2.new(0, 5, 0, 45)
ScrollFrame.Size = UDim2.new(1, -10, 1, -55)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ScrollBarThickness = 4

UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

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

-- دالة البايباس (الضغط على زر Yes)
local function PressBypass()
    pcall(function()
        local btn = game.Players.LocalPlayer.PlayerGui.ExplorerHud.ConfirmHome.Yes
        if firesignal then
            firesignal(btn.MouseButton1Click)
        else
            for _, c in pairs(getconnections(btn.MouseButton1Click)) do c:Fire() end
        end
    end)
end

-- دالة الانتقال الفعلي
local function PerformTeleport(targetPart)
    if targetPart and targetPart.Parent then
        PressBypass()
        task.wait(0.3)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 3, 0)
        end
    end
end

-- دالة التنقل للجوهرة التالية (بدون تكرار)
local function TeleportToNext(crystalName)
    local path = workspace.Things.Crystals
    local target = nil
    
    if not VisitedCrystals[crystalName] then VisitedCrystals[crystalName] = {} end
    
    for _, v in pairs(path:GetChildren()) do
        if v.Name == crystalName and v:IsA("BasePart") then
            -- التأكد أن الجوهرة لم يتم زيارتها من قبل
            if not table.find(VisitedCrystals[crystalName], v) then
                target = v
                break
            end
        end
    end
    
    if target then
        table.insert(VisitedCrystals[crystalName], target) -- حفظها في القائمة المزارة
        LastCrystalRef[crystalName] = target -- حفظها كآخر هدف لزر ResTer
        PerformTeleport(target)
    else
        warn("No more new crystals of this type! Press Reset.")
    end
end

-- دالة إعادة النقل لنفس الكريستالة (ResTer)
local function ResTerTeleport(crystalName)
    local target = LastCrystalRef[crystalName]
    if target and target.Parent then
        PerformTeleport(target)
    else
        warn("No last crystal found or it was destroyed!")
    end
end

-- دالة إنشاء أزرار التحكم
local function CreateCrystalControl(name)
    local Frame = Instance.new("Frame")
    local Label = Instance.new("TextLabel")
    local ESPBtn = Instance.new("TextButton")
    local BringBtn = Instance.new("TextButton")
    local TPNextBtn = Instance.new("TextButton")
    local ResTerBtn = Instance.new("TextButton")

    Frame.Size = UDim2.new(0.95, 0, 0, 100)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Frame.Parent = ScrollFrame

    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.Text = "Type: " .. name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Frame

    -- زر ESP
    ESPBtn.Size = UDim2.new(0.22, 0, 0, 45)
    ESPBtn.Position = UDim2.new(0.02, 0, 0, 35)
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

    -- زر Bring
    BringBtn.Size = UDim2.new(0.22, 0, 0, 45)
    BringBtn.Position = UDim2.new(0.26, 0, 0, 35)
    BringBtn.Text = "Bring"
    BringBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
    BringBtn.TextColor3 = Color3.fromRGB(255,255,255)
    BringBtn.Parent = Frame
    BringBtn.MouseButton1Click:Connect(function()
        local char = game.Players.LocalPlayer.Character
        for _, v in pairs(workspace.Things.Crystals:GetChildren()) do
            if v.Name == name and v:IsA("BasePart") then
                v.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 7, 0)
                v.Anchored = false
            end
        end
    end)

    -- زر TP Next (الجديد كلياً)
    TPNextBtn.Size = UDim2.new(0.22, 0, 0, 45)
    TPNextBtn.Position = UDim2.new(0.50, 0, 0, 35)
    TPNextBtn.Text = "TP Next"
    TPNextBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 0)
    TPNextBtn.TextColor3 = Color3.fromRGB(255,255,255)
    TPNextBtn.Font = Enum.Font.GothamBold
    TPNextBtn.Parent = Frame
    TPNextBtn.MouseButton1Click:Connect(function() TeleportToNext(name) end)

    -- زر ResTer (إعادة النقل)
    ResTerBtn.Size = UDim2.new(0.22, 0, 0, 45)
    ResTerBtn.Position = UDim2.new(0.74, 0, 0, 35)
    ResTerBtn.Text = "ResTer"
    ResTerBtn.BackgroundColor3 = Color3.fromRGB(120, 120, 0)
    ResTerBtn.TextColor3 = Color3.fromRGB(255,255,255)
    ResTerBtn.Font = Enum.Font.GothamBold
    ResTerBtn.Parent = Frame
    ResTerBtn.MouseButton1Click:Connect(function() ResTerTeleport(name) end)

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end

-- فحص الأنواع تلقائياً
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
