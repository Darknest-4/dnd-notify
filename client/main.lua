local isResourceReady = false
local validActions = {
    initialize = true,
    updateConfig = true,
    showNotification = true,
    changePosition = true,
    playSound = true
}

local notificationHistory = {}
local maxNotificationsPerMinute = 20 -- Limit to prevent spam
local notificationTimeWindow = 60000 -- 1 minute in ms

local function isValidType(data, expectedType)
    return type(data) == expectedType
end

local function sanitizeNUIMessage(data)
    if not isValidType(data, "table") then return nil end
    if not isValidType(data.action, "string") then return nil end
    if not validActions[data.action] then return nil end
    
    local sanitizedData = {
        action = data.action
    }
    
    if data.config and data.action == "updateConfig" then
        sanitizedData.config = {}
        if isValidType(data.config.defaultPosition, "string") then
            sanitizedData.config.defaultPosition = data.config.defaultPosition
        end
        
        if isValidType(data.config.notificationStyles, "table") then
            sanitizedData.config.notificationStyles = {}
            for k, v in pairs(data.config.notificationStyles) do
                if isValidType(k, "string") and (isValidType(v, "string") or isValidType(v, "number")) then
                    sanitizedData.config.notificationStyles[k] = v
                end
            end
        end
        
        if isValidType(data.config.notificationTypes, "table") then
            sanitizedData.config.notificationTypes = {}
            for k, v in pairs(data.config.notificationTypes) do
                if isValidType(k, "string") and isValidType(v, "table") then
                    sanitizedData.config.notificationTypes[k] = {}
                    for subK, subV in pairs(v) do
                        if isValidType(subK, "string") and isValidType(subV, "string") then
                            sanitizedData.config.notificationTypes[k][subK] = subV
                        end
                    end
                end
            end
        end
    elseif data.position and data.action == "changePosition" then
        sanitizedData.position = data.position
    elseif data.data and data.action == "showNotification" then
        sanitizedData.data = data.data
    end
    
    return sanitizedData
end

local function SafeSendNUIMessage(data)
    local sanitized = sanitizeNUIMessage(data)
    if sanitized then
        SendNUIMessage(sanitized)
    else
        print("[dnd-notify] Blocked malformed NUI message")
    end
end

