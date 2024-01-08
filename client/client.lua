local recording = false
local checkboxed = false
lib.registerMenu({
    id = 'rockstareditor',
    title = 'Rockstar Editor',
    position = 'bottom-right',
    options = {
        { label = 'Record',      description = 'Start recording' },
        { label = 'Stop',        description = 'Stop recording' },
        { label = 'Open Editor', description = 'Open the rockstar editor' },
        { label = 'Go Back',  icon = 'arrow-left', description = 'Return To Main Menu' },
        
    }
}, function(selected, scrollIndex, args)
    if selected == 1 then
        if not recording then
            recording = true
            StartRecording(1)
            notify("rec", "Rockstar Editor", "You started the recording!", "succ", "green")
        else
            notify("rec", "Rockstar Editor", "You are already recording!", "error", "red")
        end
    elseif selected == 2 then
        if recording then
            recording = false
            StopRecordingAndSaveClip()
            notify("rec", "Rockstar Editor", "Clip Saved!", "succ", "green")
        else
            notify("rec", "Rockstar Editor", "You are not recording!", "error", "red")
        end
    elseif selected == 3 then
        NetworkSessionLeaveSinglePlayer()
        ActivateRockstarEditor()
    elseif selected == 4 then 
        lib.showMenu('ox_devtool')
    end
end)

lib.registerMenu({
    id = 'coordsmenu',
    title = 'Coordinates',
    position = 'bottom-right',
    options = {
        { label = 'JSON', description = '' },
        { label = 'Normal', description = '' },
        { label = 'VEC3', description = '' },
        { label = 'VEC4', description = '' },
        { label = 'Go Back', icon = 'arrow-left', description = 'Return To Main Menu' },
    },

}, function(selected, scrollIndex, args)
    if selected == 1 then
        local jsonCoords = getcoord("json")
        lib.setClipboard(jsonCoords)
        notify("json", "Coords", "The coords are copied in ur clipboard", "succ", "green")      
        print(jsonCoords)
    elseif selected == 2 then
        local normalCoords = getcoord("normal")
        lib.setClipboard(normalCoords)
        notify("norm", "Coords", "The coords are copied in ur clipboard", "succ", "green")
        print(normalCoords)
    elseif selected == 3 then
        local vec3Coords = getcoord("vec3")
        lib.setClipboard(vec3Coords)
        notify("vec3", "Coords", "The coords are copied in ur clipboard", "succ", "green")
        print(tostring(vec3Coords))
    elseif selected == 4 then
        local vec4Coords = getcoord("vec4")
        lib.setClipboard(vec4Coords)
        print(tostring(vec4Coords))
        notify("vec4", "Coords", "The coords are copied in ur clipboard", "succ", "green")
    elseif selected == 5 then
        lib.showMenu('ox_devtool')
    end
end)
lib.registerMenu({
    id = 'propmenu',
    title = 'Props',
    position = 'bottom-right',
    options = {
        { label = 'Prop Finder', description = 'Find props in area' },
        { label = 'Go Back', icon = 'arrow-left', description = 'Return To Main Menu' },
    },

}, function(selected, scrollIndex, args)
    if selected == 1 then
        local input = lib.inputDialog('Insert Prop Name', {'Model name'})
        if input and input[1] then
            TriggerEvent('searchObject', input[1])
        else
            notify("prop", "Prop", "Input is empty. Please provide a valid input.", "error", "red")
        end
    elseif selected == 2 then
        lib.showMenu('ox_devtool')
    end
end)

lib.registerMenu({
    id = 'ox_devtool',
    title = 'OX DevTool',
    position = 'bottom-right',
    onSelected = function(selected, secondary, args)

    end,
    onClose = function(keyPressed)
    end,
    options = {
        { label = 'Rockstar Editor Tool',      description = 'Recording Tools' },
        { label = 'Coordinates',      description = 'All coordinates' },
        { label = 'Props Tools',      description = 'Prop Tools' },
    }
}, function(selected, scrollIndex, args)
    if selected == 1 then
        lib.showMenu('rockstareditor')
    elseif selected == 2 then
        lib.showMenu('coordsmenu')
    elseif selected == 3 then
        lib.showMenu('propmenu')
    end
end)

   
RegisterKeyMapping('+editor', 'Open The DevTool', 'keyboard', 'F5')
RegisterCommand('+editor', function()

    TriggerServerEvent("ox_devtool:canopen")
end)
