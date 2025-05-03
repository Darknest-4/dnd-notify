local isResourceReady = false

CreateThread(function()
    SetNuiFocus(false, false)
    
    SendNUIMessage({
        action = 'initialize'
    })
    
    Wait(200)
    
    SendNUIMessage({
        action = 'updateConfig',
        config = {
            defaultPosition = Config.DefaultPosition,
            notificationStyles = Config.Notifications,
            notificationTypes = Config.NotificationTypes
        }
    })
    
    Wait(100)
    isResourceReady = true
end)

function SendNotification(data)
    if not isResourceReady then return end
    
    data.type = data.type or 'info'
    data.message = data.message or ''
    data.position = data.position or Config.DefaultPosition
    data.duration = data.duration or Config.Notifications.Duration
    
    SendNUIMessage({
        action = 'showNotification',
        data = data
    })
end

exports('SendNotification', SendNotification)

RegisterNetEvent('dnd-notify:showNotification')
AddEventHandler('dnd-notify:showNotification', function(data)
    SendNotification(data)
end)

RegisterNUICallback('nuiReady', function(data, cb)
    isResourceReady = true
    cb('ok')
end)

RegisterNetEvent('dnd-notify:changePosition')
AddEventHandler('dnd-notify:changePosition', function(position)
    if position then
        SendNUIMessage({
            action = 'changePosition',
            position = position
        })
    end
end)

if Config.EnableTestCommand then
    RegisterCommand('testnotifyv2', function(source, args, rawCommand)
        local type = args[1] or 'info'
        local message = args[2] or 'This is a test notification!'
        local position = args[3] or Config.DefaultPosition
        
        if not Config.NotificationTypes[type] then
            type = 'info'
        end
        
        SendNotification({
            type = type,
            message = message,
            position = position
        })
    end, false)
    
    TriggerEvent('chat:addSuggestion', '/testnotifyv2', 'Test the notification system v2', {
        { name = 'type', help = 'Notification type (success, error, info, warning)' },
        { name = 'message', help = 'Notification message' },
        { name = 'position', help = 'Position (top-left, top-center, etc.)' }
    })
end
