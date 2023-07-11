MDTOpen = false
ESX = nil

--tablet prop
isVisible = false
tabletObject = nil

theme = nil
sidebar = nil
name = ''

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function()
    getConfig(function(t, s)
        theme = t
        sidebar = s
    end)
    ESX.TriggerServerCallback('esx_mdt:getname', function(hasname)
        name = hasname
    end)
end)

ESX = exports["es_extended"]:getSharedObject()


RegisterCommand(Config.MDTCommand, function()
    ESX.TriggerServerCallback('esx_mdt:getname', function(hasname)
        print(hasname)
        name = hasname
        TriggerEvent("mdt:client:OpenMDT")
    end)
end, false)

RegisterNetEvent("mdt:client:OpenMDT")
AddEventHandler("mdt:client:OpenMDT", function()
    local pData = ESX.GetPlayerData()
    local isPolice = false
    for k,v in pairs(Config.Policejobs) do
        if not isPolice then
            isPolice = string.find(pData.job.name, v)
        end
    end
    local isPoliceAndOnDuty =  isPolice
    local isLawyer = string.find(pData.job.name, Config.LawyerJob)
    if not isPolice and not isLawyer then
        return ESX.ShowNotification("This command is for emergency services")
    elseif not isLawyer and not isPoliceAndOnDuty then
        return ESX.ShowNotification("You need to be On Duty")
    elseif isPoliceAndOnDuty or isLawyer then

        tabletProp(true)
            SendNUIMessage({
                action = "open",
                theme = theme,
                sidebar = sidebar,
                lawyer = isLawyer,
                actOnWarrant = isLawyer and pData.job.grade >  Config.Judgegrade-1,
                job = { name = name, grade =pData.job.grade_label, level = pData.job.grade }
            })
        SetNuiFocus(true, true)
        MDTOpen = true
    end
end)

function tabletProp(open)
    local playerPed = PlayerPedId()
    if not isVisible and open then
        local dict = "amb@world_human_seat_wall_tablet@female@base"
        RequestAnimDict(dict)
        if tabletObject == nil then
            tabletObject = CreateObject(GetHashKey('prop_cs_tablet'), GetEntityCoords(playerPed), 1, 1, 1)
            AttachEntityToEntity(tabletObject, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.0, 0.03, 0.0, 0.0, 0.0, 1, 1, 0, 1, 0, 1)
        end
        while not HasAnimDictLoaded(dict) do Citizen.Wait(100) end
        if not IsEntityPlayingAnim(playerPed, dict, 'base', 3) then
            TaskPlayAnim(playerPed, dict, "base", 8.0, 1.0, -1, 49, 1.0, 0, 0, 0)
        end
    elseif not open then
        DeleteEntity(tabletObject)
        ClearPedTasks(playerPed)
        tabletObject = nil
    end
end

function getConfig(cb)
    ESX.TriggerServerCallback('mdt:server:GetConfig', function(theme, sidebar)
        cb(theme, sidebar)
    end)
end
