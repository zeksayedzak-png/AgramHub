-- Worming Clicker & Tracker
-- GitHub: your-username/roblox-scripts

local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- 1. إنشاء الواجهة الرئيسية
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WormingClickerUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 220)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Worming Clicker"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- 2. زر التشغيل والإيقاف (Select)
local SelectBtn = Instance.new("TextButton")
SelectBtn.Size = UDim2.new(1, -30, 0, 45)
SelectBtn.Position = UDim2.new(0, 15, 0, 45)
SelectBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50) -- أحمر (إيقاف)
SelectBtn.Text = "OFF"
SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectBtn.TextScaled = true
SelectBtn.Font = Enum.Font.GothamBold
SelectBtn.Parent = MainFrame

local SelectCorner = Instance.new("UICorner")
SelectCorner.CornerRadius = UDim.new(0, 8)
SelectCorner.Parent = SelectBtn

-- 3. نص إظهار السرعة
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, -30, 0, 25)
SpeedLabel.Position = UDim2.new(0, 15, 0, 105)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Delay: 1.00s"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextScaled = true
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = MainFrame

-- 4. خط السحب (Slider Frame)
local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(1, -30, 0, 10)
SliderBar.Position = UDim2.new(0, 15, 0, 145)
SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = MainFrame

local SliderBarCorner = Instance.new("UICorner")
SliderBarCorner.CornerRadius = UDim.new(1, 0)
SliderBarCorner.Parent = SliderBar

-- 5. الدائرة المتحركة (Slider Knob)
local SliderKnob = Instance.new("ImageButton")
SliderKnob.Size = UDim2.new(0, 24, 0, 24)
SliderKnob.Position = UDim2.new(0.3, -12, 0.5, -12) -- القيمة الافتراضية
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.AutoButtonColor = false
SliderKnob.Parent = SliderBar

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = SliderKnob

-- المتغيرات الأساسية
local isRunning = false
local currentDelay = 1.0 -- السرعة الافتراضية 1 ثانية
local minDelay = 0.1
local maxDelay = 3.0

-- دالة تحريك السلايدر وحساب السرعة
local UserInputService = game:GetService("UserInputService")
local dragging = false

SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local mousePos = input.Position.X
        local barPos = SliderBar.AbsolutePosition.X
        local barSize = SliderBar.AbsoluteSize.X
        
        local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
        SliderKnob.Position = UDim2.new(percent, -12, 0.5, -12)
        
        -- حساب التأخير (اليسار = 0.1 ثانية، اليمين = 3 ثواني)
        currentDelay = minDelay + (percent * (maxDelay - minDelay))
        SpeedLabel.Text = string.format("Delay: %.2fs", currentDelay)
    end
end)

-- دالة المحاكاة والنقر على الزر المطلوب
local function getTargetButton()
    local success, result = pcall(function()
        return player.PlayerGui.FishingGui.Fishing.ClickSpeedUpActive
    end)
    if success and result and result:IsA("GuiObject") and result.Visible then
        return result
    end
    return nil
end

local function triggerClick(btn)
    -- محاكاة الضغط على أزرار Roblox Lua
    for _, connection in pairs(getconnections(btn.MouseButton1Click)) do
        connection:Fire()
    end
    for _, connection in pairs(getconnections(btn.MouseButton1Down)) do
إليك السكريبت الكامل بالشروط المطلوب تنفيذها:

### مميزات السكريبت:
1. **شريط منزلق (Slider):** يمكنك سحبه يمينًا ويسارًا للتحكم بالسرعة من `3` ثوانٍ إلى `0.1` ثانية.
2. **زر Select تفاعلي:** 
   * عند التفعيل: يصبح لونه **أخضر** ويتحول النص إلى **"Active"**.
   * عند الإيقاف: يصبح لونه **أحمر** ويتحول النص إلى **"Select"**.
3. **مراقبة وضغط مستمر:** يراقب الزر `ClickSpeedUpActive` عند ظهوره في المسار المحدد ويبدأ بالضغط التلقائي بناءً على السرعة المحددة بالسلايدر.

---

### الكود:

