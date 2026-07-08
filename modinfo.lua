name = 'Auto-Unequip on 1% v30'
description = 'Server mod. Uses the original client mod logic to automatically unequip equipped items upon reaching 1% durability, while ignoring hand slot items and nonrefillables by default.'
author = 'Codex'
version = 'thirty'
forumthread = ''
api_version = 10
dst_compatible = true
client_only_mod = false
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true
icon_atlas = 'Magi Auto-Unequip.xml'
icon = 'Magi Auto-Unequip.tex'
server_filter_tags = {}

configuration_options = {
	{
		name = 'MAU_notif',
		label = 'Notify on unequip',
		options = 
		{
			{description = 'Yes', data = true, hover = 'Your character speaks upon auto-unequip'},
			{description = 'No', data = false, hover = 'Your character is quiet upon auto-unequip'},
		},
		default = true
	},
	{
		name = 'MAU_message',
		label = 'Notification text',
		options =
		{
			{description = 'Chinese + item', data = 'zh_item', hover = 'Say the item name and a Chinese auto-unequip message'},
			{description = 'Chinese only', data = 'zh_plain', hover = 'Say a short Chinese auto-unequip message'},
			{description = 'English + item', data = 'en_item', hover = 'Say the item name and an English auto-unequip message'},
		},
		default = 'zh_item'
	},
	{
		name = 'MAU_filter',
		label = 'Ignore nonrefillable items',
		options = 
		{
			{description = 'Yes', data = true, hover = 'Ignore items that cannot be refuelled'},
			{description = 'No', data = false, hover = 'Auto-unequip items that cannot be refuelled'},
		},
		default = true
	},
	{
		name = 'MAU_hands',
		label = 'Ignore hand slot items',
		options = 
		{
			{description = 'Yes', data = true, hover = 'Ignore hand slot items on 1% durability'},
			{description = 'No', data = false, hover = 'Auto-unequip hand slot items on 1% durability'},
		},
		default = true
	},
	{
		name = 'MAU_force',
		label = 'Force retrying unequip',
		options = 
		{
			{description = 'Yes', data = true, hover = 'Disable this if you\'re having an issue with unequipping'},
			{description = 'No', data = false, hover = 'Disable this if you\'re having an issue with unequipping'},
		},
		default = true
	},
	{
		name = 'MAU_scan_interval',
		label = 'Fallback scan',
		options =
		{
			{description = '3 seconds', data = 3, hover = 'Scan equipped items every 3 seconds as a fallback'},
			{description = '5 seconds', data = 5, hover = 'Scan equipped items every 5 seconds as a fallback'},
			{description = '10 seconds', data = 10, hover = 'Scan equipped items every 10 seconds as a fallback'},
			{description = 'Off', data = 0, hover = 'Only react to equip and durability events'},
		},
		default = 5
	},
}
