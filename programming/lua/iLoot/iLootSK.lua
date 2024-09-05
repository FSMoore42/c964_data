-- SK.lua
iLoot.SK = iLoot.SK or {}

-- Example SK list management functions here
function iLoot.SK:CreateList(name)
    self[name] = {}
end

function iLoot.SK:AddPlayer(listName, playerName)
    table.insert(self[listName], playerName)
end

function iLoot.SK:SuicidePlayer(listName, playerName)
    -- Logic for SK suicide
end

function iLoot.SK:PrintList(listName)
    -- Logic to print the SK list
end
