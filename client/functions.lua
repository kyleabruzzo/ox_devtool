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


