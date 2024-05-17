fx_version 'cerulean'
game 'gta5'

author 'Kubi'
Description 'Zaawansowany system narkotyków'
version '1.0.0'

server_scripts {
    '@es_extended/locale.lua',
    'config.lua',
    'server.lua'
}

client_scripts{
    '@es_extended/locale.lua',
    'config.lua',
    'client.lua'
}

dependencies {
    'es_extended'
}