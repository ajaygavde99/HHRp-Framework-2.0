HHCore = nil

TriggerEvent('hhrp:getSharedObject', function(obj) HHCore = obj end)

function AddLicense(target, type, cb)
	local xPlayer = HHCore.GetPlayerFromId(target)
	MySQL.Async.execute(
		'INSERT INTO user_licenses (type, owner) VALUES (@type, @owner)',
		{
			['@type']  = type,
			['@owner'] = xPlayer.identifier
		}, function(rowsChanged)
			if cb ~= nil then
				cb()
			end
		end
	)
end

function RemoveLicense(target, type, cb)
	local xPlayer = HHCore.GetPlayerFromId(target)
	MySQL.Async.execute(
		'DELETE FROM user_licenses WHERE type = @type AND owner = @owner',
		{
			['@type']  = type,
			['@owner'] = xPlayer.identifier
		}, function(rowsChanged)
			if cb ~= nil then
				cb()
			end
		end
	)
end

function GetLicense(type, cb)
	MySQL.Async.fetchAll(
		'SELECT * FROM licenses WHERE type = @type',
		{
			['@type'] = type
		}, function(result)
			local data = {
				type  = type,
				label = result[1].label
			}

			cb(data)
		end
	)
end

function GetLicenses(target, cb)
	local xPlayer = HHCore.GetPlayerFromId(target)
	MySQL.Async.fetchAll(
		'SELECT * FROM user_licenses WHERE owner = @owner',
		{
			['@owner'] = xPlayer.identifier
		}, function(result)
			local licenses   = {}
			local asyncTasks = {}

			for i=1, #result, 1 do

				local scope = function(type)
					table.insert(asyncTasks, function(cb)
						MySQL.Async.fetchAll(
							'SELECT * FROM licenses WHERE type = @type',
							{
								['@type'] = type
							}, function(result2)

								table.insert(licenses, {
									type  = type,
									label = result2[1].label
								})
								cb()
							end
						)
					end)
				end
				scope(result[i].type)
			end

			Async.parallel(asyncTasks, function(results)
				cb(licenses)
			end)

		end
	)
end

function CheckLicense(target, type, cb)
	local xPlayer = HHCore.GetPlayerFromId(target)
	MySQL.Async.fetchAll(
		'SELECT COUNT(*) as count FROM user_licenses WHERE type = @type AND owner = @owner',
		{
			['@type']  = type,
			['@owner'] = xPlayer.identifier
		}, function(result)
			if tonumber(result[1].count) > 0 then
				cb(true)
			else
				cb(false)
			end

		end
	)
end

function GetLicensesList(cb)
	MySQL.Async.fetchAll(
		'SELECT * FROM licenses',
		{
			['@type'] = type
		}, function(result)
			local licenses = {}

			for i=1, #result, 1 do
				table.insert(licenses, {
					type  = result[i].type,
					label = result[i].label
				})
			end
			cb(licenses)
		end
	)
end

RegisterNetEvent('hhrp-license:addLicense')
AddEventHandler('hhrp-license:addLicense', function(target, type, cb)
	AddLicense(target, type, cb)
end)

RegisterNetEvent('hhrp-license:removeLicense')
AddEventHandler('hhrp-license:removeLicense', function(target, type, cb)
	RemoveLicense(target, type, cb)
end)

AddEventHandler('hhrp-license:getLicense', function(type, cb)
	GetLicense(type, cb)
end)

AddEventHandler('hhrp-license:getLicenses', function(target, cb)
	GetLicenses(target, cb)
end)

AddEventHandler('hhrp-license:checkLicense', function(target, type, cb)
	CheckLicense(target, type, cb)
end)

AddEventHandler('hhrp-license:getLicensesList', function(cb)
	GetLicensesList(cb)
end)

HHCore.RegisterServerCallback('hhrp-license:getLicense', function(source, cb, type)
	GetLicense(type, cb)
end)

HHCore.RegisterServerCallback('hhrp-license:getLicenses', function(source, cb, target)
	GetLicenses(target, cb)
end)

HHCore.RegisterServerCallback('hhrp-license:checkLicense', function(source, cb, target, type)
	CheckLicense(target, type, cb)
end)

HHCore.RegisterServerCallback('hhrp-license:getLicensesList', function(source, cb)
	GetLicensesList(cb)
end)