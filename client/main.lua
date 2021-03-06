ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(500)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end

	ESX.PlayerData = ESX.GetPlayerData()

	-- Update the door list
	ESX.TriggerServerCallback('esx_celldoors:getDoorState', function(doorState)
		for index,state in pairs(doorState) do
			Config.DoorList[index].locked = state
		end
	end)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job) ESX.PlayerData.job = job end)

RegisterNetEvent('esx_celldoors:setDoorState')
AddEventHandler('esx_celldoors:setDoorState', function(index, state) Config.DoorList[index].locked = state end)

-- Get door objects once every second
Citizen.CreateThread(function()
	while true do
		local playerCoords = GetEntityCoords(PlayerPedId())

		for k,v in ipairs(Config.DoorList) do
			v.isAuthorized = isAuthorized(v)

			if v.doors then
				for k2,v2 in ipairs(v.doors) do
					if v2.object and DoesEntityExist(v2.object) then
						if k2 == 1 then
							v.distanceToPlayer = #(playerCoords - GetEntityCoords(v2.object))
						end
					else
						v2.object = GetClosestObjectOfType(v2.objCoords, 1.0, v2.objHash, false, false, false)
					end
				end
			else
				if v.object and DoesEntityExist(v.object) then
					v.distanceToPlayer = #(playerCoords - GetEntityCoords(v.object))
				else
					v.object = GetClosestObjectOfType(v.objCoords, 1.0, v.objHash, false, false, false)
				end
			end
		end

		Citizen.Wait(1000)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(20)
		local letSleep = true

		for k,v in ipairs(Config.DoorList) do
			if v.distanceToPlayer and v.distanceToPlayer < 50 then
				letSleep = false

				if v.doors then
					for k2,v2 in ipairs(v.doors) do
						FreezeEntityPosition(v2.object, v.locked)

						if v.locked and v2.objHeading and GetEntityHeading(v2.object) ~= v2.objHeading then
							SetEntityHeading(v2.object, v2.objHeading)
						end
					end
				else
					FreezeEntityPosition(v.object, v.locked)

					if v.locked and v.objHeading and GetEntityHeading(v.object) ~= v.objHeading then
						SetEntityHeading(v.object, v.objHeading)
					end
				end
			end

			if v.distanceToPlayer and v.distanceToPlayer < v.maxDistance then
				local size, displayText = 0.4, _U('unlocked')

				if v.size then size = v.size end
				if v.locked then displayText = _U('locked') end
				if v.isAuthorized then displayText = _U('press_button', displayText) end

				ESX.Game.Utils.DrawText3D(v.textCoords, displayText, size)

				if IsControlJustReleased(0, 38) then
					if isAuthorized then
						v.locked = not v.locked

						TriggerServerEvent('esx_doorlock:updateState', i, v.locked) -- Broadcast new state of the door to everyone
					end
				end
			end
		end
	end
end)

function isAuthorized(door)
	if not ESX or not ESX.PlayerData.job then
		return false
	end

	for k,job in pairs(door.authorizedJobs) do
		if job == ESX.PlayerData.job.name then
			return true
		end
	end

	return false
end

function ApplyDoorState(doorID)
	local closeDoor = GetClosestObjectOfType(doorID.objCoords.x, doorID.objCoords.y, doorID.objCoords.z, 1.0, GetHashKey(doorID.objName), false, false, false)
	FreezeEntityPosition(closeDoor, doorID.locked)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(30000)
		collectgarbage()
	end
end)

-- Set state for a door
RegisterNetEvent('esx_doorlock:setState')
AddEventHandler('esx_doorlock:setState', function(doorID, state)
	Config.DoorList[doorID].locked = state
end)