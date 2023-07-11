
--GET REQUESTS TO SERVER (CALLBACKS)
ESX.RegisterServerCallback("mdt:server:getPersons", function(source, cb, search)
    oxmysql:execute("SELECT CONCAT(firstname,' ',lastname) AS name, identifier FROM users WHERE CONCAT(firstname,' ',lastname) LIKE @search LIMIT 100", {
        ["@search"] = "%"..EscapeSqli(search).."%"
    }, function(result) checkNSend(result, cb) end, true)
end)

ESX.RegisterServerCallback("mdt:server:getOfficers", function(source, cb, search)
    oxmysql:execute("SELECT CONCAT('[', job_grade, ']'), CONCAT(firstname, ' ', lastname) AS name, identifier FROM users WHERE CONCAT(firstname, ' ', lastname) LIKE @search AND job LIKE '%police%' LIMIT 100", {
        ["@search"] = "%"..EscapeSqli(search).."%"
    }, function(result) checkNSend(result, cb) end, true)
end)

ESX.RegisterServerCallback("mdt:server:getPersonDetail", function(source, cb, search)
    oxmysql:execute("SELECT mdt_profiles.image, CONCAT (users.firstname,' ', users.lastname) AS name, users.identifier FROM users LEFT JOIN mdt_profiles ON mdt_profiles.identifier = users.identifier WHERE CONCAT(firstname,' ',lastname)LIKE @search LIMIT 1", {
        ["@search"] = "%"..EscapeSqli(search).."%"
    }, function(result) checkNSend(result, cb) end, true)
end)

ESX.RegisterServerCallback("mdt:server:getEvidenceById", function(source, cb, id)
    oxmysql:execute("SELECT * FROM `mdt_evidences` WHERE id = @id LIMIT 1", {
        ["@id"] = EscapeSqli(id)
    }, function(result) checkNSend(result, cb) end, true)
end)

ESX.RegisterServerCallback("mdt:server:getVehicleByPlate", function(source, cb, plate)
    oxmysql:execute("SELECT owned_vehicles.owner, owned_vehicles.plate, owned_vehicles.vehicle, CONCAT (users.firstname,' ', users.lastname) AS owner FROM owned_vehicles INNER JOIN users ON users.identifier = owned_vehicles.owner WHERE owned_vehicles.plate LIKE @plate LIMIT 1", {
        ["@plate"] = EscapeSqli(plate).."%"
    }, function(result) checkNSend(result, cb) end, true)
end)

ESX.RegisterServerCallback("mdt:server:getVehicleForProfile", function(source, cb, plate)
    oxmysql:execute("SELECT owned_vehicles.owner, owned_vehicles.plate, owned_vehicles.vehicle, mdt_vehicles.notes, mdt_vehicles.image, CONCAT (users.firstname,' ', users.lastname) AS owner FROM owned_vehicles INNER JOIN users ON users.identifier = owned_vehicles.owner LEFT JOIN mdt_vehicles ON mdt_vehicles.plate = owned_vehicles.plate WHERE owned_vehicles.plate = @plate LIMIT 1", {
        ["@plate"] = EscapeSqli(plate)
    }, function(vehicleInfo)
        oxmysql:execute("SELECT vehicles, id FROM `mdt_incidents` WHERE JSON_EXTRACT(vehicles, '$[*].plate') LIKE @plate", {
            ["@plate"] = "%"..EscapeSqli(plate).."%"
        }, function(involvedIncidents)
            oxmysql:execute("SELECT vehicles, id FROM `mdt_reports` WHERE JSON_EXTRACT(vehicles, '$[*].plate') LIKE @plate", {
                ["@plate"] = "%"..EscapeSqli(plate).."%"
            }, function(involvedReports)
                local vehiclesInIncidents = {}
                local vehiclesInReports = {}
                --Vehicles In Incidents
                for k,v in pairs(involvedIncidents) do
                    local vehicles = json.decode(v.vehicles)
                    for kV, vV in pairs(vehicles) do
                        if vV.plate == plate then table.insert(vehiclesInIncidents, {id = v.id, seize = vV.seize, fine = vV.fine, plate = vV.plate}) end
                    end
                end
                --Vehicles In Reports
                for k,v in pairs(involvedReports) do
                    local vehicles = json.decode(v.vehicles)
                    for kV, vV in pairs(vehicles) do
                        if vV.plate == plate then table.insert(vehiclesInReports, {id = v.id, seize = vV.seize, fine = vV.fine, plate = vV.plate}) end
                    end
                end
                cb({vehicleInfo = vehicleInfo[1], vehiclesInIncidents = vehiclesInIncidents , vehiclesInReports = vehiclesInReports})
            end, true)
        end, true)
    end, true)
end)





ESX.RegisterServerCallback("esx_mdt:getname", function(source, cb)
    local Player = ESX.GetPlayerFromId(source)
    oxmysql:execute('SELECT firstname, lastname FROM users WHERE identifier = ?', { Player.identifier },
    function(result)
        if result[1] then
           cb(result[1].firstname .. " " .. (result[1].lastname or '')) 
        else 
            cb('Dolaji')
        end
    end)
end)


