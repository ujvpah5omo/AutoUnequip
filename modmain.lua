local G = GLOBAL

if G.TheNet ~= nil and G.TheNet:GetIsClient() then
	return
end


local cfgThreshold = GetModConfigData('MAU_threshold') or 0.01
local cfgItemMode = GetModConfigData('MAU_item_mode') or 'whitelist'
local cfgNotif = GetModConfigData('MAU_notif')
local cfgMessage = GetModConfigData('MAU_message') or 'zh_item'
local cfgForce = GetModConfigData('MAU_force')
local cfgFilter = GetModConfigData('MAU_filter')
local cfgHands = GetModConfigData('MAU_hands')
local cfgScanInterval = GetModConfigData('MAU_scan_interval') or 5

if cfgNotif == nil then
	cfgNotif = true
end

if cfgForce == nil then
	cfgForce = true
end

if cfgFilter == nil then
	cfgFilter = true
end

if cfgHands == true then
	cfgHands = 'ignore'
elseif cfgHands == false then
	cfgHands = 'all'
elseif cfgHands == nil then
	cfgHands = 'ignore'
end


local MSG_ZH_PLAIN = '\232\163\133\229\164\135\229\191\171\229\157\143\228\186\134\239\188\140\229\183\178\232\135\170\229\138\168\229\141\184\228\184\139'
local MSG_ZH_WITH_ITEM = '\229\191\171\229\157\143\228\186\134\239\188\140\229\183\178\232\135\170\229\138\168\229\141\184\228\184\139'


local WHITELIST = {
	magiluminescence	=	true,
	yellowamulet		=	true,
	eyebrellahat		=	true,
	rainhat				=	true,
	raincoat			=	true,
	trunkvest_summer	=	true,
	trunkvest_winter	=	true,
	reflectivevest		=	true,
	sweatervest			=	true,
	winterhat			=	true,
	catcoonhat			=	true,
	beefalohat			=	true,
}


local NONREFILLABLE = {
	armor_sanity		=	true,
	armordragonfly		=	true,
	armorgrass			=	true,
	armormarble			=	true,
	armorruins			=	true,
	armorskeleton		=	true,
	armorsnurtleshell	=	true,
	armorwood			=	true,
	beehat				=	true,
	blue_mushroomhat	=	true,
	blueamulet			=	true,
	bushhat				=	true,
	flowerhat			=	true,
	footballhat			=	true,
	green_mushroomhat	=	true,
	greenamulet			=	true,
	hawaiianshirt		=	true,
	minerhat			=	true,
	onemanband			=	true,
	orangeamulet		=	true,
	purpleamulet		=	true,
	red_mushroomhat		=	true,
	ruinshat			=	true,
	sansundertalehat	=	true,
	slurper				=	true,
	slurtlehat			=	true,
	spiderhat			=	true,
	watermelonhat		=	true,
	wathgrithrhat		=	true,
}


local function GetDurabilityPercent (item)

	if item.components == nil then
		return nil
	end

	if item.components.fueled ~= nil and item.components.fueled.GetPercent ~= nil then
		return item.components.fueled:GetPercent()
	end

	if item.components.finiteuses ~= nil and item.components.finiteuses.GetPercent ~= nil then
		return item.components.finiteuses:GetPercent()
	end

	if item.components.armor ~= nil and item.components.armor.GetPercent ~= nil then
		return item.components.armor:GetPercent()
	end

	return nil

end


local function GetEquippedOwner (item)

	if item.components == nil
		or item.components.inventoryitem == nil
		or item.components.equippable == nil
	then
		return nil
	end

	local owner = item.components.inventoryitem.owner

	if owner == nil
		or owner.components == nil
		or owner.components.inventory == nil
	then
		return nil
	end

	local slot = item.components.equippable.equipslot

	if slot == nil or owner.components.inventory:GetEquippedItem(slot) ~= item then
		return nil
	end

	return owner

end


local function StopRetry (item)

	if item.MAU_unequiptask ~= nil then
		item.MAU_unequiptask:Cancel()
		item.MAU_unequiptask = nil
	end

	if GetEquippedOwner(item) == nil then
		item.MAU_notified = nil
	end

end


