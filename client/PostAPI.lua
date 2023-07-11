
--NUI POST REQUESTS EVENTS
RegisterNUICallback("CloseMDT", function(data, cb)
    SetNuiFocus(false, false)
    MDTOpen = false
    cb(json.encode({success = true}))
    tabletProp(false)
end)

RegisterNUICallback("SaveEvidence", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:saveEvidence', function(result, id)
        cb(json.encode({success = result, id = id}))
    end, data)
end)

RegisterNUICallback("SaveIncident", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:saveIncident', function(response, id)
        cb(json.encode({success = response, id = id}))
    end, data)
end)

RegisterNUICallback("SaveReport", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:SaveReport', function(response, id)
        cb(json.encode({success = response, id = id}))
    end, data)
end)

RegisterNUICallback("SaveVehicleProfile", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:SaveVehicleProfile', function(result)
        cb(json.encode({success = result}))
    end, data)
end)

RegisterNUICallback("SaveProfile", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:SaveProfile', function(result)
        cb(json.encode({success = result}))
    end, data)
end)

RegisterNUICallback("warrantAction", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:warrantAction', function(result)
        cb(json.encode({success = result}))
    end, data)
end)


RegisterNUICallback("SaveConfig", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:SaveConfig', function(result)
        if result then
            theme = data.theme
            sidebar = data.sidebar
        end
            cb(json.encode({success = result}))
    end, data)
end)

RegisterNUICallback("RemoveLicense", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:RemoveLicense', function(result, id)
        cb(json.encode({success = result, id = id}))
    end, data.identifier, data.id)
end)

