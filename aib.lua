local Aimbot = {
    Enabled = false,
    Settings = {
        FOV = 30,
        MaxDistance = 400,
        MaxTransparency = 1,
        TeamCheck = false,
        WallCheck = true,
        WallHack = false,
        AimPart = "Head",
        
        POVColor = Color3.fromRGB(255, 0, 0),
        POVThickness = 4,
        POVSegments = 36,
        POVOverlap = 0.05
    },
    Connections = {},
    Target = nil,
    FOVSegments = {} 
}

local function initDrawings()
    
    for _, segment in ipairs(Aimbot.FOVSegments) do
        if segment then segment:Remove() end
    end
    Aimbot.FOVSegments = {}

    local center = workspace.CurrentCamera.ViewportSize / 2
    local radius = Aimbot.Settings.FOV
    local numSegments = Aimbot.Settings.POVSegments  
    local overlap = Aimbot.Settings.POVOverlap       

    for i = 1, numSegments do
        local angle1 = (i - 1) * (2 * math.pi / numSegments) - overlap
        local angle2 = i * (2 * math.pi / numSegments) + overlap

        local startPos = Vector2.new(
            center.X + radius * math.cos(angle1),
            center.Y + radius * math.sin(angle1)
        )

        local endPos = Vector2.new(
            center.X + radius * math.cos(angle2),
            center.Y + radius * math.sin(angle2)
        )

        local line = Drawing.new("Line")
        line.Visible = true
        line.Thickness = Aimbot.Settings.POVThickness  
        line.Color = Aimbot.Settings.POVColor          
        line.Transparency = Aimbot.Settings.MaxTransparency
        line.From = startPos
        line.To = endPos

        table.insert(Aimbot.FOVSegments, line)
    end
end

local function updateDrawings()
    local center = workspace.CurrentCamera.ViewportSize / 2
    local radius = Aimbot.Settings.FOV
    local numSegments = #Aimbot.FOVSegments
    local overlap = Aimbot.Settings.POVOverlap  
    for i = 1, numSegments do
        local angle1 = (i - 1) * (2 * math.pi / numSegments) - overlap
        local angle2 = i * (2 * math.pi / numSegments) + overlap

        local startPos = Vector2.new(
            center.X + radius * math.cos(angle1),
            center.Y + radius * math.sin(angle1)
        )

        local endPos = Vector2.new(
            center.X + radius * math.cos(angle2),
            center.Y + radius * math.sin(angle2)
        )

        if Aimbot.FOVSegments[i] then
            Aimbot.FOVSegments[i].From = startPos
            Aimbot.FOVSegments[i].To = endPos
        end
    end
end


local function lookAt(target)
    if not Aimbot.Enabled then return end
    local lookVector = (target - workspace.CurrentCamera.CFrame.Position).unit
    local newCFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, workspace.CurrentCamera.CFrame.Position + lookVector)
    workspace.CurrentCamera.CFrame = newCFrame
end

local function calculateTransparency(distance)
    return (1 - (distance / Aimbot.Settings.FOV)) * Aimbot.Settings.MaxTransparency
end

local function isPlayerAlive(player)
    local character = player.Character
    return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
end

local function isPlayerVisibleThroughWalls(player, trg_part)
    
    if Aimbot.Settings.WallHack then
        return true
    end
    
    if not Aimbot.Settings.WallCheck then
        return true
    end

    local localPlayerCharacter = game:GetService("Players").LocalPlayer.Character
    if not localPlayerCharacter then
        return false
    end

    local part = player.Character and player.Character:FindFirstChild(trg_part)
    if not part then
        return false
    end

    local ray = Ray.new(workspace.CurrentCamera.CFrame.Position, part.Position - workspace.CurrentCamera.CFrame.Position)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayerCharacter})

    if hit and hit:IsDescendantOf(player.Character) then
        return true
    end

    local direction = (part.Position - workspace.CurrentCamera.CFrame.Position).unit
    local nearRay = Ray.new(workspace.CurrentCamera.CFrame.Position + direction * 2, direction * Aimbot.Settings.MaxDistance)
    local nearHit, _ = workspace:FindPartOnRayWithIgnoreList(nearRay, {localPlayerCharacter})

    return nearHit and nearHit:IsDescendantOf(player.Character)
