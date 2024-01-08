notify = function(id, title, desc, icon, color)
    if color == "red" then 
        color = "#C53030"
    elseif color == "green" then 
        color = "#c53030"
    end

    if icon == "error" then 
        icon = "ban"
    elseif icon == "succ" then 
        icon = "check"
    end

    lib.notify({
        id = id,
        title = title,
        description = desc,
        position = 'center-right',
        style = {
            backgroundColor = '#141517',
            color = '#C1C2C5',
            ['.description'] = {
              color = '#909296'
            }
        },
        icon = icon,
        iconColor = color
    })
end

getcoord = function(type)
    local playerCoords = GetEntityCoords(PlayerPedId())
    if type == "json" then 
    return json.encode({ y = playerCoords.y, x = playerCoords.x, h = GetEntityHeading(PlayerPedId()), z = playerCoords.z })
    elseif type == "normal" then 
        return string.format("%.2f, %.2f, %.2f, %.2f", playerCoords.x, playerCoords.y, playerCoords.z,  GetEntityHeading(PlayerPedId()))
    elseif type == "vec3" then 
        return vector3(playerCoords.x, playerCoords.y, playerCoords.z)
    elseif type == "vec4" then 
        return vector4(playerCoords.x, playerCoords.y, playerCoords.z, GetEntityHeading(PlayerPedId()))
    end
end


-- Testing
RegisterCommand('search', function(source, args, rawCommand)
    local objectName = table.concat(args, ' ')
    TriggerEvent('searchObject', objectName)
    print("worka " .. objectName)
end, false)

local currentBlip = nil  
local currentObject = nil

RegisterNetEvent('searchObject')
AddEventHandler('searchObject', function(objectName)
    local objects = GetGamePool('CObject')


    if currentBlip ~= nil then
        RemoveBlip(currentBlip)
        currentBlip = nil
    end

    if currentObject ~= nil then
        SetEntityDrawOutline(currentObject, false)
        currentObject = nil
    end

    for _, object in ipairs(objects) do
        local modelName = GetEntityModel(object)

        if modelName == GetHashKey(objectName) then
            local objCoords = GetEntityCoords(object)

            local blip = AddBlipForEntity(object)
            SetBlipSprite(blip, 433) 
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 51) 
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Found: " .. modelName)
            EndTextCommandSetBlipName(blip)


            currentBlip = blip
            currentObject = object

            if DoesEntityExist(object) then
                Citizen.CreateThread(function()
                    while true do
                        Citizen.Wait(0) 
                        
                        local playerCoords = GetEntityCoords(PlayerPedId())
                        local objCoords = GetEntityCoords(object)
                        local distance = #(playerCoords - objCoords)
                        distance = tonumber(string.format("%.2f", distance))
                        local formattedCoords = string.format("vec3(%.2f, %.2f, %.2f)", objCoords.x, objCoords.y, objCoords.z)
                        DrawLine(playerCoords.x, playerCoords.y, playerCoords.z, objCoords.x, objCoords.y, objCoords.z, 255, 0, 0, 255)
                        DrawText3D(objCoords.x, objCoords.y, objCoords.z + 1.0, "Object: " .. modelName .. "\n Hash: " .. objectName .. "\nCoordinates: " .. formattedCoords .. "\nDistance: " .. distance)
                        SetEntityDrawOutline(object, true)
                        if not DoesEntityExist(object) then
                            RemoveBlip(currentBlip)
                            currentBlip = nil
                            SetEntityDrawOutline(currentObject, false)
                            currentObject = nil
                            break
                        end
                    end
                end)
            end
        end 
    end
end)


DrawText3D = function (x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoord())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end

Isallowed = function()                
    lib.showMenu('ox_devtool')
end  

RegisterNetEvent('ox_devltool:canopenyes')
AddEventHandler('ox_devltool:canopenyes', function()
    Isallowed()
    print("è ok il bro")
end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    SetEntityDrawOutline(currentObject, false)
end)
