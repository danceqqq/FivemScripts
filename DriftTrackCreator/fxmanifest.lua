fx_version 'cerulean'
game 'gta5'

author 'YourName'
description 'Drift Race Creator v1.03'
version '1.03'

client_scripts {
    'client.lua'
}

server_scripts {
    'server.lua'
}

files {
    'html/ui/index.html',
    'html/ui/style.css',
    'html/ui/script.js'
}

ui_page 'html/ui/index.html'

dependencies {
    'input' -- Опциональная зависимость для ввода текста
}
