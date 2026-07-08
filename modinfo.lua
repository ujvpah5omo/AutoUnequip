name = ' Auto-Unequip on 1%'
description = 'Server mod. Automatically unequips equipped items upon reaching 1% durability to prevent them from breaking. Feature also applies to similar equippables such as magiluminescence, eyebrellas, puffy vests, rain hats, etc.'
author = 'John Watson'
version = 'six'
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
}
