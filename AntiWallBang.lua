local impact, hitPosition = nil, nil
local isAiming = false

local function Rotation(rotation)
    local adjustedRotation = { 
        x = (math.pi / 180) * rotation.x, 
        y = (math.pi / 180) * rotation.y, 
        z = (math.pi / 180) * rotation.z 
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

local function WeaponImpact(distance)
    local cameraRotation = GetGameplayCamRot(2)
    local cameraCoord = GetGameplayCamCoord()
    local currentWeapon = GetCurrentPedWeaponEntityIndex(PlayerPedId())
    local weaponCoords = GetEntityCoords(currentWeapon)

    local direction = Rotation(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance, 
        y = cameraCoord.y + direction.y * distance, 
        z = cameraCoord.z + direction.z * distance
    }

    local _, hitResult, hitCoords, _, _ = GetShapeTestResult
    
    (StartShapeTestRay(
       weaponCoords.x, weaponCoords.y, weaponCoords.z,
       destination.x, destination.y, destination.z,
       1, 0, 4
    ))

    impact, hitPosition = hitResult, hitCoords
end

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()

        if IsPedArmed(ped, 4) then
            WeaponImpact(Config.XRadius)
        else
            impact, hitPosition = nil, nil
        end

        if IsControlPressed(0, 25) then
            isAiming = true
        else
            isAiming = false
        end
        
        Citizen.Wait(200)
    end
end)

function X(position, text, scale)
    local onScreen, screenX, screenY = World3dToScreen2d(position.x, position.y, position.z)
    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(0)
        SetTextProportional(true)
        SetTextColour(255, 0, 0, 255)  
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(screenX, screenY)
    end
end

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()

        if ped and isAiming and impact and hitPosition ~= vector3(0.0, 0.0, 0.0) then
            DisablePlayerFiring(128, true)
            X(hitPosition, Config.X, Config.XSize)
        end

        Citizen.Wait(1)
    end
end)