fx_version 'cerulean'
game 'gta5'

name 'ESX Reworked'
version '1.3.0'
description 'A custom reworked version of es_extended (v1-final)'
author 'ThymonA'
url 'https://github.com/ThymonA/esx_reworked/'

server_scripts {
	'@fivem-mysql/lib/MySQL.lua',

	'shared/init.lua',
	'shared/functions.lua',
	'config/shared_config.lua',
	'shared/locale.lua',
	'config/server_config.lua',
	'shared/events.lua',

	'shared/helpers/*.lua',
	'server/classes/*.lua',
	'server/helpers/*.lua',

	'config/permissions.lua',

	'server/functions.lua',
	'server/load.lua',
	'server/events.lua',
	'server/main.lua',
	'server/commands.lua',

	'shared/exports.lua'
}

client_scripts {
	'shared/init.lua',
	'shared/functions.lua',
	'config/shared_config.lua',
	'shared/locale.lua',
	'config/client_config.lua',
	'shared/events.lua',

	'shared/helpers/*.lua',

	'client/main.lua',

	'shared/exports.lua'
}

ui_page {
	'html/index.html'
}

files {
	'locales/*.json',
	'html/index.html',
	'html/assets/css/*.css',
	'html/assets/js/*.js',
	'html/assets/fonts/borda/*.woff',
	'html/assets/fonts/titillium/*.woff',
	'config/shared_config.lua'
}

dependencies {
	'fivem-mysql'
}
