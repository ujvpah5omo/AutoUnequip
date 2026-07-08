name = ' Auto-Unequip on 1%'
description = 'Server mod. Automatically unequips equipped items upon reaching 1% durability to prevent them from breaking. Feature also applies to similar equippables such as magiluminescence, eyebrellas, puffy vests, rain hats, etc.'
author = 'John Watson, xx'
version = 'eight'
forumthread = ''
api_version = 10
dst_compatible = true
client_only_mod = false
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = false
icon_atlas = 'Magi Auto-Unequip.xml'
icon = 'Magi Auto-Unequip.tex'
server_filter_tags = {}

configuration_options = {
	{
		name = 'MAU_threshold',
		label = 'Unequip threshold',
		options =
		{
			{description = '1%', data = 0.01, hover = 'Unequip at 1% durability or fuel'},
			{description = '2%', data = 0.02, hover = 'Unequip at 2% durability or fuel'},
			{description = '5%', data = 0.05, hover = 'Unequip at 5% durability or fuel'},
			{description = '10%', data = 0.10, hover = 'Unequip at 10% durability or fuel'},
		},
		default = 0.01
	},
	{
		name = 'MAU_item_mode',
		label = 'Affected items',
		options =
		{
			{description = 'Common refillables', data = 'whitelist', hover = 'Only auto-unequip common refillable gear such as magiluminescence, eyebrella, rain gear, and vests'},
			{description = 'All durable gear', data = 'all', hover = 'Auto-unequip all equipped items with fuel, finite uses, or armor durability'},
		},
		default = 'whitelist'
	},
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
		label = 'Hand slot items',
		options = 
		{
			{description = 'Ignore all', data = 'ignore', hover = 'Ignore all hand slot items'},
			{description = 'Tools only', data = 'tools', hover = 'Only auto-unequip hand slot tools'},
			{description = 'Weapons only', data = 'weapons', hover = 'Only auto-unequip hand slot weapons'},
			{description = 'All hand items', data = 'all', hover = 'Auto-unequip all hand slot items'},
		},
		default = 'ignore'
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
