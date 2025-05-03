function SendNotification(source, data)
    TriggerClientEvent('dnd-notify:showNotification', source, data)
end

exports('SendNotification', SendNotification)

RegisterServerEvent('dnd-notify:sendNotification')
AddEventHandler('dnd-notify:sendNotification', function(target, data)
    if not data then return end
    
    if target == -1 then
        TriggerClientEvent('dnd-notify:showNotification', -1, data)
    else
        TriggerClientEvent('dnd-notify:showNotification', target, data)
    end
end)

RegisterServerEvent('dnd-notify:changePosition')
AddEventHandler('dnd-notify:changePosition', function(target, position)
    if not position then return end
    
    if target == -1 then
        TriggerClientEvent('dnd-notify:changePosition', -1, position)
    else
        TriggerClientEvent('dnd-notify:changePosition', target, position)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    print('^2dnd-notify^7: Resource started successfully')
end)
