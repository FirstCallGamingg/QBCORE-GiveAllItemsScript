local QBCore = exports['qb-core']:GetCoreObject()

local Config = {
    Inventory = 'core', -- 'ox' or 'core'
    PermRole = 'admin' -- Set your permission here
}

-- /giveallitem <item> <amount>
-- Example: /giveallitem bandage 2
QBCore.Commands.Add(
    'giveallitem',
    'Give an item to ALL ONLINE players',
    {
        { name = 'item', help = 'Item name (must exist)' },
        { name = 'amount', help = 'Amount (number)' },
    },
    true,
    function(source, args)
        local src = source
        if src ~= 0 and not QBCore.Functions.HasPermission(src, Config.PermRole) then
            TriggerClientEvent('QBCore:Notify', src, 'No permission', 'error')
            return
        end
        local item = tostring(args[1] or ''):lower()
        local amount = tonumber(args[2] or 0)
        if item == '' or not amount or amount < 1 then
            if src ~= 0 then
                TriggerClientEvent('QBCore:Notify', src, 'Usage: /giveallitem <item> <amount>', 'error')
            end
            return
        end
        if Config.Inventory == 'ox' then
            local items = exports.ox_inventory:Items()
            if not items or not items[item] then
                if src ~= 0 then
                    TriggerClientEvent('QBCore:Notify', src, ('Invalid item: %s'):format(item), 'error')
                end
                return
            end
        elseif Config.Inventory == 'core' then
            local items = exports.core_inventory:getItemsList()
            if not items or not items[item] then
                if src ~= 0 then
                    TriggerClientEvent('QBCore:Notify', src, ('Invalid item: %s'):format(item), 'error')
                end
                return
            end
        end
        local players = QBCore.Functions.GetPlayers()
        local given = 0
        local failed = 0
        for _, id in pairs(players) do
            -- AddItem returns true/false
            if Config.Inventory == 'ox' then
                local ok = exports.ox_inventory:AddItem(id, item, amount)
                if ok then
                    given += 1
                else
                    failed += 1
                end
            elseif Config.Inventory == 'core' then
                local ok = exports.core_inventory:addItem(id, item, amount)
                if ok then
                    given += 1
                else
                    failed += 1
                end
            end

        end
        local msg = ('Gave x%d %s to %d online players. Failed: %d')
            :format(amount, item, given, failed)
        print('[YH-GIVEALLITEM] ' .. msg)
        if src ~= 0 then
            TriggerClientEvent('QBCore:Notify', src, msg, 'success')
        end
end, Config.PermRole)
