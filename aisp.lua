--不想用垃圾ui

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()


local Window = Rayfield:CreateWindow({
    Name = " byCCA ",
    Icon = 0,
    LoadingTitle = "CCA",
    LoadingSubtitle = "by cca",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "Big Hub"
    }
})


local Tab = Window:CreateTab("Aimbot", "rewind")


local aimbotScript = nil
local aimbotEnabled = false

local function disableAimbot()
    if aimbotEnabled then

        if aimbotScript and aimbotScript.Disable then
            aimbotScript:Disable()
        end


        aimbotEnabled = false


        if fovCircle then
            fovCircle:Destroy()
            fovCircle = nil
        end

        if targetHighlight then
            targetHighlight:Destroy()
            targetHighlight = nil
        end

        print("Aimbot己禁用")
        Rayfield:Notify({
            Title = "Aimbot 禁用",
            Content = "aimbot 禁用",
            Duration = 3,
            Image = 4483362458
        })
    end
end

local ButtonLoadAimbotSuccess, ButtonLoadAimbot = pcall(function()
    return Tab:CreateButton({
        Name = "加载aimbot", 
        Callback = function()
            pcall(function()
                disableAimbot()
                aimbotScript = loadstring(game:HttpGet("https://raw.githubusercontent.com/ccacca444/text/main/aimbot.lua"))()
                                
                if aimbotScript and aimbotScript.Init then
                    aimbotScript:Init()
                    aimbotEnabled = true
                    
                    local currentConfig = aimbotScript:GetPOVConfig()
                    ColorPicker:Set(currentConfig.Color)
                    ThicknessSlider:Set(currentConfig.Thickness)
                    SegmentsSlider:Set(currentConfig.Segments)
                    OverlapSlider:Set(currentConfig.Overlap)
                    FOVSlider:Set(currentConfig.FOV)
                    TransparencySlider:Set(currentConfig.Transparency)
                    
                    WallHackToggle:Set(aimbotScript:GetWallHack())
                    
                    print("Aimbot已加载")
                end
            end)
        end
    })
end)

local ButtonDisableAimbotSuccess, ButtonDisableAimbot = pcall(function()
    return Tab:CreateButton({
        Name = "停止aimbot",  
        Callback = disableAimbot  
    })
end)

local WallHackToggle = Tab:CreateToggle({
    Name = "检查墙",
    CurrentValue = false,
    Callback = function(Value)
        if aimbotScript and aimbotScript.SetWallHack then
            aimbotScript:SetWallHack(Value)
            Rayfield:Notify({
                Title = "检查墙",
                Content = Value and "已开启" or "已关闭",
                Duration = 3,
                Image = 4483362458
            })
        end
    end
})

local ColorPicker = Tab:CreateColorPicker({
    Name = "POV颜色",
    Color = Color3.fromRGB(255, 0, 0),
    Callback = function(Color)
        if aimbotScript and aimbotScript.SetPOVConfig then
            local config = aimbotScript:GetPOVConfig() or {}
            config.Color = Color
            aimbotScript:SetPOVConfig(config)
        end
    end
})


local ThicknessSlider = Tab:CreateSlider({
    Name = "线条粗细",
    Range = {1, 15},
    Increment = 1,
    Suffix = "px",
    CurrentValue = 4,
    Callback = function(Value)
        if aimbotScript and aimbotScript.SetPOVConfig then
            local config = aimbotScript:GetPOVConfig() or {}
            config.Thickness = Value
            aimbotScript:SetPOVConfig(config)
        end
    end
})


local SegmentsSlider = Tab:CreateSlider({
    Name = "线段数量",
    Range = {12, 100},
    Increment = 1,
    Suffix = "段",
    CurrentValue = 36,
    Callback = function(Value)
        if aimbotScript and aimbotScript.SetPOVConfig then
            local config = aimbotScript:GetPOVConfig() or {}
            config.Segments = Value
            aimbotScript:SetPOVConfig(config)
        end
    end
})


local OverlapSlider = Tab:CreateSlider({
    Name = "重叠度",
    Range = {0, 0.3},
    Increment = 0.01,
    Suffix = "弧度",
    CurrentValue = 0.05,
    Callback = function(Value)
        if aimbotScript and aimbotScript.SetPOVConfig then
            local config = aimbotScript:GetPOVConfig() or {}
            config.Overlap = Value
            aimbotScript:SetPOVConfig(config)
        end
    end
})


local FOVSlider = Tab:CreateSlider({
    Name = "FOV大小",
    Range = {10, 200},
    Increment = 1,
    Suffix = "像素",
    CurrentValue = 30,
    Callback = function(Value)
        if aimbotScript and aimbotScript.SetPOVConfig then
            local config = aimbotScript:GetPOVConfig() or {}
            config.FOV = Value
            aimbotScript:SetPOVConfig(config)
        end
    end
})


