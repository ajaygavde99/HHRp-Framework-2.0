RegisterServerEvent('fireworks')
AddEventHandler('fireworks', function()
    if IsPlayerAceAllowed(source, "bz.fwcmds") then
        TriggerClientEvent('frobski-fireworks:start', source)
    else
        TriggerClientEvent('bz-noperms', source)
    end
end)
