lua54 'yes'
escrow_ignore {
	'config.lua'
}

game 'gta5'
version '1.0'
fx_version 'adamant'
description 'FFA SCRIPT by Loureiro'

-- shared_script '@es_extended/imports.lua'

server_scripts {
    '@mysql-async/lib/MySQL.lua', -- or oxmysql
	'config.lua',
	'server/server.lua'
}

client_scripts {
	'config.lua',
	'client/client.lua'
}

ui_page('html/index.html')

files({
    'html/libs/*.*',
    'html/*.*',
})
