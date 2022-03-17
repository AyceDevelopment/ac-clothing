ESX                     = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local oldData = {}
local function GetComponentData(playerPed, componentId)
	if not oldData then
		oldData = {}
	end
	local data = {}
	data[#data + 1] = GetPedDrawableVariation(playerPed, componentId)
	data[#data + 1] = GetPedTextureVariation(playerPed, componentId)
	data[#data + 1] = GetPedPaletteVariation(playerPed, componentId)
	return data
end

local function IsMale(playerPed)
	local model = GetEntityModel(playerPed)
	if model == `mp_f_freemode_01` then
		return false
	elseif model == `mp_m_freemode_01` then
		return true
	else
		return true
	end
end


RegisterNetEvent('clothes:reset')
RegisterNetEvent('clothes:tshirt')
RegisterNetEvent('clothes:pants')
RegisterNetEvent('clothes:boots')

AddEventHandler('clothes:reset', ResetClothes)
AddEventHandler('clothes:tshirt', ClothesTshirt)
AddEventHandler('clothes:pants', ClothesPants)
AddEventHandler('clothes:boots', ClothesBoots)


function ResetClothes()
	local playerPed = PlayerPedId()
	if oldData.tshirt then
		SetPedComponentVariation(playerPed,  8, table.unpack(oldData.tshirt))	-- Tshirt
		SetPedComponentVariation(playerPed, 11,	table.unpack(oldData.torso))	-- torso parts
		SetPedComponentVariation(playerPed,  3, table.unpack(oldData.arms))		-- Arms
		SetPedComponentVariation(playerPed,  9, table.unpack(oldData.bproof))	-- Bproof
	end
	if oldData.pants then
		SetPedComponentVariation(playerPed, 4, table.unpack(oldData.pants)) -- Pants
	end
	if oldData.shoes then
		SetPedComponentVariation(playerPed, 6, table.unpack(oldData.shoes)) -- Pants
	end
	oldData = {}
end

function ClothesTshirt()
	local playerPed = PlayerPedId()
	if not oldData then
		oldData = {}
	elseif oldData.tshirt then
		SetPedComponentVariation(playerPed,  8,	table.unpack(oldData.tshirt))	-- Tshirt
		SetPedComponentVariation(playerPed, 11,	table.unpack(oldData.torso))	-- torso parts
		SetPedComponentVariation(playerPed,  3, table.unpack(oldData.arms))		-- Arms
		if oldData.bproof then
			SetPedComponentVariation(playerPed,  9, table.unpack(oldData.bproof))	-- Bproof
		end
		oldData.tshirt = nil
		oldData.torso = nil
		oldData.arms = nil
		oldData.bproof = nil
		return
	end
	oldData.tshirt = GetComponentData(playerPed, 8)
	oldData.torso = GetComponentData(playerPed, 11)
	oldData.arms = GetComponentData(playerPed, 3)
	oldData.bproof = GetComponentData(playerPed, 9)
	SetPedComponentVariation(playerPed,  8,	15,	0, 2)			-- Tshirt
	SetPedComponentVariation(playerPed, 11,	15,	0, 2)			-- torso parts
	SetPedComponentVariation(playerPed,  3,	15,	0, 2)			-- Arms
	SetPedComponentVariation(playerPed,  9,	 0, 0, 2)			-- Bproof
end

function ClothesPants()
	local clothesSkin
	local playerPed = PlayerPedId()
	if IsMale(playerPed) then
		clothesSkin = {
			21, 0, 2
		}
	else
		clothesSkin = {
			21, 0, 2
		}
	end

	if not oldData then
		oldData = {}
	elseif oldData.pants then
		SetPedComponentVariation(playerPed, 4, table.unpack(oldData.pants)) -- Pants
		oldData.pants = nil
		return
	end
	oldData.pants = GetComponentData(playerPed, 4)
	SetPedComponentVariation(playerPed, 4, table.unpack(clothesSkin)) -- Pants
end

function ClothesBulletproof()
	local playerPed = PlayerPedId()

	if not oldData then
		oldData = {}
	elseif oldData.bproof then
		SetPedComponentVariation(playerPed, 9, table.unpack(oldData.bproof)) -- Pants
		oldData.bproof = nil
		return
	end
	oldData.bproof = GetComponentData(playerPed, 9)
	SetPedComponentVariation(playerPed,  9,	 0, 0, 2)			-- Bproof
end

function ClothesBoots()
	local playerPed = PlayerPedId()
	local clothesSkin
	if IsMale(playerPed) then
		clothesSkin = {
			34, 0, 2
		}
	else
		clothesSkin = {
			35, 0, 2
		}
	end

	if not oldData then
		oldData = {}
	elseif oldData.shoes then
		SetPedComponentVariation(playerPed, 6, table.unpack(oldData.shoes)) -- Pants
		oldData.shoes = nil
		return
	end
	oldData.shoes = GetComponentData(playerPed, 6)
	SetPedComponentVariation(playerPed, 6, table.unpack(clothesSkin))
end

function DoDelay(time)
	local coords = GetEntityCoords(PlayerPedId())
	ESX.ShowNotification(_U('Wait-Time')
	Citizen.Wait(time)
	if #(coords - GetEntityCoords(PlayerPedId())) < 0.5 then
		return true
	else
		ESX.ShowNotification(_U('Moved'))
		return false
	end
end

function OpenMenu()
	local elements = {
		{label = _U('Do-Clothing'), value = 'reset'},
		{label = _U('Remove-Shirt'),, value = 'tshirt'},
		{label = _U('Remove-Pants'),, value = 'pants'},
		{label = _U('Take-Shoes'),, value = 'shoes'},
		{label = _U('Take-Vest'),, value = 'bproof'},
	}

	ESX.UI.Menu.CloseAll()


	ESX.UI.Menu.Open(
	'default', GetCurrentResourceName(), 'action_menu',
	{
		title    = _U('Title'),
		align    = 'top-right',
		elements = elements
	},
	function(data, menu)
		menu.close()
		if Config.VehicleUsage then 
			if GetVehiclePedIsIn(PlayerPedId()) ~= 0 then
				ESX.ShowNotification(_U('Vehicle'))
				return
			end
		end
		if Config.UseTimer then 
			if DoDelay(5000) then
				if data.current.value == 'reset' then
					ResetClothes()
				elseif data.current.value == 'tshirt' then
					ClothesTshirt()
				elseif data.current.value == 'pants' then
					ClothesPants()
				elseif data.current.value == 'shoes' then
					ClothesBoots()
				elseif data.current.value == 'bproof' then
					ClothesBulletproof()
				end
			end
		else
			if data.current.value == 'reset' then
				ResetClothes()
			elseif data.current.value == 'tshirt' then
				ClothesTshirt()
			elseif data.current.value == 'pants' then
				ClothesPants()
			elseif data.current.value == 'shoes' then
				ClothesBoots()
			elseif data.current.value == 'bproof' then
				ClothesBulletproof()
			end
		end
	end,
	function(data, menu)
		if menu then
			menu.close()
		end
	end)
end

local timer = 0
RegisterCommand('openclothingmenu', function (source, args, raw)
	if not IsControlEnabled(0, 344) or not IsInputDisabled(2) or ESX.UI.Menu.IsOpen('default', GetCurrentResourceName(), 'action_menu') then
		return
	end

	if Config.UseDelay then 
		if GetCloudTimeAsInt() - timer < 300 then
			ESX.ShowNotification(_U('Delay'))
			return
		end
	end

	OpenMenu()
end)

RegisterKeyMapping('openclothingmenu', _U('KeyMapping'), 'keyboard', 'F11')