CreateThread(function()
    SetNuiFocus(false, false)
    
    SafeSendNUIMessage({
        action = 'initialize'
    })
    
    Wait(200)
    
    SafeSendNUIMessage({
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

local function sanitizeString(str)
    if not isValidType(str, 'string') then return '' end
    
    local sanitized = str:gsub('<script.->(.-)</script>', '')
                        :gsub('<iframe.->(.-)</iframe>', '')
                        :gsub('javascript:', '')
                        :gsub('onerror=', '')
                        :gsub('onload=', '')
    
    return sanitized
end

local function checkRateLimit()
    local currentTime = GetGameTimer()
    local count = 0
    
    for i = #notificationHistory, 1, -1 do
        if currentTime - notificationHistory[i] > notificationTimeWindow then
            table.remove(notificationHistory, i)
        else
            count = count + 1
        end
    end
    
    if count >= maxNotificationsPerMinute then
        return false
    end
    
    table.insert(notificationHistory, currentTime)
    return true
end

function SendNotification(data)
    if not isResourceReady then return end
    
    if not checkRateLimit() then
        print("[dnd-notify] Rate limit exceeded, notification blocked")
        return
    end
    
    local sanitizedData = {}
    
    if type(data) == 'table' then
        if data.type == 'success' or data.type == 'error' or data.type == 'info' or data.type == 'warning' then
            sanitizedData.type = data.type
        elseif data.type == 'inform' then
            sanitizedData.type = 'info'
        else
            sanitizedData.type = 'info'
        end
        
        sanitizedData.title = sanitizeString(data.title or '')
        sanitizedData.message = sanitizeString(data.message or data.description or '')
        
        local validPositions = {
            ['top-left'] = true, ['top-center'] = true, ['top-right'] = true,
            ['middle-left'] = true, ['middle-center'] = true, ['middle-right'] = true, 
            ['bottom-left'] = true, ['bottom-center'] = true, ['bottom-right'] = true
        }
        
        if data.position and validPositions[data.position] then
            sanitizedData.position = data.position
        else
            sanitizedData.position = Config.DefaultPosition
        end
        
        if type(data.duration) == 'number' and data.duration >= 1000 and data.duration <= 30000 then
            sanitizedData.duration = data.duration
        else
            sanitizedData.duration = Config.Notifications.Duration
        end
        
        sanitizedData.showDuration = data.showDuration == true
        
        if type(data.id) == 'string' then
            sanitizedData.id = data.id:sub(1, 64)
        end
        
        if type(data.style) == 'table' then
            sanitizedData.style = {}
            for k, v in pairs(data.style) do
                if type(k) == 'string' and type(v) == 'string' and
                   not v:match('javascript:') and not v:match('expression') then
                    sanitizedData.style[k] = v
                end
            end
        else
            sanitizedData.style = {}
        end
        
        if type(data.icon) == 'string' then
            if data.icon:match('^<i class="fa[srlbd]? fa%-[%w%-]+"></i>$') then
                sanitizedData.icon = data.icon
            end
        end
        
        if type(data.iconColor) == 'string' then
            sanitizedData.iconColor = data.iconColor
        end
        
        if type(data.iconAnimation) == 'string' then
            local safeAnimations = {spin = true, pulse = true, shake = true}
            if safeAnimations[data.iconAnimation] then
                sanitizedData.iconAnimation = data.iconAnimation
            end
        end
        
        if type(data.alignIcon) == 'string' then
            if data.alignIcon == 'top' or data.alignIcon == 'center' then
                sanitizedData.alignIcon = data.alignIcon
            end
        end
        
        if type(data.sound) == 'table' and type(data.sound.name) == 'string' then
            sanitizedData.sound = {
                name = data.sound.name:sub(1, 64),
                set = type(data.sound.set) == 'string' and data.sound.set:sub(1, 64) or '',
                bank = type(data.sound.bank) == 'string' and data.sound.bank:sub(1, 64) or ''
            }
        end
    else
        sanitizedData = {
            type = 'info',
            message = sanitizeString(tostring(data)),
            position = Config.DefaultPosition,
            duration = Config.Notifications.Duration,
            showDuration = true
        }
    end
    
    SafeSendNUIMessage({
        action = 'showNotification',
        data = sanitizedData
    })
end

exports('SendNotification', SendNotification)

RegisterNetEvent('dnd-notify:showNotification')
AddEventHandler('dnd-notify:showNotification', function(data)
    SendNotification(data)
end)

RegisterNUICallback('nuiReady', function(data, cb)
    isResourceReady = true
    cb({status = 'ok'})
end)

RegisterNetEvent('dnd-notify:changePosition')
AddEventHandler('dnd-notify:changePosition', function(position)
    local validPositions = {
        ['top-left'] = true, ['top-center'] = true, ['top-right'] = true,
        ['middle-left'] = true, ['middle-center'] = true, ['middle-right'] = true, 
        ['bottom-left'] = true, ['bottom-center'] = true, ['bottom-right'] = true
    }
    
    if position and validPositions[position] then
        SafeSendNUIMessage({
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
    
    TriggerEvent('chat:addSuggestion', '/testnotify', 'Test the notification system', {
        { name = 'type', help = 'Notification type (success, error, info, warning, all)' },
        { name = 'message/position', help = 'Message or position when using "all"' },
        { name = 'title/duration', help = 'Title or duration when using "all"' },
        { name = 'position', help = 'Position (top-left, top-center, etc.)' },
        { name = 'duration', help = 'Duration in milliseconds' }
    })
end
