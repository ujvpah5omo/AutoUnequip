local G = GLOBAL

local IS_CLIENT = G.TheNet ~= nil and G.TheNet:GetIsClient()
local MOD_VERSION = 'v31'


local cfgThreshold = 0.01
local cfgNotif = GetModConfigData('MAU_notif')
local cfgMessage = GetModConfigData('MAU_message') or 'zh_item'
local cfgForce = GetModConfigData('MAU_force')
local cfgFilter = GetModConfigData('MAU_filter')
local cfgHands = GetModConfigData('MAU_hands')
local cfgScanInterval = GetModConfigData('MAU_scan_interval') or 5
local YELLOWAMULET_SAFETY_THRESHOLD = math.min(math.max(cfgThreshold, 0), 1)
local YELLOWAMULET_FUEL_FLOOR = math.min(math.max(cfgThreshold, 0.01), 1)


local function DebugPrint (...)

	local parts = { '[AutoUnequip '..MOD_VERSION..']' }
	local args = { ... }

	for i = 1, #args do
		parts[#parts + 1] = tostring(args[i])
	end

	print(table.concat(parts, ' '))

end


local function OwnerLabel (owner)

	if owner == nil then
		return 'nil'
	end

	return owner.userid or owner.prefab or tostring(owner)

end


DebugPrint('loaded', 'client='..tostring(IS_CLIENT), 'dedicated='..tostring(G.TheNet ~= nil and G.TheNet:IsDedicated()), 'threshold='..tostring(cfgThreshold))

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


local function GetItemThreshold (item)

	return item ~= nil and item.prefab == 'yellowamulet'
		and YELLOWAMULET_SAFETY_THRESHOLD
		or cfgThreshold

end


local function ResetSavedStateIfRefueled (item, percent, threshold)

	if item ~= nil
		and item.MAU_auto_unequipped
		and percent ~= nil
		and percent > threshold
	then
		item.MAU_auto_unequipped = nil
		item.MAU_notified = nil

		if item.prefab == 'yellowamulet' then
			DebugPrint('yellowamulet saved state reset', 'percent='..tostring(percent), 'threshold='..tostring(threshold))
		end
	end

end


local function SetSavedFuelFloor (item, threshold)

	local fueled = item.components ~= nil and item.components.fueled or nil

	if fueled == nil
		or fueled.currentfuel == nil
		or fueled.maxfuel == nil
		or fueled.maxfuel <= 0
	then
		return
	end

	local savedfuel = fueled.maxfuel * threshold

	if fueled.currentfuel > savedfuel then
		DebugPrint('saved item fuel capped', 'prefab='..tostring(item.prefab), 'from='..tostring(fueled.currentfuel), 'to='..tostring(savedfuel))
		fueled.currentfuel = savedfuel
	end

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

	return not cfgFilter or not NONREFILLABLE[item.prefab]

end


local function ShouldUnequip (item, owner, percent, threshold)

	if item == nil
		or item.components == nil
		or item.components.equippable == nil
	then
		return false
	end

	local slot = item.components.equippable.equipslot
	percent = percent or GetDurabilityPercent(item)
	threshold = threshold or GetItemThreshold(item)

	ResetSavedStateIfRefueled(item, percent, threshold)

	if owner == nil or item.MAU_auto_unequipped then
		return false
	end

	return percent ~= nil
		and percent <= threshold
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


local function PreserveFueledItem (item)

	local fueled = item.components ~= nil and item.components.fueled or nil

	if fueled == nil then
		return
	end

	if fueled.StopConsuming ~= nil then
		fueled:StopConsuming()
	end

	if item.prefab == 'yellowamulet'
		and fueled.currentfuel ~= nil
		and fueled.maxfuel ~= nil
		and fueled.maxfuel > 0
	then
		local minfuel = fueled.maxfuel * YELLOWAMULET_FUEL_FLOOR

		if fueled.currentfuel < minfuel then
			DebugPrint('yellowamulet fuel floored', 'from='..tostring(fueled.currentfuel), 'to='..tostring(minfuel))
			fueled.currentfuel = minfuel
		end
	end

end


local function OwnerHasVisibleItem (item, owner)

	if item == nil
		or owner == nil
		or owner.components == nil
		or owner.components.inventory == nil
		or item.components == nil
		or item.components.inventoryitem == nil
	then
		return false
	end

	local inventory = owner.components.inventory

	if inventory:IsItemEquipped(item) ~= nil
		or inventory:GetItemSlot(item) ~= nil
		or inventory:GetActiveItem() == item
	then
		return true
	end

	local overflow = inventory:GetOverflowContainer()

	return overflow ~= nil
		and overflow.GetItemSlot ~= nil
		and overflow:GetItemSlot(item) ~= nil

end


local function KeepItemWithOwner (item, owner)

	if item == nil
		or owner == nil
		or owner.components == nil
		or owner.components.inventory == nil
		or item.components == nil
		or item.components.inventoryitem == nil
		or (item.IsValid ~= nil and not item:IsValid())
	then
		return false
	end

	if OwnerHasVisibleItem(item, owner) then
		return true
	end

	local inventory = owner.components.inventory
	local result = inventory:GiveItem(item)

	if item.prefab == 'yellowamulet' then
		DebugPrint('yellowamulet give back', 'result='..tostring(result), 'visible='..tostring(OwnerHasVisibleItem(item, owner)), 'owner='..OwnerLabel(item.components.inventoryitem.owner))
	end

	return result ~= false and OwnerHasVisibleItem(item, owner)

end


local function GetInventoryOwner (item)

	if item == nil
		or item.components == nil
		or item.components.inventoryitem == nil
	then
		return nil
	end

	local owner = item.components.inventoryitem.owner

	if owner ~= nil
		and owner.components ~= nil
		and owner.components.inventory ~= nil
	then
		return owner
	end

	return nil

end


local function TryUnequip (item, percent, threshold)

	local owner = GetEquippedOwner(item)
	threshold = threshold or GetItemThreshold(item)

	if not ShouldUnequip(item, owner, percent, threshold) then
		StopRetry(item)
		return false
	end

	local slot = item.components.equippable.equipslot

	if item.prefab == 'yellowamulet' then
		DebugPrint('yellowamulet try unequip', 'owner='..OwnerLabel(owner), 'percent='..tostring(percent or GetDurabilityPercent(item)), 'threshold='..tostring(threshold or cfgThreshold))
	end

	PreserveFueledItem(item)

	local unequipped = owner.components.inventory:Unequip(slot) or item

	PreserveFueledItem(unequipped)
	KeepItemWithOwner(unequipped, owner)

	if cfgNotif and owner.components.talker ~= nil and not unequipped.MAU_notified then
		owner.components.talker:Say(GetNotificationText(unequipped, slot))
		unequipped.MAU_notified = true
	end

	if cfgForce and GetEquippedOwner(unequipped) ~= nil then
		if unequipped.MAU_unequiptask == nil then
			unequipped.MAU_unequiptask = unequipped:DoPeriodicTask(0, function ()
				TryUnequip(unequipped)
			end)
		end
	else
		StopRetry(unequipped)
	end

	if unequipped.prefab == 'yellowamulet' then
		DebugPrint('yellowamulet unequip result', 'equipped='..tostring(GetEquippedOwner(unequipped) ~= nil), 'visible='..tostring(OwnerHasVisibleItem(unequipped, owner)), 'owner='..OwnerLabel(GetInventoryOwner(unequipped)))
	end

	local saved = GetEquippedOwner(unequipped) == nil and OwnerHasVisibleItem(unequipped, owner)

	if saved then
		SetSavedFuelFloor(unequipped, threshold)
		unequipped.MAU_auto_unequipped = true

		if unequipped.prefab == 'yellowamulet' then
			DebugPrint('yellowamulet saved once; next equip may consume')
		end
	end

	return saved

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


local function WrapFueledDoDelta (self)

	local oldfn = self.DoDelta

	if oldfn == nil or self.MAU_old_DoDelta ~= nil then
		return
	end

	self.MAU_old_DoDelta = oldfn

	self.DoDelta = function (component, amount, ...)
		if amount ~= nil
			and amount < 0
			and component.currentfuel ~= nil
			and component.maxfuel ~= nil
			and component.maxfuel > 0
		then
			local percent = (component.currentfuel + amount) / component.maxfuel

			local threshold = component.inst.prefab == 'yellowamulet'
				and YELLOWAMULET_SAFETY_THRESHOLD
				or cfgThreshold

			if percent <= threshold and TryUnequip(component.inst, percent, threshold) then
				if component.inst.prefab == 'yellowamulet' then
					DebugPrint('yellowamulet DoDelta blocked', 'amount='..tostring(amount), 'predicted='..tostring(percent))
				end

				return
			end
		end

		local ret = oldfn(component, amount, ...)
		CheckItemSoon(component.inst)
		return ret
	end

end


local function WrapFueledSetPercent (self)

	local oldfn = self.SetPercent

	if oldfn == nil or self.MAU_old_SetPercent ~= nil then
		return
	end

	self.MAU_old_SetPercent = oldfn

	self.SetPercent = function (component, percent, ...)
		local threshold = component.inst.prefab == 'yellowamulet'
			and YELLOWAMULET_SAFETY_THRESHOLD
			or cfgThreshold

		if percent ~= nil and percent <= threshold and TryUnequip(component.inst, percent, threshold) then
			if component.inst.prefab == 'yellowamulet' then
				DebugPrint('yellowamulet SetPercent blocked', 'percent='..tostring(percent))
			end

			return
		end

		local ret = oldfn(component, percent, ...)
		CheckItemSoon(component.inst)
		return ret
	end

end


local function WrapFueledSetCurrentFuel (self)

	local oldfn = self.SetCurrentFuel

	if oldfn == nil or self.MAU_old_SetCurrentFuel ~= nil then
		return
	end

	self.MAU_old_SetCurrentFuel = oldfn

	self.SetCurrentFuel = function (component, fuel, ...)
		if fuel ~= nil
			and component.maxfuel ~= nil
			and component.maxfuel > 0
		then
			local percent = fuel / component.maxfuel
			local threshold = component.inst.prefab == 'yellowamulet'
				and YELLOWAMULET_SAFETY_THRESHOLD
				or cfgThreshold

			if percent <= threshold and TryUnequip(component.inst, percent, threshold) then
				if component.inst.prefab == 'yellowamulet' then
					DebugPrint('yellowamulet SetCurrentFuel blocked', 'fuel='..tostring(fuel), 'percent='..tostring(percent))
				end

				return
			end
		end

		local ret = oldfn(component, fuel, ...)
		CheckItemSoon(component.inst)
		return ret
	end

end


local function ProtectYellowAmulet (inst)

	if inst.components == nil or inst.components.fueled == nil then
		DebugPrint('yellowamulet protect skipped', 'has_components='..tostring(inst.components ~= nil))
		return
	end

	inst.components.fueled:SetDepletedFn(function (item)
		local owner = GetEquippedOwner(item) or GetInventoryOwner(item)

		DebugPrint('yellowamulet depleted callback', 'owner='..OwnerLabel(owner), 'equipped='..tostring(GetEquippedOwner(item) ~= nil))

		if item.MAU_auto_unequipped then
			DebugPrint('yellowamulet depleted after saved once; removing')

			if item.Remove ~= nil then
				item:Remove()
			end

			return
		end

		PreserveFueledItem(item)

		if GetEquippedOwner(item) ~= nil then
			TryUnequip(item, 0, 1)
		elseif owner ~= nil then
			KeepItemWithOwner(item, owner)
		end

		PreserveFueledItem(item)
	end)

	DebugPrint('yellowamulet depleted fn replaced')

end


local function WatchYellowAmulet (inst)

	if inst.components == nil or inst.components.fueled == nil then
		return
	end

	local owner = GetEquippedOwner(inst)

	if owner == nil then
		StopRetry(inst)
		return
	end

	local percent = inst.components.fueled:GetPercent()

	if percent <= YELLOWAMULET_SAFETY_THRESHOLD then
		DebugPrint('yellowamulet watcher threshold', 'percent='..tostring(percent), 'threshold='..tostring(YELLOWAMULET_SAFETY_THRESHOLD))
		TryUnequip(inst, percent, YELLOWAMULET_SAFETY_THRESHOLD)
	end

end


AddComponentPostInit('inventoryitem', function (self)
	if not G.TheWorld.ismastersim then
		return
	end

	self.inst:ListenForEvent('percentusedchange', function (inst)
		CheckItemSoon(inst)
	end)
end)


AddComponentPostInit('equippable', function (self)
	if not G.TheWorld.ismastersim then
		return
	end

	self.inst:ListenForEvent('equipped', function (inst)
		CheckItemSoon(inst)
	end)
end)


AddComponentPostInit('fueled', function (self)
	if not G.TheWorld.ismastersim then
		return
	end

	WrapFueledDoDelta(self)
	WrapFueledSetPercent(self)
	WrapFueledSetCurrentFuel(self)
end)


AddComponentPostInit('finiteuses', function (self)
	if not G.TheWorld.ismastersim then
		return
	end

	WrapComponentMethod(self, 'Use')
	WrapComponentMethod(self, 'SetUses')
	WrapComponentMethod(self, 'SetPercent')
end)


AddComponentPostInit('armor', function (self)
	if not G.TheWorld.ismastersim then
		return
	end

	WrapComponentMethod(self, 'SetPercent')
	WrapComponentMethod(self, 'SetCondition')
	WrapComponentMethod(self, 'TakeDamage')
end)


AddPrefabPostInit('yellowamulet', function (inst)
	if not G.TheWorld.ismastersim then
		return
	end

	DebugPrint('yellowamulet prefab postinit')
	inst:DoTaskInTime(0, ProtectYellowAmulet)
	inst:DoPeriodicTask(0.25, WatchYellowAmulet)
end)


AddPlayerPostInit(function (inst)
	if not G.TheWorld.ismastersim then
		return
	end

	inst:DoTaskInTime(0, CheckEquippedItems)

	if cfgScanInterval > 0 then
		inst:DoPeriodicTask(cfgScanInterval, CheckEquippedItems)
	end
end)
