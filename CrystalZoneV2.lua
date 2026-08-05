-- =====================================================
-- RADAR CREATOR + KEEPER (AETHER + BOMBVEIN)
-- =====================================================

local function CreateRadar(name, bbName, labelText)
    -- البحث إذا كان موجود
    local existing = workspace:FindFirstChild(name)
    if existing then
        return existing -- موجود، نرجعه
    end

    -- إنشاء الجزء الرئيسي (Part)
    local part = Instance.new("Part")
    part.Name = name
    part.Parent = workspace
    part.Size = Vector3.new(1, 1, 1)
    part.Transparency = 1
    part.Anchored = true
    part.CanCollide = false

    -- إنشاء BillboardGui
    local bb = Instance.new("BillboardGui", part)
    bb.Name = bbName
    bb.Size = UDim2.new(0, 200, 0, 50)
    bb.AlwaysOnTop = true
    bb.Enabled = true

    -- إنشاء TextLabel
    local label = Instance.new("TextLabel", bb)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = Color3.fromRGB(0, 255, 255)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 18
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.Visible = true

    -- إضافة UIStroke (حدود)
    local stroke = Instance.new("UIStroke", label)
    stroke.Color = Color3.fromRGB(255, 255, 255)

    -- إضافة UITextSizeConstraint (للتحكم بحجم النص)
    Instance.new("UITextSizeConstraint", label).MaxTextSize = 18

    -- إضافة UIListLayout (لترتيب العناصر)
    local layout = Instance.new("UIListLayout", bb)
    layout.Padding = UDim.new(0, 5)

    -- إضافة Attachment (نقطة ارتكاز)
    local attachment = Instance.new("Attachment", part)
    attachment.Name = "Attachment"

    print("✅ " .. name .. " created!")

    return part
end

local function EnsureRadarEnabled()
    -- 1. التأكد من وجود AetherMarkerAnchor
    local aether = workspace:FindFirstChild("AetherMarkerAnchor")
    if not aether then
        aether = CreateRadar("AetherMarkerAnchor", "AetherBB", "📡 RADAR ACTIVE")
    end

    -- 2. التأكد من وجود BombveinMarkerAnchor
    local bombvein = workspace:FindFirstChild("BombveinMarkerAnchor")
    if not bombvein then
        bombvein = CreateRadar("BombveinMarkerAnchor", "BombveinBB", "💣 BOMBVEIN ACTIVE")
    end

    -- 3. تفعيلهم
    if aether then
        aether.Enabled = true
        local bb = aether:FindFirstChild("AetherBB")
        if bb then
            bb.Enabled = true
            local label = bb:FindFirstChild("TextLabel")
            if label then
                label.Visible = true
            end
        end
    end

    if bombvein then
        bombvein.Enabled = true
        local bb = bombvein:FindFirstChild("BombveinBB")
        if bb then
            bb.Enabled = true
            local label = bb:FindFirstChild("TextLabel")
            if label then
                label.Visible = true
            end
        end
    end
end

-- تشغيل فحص كل نصف ثانية
spawn(function()
    while task.wait(0.5) do
        EnsureRadarEnabled()
    end
end)

-- فحص فوري عند بدء السكريبت
EnsureRadarEnabled()

print("✅ Radar Creator + Keeper Active (Aether + Bombvein)")
