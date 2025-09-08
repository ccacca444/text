--请输入文字。

local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles


local Window = Library:CreateWindow({
    Title = 'ESPBYCCA',
    Center = true,
    AutoShow = true,
})


    local Tabs = {
    ['ESP'] = Window:AddTab('ESP'),
}



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
    TracerOrigin = "Bottom" 
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
                            local healthPercent = humanoid.Health / humanoid.MaxHealth
                            
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
                        
                        if espSettings.Tracers then
                            local origin = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                            --追踪线逻辑
                            if espSettings.TracerOrigin == "Top" then
                                origin = Vector2.new(camera.ViewportSize.X / 2, 0)
                            elseif espSettings.TracerOrigin == "Mouse" then
                                local mouse = localPlayer:GetMouse()
                                origin = Vector2.new(mouse.X, mouse.Y + 36)
                                elseif espSettings.TracerOrigin == "Head" then
       
        if localPlayer.Character then
            local head = localPlayer.Character:FindFirstChild("Head")
            if head then
                local headPos, headOnScreen = camera:WorldToViewportPoint(head.Position)
                if headOnScreen then
                    origin = Vector2.new(headPos.X, headPos.Y)
                else
                    origin = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
                end
            else
                origin = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
            end
        else
            origin = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
        end
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
                            esp.NameLabel.Position = Vector2.new(position.X - 25, position.Y + 15)
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

local EspSettingsGroup = Tabs['ESP']:AddLeftGroupbox('ESP')

EspSettingsGroup:AddToggle('ESPEnabled', {
    Text = '启用 ESP',
    Default = false,
    Callback = function(value)
        toggleEsp(value)
    end
})

-- 基本设置


EspSettingsGroup:AddToggle('ESPTracers', {
    Text = '显示追踪线',
    Default = espSettings.Tracers,
    Callback = function(value)
        espSettings.Tracers = value
    end
})


EspSettingsGroup:AddToggle('MyToggle', {
    Text = '显示方框',  
    Default = true, 
    Disabled = false, 
    Visible = true, 
    Risky = false,
    Callback = function(Value)
        espSettings.Boxes = Value  
    end
}):AddColorPicker('ESPBoxColor', {
    Default = espSettings.BoxColor,  
    Title = '方框颜色', 
    Transparency = 0, 
    Callback = function(Value)
        espSettings.BoxColor = Value    
    end
})  

EspSettingsGroup:AddToggle('ESPNames', {
    Text = '显示名字',  
    Default = true, 
    Disabled = false, 
    Visible = true, 
    Risky = false,
    Callback = function(Value)
        espSettings.TextSize = Value  
    end
}):AddColorPicker('ESPTextColor', {
    Default = espSettings.TextColor,  
    Title = '文字颜色', 
    Transparency = 0, 
    Callback = function(Value)
        espSettings.TextColor = Value
    end
})  

EspSettingsGroup:AddToggle('ESPHealthBar', {
    Text = '显示血条',
    Default = espSettings.HealthBar,
    Callback = function(value)
        espSettings.HealthBar = value
    end
})

EspSettingsGroup:AddToggle('ESPTeamCheck', {
    Text = '队伍检查',
    Default = espSettings.TeamCheck,
    Callback = function(value)
        espSettings.TeamCheck = value
    end
})

EspSettingsGroup:AddToggle('ESPTeamColor', {
    Text = '队伍颜色',
    Default = espSettings.TeamColor,
    Callback = function(value)
        espSettings.TeamColor = value
    end
})

-- 高级设置组
local AdvancedEspGroup = Tabs['ESP']:AddRightGroupbox('ESPDIY')

AdvancedEspGroup:AddSlider('ESPMaxDistance', {
    Text = '最大距离',
    Default = espSettings.MaxDistance,
    Min = 0,
    Max = 5000,
    Rounding = 0,
    Callback = function(value)
        espSettings.MaxDistance = value
    end
})



AdvancedEspGroup:AddSlider('ESPTextSize', {
    Text = '文本大小',
    Default = espSettings.TextSize,
    Min = 8,
    Max = 24,
    Rounding = 0,
    Callback = function(value)
        espSettings.TextSize = value
    end
})

AdvancedEspGroup:AddSlider('ESPBoxThickness', {
    Text = '方框厚度',
    Default = espSettings.BoxThickness,
    Min = 1,
    Max = 5,
    Rounding = 0,
    Callback = function(value)
        espSettings.BoxThickness = value
    end
})

AdvancedEspGroup:AddDropdown('ESPTracerOrigin', {
    Values = { "Bottom", "Top", "Mouse", "Head" },  
    Default = 1,
    Text = '追踪线起点',
    Callback = function(value)
        espSettings.TracerOrigin = value
    end
})


ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })

SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()


Library:SetWatermarkVisibility(true)
Library:SetWatermark('ESP')


Library:OnUnload(function()
    clearEsp()
    print('idk')
    Library.Unloaded = true
end)