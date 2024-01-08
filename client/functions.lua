local objeSet = false
local obje = nil
local objeLocked = false
local editMode = false
local currentBlip = nil  
local currentObject = nil


notify = function(id, title, desc, icon, color)
    if color == "red" then 
        color = "#C53030"
    elseif color == "green" then 
        color = "#30c57b"
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
            backgroundColor = '#383b40',
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



-- Testing
RegisterCommand('setes', function(source, args, rawCommand)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsUsing(playerPed)
    SetVehicleEngineHealth(vehicle, 0)
    SetVehicleBodyHealth(vehicle, 0)
end, false)

RegisterNetEvent('drawCarinfo')
AddEventHandler('drawCarinfo', function()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            local playerPed = PlayerPedId()
            local vehicle = GetVehiclePedIsUsing(playerPed)

            if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                local carCoords = GetEntityCoords(vehicle)

                local maxt = GetVehicleMaxTraction(vehicle)
                local maxBrakeForce = GetVehicleHandlingFloat(vehicle, "CHandlingData", "fBrakeForce")
                local engineStatus = GetVehicleEngineHealth(vehicle)
                local bodyStatus = GetVehicleBodyHealth(vehicle)

                local textcar = string.format("Max Traction: %.2f\n Max Break force: %.2f\n Engine Status: %.2f\n Body Status: %.2f",maxt,maxBrakeForce,engineStatus,bodyStatus)
                local speed = GetEntitySpeed(vehicle) * 3.6
                local speedText = string.format("Speed: %.2f km/h \n", speed)
                DrawText3D(carCoords.x, carCoords.y , carCoords.z - 1.0,speedText)                
                DrawText3D(carCoords.x, carCoords.y , carCoords.z - 1.2, textcar)                
            end
        end
    end)
end)




RegisterNetEvent('repairCar')
AddEventHandler('repairCar', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsUsing(playerPed)
    SetVehicleEngineHealth(vehicle, 1000)
	SetVehicleEngineOn(vehicle, true, true)
	SetVehicleFixed(vehicle)
	SetVehicleDirtLevel(vehicle, 0)
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


RegisterCommand("spawnt", function(source, args, rawCommand)
    local data =  { objname = args[1] }    
    TriggerEvent("objectspawn", data)
end, false)

RegisterCommand("dell", function(source, args, rawCommand)
    local data = { objname = args[1] }  
    TriggerEvent("deleteobject", data)
end, false)


AddEventHandler("objectspawn", function(data)
		local playerCoords = GetEntityCoords(PlayerPedId())
		obje = CreateObject(data.objname, playerCoords.x + 1.25, playerCoords.y, playerCoords.z -1, true, true, true)
		print(obje)
        notify("propsw", "Prop", "Object Spawned.", "succ", "green")
		FreezeEntityPosition(obje, true)
		SetEntityAsMissionEntity(obje,true,true)
		objeSet = true
		editMode = true
		objeLocked = false

end)



AddEventHandler("deleteobject", function(data)
    print(data.objname)
	local playerPed = PlayerPedId()
    local obbje = GetHashKey(data.objname)
	local playercoords = GetEntityCoords(playerPed)
    if DoesObjectOfTypeExistAtCoords(playercoords, 4.5, obbje, true) then
		FreezeEntityPosition(obbje,false)
        local obj = GetClosestObjectOfType(playercoords, 4.5, obbje, false, false, false)
        DeleteObject(obj)
        notify("propsw", "Prop", "Prop deleted.", "succ", "green")
	else
        notify("propsw", "Prop", "No objects nearby.", "error", "red")
    end
end)



Citizen.CreateThread(function()
	while not NetworkIsSessionStarted() do
		Citizen.Wait(500)
	end
	while true do
		local sleep = 1500
		if objeSet and editMode then
			sleep  = 1
			local playerPed = PlayerPedId()
			local playercoords = GetEntityCoords(playerPed)
			local objecoords = GetEntityCoords(obje)
			local Waiting = 1500
			while #(objecoords - playercoords) < 4.0 and editMode and  not objeLocked do
				Waiting = 1
                
				ESX.ShowHelpNotification('~INPUT_VEH_FLY_PITCH_UD~ : Up & Down ~n~~INPUT_CELLPHONE_UP~ ~INPUT_CELLPHONE_LEFT~ ~INPUT_CELLPHONE_RIGHT~ ~INPUT_CELLPHONE_DOWN~ : Steer ~n~~INPUT_VEH_FLY_SELECT_TARGET_LEFT~ ~INPUT_VEH_FLY_SELECT_TARGET_RIGHT~ : Direction ~n~~INPUT_WEAPON_WHEEL_NEXT~ ~INPUT_WEAPON_WHEEL_PREV~ : Rotation ~n~ ~INPUT_FRONTEND_ACCEPT~ : Lock Object ~n~ ~INPUT_FRONTEND_RRIGHT~ : Close Edit', true)
				if IsControlPressed(0, 111) then
					SetEntityCoords(obje, GetOffsetFromEntityInWorldCoords(obje, 0.0, 0.0, 0.05))
				end
				if IsControlPressed(0, 110) then
					SetEntityCoords(obje, GetOffsetFromEntityInWorldCoords(obje, 0.0, 0.0, -0.05))
				end
				if IsControlPressed(0, 172) then
					SetEntityCoords(obje, GetOffsetFromEntityInWorldCoords(obje, 0.0, 0.05, 0.0))
				end
				if IsControlPressed(0, 173) then
					SetEntityCoords(obje, GetOffsetFromEntityInWorldCoords(obje, 0.0, -0.05, 0.0))
				end
				if IsControlPressed(0, 174) then
					SetEntityCoords(obje, GetOffsetFromEntityInWorldCoords(obje, -0.05, 0.0, 0.0))
				end
				if IsControlPressed(0, 175) then
					SetEntityCoords(obje, GetOffsetFromEntityInWorldCoords(obje, 0.05, 0.0, 0.0))
				end
				if IsControlPressed(0, 117) then
					SetEntityHeading(obje, GetEntityHeading(obje) + 0.5)
				end
				if IsControlPressed(0, 118) then
					SetEntityHeading(obje, GetEntityHeading(obje) - 0.5)
				end
				if IsControlPressed(0, 14) then
					SetEntityRotation(obje, GetEntityRotation(obje) - 0.5)
				end
				if IsControlPressed(0, 15) then
					SetEntityRotation(obje, GetEntityRotation(obje) + 0.5)
				end
				if IsControlJustReleased(0, 191) then
					objeLocked = true
					editMode = not editMode
					FreezeEntityPosition(obje, true)
				end
                if IsControlJustReleased(0, 194) then
                    editMode = false
                    lib.hideTextUI()
				end
                
				Citizen.Wait(Waiting)
			end
			playerPed = PlayerPedId()
			playercoords = GetEntityCoords(playerPed)
			objecoords = GetEntityCoords(obje)
			
		end
		Citizen.Wait(sleep)
	end
end)



Isallowed = function()                
    lib.showMenu('ox_devtool')
end  

RegisterNetEvent('ox_devltool:canopenyes')
AddEventHandler('ox_devltool:canopenyes', function()
    Isallowed()

end)

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    SetEntityDrawOutline(currentObject, false)
end)
