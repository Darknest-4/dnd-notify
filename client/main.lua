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
    
    if type(data) == 'table' then
        if data.type == 'success' or data.type == 'error' or data.type == 'info' or data.type == 'warning' then
        elseif data.type == 'inform' then
            data.type = 'info'
        end
        
        data.type = data.type or 'info'
        data.title = data.title or ''
        data.message = data.message or data.description or ''
        data.position = data.position or Config.DefaultPosition
        data.duration = data.duration or Config.Notifications.Duration
        
        if data.showDuration == nil then
            data.showDuration = true
        end
        
        if not data.style then
            data.style = {}
        end
    else
        data = {
            type = 'info',
            message = tostring(data),
            position = Config.DefaultPosition,
            duration = Config.Notifications.Duration,
            showDuration = true
        }
    end
    
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
    RegisterCommand('testnotify', function(source, args, rawCommand)
        local type = args[1] or 'info'
        
        if type == 'all' then
            local position = args[2] or Config.DefaultPosition
            local duration = args[3] and tonumber(args[3]) or Config.Notifications.Duration
            
            local notifyTypes = {'success', 'error', 'info', 'warning'}
            
            CreateThread(function()
                for i, notifyType in ipairs(notifyTypes) do
                    SendNotification({
                        type = notifyType,
                        title = notifyType:gsub('^%l', string.upper) .. ' Notification',
                        description = 'This is an example of a ' .. notifyType .. ' notification!',
                        position = position,
                        duration = duration
                    })
                    Wait(600)
                end
            end)
            return
        end
        
        local msg = args[2] or 'This is a test notification!'
        local title = args[3] or 'Notification'
        local position = args[4] or Config.DefaultPosition
        local duration = args[5] and tonumber(args[5]) or Config.Notifications.Duration
        
        if not Config.NotificationTypes[type] then
            type = 'info'
        end
        
        SendNotification({
            type = type,
            title = title,
            description = msg,
            position = position,
            duration = duration
        })
    end, false)
    
    TriggerEvent('chat:addSuggestion', '/testnotify', 'Test the notification system v2', {
        { name = 'type', help = 'Notification type (success, error, info, warning, all)' },
        { name = 'message/position', help = 'Message or position when using "all"' },
        { name = 'title/duration', help = 'Title or duration when using "all"' },
        { name = 'position', help = 'Position (top-left, top-center, etc.)' },
        { name = 'duration', help = 'Duration in milliseconds' }
    })
end
