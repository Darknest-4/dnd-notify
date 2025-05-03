Config = {}

-- Enable or disable test command (/testnotify)
Config.EnableTestCommand = true

-- Default position for notifications
-- Available positions: 'top-left', 'top-center', 'top-right', 
--                      'middle-left', 'middle-center', 'middle-right',
--                      'bottom-left', 'bottom-center', 'bottom-right'
Config.DefaultPosition = 'top-right'

Config.Notifications = {
    BackgroundColor = 'rgba(20, 20, 40, 0.85)',
    TextColor = '#ffffff',
    BorderWidth = '4px',
    BorderRadius = '8px',
    FontSize = '14px',
    Width = '320px',
    MinWidth = '300px',
    MinHeight = '80px',
    Padding = '12px',
    MarginBottom = '8px',
    Duration = 4000 -- milliseconds
}

Config.NotificationTypes = {
    ['success'] = {
        icon = '<i class="fas fa-check-circle"></i>',
        borderColor = '#2ecc71',
        backgroundColor = 'rgba(20, 40, 20, 0.85)'
    },
    ['error'] = {
        icon = '<i class="fas fa-times-circle"></i>',
        borderColor = '#e74c3c',
        backgroundColor = 'rgba(40, 20, 20, 0.85)'
    },
    ['info'] = {
        icon = '<i class="fas fa-info-circle"></i>',
        borderColor = '#3498db',
        backgroundColor = 'rgba(20, 20, 40, 0.85)'
    },
    ['warning'] = {
        icon = '<i class="fas fa-exclamation-triangle"></i>',
        borderColor = '#f39c12',
        backgroundColor = 'rgba(40, 35, 10, 0.85)'
    }
}