ESX.RegisterServerCallback("mdt:server:getProfile", function(source, cb, identifier)
    local escCitizenId = EscapeSqli(identifier)
    oxmysql:execute("SELECT mdt_profiles.notes, mdt_profiles.image, users.identifier, users.identifier,  CONCAT (users.firstname,' ', users.lastname) AS name, users.job AS job, users.job_grade AS jobgrade FROM mdt_profiles RIGHT JOIN users ON users.identifier = mdt_profiles.identifier WHERE users.identifier = @identifier LIMIT 1", {
        ["@identifier"] = escCitizenId
    }, function(profile)
        oxmysql:execute("SELECT vehicle, plate FROM owned_vehicles WHERE owner = @identifier", {
            ["@identifier"] = escCitizenId
        }, function(vehicles)
            oxmysql:execute("SELECT criminals, id FROM `mdt_incidents` WHERE JSON_EXTRACT(criminals, '$[*].identifier') LIKE @identifier", {
                ["@identifier"] = "%"..escCitizenId.."%"
            }, function(criminals)
                local priors = {}
                for k,v in pairs(criminals) do
                    local criminalsInIncident = json.decode(v.criminals)
                    for kC, vC in pairs(criminalsInIncident) do
                        if vC.identifier == identifier then
                            for kCC, vCC in pairs(vC.charges) do
                                if not contains(priors, vCC.name) then table.insert(priors, vCC.name) end
                            end
                        end
                    end
                end
                profile[1].metadata = {}
                profile[1].metadata.licences = {}
                local ESXJobs
                if Config.ESXVersion == 'Legacy' then
                    ESXJobs = ESX.GetJobs()
                else
                    ESXJobs = ESX.Jobs
                end
                if ESXJobs[profile[1]['job']].grades[tostring(profile[1]['jobgrade'])] ~= nil then
                    profile[1]['jobgrade'] = ESXJobs[profile[1]['job']].grades[tostring(profile[1]['jobgrade'])].label
                else
                    profile[1]['jobgrade'] = ESXJobs[profile[1]['job']].grades[profile[1]['jobgrade']].label
                end
                profile[1]['job'] = ESXJobs[profile[1]['job']].label
                local liedata = {}
                oxmysql:execute("SELECT * FROM `user_licenses` WHERE owner  = @identifier", {
                    ["@identifier"] = identifier
                }, function(result)
                    
                    if result[1] ~= nil then
                        for k,v in pairs(result) do
                            print(v.type)
                            liedata[v.type] = true
                        end
                        profile[1].metadata.licences = liedata
                    end

                    

                    cb({info = profile[1], priors = priors, vehicles = vehicles})

                end, true)

            end, true)
        end, true)
    end, true)
end)

--Listings
ESX.RegisterServerCallback("mdt:server:ListWarrants", function(source, cb, search)
    oxmysql:execute(ListData.Query["warrants"], ListData.QueryParam("warrants", search), function(result) checkNSend(result, cb) end, true)
end)

ESX.RegisterServerCallback("mdt:server:ListReports", function(source, cb, search)
    oxmysql:execute(ListData.Query["reports"], ListData.QueryParam("reports", search), function(result) checkNSend(result, cb) end, true)
end)

ESX.RegisterServerCallback("mdt:server:ListIncidents", function(source, cb, search)
    oxmysql:execute(ListData.Query["incidents"], ListData.QueryParam("incidents", search), function(result) checkNSend(result, cb) end, true)
end)

ESX.RegisterServerCallback("mdt:server:ListVehicles", function(source, cb, search)
    oxmysql:execute(ListData.Query["vehicles"], ListData.QueryParam("vehicles", search), function(result) checkNSend(result, cb) end, true)
end)

ESX.RegisterServerCallback("mdt:server:ListProfiles", function(source, cb, search)
    oxmysql:execute(ListData.Query["profiles"], ListData.QueryParam("profiles", search), function(result) checkNSend(result, cb) end, true)
end)

ESX.RegisterServerCallback("mdt:server:ListEvidences", function(source, cb, search)
    oxmysql:execute(ListData.Query["evidences"], ListData.QueryParam("evidences", search), function(result) checkNSend(result, cb) end, true)
end)


--Loading Data
ESX.RegisterServerCallback("mdt:server:LoadData", function(source, cb, id, type)
    local typeLower = string.lower(type)
    local Player = ESX.GetPlayerFromId(source)

    local identifier = Player.identifier;
    oxmysql:execute(LoadData.Query[typeLower], LoadData.QueryParam(id), function(result)
        local edit = result[1].createdby == identifier
        cb({result = result[1], edit = edit})
    end, true)
end)

ESX.RegisterServerCallback("mdt:server:GetConfig", function(source, cb)
    local Player = ESX.GetPlayerFromId(source)
    local identifier = Player.identifier;
    oxmysql:execute("SELECT * FROM `mdt_config` WHERE identifier  = @identifier LIMIT 1", {
        ["@identifier"] = identifier
    }, function(result)
        
        if result[1] ~= nil then
            cb(result[1].theme, result[1].sidebar)
        else
            cb(0,1)
        end
    end, true)
end)

EscapeSqli = function(str)
    local replacements = { ['"'] = '\\"', ["'"] = "\\'" }
    return str:gsub( "['\"]", replacements ) -- or string.gsub( source, "['\"]", replacements )
end