local TransparencySlider = Tab:CreateSlider({
    Name = "透明度",
    Range = {0, 1},
    Increment = 0.1,
    Suffix = "",
    CurrentValue = 0.3,
    Callback = function(Value)
        if aimbotScript and aimbotScript.SetPOVConfig then
            local config = aimbotScript:GetPOVConfig() or {}
            config.Transparency = Value
            aimbotScript:SetPOVConfig(config)
        end
    end
})

local Tab = Window:CreateTab("esp", "rewind")

--请输入文字。
local espEnabled = false
local espObjects = {}
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer
local runService = game:GetService("RunService")


local espSettings = {
    TeamCheck = false,
    TeamColor = false,
    Boxes = true,
    Tracers = false,
    Names = true,
    Distance = true,
    HealthBar = false,  
    MaxDistance = 1000,
    BoxColor = Color3.fromRGB(255, 0, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    HealthColor = Color3.fromRGB(0, 255, 0),  
    TextSize = 14,
    BoxThickness = 1,
    HealthBarWidth = 2,  
    HealthBarHeight = 20, 
    TracerOrigin = "Bottom" -- Bottom
}

local function createEsp(player)
    if espObjects[player] then return end
    
    local esp = {
        Player = player,
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        NameLabel = Drawing.new("Text"),
        HealthBarBackground = Drawing.new("Square"),  
        HealthBarForeground = Drawing.new("Square")   
    }
    
    
    esp.Box.Visible = false
    esp.Box.Color = espSettings.BoxColor
    esp.Box.Thickness = espSettings.BoxThickness
    esp.Box.Filled = false
    
    
    esp.Tracer.Visible = false
    esp.Tracer.Color = espSettings.BoxColor
    esp.Tracer.Thickness = espSettings.BoxThickness
    
    
    esp.NameLabel.Visible = false
    esp.NameLabel.Color = espSettings.TextColor
    esp.NameLabel.Size = espSettings.TextSize
    esp.NameLabel.Outline = true
    esp.NameLabel.Text = player.Name
    
    
    esp.HealthBarBackground.Visible = false
    esp.HealthBarBackground.Color = Color3.fromRGB(50, 50, 50)
    esp.HealthBarBackground.Filled = true
    esp.HealthBarBackground.Thickness = 1
    
    
    esp.HealthBarForeground.Visible = false
    esp.HealthBarForeground.Color = espSettings.HealthColor
    esp.HealthBarForeground.Filled = true
    esp.HealthBarForeground.Thickness = 1
    
    espObjects[player] = esp
    
    
    if player.Character then
        esp.Character = player.Character
    end
    
    player.CharacterAdded:Connect(function(character)
        esp.Character = character
    end)
    
    return esp
end


local function updateEsp()
    if not espEnabled then return end
    
    local camera = workspace.CurrentCamera
    if not camera then return end
    
    for player, esp in pairs(espObjects) do
        if player ~= localPlayer and esp.Character and esp.Character.Parent ~= nil then
            local humanoidRootPart = esp.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = esp.Character:FindFirstChild("Humanoid")
            
            if humanoidRootPart and humanoid and humanoid.Health > 0 then
                local position, onScreen = camera:WorldToViewportPoint(humanoidRootPart.Position)
                
                
                local localRoot = localPlayer.Character and localPlayer.Character:FindFirstChild("HumanoidRootPart")
                local distance = 0
                if localRoot then
                    distance = (localRoot.Position - humanoidRootPart.Position).Magnitude
                end
                
                if onScreen and distance <= espSettings.MaxDistance then
                    
                    local shouldShow = true
                    if espSettings.TeamCheck and player.Team and localPlayer.Team and player.Team == localPlayer.Team then
                        shouldShow = false
                    end
                    
                    if shouldShow then
                        
                        if espSettings.Boxes then
                            local scale = 325 / position.Z
                            local width, height = 3 * scale, 5 * scale
                            
                            esp.Box.Size = Vector2.new(width, height)
                            esp.Box.Position = Vector2.new(position.X - width / 2, position.Y - height / 2)
                            esp.Box.Visible = true
                            
                            
                            if espSettings.TeamColor and player.Team then
                                esp.Box.Color = player.Team.TeamColor.Color
                            else
                                esp.Box.Color = espSettings.BoxColor
                            end
                        else
                            esp.Box.Visible = false
                        end
                        
                        
                        
if espSettings.HealthBar then
    local scale = 325 / position.Z
    local boxWidth, boxHeight = 3 * scale, 5 * scale
    
    
    if humanoid and humanoid.Health > 0 and humanoid.MaxHealth > 0 then
        local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
        
        
        local bgX = position.X - boxWidth / 2 - espSettings.HealthBarWidth - 2
        local bgY = position.Y - boxHeight / 2
        esp.HealthBarBackground.Size = Vector2.new(espSettings.HealthBarWidth, boxHeight)
        esp.HealthBarBackground.Position = Vector2.new(bgX, bgY)
        esp.HealthBarBackground.Visible = true
        
        
        local healthHeight = boxHeight * healthPercent
        local fgX = bgX
        local fgY = bgY + (boxHeight - healthHeight)
        esp.HealthBarForeground.Size = Vector2.new(espSettings.HealthBarWidth, healthHeight)
        esp.HealthBarForeground.Position = Vector2.new(fgX, fgY)
        esp.HealthBarForeground.Visible = true
        
        
        if healthPercent > 0.7 then
            esp.HealthBarForeground.Color = Color3.fromRGB(0, 255, 0)  
        elseif healthPercent > 0.3 then
            esp.HealthBarForeground.Color = Color3.fromRGB(255, 255, 0)  
        else
            esp.HealthBarForeground.Color = Color3.fromRGB(255, 0, 0)  
        end
    else
        
        esp.HealthBarBackground.Visible = false
        esp.HealthBarForeground.Visible = false
    end
else
    esp.HealthBarBackground.Visible = false
    esp.HealthBarForeground.Visible = false
end

                        
                        
                        if espSettings.Tracers then
    local origin
    
    
    if espSettings.TracerOrigin == "Top" then
        origin = Vector2.new(camera.ViewportSize.X / 2, 0)  
    elseif espSettings.TracerOrigin == "Mouse" then
        local mouse = localPlayer:GetMouse()
        origin = Vector2.new(mouse.X, mouse.Y)  
    else  
        origin = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)  
    end

    esp.Tracer.From = origin
    esp.Tracer.To = Vector2.new(position.X, position.Y)
    esp.Tracer.Visible = true
                            
                            
                            if espSettings.TeamColor and player.Team then
                                esp.Tracer.Color = player.Team.TeamColor.Color
                            else
                                esp.Tracer.Color = espSettings.BoxColor
                            end
                        else
                            esp.Tracer.Visible = false
                        end
                        
                        
                        if espSettings.Names or espSettings.Distance then
                            local text = ""
                            if espSettings.Names then
                                text = player.Name
                            end
                            
                            if espSettings.Distance then
                                if text ~= "" then
                                    text = text .. " "
                                end
                                text = text .. string.format("[%d]", math.floor(distance))
                            end
                            
                            esp.NameLabel.Text = text
                            
