package.path = package.path .. ";../?.lua"
local utils = require("utils")

local inputFile = "q25.in.txt"

local maxSpace = 5

local function getKeyHeights(key)
    local heights = {}
    for col = 1, #key[1] do
        local height = 0
        for row = #key - 1, 1, -1 do
            if key[row][col] == "#" then height = height + 1
            else break end
        end
        heights[#heights+1] = height
    end
    return heights
end

local function getLockHeights(lock)
    local heights = {}
    for col = 1, #lock[1] do
        local height = 0
        for row = 2, #lock do
            if lock[row][col] == "#" then height = height + 1
            else break end
        end
        heights[#heights+1] = height
    end
    return heights
end

local function getInput(data)

    local locks = {}
    local keys = {}
    local current = {}
    for _, line in pairs(data) do
        if line == "" then
            if current[1][1] == "#" then
                locks[#locks+1] = utils.copyTable2D(current)
            else
                keys[#keys+1] = utils.copyTable2D(current)
            end

            current = {}
        else
            table.insert(current, {})
            for i = 1, #line do
                table.insert(current[#current], string.sub(line, i, i))
            end
        end
    end

    -- Catch final lock or key
    if current[1][1] == "#" then
        locks[#locks+1] = utils.copyTable2D(current)
    else
        keys[#keys+1] = utils.copyTable2D(current)
    end

    local lockHeights = {}
    local keyHeights = {}
    for _, lock in pairs(locks) do
        lockHeights[#lockHeights+1] = getLockHeights(lock)
    end
    for _, key in pairs(keys) do
        keyHeights[#keyHeights+1] = getKeyHeights(key)
    end

    return {lockHeights, keyHeights}
end

local function validKeyLockPair(key, lock, space)
    for i = 1, #key do
        if key[i] + lock[i] > space then return false end
    end
    return true
end

local function getNumberOfUniqueKeyLockPairs(locks, keys)
    local count = 0
    for _, lock in pairs(locks) do
        for _, key in pairs(keys) do
            if validKeyLockPair(key, lock, maxSpace) then count = count + 1 end
        end
    end
    return count
end

local input = getInput(utils.getData(inputFile))
local locks, keys = input[1], input[2]

print(getNumberOfUniqueKeyLockPairs(locks, keys))
