local G = GLOBAL


local cfgNotif = GetModConfigData('MAU_notif')
local cfgForce = GetModConfigData('MAU_force')
local cfgFilter = GetModConfigData('MAU_filter')
local cfgHands = GetModConfigData('MAU_hands')


local notification = '%s\nauto-unequipped'


G.NONREFILLABLE = {
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


local function Unequip (inst)

	if inst.replica.equippable:IsEquipped() then
		G.ThePlayer.replica.inventory:ControllerUseItemOnSelfFromInvTile(inst)
	end

	if cfgForce
		and not inst.replica.equippable:IsEquipped()
		and inst.unequiptask ~= nil
	then
		inst.unequiptask:Cancel()
		inst.unequiptask = nil
	end

end


local function AutoUnequip (inst)

	local item = inst.entity:GetParent()

	local slot = item.replica.equippable:EquipSlot()

	if (not item.replica.inventoryitem:IsHeldBy(G.ThePlayer))
		or (not item.replica.equippable:IsEquipped())
		or (cfgHands and slot == G.EQUIPSLOTS.HANDS)
		or (cfgFilter and G.NONREFILLABLE[item.prefab])
		or (inst.percentused:value() > 1)
	then
		return
	end

	if cfgForce then
		item.unequiptask = item:DoPeriodicTask(0, function ()
			Unequip(item)
		end)
	end

	Unequip(item)

	if cfgNotif and G.ThePlayer.components.talker then
		G.ThePlayer.components.talker:Say(
			notification:format(item.name or slot..' slot item')
		)
	end

end


local function PostInit (inst)

	local item = inst.entity:GetParent()

	if item == nil or item.replica.equippable == nil then
		return
	end

	inst:ListenForEvent('percentuseddirty', function ()
		AutoUnequip(inst)
	end)

end


AddPrefabPostInit('inventoryitem_classified', function (inst)
	if not G.TheNet:IsDedicated() then
		inst:DoTaskInTime(0, function ()
			PostInit(inst)
		end)
	end
end)