local depthScale = math.clamp(50 / position.Z, 0.5, 2)  
local xOffset = -25 * depthScale
local yOffset = 15 * depthScale
esp.NameLabel.Position = Vector2.new(position.X + xOffset, position.Y + yOffset)
                            esp.NameLabel.Visible = true
                            
                            
                            if espSettings.TeamColor and player.Team then
                                esp.NameLabel.Color = player.Team.TeamColor.Color
                            else
                                esp.NameLabel.Color = espSettings.TextColor
                            end
                        else
                            esp.NameLabel.Visible = false
                        end
                    else
                        esp.Box.Visible = false
                        esp.Tracer.Visible = false
                        esp.NameLabel.Visible = false
                        esp.HealthBarBackground.Visible = false
                        esp.HealthBarForeground.Visible = false
                    end
                else
                    esp.Box.Visible = false
                    esp.Tracer.Visible = false
                    esp.NameLabel.Visible = false
                    esp.HealthBarBackground.Visible = false
                    esp.HealthBarForeground.Visible = false
                end
            else
                esp.Box.Visible = false
                esp.Tracer.Visible = false
                esp.NameLabel.Visible = false
                esp.HealthBarBackground.Visible = false
                esp.HealthBarForeground.Visible = false
            end
        else
            esp.Box.Visible = false
            esp.Tracer.Visible = false
            esp.NameLabel.Visible = false
            esp.HealthBarBackground.Visible = false
            esp.HealthBarForeground.Visible = false
        end
    end
end


local function clearEsp()
    for player, esp in pairs(espObjects) do
        if esp.Box then esp.Box:Remove() end
        if esp.Tracer then esp.Tracer:Remove() end
        if esp.NameLabel then esp.NameLabel:Remove() end
        if esp.HealthBarBackground then esp.HealthBarBackground:Remove() end
        if esp.HealthBarForeground then esp.HealthBarForeground:Remove() end
    end
    espObjects = {}
end