end

local function getClosestPlayerInFOV()
    local nearest = nil
    local last = math.huge
    local playerMousePos = workspace.CurrentCamera.ViewportSize / 2
    local localPlayer = game:GetService("Players").LocalPlayer

    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= localPlayer and (not Aimbot.Settings.TeamCheck or player.Team ~= localPlayer.Team) and isPlayerAlive(player) then
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            local part = player.Character and player.Character:FindFirstChild(Aimbot.Settings.AimPart)
            if humanoid and part then
                local ePos, isVisible = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
                local distance = (Vector2.new(ePos.x, ePos.y) - playerMousePos).Magnitude

                if distance < last and isVisible and distance < Aimbot.Settings.FOV and distance < Aimbot.Settings.MaxDistance and isPlayerVisibleThroughWalls(player, Aimbot.Settings.AimPart) then
                    last = distance
                    nearest = player
                end
            end
        end
    end

    return nearest
end

local function mainLoop()
    if not Aimbot.Enabled then return end
    
    updateDrawings()
    Aimbot.Target = getClosestPlayerInFOV()

    if Aimbot.Target and Aimbot.Target.Character:FindFirstChild(Aimbot.Settings.AimPart) then
        lookAt(Aimbot.Target.Character[Aimbot.Settings.AimPart].Position)
        
        local part = Aimbot.Target.Character[Aimbot.Settings.AimPart]
        local ePos = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
        local distance = (Vector2.new(ePos.x, ePos.y) - (workspace.CurrentCamera.ViewportSize / 2)).Magnitude
        local transparency = calculateTransparency(distance)
        
        
        for _, segment in ipairs(Aimbot.FOVSegments) do
            segment.Transparency = transparency
        end
    else
        
        for _, segment in ipairs(Aimbot.FOVSegments) do
            segment.Transparency = Aimbot.Settings.MaxTransparency
        end
    end
end

function Aimbot:Init()
    if self.Enabled then return end
    
    initDrawings()
    
    table.insert(self.Connections, game:GetService("RunService").RenderStepped:Connect(mainLoop))
    
    self.Enabled = true
    print("Aimbot已启用")
end

function Aimbot:Disable()
    if not self.Enabled then return end
    
    for _, conn in ipairs(self.Connections) do
        conn:Disconnect()
    end
    self.Connections = {}
    
    
    for _, segment in ipairs(self.FOVSegments) do
        if segment then
            segment:Remove()
        end
    end
    self.FOVSegments = {}
    
    self.Enabled = false
    self.Target = nil
    print("Aimbot已禁用")
end

function Aimbot:Configure(settings)
    for k, v in pairs(settings) do
        if self.Settings[k] ~= nil then
            self.Settings[k] = v
        end
    end
    
    
    if self.Enabled then
        initDrawings()
    end
end

function Aimbot:GetPOVConfig()
    return {
        FOV = self.Settings.FOV,
        Color = self.Settings.POVColor,
        Thickness = self.Settings.POVThickness,
        Segments = self.Settings.POVSegments,
        Overlap = self.Settings.POVOverlap,
        Transparency = self.Settings.MaxTransparency
    }
end


function Aimbot:SetPOVConfig(config)
    if config.FOV then self.Settings.FOV = config.FOV end
    if config.Color then self.Settings.POVColor = config.Color end
    if config.Thickness then self.Settings.POVThickness = config.Thickness end
    if config.Segments then self.Settings.POVSegments = config.Segments end
    if config.Overlap then self.Settings.POVOverlap = config.Overlap end
    if config.Transparency then self.Settings.MaxTransparency = config.Transparency end
    
    
    if self.Enabled then
        initDrawings()
    end
    return true
end

function Aimbot:SetWallHack(enabled)
    self.Settings.WallHack = enabled
    print("你妈死了没有: " .. (enabled and "死了" or "没死"))
    return true
end

function Aimbot:GetWallHack()
    return self.Settings.WallHack
end

return Aimbot 