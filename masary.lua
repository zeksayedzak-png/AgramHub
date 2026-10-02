-- Worming Scanner (Fixed Path & Visible Buttons Only)
-- GitHub: your-username/roblox-scripts

local player = game.Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "WormingScanner"
ScreenGui.Parent = PlayerGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 400)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -200)
MainFrame.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
MainFrame.BackgroundTransparency = 0.3
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Worming Scanner"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

local SelectBtn = Instance.new("TextButton")
SelectBtn.Size = UDim2.new(1, -20, 0, 40)
SelectBtn.Position = UDim2.new(0, 10, 0, 40)
SelectBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
SelectBtn.Text = "Select"
SelectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SelectBtn.TextScaled = true
SelectBtn.Font = Enum.Font.GothamBold
SelectBtn.Parent = MainFrame

local SelectCorner = Instance.new("UICorner")
SelectCorner.CornerRadius = UDim.new(0, 8)
SelectCorner.Parent = SelectBtn

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -20, 1, -150)
ScrollFrame.Position = UDim2.new(0, 10, 0, 90)
ScrollFrame.BackgroundColor3 = Color3.fromRGB(255, 180, 100)
ScrollFrame.BackgroundTransparency = 0.5
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ScrollFrame.Parent = MainFrame

local ScrollCorner = Instance.new("UICorner")
ScrollCorner.CornerRadius = UDim.new(0, 8)
ScrollCorner.Parent = ScrollFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 5)
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Parent = ScrollFrame

-- دالة جلب المسار الكامل المعتمدة رسمياً من روبلوكس
local function getFullPath(instance)
    return "game." .. instance:GetFullName()
end

local function clearList()
    for _, child in pairs(ScrollFrame:GetChildren()) do
        if child:IsA("Frame") or child:IsA("TextButton") then
            child:Destroy()
        end
    end
end

local function createItem(button)
    local fullPath = getFullPath(button)

    local ItemFrame = Instance.new("Frame")
    ItemFrame.Size = UDim2.new(1, -10, 0, 50)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(255, 200, 150)
    ItemFrame.BackgroundTransparency = 0.3
    ItemFrame.BorderSizePixel = 0
    ItemFrame.Parent = ScrollFrame

    local ItemCorner = Instance.new("UICorner")
    ItemCorner.CornerRadius = UDim.new(0, 6)
    ItemCorner.Parent = ItemFrame

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, -60, 0, 20)
    NameLabel.Position = UDim2.new(0, 5, 0, 2)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = button.Name
    NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    NameLabel.TextScaled = true
    NameLabel.Font = Enum.Font.GothamBold
    NameLabel.TextXAlignment = Enum.TextXAlignment.Left
    NameLabel.Parent = ItemFrame

    local PathLabel = Instance.new("TextLabel")
    PathLabel.Size = UDim2.new(1, -60, 0, 20)
    PathLabel.Position = UDim2.new(0, 5, 0, 24)
    PathLabel.BackgroundTransparency = 1
    PathLabel.Text = fullPath
    PathLabel.TextColor3 = Color3.fromRGB(255, 255, 200)
    PathLabel.TextScaled = true
    PathLabel.Font = Enum.Font.Gotham
    PathLabel.TextXAlignment = Enum.TextXAlignment.Left
    PathLabel.Parent = ItemFrame

    local CopyBtn = Instance.new("TextButton")
    CopyBtn.Size = UDim2.new(0, 50, 0, 40)
    CopyBtn.Position = UDim2.new(1, -55, 0, 5)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 255)
    CopyBtn.Text = "Copy"
    CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CopyBtn.TextScaled = true
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.Parent = ItemFrame

    local CopyCorner = Instance.new("UICorner")
    CopyCorner.CornerRadius = UDim.new(0, 6)
    CopyCorner.Parent = CopyBtn

    CopyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(fullPath)
            CopyBtn.Text = "Copied!"
            task.wait(1)
            CopyBtn.Text = "Copy"
        else
            CopyBtn.Text = "No Clip"
        end
    end)
end

local function isButtonVisible(btn)
    local screenGui = btn:FindFirstAncestorOfClass("ScreenGui")
    if not screenGui or not screenGui.Enabled then
        return false
    end

    local current = btn
    while current and current ~= screenGui do
        if current:IsA("GuiObject") and not current.Visible then
            return false
        end
        current = current.Parent
    end

    if btn.AbsoluteSize.X <= 0 or btn.AbsoluteSize.Y <= 0 then
        return false
    end

    local camera = workspace.CurrentCamera
    if camera then
        local pos = btn.AbsolutePosition
        local size = btn.AbsoluteSize
        local viewportSize = camera.ViewportSize

        if pos.X + size.X < 0 or pos.X > viewportSize.X or
           pos.Y + size.Y < 0 or pos.Y > viewportSize.Y then
            return false
        end
    end

    return true
end

local function scanButtons()
    clearList()
    local buttons = {}
    for _, gui in pairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") and gui ~= ScreenGui then
            for _, obj in pairs(gui:GetDescendants()) do
                if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and isButtonVisible(obj) then
                    table.insert(buttons, obj)
                end
            end
        end
    end
    for _, btn in pairs(buttons) do
        createItem(btn)
    end
    return #buttons
end

local isScanning = false

SelectBtn.MouseButton1Click:Connect(function()
    if isScanning then
        clearList()
        isScanning = false
        SelectBtn.Text = "Select"
    else
        SelectBtn.Text = "Scanning..."
        local count = scanButtons()
        SelectBtn.Text = "Reset (" .. count .. ")"
        isScanning = true
    end
end)
