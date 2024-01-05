-- clear terminal
term.clear()
term.setCursorPos(1,1)

-- requires
local dump = require("helpers.dump")
local AC = require("helpers.autoComplete")
local SAC = require("helpers.showAvailableCommands")
local CS = require("helpers.cleanString")

-- variabels
local chests = {
    peripheral.find("minecraft:chest"),
    peripheral.find("ironchests:gold_chest")}

local deliveryChest

local itemIndex = {}

for numb, DC in pairs(chests) do
    if DC.size() == 27 then
        deliveryChest = DC
    end
end

-- define functions
function getChestContents()
    for chestListId, chest in pairs(chests) do
        for slot, chItems in pairs(chest.list()) do
            local itemDetail = chest.getItemDetail(slot)
            print(("%d x %s in chest %d in slot %d"):format(chItems.count, itemDetail.displayName, chestListId, slot))
        end    
    end
end

function index()
    -- store chest ID, item #, item name and slot #
    for chestListId, chest in pairs(chests) do
        if chest.size() > 27 then
            for slot, chItems in pairs(chest.list()) do
                local itemDetail = chest.getItemDetail(slot)
                -- for some reason, if slot = 1 then it bugs out? So we add 1 to slot so it doesn't do that, nani the fuck?
                slot = slot + 1
                if itemDetail == nil then
                    return
                end
                local lowerCaseDisplayName = string.lower(itemDetail.displayName) -- to make it easier to get items further down the line
                if itemIndex[lowerCaseDisplayName] == nil then
                    itemIndex[lowerCaseDisplayName] = {}
                end
                if itemIndex[lowerCaseDisplayName][chestListId+1] == nil then
                    itemIndex[lowerCaseDisplayName][chestListId+1] = {}
                end 
                itemIndex[lowerCaseDisplayName][chestListId+1][slot] = {
                    ["count"] = chItems.count
                }
            end
        end
    end
end

function findItem(itemName)
    itemName = CS.cleanString(itemName)
    local foundItems = findItemWithIndex(itemName)
    if foundItems == nil or #foundItems <= 0 then
        return false
    end

end

function findItemWithIndex(itemName)
    local foundItems = {}
    for items, itemInfo in pairs(itemIndex) do
        if string.lower(items) == itemName then
            foundItems = itemInfo
        end
    end
    return foundItems
end

function getItems(itemName, amount)
    -- define local variabels
    itemName = CS.cleanString(itemName)
    local item = findItemWithIndex(itemName)
    local getAllItems
    local getAll

    if item == nil then
        return false
    end
    if next(item) == nil then
        return false
    end

    amount = tonumber(amount)

    if amount == nil then
        getAllItems = true
    end
    for chestInfo, slotInfo in pairs(item) do
        local pullChest = peripheral.wrap(peripheral.getName(chests[chestInfo-1])) -- since we had to add 1 to the chests index we now remove that 1
        for slot, itemCount in pairs(slotInfo) do
            if getAllItems == true then
                amount = itemCount.count
            end

            if amount <= 0 then
                return
            end
            if itemCount.count < amount then
                getAll = itemCount.count
            else
                getAll = amount
             end

            if itemCount.count - amount <= 0 then
                itemIndex[itemName][chestInfo][slot] = nil
                file.write(itemIndex[itemName][chestInfo][slot])
                if #itemIndex[itemName][chestInfo] <= 0 then
                    itemIndex[itemName][chestInfo] = nil
                end
            end

            if getAllItems == true then
                amount = amount - itemCount.count
                getAllItems = false
            else
                amount = amount - amount
            end

            pullChest.pushItems(peripheral.getName(deliveryChest), slot-1, getAll) -- since we had to add 1 to the slot index we now remove that 1
        end
    end
end

function storeItems()
    -- TODO
end

function clear()
    term.clear()
    term.setCursorPos(1,1)
end

-- List of choices, used for the `help` command and for the autocomplete
local choices = 
{
    {["name"] = "find", ["params"] = "<item>", ["description"] = "Find an item"},
    {["name"] = "help", ["params"] = nil, ["description"] = "Shows all available commands"},
    {["name"] = "get", ["params"] = "<item>", ["description"] = "Gets an item"},
    {["name"] = "clear", ["params"] = nil, ["description"] = "Clears screen"},
    {["name"] = "index", ["params"] = nil, ["description"] = "Reindexes all available items"}
}

local firstRun = true

-- run startup functions
index()

while true do
    if firstRun == true then
        write("Welcome, for a list of available commands use 'help'\n")
        
        firstRun = false
    end
    
    write("> ")

    local command = read(nil, nil, function(text) return AC.autoComplete(text, choices) end)

    if string.find(string.lower(command), "find") ~= nil then
        local q = string.gsub(command, "find", "")

        if q == "" or q == " " then
            write("What Item Do You Need?\n> ")

            q = read()
        end

        findItem(q)
    elseif string.find(string.lower(command), "get") ~= nil then
        local q = string.gsub(command, "get", "")
        local a = string.gsub(q, " [a-z]+ ", "")

        q = string.gsub(q, " [0-9]+", "")

        if q == "" or q == " " then
            write("\nWhat Item Do You Want?\n>")

            q = read()

            write("\nHow many do you want? Leave empty for current available stack size\n>")

            a = read()
        end

        items = getItems(q, a)

        if items == false then
            write(("\n%s could not be found\n"):format(q))
        else
            write(("\n%s has/have been delivered\n"):format(q))
        end
    elseif string.lower(command) == "help" then
        write("The available commands are:\n")

        SAC.showAvailableCommands(choices)
    elseif string.lower(command) == "clear" then
        clear()
    elseif string.lower(command) == "index" then
        write("This might take a little while.\n")

        index()

        write("Done!\n")
    else
        write("Command not found\n")
    end
end
