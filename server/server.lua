local reqperm = true

RegisterNetEvent("ox_devtool:canopen")
AddEventHandler("ox_devtool:canopen", function()
	local src = source
	if not reqperm or IsPlayerAceAllowed(src, "command.devtools") == 1 then
        print("si server")
		TriggerClientEvent("ox_devltool:canopenyes", src)
	end
end)