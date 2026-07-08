local G = GLOBAL

if G.TheNet ~= nil and G.TheNet:GetIsClient() then
	return
end


local cfgNotif = GetModConfigData('MAU_notif')
local cfgForce = GetModConfigData('MAU_force')
local cfgFilter = GetModConfigData('MAU_filter')
local cfgHands = GetModConfigData('MAU_hands')


local notification = '%s\nauto-unequipped'


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
		and percent <= 0.01
		and (not cfgHands or slot ~= G.EQUIPSLOTS.HANDS)
		and (not cfgFilter or not NONREFILLABLE[item.prefab])

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
		owner.components.talker:Say(
			notification:format(item.name or slot..' slot item')
		)
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


AddComponentPostInit('inventoryitem', function (self)
	self.inst:ListenForEvent('percentusedchange', function (inst)
		inst:DoTaskInTime(0, TryUnequip)
	end)
end)


AddPlayerPostInit(function (inst)
	inst:DoPeriodicTask(1, CheckEquippedItems)
end)
