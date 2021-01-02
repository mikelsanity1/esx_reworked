fx_version 'adamant'

game 'gta5'

description 'ES Extended'

version '1.2.0'

server_scripts {
	'@fivem-mysql/lib/MySQL.lua',

	'shared/init.lua',
	'shared/functions.lua',
	'config/shared_config.lua',
	'shared/locale.lua',
	'config/server_config.lua',

	'server/classes/*.lua',
	'server/load.lua',

	'shared/exports.lua'
}

client_scripts {
	'shared/init.lua',
	'shared/functions.lua',
	'config/shared_config.lua',
	'shared/locale.lua',
	'config/client_config.lua'
}

ui_page {
	'html/ui.html'
}

files {
	'locales/*.json',

	'locale.js',
	'html/ui.html',

	'html/css/app.css',

	'html/js/mustache.min.js',
	'html/js/wrapper.js',
	'html/js/app.js',

	'html/fonts/pdown.ttf',
	'html/fonts/bankgothic.ttf',

	'html/img/accounts/bank.png',
	'html/img/accounts/black_money.png',
	'html/img/accounts/money.png'
}

dependencies {
	'fivem-mysql'
}
