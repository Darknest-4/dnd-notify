local function sanitizeString(str)
    if type(str) ~= 'string' then return '' end
    str = str:gsub('<script.->(.-)</script>', '')
    str = str:gsub('<iframe.->(.-)</iframe>', '')
    str = str:gsub('javascript:', '')
    str = str:gsub('onerror=', '')
    str = str:gsub('onload=', '')
    return str
end

local allowedParams = {
    type = true, title = true, message = true, description = true, 
    position = true, duration = true, showDuration = true, 
    id = true, style = true, icon = true, iconColor = true,
    iconAnimation = true, alignIcon = true, sound = true
}

local allowedPositions = {
    ['top-left'] = true, ['top-center'] = true, ['top-right'] = true,
    ['middle-left'] = true, ['middle-center'] = true, ['middle-right'] = true,
    ['bottom-left'] = true, ['bottom-center'] = true, ['bottom-right'] = true
}

local allowedTypes = {
    ['success'] = true, ['error'] = true, 
    ['info'] = true, ['warning'] = true, ['inform'] = true
}

RegisterNetEvent('dnd-notify:sendNotification')
AddEventHandler('dnd-notify:sendNotification', function(target, notificationData)
    local source = source
    
    if type(notificationData) ~= 'table' then
        print('[dnd-notify] Invalid notification data format from source: ' .. source)
        return
    end
    
    local sanitizedData = {}
    
    for k, v in pairs(notificationData) do
        if allowedParams[k] then
            if k == 'type' and type(v) == 'string' then
                if allowedTypes[v] then
                    sanitizedData[k] = v
                else
                    sanitizedData[k] = 'info'
                end
            elseif k == 'position' and type(v) == 'string' then
                if allowedPositions[v] then
                    sanitizedData[k] = v
                else
                    sanitizedData[k] = Config.DefaultPosition
                end
            elseif k == 'title' or k == 'message' or k == 'description' then
                sanitizedData[k] = sanitizeString(tostring(v))
            elseif k == 'style' and type(v) == 'table' then
                sanitizedData[k] = {}
                for styleKey, styleValue in pairs(v) do
                    if type(styleKey) == 'string' and type(styleValue) == 'string' and
                       not styleValue:match('javascript:') and not styleValue:match('expression') then
                        sanitizedData[k][styleKey] = styleValue
                    end
                end
            elseif k == 'sound' and type(v) == 'table' then
                sanitizedData[k] = {
                    name = type(v.name) == 'string' and v.name:sub(1, 64) or '',
                    set = type(v.set) == 'string' and v.set:sub(1, 64) or '',
                    bank = type(v.bank) == 'string' and v.bank:sub(1, 64) or ''
                }
            elseif k == 'duration' then
                if type(v) == 'number' and v >= 1000 and v <= 30000 then
                    sanitizedData[k] = v
                else
                    sanitizedData[k] = Config.Notifications.Duration
                end
            elseif k == 'id' and type(v) == 'string' then
                sanitizedData[k] = v:sub(1, 64)
            else
                sanitizedData[k] = v
            end
        end
    end
    
    if source > 0 then
        if GetPlayerName(source) then
            TriggerClientEvent('dnd-notify:showNotification', source, sanitizedData)
            if target and target ~= source then
                print('[dnd-notify] Security: Player ' .. source .. ' attempted to send notification to different player: ' .. tostring(target))
            end
        end
    else
        if target and type(target) == 'number' and GetPlayerName(target) then
            TriggerClientEvent('dnd-notify:showNotification', target, sanitizedData)
        end
    end
end)

local function SendNotificationToPlayer(playerId, data)
    if not playerId or not GetPlayerName(playerId) then return end
    
    TriggerEvent('dnd-notify:sendNotification', playerId, data)
end

local function SendSelfNotification(data)
    local source = source
    if source > 0 and GetPlayerName(source) then
        TriggerClientEvent('dnd-notify:showNotification', source, data)
    end
end

exports('SendNotificationToPlayer', SendNotificationToPlayer)
exports('SendSelfNotification', SendSelfNotification)
