--BY RED DEV--
--VERSION 1.0.0--


fx_version 'adamant'

game 'gta5'

description 'ESX Door Lock'

version '1.4.0'

server_scripts {
	'@sExtended/locale.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@sExtended/locale.lua',
	'locales/en.lua',
	'locales/fr.lua',
	'locales/sv.lua',
	'locales/pl.lua',
	'config.lua',
	'client/main.lua'
}

dependency 'sExtended'
