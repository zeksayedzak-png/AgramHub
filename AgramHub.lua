-- Roblox Tree Deleter Script (Optimized for Mobile/Delta)
-- Target: Dogwood Trees (Trunk & Leaf)

local function cleanObject(obj)
    -- التحقق من اسم الجذع أو الأوراق بناءً على البيانات التي أرسلتها
    if obj.Name == "Meshes/Dogwood Trees 01_Trunk" or obj.Name == "Meshes/Dogwood Trees 01_Leaf" then
        obj:Destroy()
    end
    
    -- التحقق من المجلد الحاوي (الاسم المتغير للأشجار)
    if obj.Name == "DogwoodTree_Var03" then
        obj:Destroy()
    end
end

-- 1. المرحلة الأولى: حذف الأشجار الموجودة حالياً عند تشغيل السكريبت
print("جاري حذف الأشجار الحالية لتسريع اللعبة...")
for _, item in pairs(game.Workspace:GetDescendants()) do
    cleanObject(item)
end

-- 2. المرحلة الثانية: مراقبة "Workspace" باستمرار لحذف أي شجرة ترسبن (Spawn) فوراً
game.Workspace.DescendantAdded:Connect(function(newObj)
    -- ننتظر أجزاء من الثانية للتأكد من تحميل خصائص الكائن
    task.wait() 
    cleanObject(newObj)
end)

print("تم تفعيل نظام الحذف التلقائي بنجاح. اللعبة الآن أسرع!")
