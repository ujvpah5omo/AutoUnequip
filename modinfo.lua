local is_zh = locale == 'zh' or locale == 'zhr' or locale == 'zht'

local function L(en, zh)
	return is_zh and zh or en
end

name = L('Auto-Unequip on 1%', '1% 自动卸装')
description = L(
	'Server-side auto unequip mod for Don\'t Starve Together. Uses the original client mod behavior: equipped items are automatically unequipped at 1% durability or fuel, hand slot items and non-refillable items are ignored by default, and Magiluminescence is protected from breaking once before being allowed to consume normally.',
	'饥荒联机版服务端自动卸装模组。按原客户端模组逻辑，在装备耐久或燃料到 1% 时自动卸下；默认忽略手持物和不可补充物品；魔光护符会先保护一次，再次装备后按原版逻辑正常消耗。'
)
author = 'Codex'
version = '31.0.0'
forumthread = 'https://steamcommunity.com/sharedfiles/filedetails/?id=3760111829'
api_version = 10
api_version_dst = 10
priority = 0
dst_compatible = true
client_only_mod = false
server_only_mod = false
all_clients_require_mod = true
dont_starve_compatible = false
reign_of_giants_compatible = false
shipwrecked_compatible = false
hamlet_compatible = false
forge_compatible = false
gorge_compatible = false
icon_atlas = 'Magi Auto-Unequip.xml'
icon = 'Magi Auto-Unequip.tex'
server_filter_tags = {
	'auto unequip',
	'durability',
	'server',
	'quality of life',
}

configuration_options = {
	{
		name = 'MAU_notif',
		label = L('Notify on unequip', '卸下时提示'),
		hover = L('Whether the character says a message after an automatic unequip.', '自动卸下装备后，角色是否说一句提示。'),
		options =
		{
			{description = L('Yes', '是'), data = true, hover = L('Your character speaks after auto-unequip.', '自动卸下后角色会说话提示。')},
			{description = L('No', '否'), data = false, hover = L('No speech message after auto-unequip.', '自动卸下后不说话提示。')},
		},
		default = true
	},
	{
		name = 'MAU_message',
		label = L('Notification text', '提示文本'),
		hover = L('Choose the speech text used after automatic unequip.', '选择自动卸下装备后的角色提示文本。'),
		options =
		{
			{description = L('Chinese + item', '中文 + 物品名'), data = 'zh_item', hover = L('Say the item name and a Chinese auto-unequip message.', '显示物品名，并使用中文自动卸下提示。')},
			{description = L('Chinese only', '仅中文'), data = 'zh_plain', hover = L('Say a short Chinese auto-unequip message.', '只显示简短中文自动卸下提示。')},
			{description = L('English + item', '英文 + 物品名'), data = 'en_item', hover = L('Say the item name and an English auto-unequip message.', '显示物品名，并使用英文自动卸下提示。')},
		},
		default = 'zh_item'
	},
	{
		name = 'MAU_filter',
		label = L('Ignore non-refillable items', '忽略不可补充物品'),
		hover = L('Use the original mod blacklist for items that usually cannot be refilled or repaired.', '使用原版模组黑名单，忽略通常无法补充或修复的装备。'),
		options =
		{
			{description = L('Yes', '是'), data = true, hover = L('Ignore blacklisted non-refillable items.', '忽略黑名单中的不可补充物品。')},
			{description = L('No', '否'), data = false, hover = L('Allow blacklisted non-refillable items to auto-unequip too.', '黑名单物品也允许自动卸下。')},
		},
		default = true
	},
	{
		name = 'MAU_hands',
		label = L('Ignore hand slot items', '忽略手持物'),
		hover = L('Match the original client mod behavior by ignoring hand slot items by default.', '默认忽略手持物，以贴近原客户端模组逻辑。'),
		options =
		{
			{description = L('Yes', '是'), data = true, hover = L('Ignore all hand slot items at 1% durability or fuel.', '手持物到 1% 时也不自动卸下。')},
			{description = L('No', '否'), data = false, hover = L('Allow hand slot items to auto-unequip at 1%.', '允许手持物在 1% 时自动卸下。')},
		},
		default = true
	},
	{
		name = 'MAU_force',
		label = L('Force retrying unequip', '强制重试卸下'),
		hover = L('Keep retrying briefly if the first automatic unequip attempt does not succeed.', '如果第一次自动卸下没有成功，会短暂重复尝试。'),
		options =
		{
			{description = L('Yes', '是'), data = true, hover = L('Recommended. Helps when an item resists the first unequip attempt.', '推荐。可处理第一次卸下失败的情况。')},
			{description = L('No', '否'), data = false, hover = L('Disable retrying if it causes compatibility issues.', '如果与其他模组冲突，可关闭重试。')},
		},
		default = true
	},
	{
		name = 'MAU_scan_interval',
		label = L('Fallback scan', '备用扫描'),
		hover = L('Periodically scan equipped items as a server-side fallback.', '服务端定期扫描已装备物品，作为备用触发方式。'),
		options =
		{
			{description = L('3 seconds', '3 秒'), data = 3, hover = L('Scan equipped items every 3 seconds.', '每 3 秒扫描一次已装备物品。')},
			{description = L('5 seconds', '5 秒'), data = 5, hover = L('Scan equipped items every 5 seconds.', '每 5 秒扫描一次已装备物品。')},
			{description = L('10 seconds', '10 秒'), data = 10, hover = L('Scan equipped items every 10 seconds.', '每 10 秒扫描一次已装备物品。')},
			{description = L('Off', '关闭'), data = 0, hover = L('Only react to equip and durability events.', '只响应装备和耐久变化事件。')},
		},
		default = 5
	},
}
