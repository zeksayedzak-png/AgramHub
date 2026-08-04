--[[
    Crystal Manager Pro - V3.6 (Size Prioritization Update)
    Features: Smart ESP, Bring All, Smooth Teleport, Speed Control, Giant Crystal Priority
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local SideFrame = Instance.new("Frame") 
local Title = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

_G.TravelSpeed = 50 

ScreenGui.Name = "CrystalHunter_V3_6"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -135, 0.5, -150)
MainFrame.Size = UDim2.new(0, 270, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

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
    btn.TextSize = 20
    
    btn.MouseButton1Click:Connect(function()
        _G.TravelSpeed = math.max(5, _G.TravelSpeed + delta)
        SpeedLabel.Text = "Travel Speed:\n" .. _G.TravelSpeed
    end)
end

CreateSpeedBtn("+", UDim2.new(0, 55, 0, 85), 5)
CreateSpeedBtn("-", UDim2.new(0, 10, 0, 85), -5)

-- دالة الحركة السلسة
local function SmoothMove(targetCFrame)
    local char = game.Players.LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local distance = (hrp.Position - targetCFrame.Position).Magnitude
    local duration = distance / _G.TravelSpeed
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame + Vector3.new(0, 5, 0)})
    
    hrp.Anchored = true
    tween:Play()
    tween.Completed:Connect(function()
        hrp.Anchored = false
    end)
end

Title.Name = "Title"
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "Crystal Manager V3.6 💎"
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
local ActiveESP = {}

local function CreateTag(target, color)
    if target:FindFirstChild("CrystalTag") then return end
    local hl = Instance.new("Highlight", target)
    hl.Name = "CrystalHighlight"
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.5

    local bg = Instance.new("BillboardGui", target)
    bg.Name = "CrystalTag"
    bg.AlwaysOnTop = true
    bg.Size = UDim2.new(0, 100, 0, 50)
    bg.ExtentsOffset = Vector3.new(0, 3, 0)

    local tl = Instance.new("TextLabel", bg)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 1
    tl.TextColor3 = Color3.fromRGB(255, 255, 255)
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 12
    return tl, hl
end

task.spawn(function()
    while task.wait(0.5) do
        local char = game.Players.LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then continue end
        local myPos = char.HumanoidRootPart.Position

        for crystalName, isActive in pairs(ActiveESP) do
            if isActive then
                local allOfThisType = {}
                for _, v in pairs(workspace.Things.Crystals:GetChildren()) do
                    if v.Name == crystalName and v:IsA("BasePart") then
                        table.insert(allOfThisType, {part = v, dist = (v.Position - myPos).Magnitude})
                    end
                end
                table.sort(allOfThisType, function(a, b) return a.dist < b.dist end)
                for i = 1, math.min(5, #allOfThisType) do
                    local crystal = allOfThisType[i].part
                    local label, highlight = CreateTag(crystal, Color3.fromRGB(0, 255, 255))
                    if label then
                        label.Parent.Enabled = true
                        highlight.Enabled = true
                        label.Text = crystalName .. "\n[" .. math.floor(allOfThisType[i].dist) .. "m]"
                    end
                end
            end
        end
    end
end)

-- دالة التيلبورت المعدلة لاستهداف الأكبر حجماً
local function TeleportToNext(crystalName)
    local allCrystals = {}
    for _, v in pairs(workspace.Things.Crystals:GetChildren()) do
        if v.Name == crystalName and v:IsA("BasePart") then 
            table.insert(allCrystals, v) 
        end
    end
    
    if #allCrystals == 0 then return end
    
    -- ترتيب الكريستالات بناءً على الحجم (الأكبر أولاً)
    table.sort(allCrystals, function(a, b)
        return a.Size.Magnitude > b.Size.Magnitude
    end)
    
    -- تصفير العداد إذا انتهت الكريستالات أو بدأت من جديد
    if not LastUsedIndex[crystalName] or LastUsedIndex[crystalName] >= #allCrystals then
        LastUsedIndex[crystalName] = 1
    else
        LastUsedIndex[crystalName] = LastUsedIndex[crystalName] + 1
    end
    
    local target = allCrystals[LastUsedIndex[crystalName]]
    SmoothMove(target.CFrame)
end

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

    local ESPBtn = Instance.new("TextButton", Frame)
    ESPBtn.Size = UDim2.new(0.3, 0, 0, 50)
    ESPBtn.Position = UDim2.new(0.02, 0, 0, 30)
    ESPBtn.Text = "Smart ESP"
    ESPBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    ESPBtn.TextColor3 = Color3.fromRGB(255,255,255)
    ESPBtn.MouseButton1Click:Connect(function()
        ActiveESP[name] = not ActiveESP[name]
        ESPBtn.BackgroundColor3 = ActiveESP[name] and Color3.fromRGB(0, 100, 0) or Color3.fromRGB(100, 0, 0)
    end)

    local BringBtn = Instance.new("TextButton", Frame)
    BringBtn.Size = UDim2.new(0.3, 0, 0, 50)
    BringBtn.Position = UDim2.new(0.35, 0, 0, 30)
    BringBtn.Text = "Bring"
    BringBtn.BackgroundColor3 = Color3.fromRGB(0, 80, 150)
    BringBtn.TextColor3 = Color3.fromRGB(255,255,255)
    BringBtn.MouseButton1Click:Connect(function()
        local char = game.Players.LocalPlayer.Character
        for _, v in pairs(workspace.Things.Crystals:GetChildren()) do
            if v.Name == name and v:IsA("BasePart") then
                v.CFrame = char.HumanoidRootPart.CFrame + Vector3.new(0, 7, 0)
                v.Anchored = false
            end
        end
    end)

    local TPNextBtn = Instance.new("TextButton", Frame)
    TPNextBtn.Size = UDim2.new(0.3, 0, 0, 50)
    TPNextBtn.Position = UDim2.new(0.68, 0, 0, 30)
    TPNextBtn.Text = "Go Big/Next"
    TPNextBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0)
    TPNextBtn.TextColor3 = Color3.fromRGB(255,255,255)
    TPNextBtn.MouseButton1Click:Connect(function() TeleportToNext(name) end)

    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 20)
end

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

local Close = Instance.new("TextButton", MainFrame)
Close.Size = UDim2.new(0, 25, 0, 25)
Close.Position = UDim2.new(1, -30, 0, 5)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
Close.TextColor3 = Color3.fromRGB(255,255,255)
Close.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
