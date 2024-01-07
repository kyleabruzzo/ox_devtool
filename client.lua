local recording = false
lib.registerMenu({
    id = 'ox_editor',
    title = 'OX Editor',
    position = 'bottom-right',
    onSelected = function(selected, secondary, args)

    end,
    onClose = function(keyPressed)
    end,
    options = {
        { label = 'Record',      description = 'Start recording' },
        { label = 'Stop',        description = 'Stop recording' },
        { label = 'Open Editor', description = 'Open the rockstar editor' },
    }
}, function(selected, scrollIndex, args)
    if selected == 1 then
        if not recording then
            recording = true
            StartRecording(1)
            lib.notify({
                title = 'OX Editor',
                description = 'You are recording!',
                type = 'success'
            })
        else
            lib.notify({
                title = 'OX Editor',
                description = 'You are already recording!',
                type = 'error'
            })
        end
    elseif selected == 2 then
        if recording then
            recording = false
            StopRecordingAndSaveClip()
            lib.notify({
                title = 'OX Editor',
                description = 'Stopped succesfuly!',
                type = 'success'
            })
        else
            lib.notify({
                title = 'OX Editor',
                description = 'You are not recording!',
                type = 'error'
            })
        end
    elseif selected == 3 then
        NetworkSessionLeaveSinglePlayer()
        ActivateRockstarEditor()
    end
end)

RegisterKeyMapping('+editor', 'Open The Editor', 'keyboard', 'F5')
RegisterCommand('+editor', function()
    lib.showMenu('ox_editor')
end)
