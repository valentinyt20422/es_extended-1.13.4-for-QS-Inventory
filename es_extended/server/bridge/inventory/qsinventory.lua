if Config.CustomInventory ~= 'qs' then return end
MySQL.ready(function()
    ESX.Items = exports['qs-inventory']:GetItemList()
end)
---@diagnostic disable-next-line: duplicate-set-field
ESX.GetItemLabel = function(item)
    return exports['qs-inventory']:GetItemLabel(item)
end
exports('GetUsableItems', function()
    return Core.UsableItemsCallbacks
end)
---@diagnostic disable-next-line: duplicate-set-field
ESX.RegisterUsableItem = function(item, cb)
    Core.UsableItemsCallbacks[item] = cb
    exports['qs-inventory']:CreateUsableItem(item, cb)
end
---@diagnostic disable-next-line: duplicate-set-field
ESX.UseItem = function(source, item, ...)
    if ESX.Items[item] then
        local itemCallback = Core.UsableItemsCallbacks[item]
        return exports['qs-inventory']:UseItem(item, source, ...)
    else
        print(('[^3WARNING^7] Item ^5"%s"^7 was used but does not exist!'):format(item))
    end
end
