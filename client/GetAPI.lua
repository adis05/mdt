
--NUI GET REQUESTS EVENTS
RegisterNUICallback("GetPersons", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:getPersons', function(persons)
        cb(json.encode({persons = persons}))
    end, data.search)
end)

RegisterNUICallback("GetOfficers", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:getOfficers', function(officers)
        cb(json.encode({officers = officers}))
    end, data.search)
end)

RegisterNUICallback("GetPersonDetail", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:getPersonDetail', function(person)
        cb(json.encode({person = person[1]}))
    end, data.search)
end)

RegisterNUICallback("GetEvidenceById", function(data, cb)
    local id = data.id
    ESX.TriggerServerCallback('mdt:server:getEvidenceById', function(evidence)
        if #evidence >=0 then cb(json.encode({success = true, evidence = evidence[1], count = count}))
        else cb(json.encode({success = false, count = -1})) end
    end, id)
end)

RegisterNUICallback("GetVehicleDetail", function(data, cb)
    local plate = data.search
    ESX.TriggerServerCallback('mdt:server:getVehicleByPlate', function(vehicle)
        if vehicle[1] ~= nil then
            local data = json.decode(vehicle[1].vehicle)
            vehicle[1].vehicle = GetDisplayNameFromVehicleModel(data.model)
            cb(json.encode({vehicle = vehicle[1]}))
        end
    end, plate)
end)

RegisterNUICallback("GetVehicleForProfile", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:getVehicleForProfile', function(vehicle)
        if vehicle.vehicleInfo ~= nil then
            local data = json.decode(vehicle.vehicleInfo.vehicle)
            vehicle.vehicleInfo.vehicle = GetDisplayNameFromVehicleModel(data.model)
        end
        cb(json.encode(vehicle))

    end, data.search)
end)

RegisterNUICallback("GetProfile", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:getProfile', function(profile)
        if profile.vehicles[1] ~= nil then
            for k,v in pairs(profile.vehicles) do
                local data = json.decode(profile.vehicles[k].vehicle)
                profile.vehicles[k].vehicle = GetDisplayNameFromVehicleModel(data.model)
            end
        end
        cb(json.encode(profile))
    end, data.search)
end)

RegisterNUICallback("ListWarrants", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:ListWarrants',function(results)
        cb(json.encode(results))
    end, data.search)
end)

RegisterNUICallback("ListReports", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:ListReports',function(results)
        cb(json.encode(results))
    end, data.search)
end)

RegisterNUICallback("ListIncidents", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:ListIncidents',function(results)
        cb(json.encode(results))
    end, data.search)
end)

RegisterNUICallback("ListVehicles", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:ListVehicles',function(results)
        if results[1] ~= nil then
            for k,v in pairs(results) do
                local data = json.decode(results[k].vehicle)
                results[k].vehicle = GetDisplayNameFromVehicleModel(data.model)
            end
        end
        cb(json.encode(results))
    end, data.search)
end)

RegisterNUICallback("ListEvidences", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:ListEvidences',function(results)
        cb(json.encode(results))
    end, data.search)
end)

RegisterNUICallback("ListProfiles", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:ListProfiles',function(results)
        cb(json.encode(results))
    end, data.search)
end)

RegisterNUICallback("LoadData", function(data, cb)
    ESX.TriggerServerCallback('mdt:server:LoadData',function(loadData)
        cb(json.encode(loadData))
    end, data.id, data.type)
end)