fx_version 'cerulean'
game 'gta5'

author 'DND Development'
description 'Simple Notification System'
version '1.0.0'

ui_page 'html/index.html'

client_scripts {
    'config.lua',
    'client/main.lua'
}

server_scripts {
    'config.lua',
    'server/main.lua'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}
