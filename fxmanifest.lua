fx_version 'cerulean'
game 'gta5'

author 'Crazy -- Dont DM me, Use the GitHub...'
description 'GangWars & Stuff'
version '0.0.1'

client_scripts {
    'Client/main.lua',
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/CircleZone.lua',
}

server_scripts {
    'Server/server.lua'
}

shared_scripts {
    '@qb-core/shared/locale.lua',
    'Locales/en.lua',
    'Config.lua'
}