function cleanString(itemName)
    if string.find(itemName, "^%s") then
        itemName = string.gsub(itemName, "^%s", "")
    end
    return string.lower(itemName)
end

return { cleanString = cleanString }