local function IsAllowedHandItem (item, slot)

	if slot ~= G.EQUIPSLOTS.HANDS then
		return true
	end

	if cfgHands == 'ignore' then
		return false
	end

	if cfgHands == 'tools' then
		return item.components ~= nil and item.components.tool ~= nil
	end

	if cfgHands == 'weapons' then
		return item.components ~= nil and item.components.weapon ~= nil
	end

	return true

end


local function IsAllowedItem (item, slot)

	if slot ~= G.EQUIPSLOTS.HANDS
		and cfgItemMode ~= 'all'
		and not WHITELIST[item.prefab]
	then
		return false
	end

	return not cfgFilter or not NONREFILLABLE[item.prefab]

end


local function ShouldUnequip (item, owner)

	if item == nil
		or owner == nil
		or item.components == nil
		or item.components.equippable == nil
	then
		return false
	end

	local slot = item.components.equippable.equipslot
	local percent = GetDurabilityPercent(item)

	return percent ~= nil
		and percent <= cfgThreshold
		and IsAllowedHandItem(item, slot)
		and IsAllowedItem(item, slot)

end


local function GetNotificationText (item, slot)

	local name = item.name or slot..' slot item'

	if cfgMessage == 'zh_plain' then
		return MSG_ZH_PLAIN
	end

	if cfgMessage == 'en_item' then
		return name..'\nauto-unequipped'
	end

	return name..'\n'..MSG_ZH_WITH_ITEM

end


local function TryUnequip (item)

	local owner = GetEquippedOwner(item)

	if not ShouldUnequip(item, owner) then
		StopRetry(item)
		return
	end

	local slot = item.components.equippable.equipslot
	owner.components.inventory:Unequip(slot)

	if cfgNotif and owner.components.talker ~= nil and not item.MAU_notified then
		owner.components.talker:Say(GetNotificationText(item, slot))
		item.MAU_notified = true
	end

	if cfgForce and GetEquippedOwner(item) ~= nil then
		if item.MAU_unequiptask == nil then
			item.MAU_unequiptask = item:DoPeriodicTask(0, function ()
				TryUnequip(item)
			end)
		end
	else
		StopRetry(item)
	end

end


local function CheckItemSoon (item)

	if item ~= nil and item.DoTaskInTime ~= nil then
		item:DoTaskInTime(0, TryUnequip)
	end

end


local function CheckEquippedItems (player)

	if player.components == nil or player.components.inventory == nil then
		return
	end

	for _, slot in pairs(G.EQUIPSLOTS) do
		local item = player.components.inventory:GetEquippedItem(slot)

		if item ~= nil then
			TryUnequip(item)
		end
	end

end


local function WrapComponentMethod (self, name)

	local oldfn = self[name]

	if oldfn == nil or self['MAU_old_'..name] ~= nil then
		return
	end

	self['MAU_old_'..name] = oldfn

	self[name] = function (component, ...)
		local ret = oldfn(component, ...)
		CheckItemSoon(component.inst)
		return ret
	end

end


AddComponentPostInit('inventoryitem', function (self)
	self.inst:ListenForEvent('percentusedchange', function (inst)
		CheckItemSoon(inst)
	end)
end)


AddComponentPostInit('equippable', function (self)
	self.inst:ListenForEvent('equipped', function (inst)
		CheckItemSoon(inst)
	end)
end)


AddComponentPostInit('fueled', function (self)
	WrapComponentMethod(self, 'DoDelta')
	WrapComponentMethod(self, 'SetPercent')
	WrapComponentMethod(self, 'SetCurrentFuel')
end)


AddComponentPostInit('finiteuses', function (self)
	WrapComponentMethod(self, 'Use')
	WrapComponentMethod(self, 'SetUses')
	WrapComponentMethod(self, 'SetPercent')
end)


AddComponentPostInit('armor', function (self)
	WrapComponentMethod(self, 'SetPercent')
	WrapComponentMethod(self, 'SetCondition')
	WrapComponentMethod(self, 'TakeDamage')
end)


AddPlayerPostInit(function (inst)
	inst:DoTaskInTime(0, CheckEquippedItems)

	if cfgScanInterval > 0 then
		inst:DoPeriodicTask(cfgScanInterval, CheckEquippedItems)
	end
end)
