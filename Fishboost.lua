-- Roblox Auto Clicker (Fixed Dragging & Click Methods)
local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- 1. إنشاء الواجهة
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoClickerGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 180)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -90) -- منتصف الشاشة
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- العنوان (المنطقة المخصصة لتحريك الواجهة)
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Worming Controller (Drag Here)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- نص إظهار السرعة
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 25)
SpeedLabel.Position = UDim2.new(0, 0, 0, 35)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 1.5s"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 14
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = MainFrame

-- خط السحب (Slider Bar)
local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(0, 200, 0, 6)
SliderBar.Position = UDim2.new(0.5, -100, 0, 75)
SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = MainFrame

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = SliderBar

-- زر/دائرة السحب (Slider Knob)
local SliderKnob = Instance.new("TextButton")
SliderKnob.Size = UDim2.new(0, 22, 0, 22)
SliderKnob.Position = UDim2.new(0.5, -11, 0.5, -11)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.BorderSizePixel = 0
SliderKnob.Text = ""
SliderKnob.Parent = SliderBar

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = SliderKnob

-- زر التشغيل والإيقاف (Select)
local SelectBtn = Instance.new("TextButton")
SelectBtn.Size = UDim2.new(0, 200, 0, 40)
SelectBtn.Position = UDim2.new(0.5, -100, 0, 115)
SelectBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50) -- أحمر
SelectBtn.Text = "Select"
SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectBtn.TextSize = 16
SelectBtn.Font = Enum.Font.GothamBold
SelectBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = SelectBtn

-- المتغيرات
local isClicking = false
local currentDelay = 1.5
local minDelay = 0.1
local maxDelay = 3.0
local draggingKnob = false

-- 2. نظام تحريك الواجهة من العنوان فقط
local draggingFrame = false
local dragStart = nil
local startPos = nil

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFrame = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingFrame and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingFrame = false
    end
end)

-- 3. نظام السحب والتحكم بالسرعة (Slider)
local function updateSlider(input)
    local barPos = SliderBar.AbsolutePosition.X
    local barWidth = SliderBar.AbsoluteSize.X
    local inputPos = input.Position.X
    
    local percentage = math.clamp((inputPos - barPos) / barWidth, 0, 1)
    SliderKnob.Position = UDim2.new(percentage, -11, 0.5, -11)
    
    -- حساب السرعة (اليمين أسرع = 0.1s / اليسار أبطأ = 3.0s)
    currentDelay = math.floor((maxDelay - (percentage * (maxDelay - minDelay))) * 10) / 10
    if currentDelay < 0.1 then currentDelay = 0.1 end
    SpeedLabel.Text = "Speed: " .. tostring(currentDelay) .. "s"
end

SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingKnob = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingKnob = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingKnob and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- 4. دالة ضغط فائقة التوافق مع المشغلات
local function clickTarget(btn)
    if firesignal then
        pcall(function()
            firesignal(btn.MouseButton1Click)
            firesignal(btn.MouseButton1Down)
            firesignal(btn.MouseButton1Up)
            firesignal(btn.Activated)
        end)
    else
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(btn.AbsolutePosition.X + (btn.AbsoluteSize.X / 2), btn.AbsolutePosition.Y + (btn.AbsoluteSize.Y / 2)))
        end)
    end
end

-- زر التفعيل
SelectBtn.MouseButton1Click:Connect(function()
    isClicking = not isClicking
    
    if isClicking then
        SelectBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- أخضر عند التشغيل
        SelectBtn.Text = "Active"
    else
        SelectBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50) -- أحمر عند الإيقاف
        SelectBtn.Text = "Select"
    end
end)

-- 5. حلقة المراقبة والضغط المستمر
task.spawn(function()
    while true do
        if isClicking then
            local fishingGui = PlayerGui:FindFirstChild("FishingGui")
            if fishingGui then
                local fishing = fishingGui:FindFirstChild("Fishing")
                if fishing then
                    local targetBtn = fishing:FindFirstChild("ClickSpeedUpActive")
                    if targetBtn and targetBtn.Visible then
                        clickTarget(targetBtn)
                    end
                end
            end
        end
        task.wait(currentDelay)
    end
end)