```lua
-- Roblox Auto Clicker & Speed Controller
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- إنشاء الواجهة الشفافة والـ ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AutoClickerGUI"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 180)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -90)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- عنوان الواجهة
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Auto Clicker Speed"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- عرض القيمة الحالية للسرعة
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Size = UDim2.new(1, 0, 0, 25)
SpeedLabel.Position = UDim2.new(0, 0, 0, 35)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.Text = "Speed: 1.5s"
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.TextSize = 14
SpeedLabel.Font = Enum.Font.Gotham
SpeedLabel.Parent = MainFrame

-- خلفية الشريط (Line)
local SliderBar = Instance.new("Frame")
SliderBar.Size = UDim2.new(0, 200, 0, 6)
SliderBar.Position = UDim2.new(0.5, -100, 0, 75)
SliderBar.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
SliderBar.BorderSizePixel = 0
SliderBar.Parent = MainFrame

local BarCorner = Instance.new("UICorner")
BarCorner.CornerRadius = UDim.new(1, 0)
BarCorner.Parent = SliderBar

-- الدائرة المتحركة (Knob)
local SliderKnob = Instance.new("Frame")
SliderKnob.Size = UDim2.new(0, 18, 0, 18)
SliderKnob.Position = UDim2.new(0.5, -9, 0.5, -9)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.BorderSizePixel = 0
SliderKnob.Parent = SliderBar

local KnobCorner = Instance.new("UICorner")
KnobCorner.CornerRadius = UDim.new(1, 0)
KnobCorner.Parent = SliderKnob

-- زر التشغيل الإيقاف (Select)
local SelectBtn = Instance.new("TextButton")
SelectBtn.Size = UDim2.new(0, 200, 0, 40)
SelectBtn.Position = UDim2.new(0.5, -100, 0, 115)
SelectBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50) -- أحمر في البداية
SelectBtn.Text = "Select"
SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectBtn.TextSize = 16
SelectBtn.Font = Enum.Font.GothamBold
SelectBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = SelectBtn

-- المتغيرات الأساسية
local isClicking = false
local currentDelay = 1.5 -- السرعة الافتراضية
local minDelay = 0.1
local maxDelay = 3.0
local dragging = false

-- التحكم بالسلايدر (السحب والتحريك)
local function updateSlider(input)
    local barPos = SliderBar.AbsolutePosition.X
    local barWidth = SliderBar.AbsoluteSize.X
    local inputPos = input.Position.X
    
    local percentage = math.clamp((inputPos - barPos) / barWidth, 0, 1)
    SliderKnob.Position = UDim2.new(percentage, -9, 0.5, -9)
    
    -- حساب السرعة عكسياً (اليمين أسرع = قيم أقل / اليسار أبطأ = قيم أعلى)
    currentDelay = math.floor((maxDelay - (percentage * (maxDelay - minDelay))) * 10) / 10
    SpeedLabel.Text = "Speed: " .. tostring(currentDelay) .. "s"
end

SliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        updateSlider(input)
    end
end)

-- محاكاة الضغط الفعلي على الزر
local function clickButton(btn)
    if btn and btn:IsA("GuiObject") then
        local pos = btn.AbsolutePosition
        local size = btn.AbsoluteSize
        local centerX = pos.X + (size.X / 2)
        local centerY = pos.Y + (size.Y / 2) + 36 -- تعويض شريط العنوان
        
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, true, game, 0)
        task.wait(0.02)
        VirtualInputManager:SendMouseButtonEvent(centerX, centerY, 0, false, game, 0)
    end
end

-- زر التفعيل والإيقاف
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

-- حلقة المراقبة والضغط المستمر
task.spawn(function()
    while true do
        if isClicking then
            -- البحث الديناميكي عن الزر داخل الشاشة
            local fishingGui = PlayerGui:FindFirstChild("FishingGui")
            if fishingGui then
                local fishing = fishingGui:FindFirstChild("Fishing")
                if fishing then
                    local targetBtn = fishing:FindFirstChild("ClickSpeedUpActive")
                    if targetBtn and targetBtn.Visible and targetBtn.AbsoluteSize.X > 0 then
                        clickButton(targetBtn)
                    end
                end
            end
        end
        task.wait(currentDelay)
    end
end)
