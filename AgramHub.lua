--[[
    Script for: Crystal_T1 X-Ray & ESP
    Supported: Delta, Fluxus, Hydrogen (Mobile)
]]

local Library = {} -- نظام بسيط للواجهة
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleXray = Instance.new("TextButton")
local CollectButton = Instance.new("TextButton")
local UIListLayout = Instance.new("UIListLayout")

-- إعدادات الواجهة
ScreenGui.Name = "CrystalHub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- لون أسود
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MainFrame.Size = UDim2.new(0, 200, 0, 180)
MainFrame.Active = true
MainFrame.Draggable = true -- تفعيل السحب للهاتف

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Font = Enum.Font.GothamBold
Title.Text = "Crystal T1 Manager"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14

UIListLayout.Parent = MainFrame
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- تنسيق الأزرار
local function StyleButton(btn, text, pos)
    btn.Parent = MainFrame
    btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    btn.Size = UDim2.new(0.9, 0, 0, 40)
    btn.Font = Enum.Font.Gotham
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
end

StyleButton(ToggleXray, "تفعيل X-Ray & ESP")
StyleButton(CollectButton, "جلب كل الجواهر إلي")

-- دالة للحصول على السعر (تلقائياً)
local function GetPrice(obj)
    -- يبحث عن قيمة السعر داخل الجوهرة (تعدل حسب الماب)
    local price = obj:FindFirstChild("Price") or obj:GetAttribute("Price") or "غير معروف"
    return tostring(price)
end

-- دالة إنشاء الـ ESP والـ X-Ray
local function CreateESP(crystal)
    if not crystal:FindFirstChild("Highlight") then
        -- X-Ray (أحمر)
        local highlight = Instance.new("Highlight")
        highlight.Parent = crystal
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5

        -- لوحة المعلومات (BillboardGui)
        local bill = Instance.new("BillboardGui")
        bill.Name = "CrystalESP"
        bill.AlwaysOnTop = true
        bill.Size = UDim2.new(0, 100, 0, 50)
        bill.Adornee = crystal
        bill.MaxDistance = 5000
        bill.Parent = crystal

        local label = Instance.new("TextLabel")
        label.Parent = bill
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(1, 0, 1, 0)
        label.TextColor3 = Color3.fromRGB(255, 255, 0) -- أصفر للقراءة
        label.TextStrokeTransparency = 0
        label.TextSize = 12
        label.Font = Enum.Font.GothamBold

        -- تحديث المسافة والسعر باستمرار
        spawn(function()
            while crystal.Parent do
                local player = game.Players.LocalPlayer
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = math.floor((crystal.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                    local sizeX = math.round(crystal.Size.X * 10)/10
                    label.Text = string.format("Name: %s\nSize: %s\nPrice: %s\n[%dm]", crystal.Name, tostring(sizeX), GetPrice(crystal), dist)
                end
                task.wait(0.5)
            end
        end)
    end
end

-- تفعيل الـ ESP عند الضغط
ToggleXray.MouseButton1Click:Connect(function()
    local path = workspace:FindFirstChild("Things") and workspace.Things:FindFirstChild("Crystals")
    if path then
        for _, v in pairs(path:GetChildren()) do
            if v.Name == "Crystal_T1" or v:IsA("BasePart") then
                CreateESP(v)
            end
        end
        ToggleXray.Text = "تم التفعيل ✅"
        ToggleXray.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        warn("المسار غير موجود في هذا الماب!")
    end
end)

-- خاصية جلب الجواهر (Drop on me)
CollectButton.MouseButton1Click:Connect(function()
    local player = game.Players.LocalPlayer
    local char = player.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local path = workspace.Things.Crystals
        for _, v in pairs(path:GetChildren()) do
            if v:IsA("BasePart") then
                -- نقل الجوهرة فوق اللاعب بـ 10 أمتار لتسقط عليه
                v.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 10, 0)
                v.Anchored = false -- إلغاء التثبيت لتسقط (إذا كانت تسمح)
            end
        end
    end
end)

-- زر إغلاق صغير
local Close = Instance.new("TextButton")
Close.Parent = MainFrame
Close.Text = "X"
Close.Size = UDim2.new(0, 20, 0, 20)
Close.Position = UDim2.new(1, -25, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