local function initEsp()
    
    for _, player in pairs(players:GetPlayers()) do
        if player ~= localPlayer then
            createEsp(player)
        end
    end
    
    
    players.PlayerAdded:Connect(function(player)
        createEsp(player)
    end)
    
    
    players.PlayerRemoving:Connect(function(player)
        if espObjects[player] then
            if espObjects[player].Box then espObjects[player].Box:Remove() end
            if espObjects[player].Tracer then espObjects[player].Tracer:Remove() end
            if espObjects[player].NameLabel then espObjects[player].NameLabel:Remove() end
            if espObjects[player].HealthBarBackground then espObjects[player].HealthBarBackground:Remove() end
            if espObjects[player].HealthBarForeground then espObjects[player].HealthBarForeground:Remove() end
            espObjects[player] = nil
        end
    end)
    
    
    runService.RenderStepped:Connect(updateEsp)
end


local function toggleEsp(value)
    espEnabled = value
    if not value then
        clearEsp()
    else
        initEsp()
    end
end


local ESPToggle = Tab:CreateToggle({
    Name = "ESP",
    CurrentValue = false,
    Callback = function(Value)
        toggleEsp(Value)
        Rayfield:Notify({
            Title = "ESP " .. (Value and "启用" or "禁用"),
            Content = Value and "ESP已启用" or "ESP已禁用",
            Duration = 3,
            Image = 4483362458
        })
    end
})


local HealthBarToggle = Tab:CreateToggle({
    Name = "显示血条(99%bug)",
    CurrentValue = espSettings.HealthBar,
    Callback = function(Value)
        espSettings.HealthBar = Value
    end
})

local TeamCheckToggle = Tab:CreateToggle({
    Name = "只显示敌人",
    CurrentValue = espSettings.TeamCheck,
    Callback = function(Value)
        espSettings.TeamCheck = Value
    end
})

local TeamColorToggle = Tab:CreateToggle({
    Name = "使用队伍颜色",
    CurrentValue = espSettings.TeamColor,
    Callback = function(Value)
        espSettings.TeamColor = Value
    end
})

local BoxesToggle = Tab:CreateToggle({
    Name = "显示方框",
    CurrentValue = espSettings.Boxes,
    Callback = function(Value)
        espSettings.Boxes = Value
    end
})

local TracersToggle = Tab:CreateToggle({
    Name = "显示追踪线",
    CurrentValue = espSettings.Tracers,
    Callback = function(Value)
        espSettings.Tracers = Value
    end
})

local TracerOriginDropdown = Tab:CreateDropdown({
    Name = "追踪线起点",
    Options = {"Bottom", "Top", "Mouse"},
    CurrentOption = espSettings.TracerOrigin,
    Callback = function(Option)
        espSettings.TracerOrigin = Option
    end
})

local NamesToggle = Tab:CreateToggle({
    Name = "显示名称",
    CurrentValue = espSettings.Names,
    Callback = function(Value)
        espSettings.Names = Value
    end
})

local DistanceToggle = Tab:CreateToggle({
    Name = "显示距离",
    CurrentValue = espSettings.Distance,
    Callback = function(Value)
        espSettings.Distance = Value
    end
})

local MaxDistanceSlider = Tab:CreateSlider({
    Name = "最大距离",
    Range = {0, 5000},
    Increment = 50,
    Suffix = "studs",
    CurrentValue = espSettings.MaxDistance,
    Callback = function(Value)
        espSettings.MaxDistance = Value
    end
})


local HealthBarWidthSlider = Tab:CreateSlider({
    Name = "血条宽度",
    Range = {1, 10},
    Increment = 1,
    Suffix = "px",
    CurrentValue = espSettings.HealthBarWidth,
    Callback = function(Value)
        espSettings.HealthBarWidth = Value
    end
})

local BoxColorPicker = Tab:CreateColorPicker({
    Name = "方框颜色",
    Color = espSettings.BoxColor,
    Callback = function(Color)
        espSettings.BoxColor = Color
    end
})

local TextColorPicker = Tab:CreateColorPicker({
    Name = "文本颜色",
    Color = espSettings.TextColor,
    Callback = function(Color)
        espSettings.TextColor = Color
    end
})


local HealthColorPicker = Tab:CreateColorPicker({
    Name = "血条颜色",
    Color = espSettings.HealthColor,
    Callback = function(Color)
        espSettings.HealthColor = Color
    end
})

Tab:CreateButton({
    Name = "强制清除所有ESP",
    Callback = function()
        clearEsp()
        Rayfield:Notify({
            Title = "ESP清除",
            Content = "所有ESP已清除",
            Duration = 3,
            Image = 4483362458
        })
    end
})


--cca代做
-- 如果不是cca 或者卡卡脚本制作者 说明你妈死了