local Aimbot = {
    Enabled = false,
    FOV = 30,
    MaxDistance = 400,
    MaxTransparency = 0.1,
    TeamCheck = false,
    WallCheck = true,
    AimPart = "Head",
    Connection = nil
}

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Cam = game.Workspace.CurrentCamera

local FOVring = Drawing.new("Circle")
FOVring.Visible = true
FOVring.Thickness = 2
FOVring.Color = Color3.fromRGB(128, 0, 128)
FOVring.Filled = false
FOVring.Radius = Aimbot.FOV
FOVring.Position = Cam.ViewportSize / 2

-- 公开的接口函数
function Aimbot:SetEnabled(state)
    self.Enabled = state
    if state and not self.Connection then
        self:Start()
    elseif not state and self.Connection then
        self:Stop()
    end
end

function Aimbot:Toggle()
    self:SetEnabled(not self.Enabled)
end

function Aimbot:SetFOV(value)
    self.FOV = value
    FOVring.Radius = value
end

function Aimbot:SetAimPart(partName)
    self.AimPart = partName
end

function Aimbot:SetTeamCheck(state)
    self.TeamCheck = state
end

function Aimbot:SetWallCheck(state)
    self.WallCheck = state
end

function Aimbot:Start()
    if self.Connection then
        self.Connection:Disconnect()
    end
    
    self.Connection = RunService.RenderStepped:Connect(function()
        if not self.Enabled then return end
        updateDrawings()
        local closest = getClosestPlayerInFOV()
        if closest and closest.Character:FindFirstChild(self.AimPart) then
            lookAt(closest.Character[self.AimPart].Position)
        end
        
        if closest then
            local part = closest.Character[self.AimPart]
            local ePos, isVisible = Cam:WorldToViewportPoint(part.Position)
            local distance = (Vector2.new(ePos.x, ePos.y) - (Cam.ViewportSize / 2)).Magnitude
            FOVring.Transparency = calculateTransparency(distance)
        else
            FOVring.Transparency = Aimbot.MaxTransparency
        end
    end)
end

function Aimbot:Stop()
    if self.Connection then
        self.Connection:Disconnect()
        self.Connection = nil
    end
    FOVring.Transparency = Aimbot.MaxTransparency
end

-- 原有的辅助函数（保持不变）
local function updateDrawings()
    FOVring.Position = Cam.ViewportSize / 2
end

local function lookAt(target)
    local lookVector = (target - Cam.CFrame.Position).unit
    local newCFrame = CFrame.new(Cam.CFrame.Position, Cam.CFrame.Position + lookVector)
    Cam.CFrame = newCFrame
end

local function calculateTransparency(distance)
    return (1 - (distance / Aimbot.FOV)) * Aimbot.MaxTransparency
end

local function isPlayerAlive(player)
    local character = player.Character
    return character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0
end

local function isPlayerVisibleThroughWalls(player, trg_part)
    if not Aimbot.WallCheck then
        return true
    end

    local localPlayerCharacter = Players.LocalPlayer.Character
    if not localPlayerCharacter then
        return false
    end

    local part = player.Character and player.Character:FindFirstChild(trg_part)
    if not part then
        return false
    end

    local ray = Ray.new(Cam.CFrame.Position, part.Position - Cam.CFrame.Position)
    local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayerCharacter})

    if hit and hit:IsDescendantOf(player.Character) then
        return true
    end

    local direction = (part.Position - Cam.CFrame.Position).unit
    local nearRay = Ray.new(Cam.CFrame.Position + direction * 2, direction * Aimbot.MaxDistance)
    local nearHit, _ = workspace:FindPartOnRayWithIgnoreList(nearRay, {localPlayerCharacter})

    return nearHit and nearHit:IsDescendantOf(player.Character)
end

local function getClosestPlayerInFOV()
    local nearest = nil
    local last = math.huge
    local playerMousePos = Cam.ViewportSize / 2
    local localPlayer = Players.LocalPlayer

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and (not Aimbot.TeamCheck or player.Team ~= localPlayer.Team) and isPlayerAlive(player) then
            local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
            local part = player.Character and player.Character:FindFirstChild(Aimbot.AimPart)
            if humanoid and part then
                local ePos, isVisible = Cam:WorldToViewportPoint(part.Position)
                local distance = (Vector2.new(ePos.x, ePos.y) - playerMousePos).Magnitude

                if distance < last and isVisible and distance < Aimbot.FOV and distance < Aimbot.MaxDistance and isPlayerVisibleThroughWalls(player, Aimbot.AimPart) then
                    last = distance
                    nearest = player
                end
            end
        end
    end

    return nearest
end

-- 初始化但不立即启动
FOVring.Transparency = Aimbot.MaxTransparency

return Aimbot