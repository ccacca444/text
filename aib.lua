local Aimbot = {
    Enabled = false,
    Connection = nil
}


local config = {
    fov = 30,
    maxDistance = 400,
    maxTransparency = 0.1,
    teamCheck = false,  
    wallCheck = true,
    aimPart = "Head"
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")


local Cam, FOVring

local function initializeDrawing()
    if not Cam or not Cam.ViewportSize then
        Cam = workspace:FindFirstChildOfClass("Camera")
        if not Cam then return end
    end

    if not FOVring then
        FOVring = Drawing.new("Circle")
        FOVring.Visible = false
        FOVring.Thickness = 2
        FOVring.Color = Color3.fromRGB(128, 0, 128)
        FOVring.Filled = false
        FOVring.Radius = config.fov
        if Cam and Cam.ViewportSize then
            FOVring.Position = Cam.ViewportSize / 2
        end
    end
end

function Aimbot:SetEnabled(state)
    self.Enabled = state
    if state then
        self:Start()
    else
        self:Stop()
    end
end

function Aimbot:Toggle()
    self:SetEnabled(not self.Enabled)
    return self.Enabled
end


function Aimbot:SetTeamCheck(value)
    config.teamCheck = value
end

function Aimbot:GetTeamCheck()
    return config.teamCheck
end

function Aimbot:SetWallCheck(value)
    config.wallCheck = value
end

function Aimbot:GetWallCheck()
    return config.wallCheck
end

function Aimbot:SetFOV(value)
    config.fov = value
    if FOVring then
        FOVring.Radius = value
    end
end

function Aimbot:GetFOV()
    return config.fov
end

function Aimbot:SetMaxDistance(value)
    config.maxDistance = value
end

function Aimbot:GetMaxDistance()
    return config.maxDistance
end

function Aimbot:Start()
    initializeDrawing()
    if not FOVring then return end

    if self.Connection then
        self.Connection:Disconnect()
    end

    self.Connection = RunService.RenderStepped:Connect(function()
        if not self.Enabled then return end
        if not Cam then
            Cam = workspace:FindFirstChildOfClass("Camera")
            if not Cam then return end
        end

        updateDrawings()
        local closest = getClosestPlayerInFOV()
        if closest and closest.Character and closest.Character:FindFirstChild(config.aimPart) then
            lookAt(closest.Character[config.aimPart].Position)
        end

        if closest then
            local part = closest.Character[config.aimPart]
            local ePos, isVisible = Cam:WorldToViewportPoint(part.Position)
            local distance = (Vector2.new(ePos.x, ePos.y) - (Cam.ViewportSize / 2)).Magnitude
            FOVring.Transparency = calculateTransparency(distance)
        else
            FOVring.Transparency = config.maxTransparency
        end
    end)

    FOVring.Visible = true
end

function Aimbot:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    if FOVring then
        FOVring.Visible = false
        FOVring.Transparency = config.maxTransparency
    end
end


local function updateDrawings()
    if FOVring and Cam and Cam.ViewportSize then
        FOVring.Position = Cam.ViewportSize / 2
    end
end

local function lookAt(target)
    if not Cam then return end
    local lookVector = (target - Cam.CFrame.Position).unit
    local newCFrame = CFrame.new(Cam.CFrame.Position, Cam.CFrame.Position + lookVector)
    Cam.CFrame = newCFrame
end

local function calculateTransparency(distance)
    return (1 - (distance / config.fov)) * config.maxTransparency
end

local function isPlayerAlive(player)
    local character = player.Character
    return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
end

local function isPlayerVisibleThroughWalls(player, trg_part)
    if not config.wallCheck then
        return true
    end

    local localPlayer = Players.LocalPlayer
    if not localPlayer or not localPlayer.Character then
        return false
    end

    local part = player.Character and player.Character:FindFirstChild(trg_part)
    if not part then
        return false
    end

    if not Cam then return false end

    local ray = Ray.new(Cam.CFrame.Position, part.Position - Cam.CFrame.Position)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character})

    if hit and hit:IsDescendantOf(player.Character) then
        return true
    end

    local direction = (part.Position - Cam.CFrame.Position).unit
    local nearRay = Ray.new(Cam.CFrame.Position + direction * 2, direction * config.maxDistance)
    local nearHit, _ = workspace:FindPartOnRayWithIgnoreList(nearRay, {localPlayer.Character})

    return nearHit and nearHit:IsDescendantOf(player.Character)
end

local function getClosestPlayerInFOV()
    local nearest = nil
    local last = math.huge
    local localPlayer = Players.LocalPlayer

    if not localPlayer or not localPlayer.Character or not Cam or not Cam.ViewportSize then
        return nil
    end

    local playerMousePos = Cam.ViewportSize / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and (not config.teamCheck or player.Team ~= localPlayer.Team) and isPlayerAlive(player) then
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            local part = player.Character and player.Character:FindFirstChild(config.aimPart)
            if humanoid and part then
                local ePos, isVisible = Cam:WorldToViewportPoint(part.Position)
                local distance = (Vector2.new(ePos.x, ePos.y) - playerMousePos).Magnitude

                if distance < last and isVisible and distance < config.fov and distance < config.maxDistance and isPlayerVisibleThroughWalls(player, config.aimPart) then
                    last = distance
                    nearest = player
                end
            end
        end
    end

    return nearest
end

-- 初始状态：关
if FOVring then
    FOVring.Visible = false
end

return Aimbot