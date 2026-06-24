--[[
    Dynamic Crystal Manager (T1, T2, T3, etc.)
    Supported: Delta, Fluxus, Hydrogen
]]

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- إعدادات الواجهة الأساسية
ScreenGui.Name = "CrystalManagerPro"
ScreenGui.Parent = game.CoreGui

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -150)
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Active = true
MainFrame.Draggable = true -- للسحب باللمس

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "Crystal Multi-Tool 💎"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 16

ScrollFrame.Name = "ScrollFrame"
ScrollFrame.Parent = MainFrame
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) -- يتعدل تلقائياً
ScrollFrame.ScrollBarThickness = 4

UIListLayout.Parent = ScrollFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- دالة إنشاء ESP لنوع معين
local function ToggleESP(crystalName, state)
    local path = workspace.Things.Crystals
    for _, v in pairs(path:GetChildren()) do
        if v.Name == crystalName and v:IsA("BasePart") then
            if state then
                -- إنشاء Highlight
                if not v:FindFirstChild("Highlight") then
                    local hl = Instance.new("Highlight", v)
                    hl.FillColor = Color3.fromRGB(255, 0, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
                -- إنشاء معلومات (اسم، سعر، مسافة)
                if not v:FindFirstChild("CrystalESP") then
                    local bill = Instance.new("BillboardGui", v)
                    bill.Name = "CrystalESP"
                    bill.AlwaysOnTop = true
                    bill.Size = UDim2.new(0, 100, 0, 50)
                    local lbl = Instance.new("TextLabel", bill)
                    lbl.Size = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
                    lbl.TextStrokeTransparency = 0
                    lbl.TextSize = 10
                    lbl.Font = Enum.Font.GothamBold
                    
                    spawn(function()
                        while v.Parent and v:FindFirstChild("CrystalESP") do
                            local dist = math.floor((v.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
                            lbl.Text = string.format("%s\nDist: [%dm]", v.Name, dist)
                            task.wait(1)
                        end
                    end)
                end
            else
                -- حذف الـ ESP
                if v:FindFirstChild("Highlight") then v.Highlight:Destroy() end
                if v:FindFirstChild("CrystalESP") then v.CrystalESP:Destroy() end
            end
        end
    end
end

-- دالة نقل نوع معين من الكريستال
local function TeleportCrystals(crystalName)
    local char = game.Players.LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local path = workspace.Things.Crystals
        for _, v in pairs(path:GetChildren()) do
            if v.Name == crystalName and v:IsA("BasePart") then
                v.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 5, 0)
                v.Anchored = false -- لجعلها تسقط عليك
            end
        end
    end
end

-- دالة صنع "بلوك" الأزرار لكل نوع
local function CreateCrystalControl(name)
    local Frame = Instance.new("Frame")
    local Label = Instance.new("TextLabel")
    local ESPBtn = Instance.new("TextButton")
    local TPBtn = Instance.new("TextButton")

    Frame.Size = UDim2.new(0.95, 0, 0, 60)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Frame.Parent = ScrollFrame

    Label.Size = UDim2.new(1, 0, 0, 25)
    Label.Text = "Type: " .. name
    Label.TextColor3 = Color3.fromRGB(255, 215, 0)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold
    Label.Parent = Frame

    ESPBtn.Size = UDim2.new(0.45, 0, 0, 25)
    ESPBtn.Position = UDim2.new(0, 5, 0, 30)
    ESPBtn.Text = "ESP: OFF"
    ESPBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    ESPBtn.TextColor3 = Color3.fromRGB(255,255,255)
    ESPBtn.Parent = Frame

    local espActive = false
    ESPBtn.MouseButton1Click:Connect(function()
        espActive = not espActive
        ToggleESP(name, espActive)
        ESPBtn.Text = espActive and "ESP: ON" or "ESP: OFF"
        ESPBtn.BackgroundColor3 = espActive and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
    end)

    TPBtn.Size = UDim2.new(0.45, 0, 0, 25)
    TPBtn.Position = UDim2.new(0.52, 0, 0, 30)
    TPBtn.Text = "Bring All"
    TPBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 150)
    TPBtn.TextColor3 = Color3.fromRGB(255,255,255)
    TPBtn.Parent = Frame

    TPBtn.MouseButton1Click:Connect(function()
        TeleportCrystals(name)
    end)

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end

-- الفحص التلقائي للأنواع الموجودة في الماب
local function ScanCrystals()
    local path = workspace:WaitForChild("Things"):WaitForChild("Crystals")
    local foundTypes = {}

    for _, v in pairs(path:GetChildren()) do
        if not foundTypes[v.Name] then
            foundTypes[v.Name] = true
            CreateCrystalControl(v.Name)
        end
    end
end

-- بدء التشغيل
ScanCrystals()

-- زر إغلاق
local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -30, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Close.TextColor3 = Color3.fromRGB(255,255,255)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
