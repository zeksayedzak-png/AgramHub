--[[
    Crystal Manager Pro - V4.5 (Noclip & Smart Size Update)
]]

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local SideFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ScrollFrame = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

-- إعدادات الحالة
_G.TravelSpeed = 50 
_G.AutoFarm = false
local CurrentTarget = nil

-- إعدادات الواجهة
ScreenGui.Name = "CrystalHunter_V4_5"
ScreenGui.Parent = game.CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -135, 0.5, -150)
MainFrame.Size = UDim2.new(0, 270, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

-- اللوحة الجانبية (Settings)
SideFrame.Name = "SideFrame"
SideFrame.Parent = MainFrame
SideFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SideFrame.Position = UDim2.new(0, -110, 0, 0)
SideFrame.Size = UDim2.new(0, 105, 0, 160)
SideFrame.BorderSizePixel = 0

local SideTitle = Instance.new("TextLabel", SideFrame)
SideTitle.Size = UDim2.new(1, 0, 0, 30)
SideTitle.Text = "Settings"
SideTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
SideTitle.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SideTitle.Font = Enum.Font.GothamBold

local SpeedLabel = Instance.new("TextLabel", SideFrame)
SpeedLabel.Size = UDim2.new(1, 0, 0, 40)
SpeedLabel.Position = UDim2.new(0, 0, 0, 35)
SpeedLabel.Text = "Speed: " .. _G.TravelSpeed
SpeedLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Font = Enum.Font.GothamBold

local function CreateSpeedBtn(text, pos, delta)
    local btn = Instance.new("TextButton", SideFrame)
    btn.Size = UDim2.new(0, 40, 0, 40)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.MouseButton1Click:Connect(function()
        _G.TravelSpeed = math.max(5, _G.TravelSpeed + delta)
        SpeedLabel.Text = "Speed: " .. _G.TravelSpeed
    end)
end

CreateSpeedBtn("+", UDim2.new(0, 55, 0, 85), 5)
CreateSpeedBtn("-", UDim2.new(0, 10, 0, 85), -5)

-- وظيفة اختراق الجدران (Noclip)
local NoclipConnection
local function EnableNoclip()
    NoclipConnection = RunService.Stepped:Connect(function()
        local char = Players.LocalPlayer.Character
        if char then
            for _, v in pairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
end

local function DisableNoclip()
    if NoclipConnection then NoclipConnection:Disconnect() end
end

-- وظيفة حساب الحجم الحقيقي (للأجزاء والموديلات)
local function GetObjectSize(obj)
    if obj:IsA("BasePart") then
        return obj.Size.Magnitude
    elseif obj:IsA("Model") then
        return obj:GetExtentsSize().Magnitude
    end
    return 0
end

-- وظيفة البحث عن أكبر كريستال
local function FindLargest(crystalName)
    local largest = nil
    local maxS = 0
    local crystals = workspace.Things.Crystals:GetChildren()
    
    for _, v in pairs(crystals) do
        if v.Name == crystalName then
            local size = GetObjectSize(v)
            if size > maxS then
                maxS = size
                largest = v
            end
        end
    end
    return largest
end

-- وظيفة الحركة السلسة عبر الجدران
local function SmoothMove(target)
    if not target then return end
    local char = Players.LocalPlayer.Character
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    EnableNoclip() -- تفعيل الاختراق قبل الحركة
    
    local distance = (hrp.Position - target.Position).Magnitude
    local duration = distance / _G.TravelSpeed
    
    local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        CFrame = target.CFrame + Vector3.new(0, 3, 0)
    })
    
    tween:Play()
    tween.Completed:Wait()
    
    DisableNoclip() -- إيقاف الاختراق بعد الوصول
end

-- زر التحكم الرئيسي
local function CreateCrystalControl(name)
    local Frame = Instance.new("Frame", ScrollFrame)
    Frame.Size = UDim2.new(0.95, 0, 0, 80)
    Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

    local Label = Instance.new("TextLabel", Frame)
    Label.Size = UDim2.new(1, 0, 0, 30)
    Label.Text = "Crystal: " .. name
    Label.TextColor3 = Color3.fromRGB(255, 255, 255)
    Label.BackgroundTransparency = 1
    Label.Font = Enum.Font.GothamBold

    local ActionBtn = Instance.new("TextButton", Frame)
    ActionBtn.Size = UDim2.new(0.9, 0, 0, 40)
    ActionBtn.Position = UDim2.new(0.05, 0, 0, 35)
    ActionBtn.Text = "Start Farming Largest 💎"
    ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ActionBtn.Font = Enum.Font.GothamBold

    ActionBtn.MouseButton1Click:Connect(function()
        _G.AutoFarm = not _G.AutoFarm
        if _G.AutoFarm then
            ActionBtn.Text = "STOP"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
            
            task.spawn(function()
                while _G.AutoFarm do
                    local target = FindLargest(name)
                    if target then
                        CurrentTarget = target
                        SmoothMove(target)
                        -- انتظر حتى تختفي الكريستالة
                        repeat task.wait(1) until not target or not target.Parent or not _G.AutoFarm
                    else
                        task.wait(2) -- إذا لم يجد كريستالات ينتظر قليلاً
                    end
                end
            end)
        else
            ActionBtn.Text = "Start Farming Largest 💎"
            ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        end
    end)
end

-- تجهيز الواجهة الأساسية
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.GothamBold
Title.Text = "Crystal Manager V4.5 PRO"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)

ScrollFrame.Parent = MainFrame
ScrollFrame.Position = UDim2.new(0, 5, 0, 40)
ScrollFrame.Size = UDim2.new(1, -10, 1, -45)
ScrollFrame.BackgroundTransparency = 1
UIListLayout.Parent = ScrollFrame
UIListLayout.Padding = UDim.new(0, 10)

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
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.MouseButton1Click:Connect(function() 
    _G.AutoFarm = false 
    DisableNoclip()
    ScreenGui:Destroy() 
end)
