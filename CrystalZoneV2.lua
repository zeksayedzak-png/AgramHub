-- =====================================================
-- AETHER MARKER CONTROLLER (FLOATING GUI)
-- =====================================================

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- 1. إنشاء النافذة
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "AetherController"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 160, 0, 80)
frame.Position = UDim2.new(0.5, -80, 0.5, -40)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.5
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(100, 100, 100)

-- 2. عنوان
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 25)
title.Text = "📡 Aether Radar"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.BackgroundTransparency = 1

-- 3. زر التشغيل التلقائي
local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.new(0, 100, 0, 30)
btn.Position = UDim2.new(0.5, -50, 0.6, 0)
btn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
btn.Text = "▶ تشغيل تلقائي"
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Font = Enum.Font.GothamBold
btn.TextSize = 12
Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

-- 4. زر الإضافة والتشغيل
btn.MouseButton1Click:Connect(function()
    -- التحقق إذا كان الرادار موجود
    local marker = workspace:FindFirstChild("AetherMarkerAnchor")
    
    if not marker then
        -- إنشاء الرادار من الصفر (لأنه مش موجود)
        local newMarker = Instance.new("Part")
        newMarker.Name = "AetherMarkerAnchor"
        newMarker.Parent = workspace
        newMarker.Size = Vector3.new(1, 1, 1)
        newMarker.Transparency = 1
        newMarker.Anchored = true
        newMarker.CanCollide = false
        
        -- إضافة BillboardGui
        local bb = Instance.new("BillboardGui", newMarker)
        bb.Name = "AetherBB"
        bb.Size = UDim2.new(0, 200, 0, 50)
        bb.AlwaysOnTop = true
        bb.StudsOffset = Vector3.new(0, 3, 0)
        
        local label = Instance.new("TextLabel", bb)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "📡 RADAR ACTIVE"
        label.TextColor3 = Color3.fromRGB(0, 255, 255)
        label.Font = Enum.Font.GothamBold
        label.TextSize = 18
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0
        
        Instance.new("UIStroke", label).Color = Color3.fromRGB(255, 255, 255)
        Instance.new("UITextSizeConstraint", label).MaxTextSize = 18
        
        print("✅ AetherMarkerAnchor created!")
    else
        -- إذا كان موجود، نثبته شغال
        marker.Enabled = true
        print("✅ AetherMarkerAnchor activated!")
    end
    
    -- تغيير لون الزر للتأكيد
    btn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    btn.Text = "✅ مفعل"
end)

-- 5. سحب النافذة (باللمس أو الفأرة)
local dragging = false
local dragStart = nil
local startPos = nil

frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("📡 Aether Radar Controller Loaded")
