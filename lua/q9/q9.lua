local inputFile = "q9.in.txt"

local function printList(l)
    for _, v in pairs(l) do
        io.write(v)
    end
    io.write("\n")
end

local function print2DList(l)
    for _, r in pairs(l) do
        io.write("{")
        for i, v in pairs(r) do
            io.write(v)
            if i ~= #r then io.write(" ") end
        end
        io.write("} ")
    end
    io.write("\n")
end

local function copyList(l)
    local copy = {}
    for i, v in pairs(l) do copy[i] = v end
    return copy
end

local function getData(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local data = {}
    local stringData = ""
    for line in io.lines(filename) do stringData = line end
    for i = 1, #stringData do
        data[#data+1] = tonumber(string.sub(stringData, i, i))
    end
    return data
end

local function getExpandedDiskMap(m)
    local id = 0

    local expandedMap = {}
    for i = 1, #m do
        if i % 2 == 1 then
            for _ = 1, m[i] do
                expandedMap[#expandedMap+1] = id
            end
            id = id + 1
        else
            for _ = 1, m[i] do
                expandedMap[#expandedMap+1] = "."
            end
        end
    end

    return expandedMap
end

local function getCompactMap(m)
    local left, right = 1, #m
    local compactMap = copyList(m)

    while left < right do
        while left < right and compactMap[left] ~= "." do
            left = left + 1
        end
        while right > left and compactMap[right] == "." do
            right = right - 1
        end
        compactMap[left] = compactMap[right]
        compactMap[right] = "."
    end

    return compactMap
end

local function getChecksum(m)
    local checksum = 0
    for i = 0, #m - 1 do
        if m[i+1] ~= "." then
            checksum = checksum + (i * tonumber(m[i + 1]))
        end
    end
    return checksum
end

-- Part 2
local function getExpandedContiguousMap(m)

    local expandedMap = {}
    for i = 1, #m do
        if m[i][2] == -1 then
            for _ = 1, tonumber(m[i][1]) do
                expandedMap[#expandedMap+1] = "."
            end
        else
            for _ = 1, tonumber(m[i][1]) do
                expandedMap[#expandedMap+1] = m[i][2]
            end
        end
    end

    return expandedMap
end
local function getContiguousCompactedMap(m)
    local map = {}
    local id = 0

    for i = 1, #m do
        if i % 2 == 1 then
            map[#map+1] = {tonumber(m[i]), id}
            id = id + 1
        else
            map[#map+1] = {tonumber(m[i]), -1}
        end
    end

    --print2DList(map)
    --printList(getExpandedContiguousMap(map))
    local left, right = 0, #map
    while left < right do
        local maxSpace = 0
        left = 1
        while left < right do
            if map[left][2] == -1 and map[left][1] > maxSpace then maxSpace = map[left][1] end
            left = left + 1
        end

        left = 1
        right = #map
        while right > left and map[right][1] > maxSpace or map[right][2] == -1 do
            right = right - 1
        end

        while left < right and map[left][2] ~= -1 or map[left][1] < map[right][1] do
            left = left + 1
        end

        if left < right then
            local remainder = map[left][1] - map[right][1]
            map[left][1] = map[right][1]
            map[left][2] = map[right][2]
            map[right][2] = -1
            if remainder > 0 then table.insert(map, left + 1, {remainder, -1}) end
        end
        --print2DList(map)
        --printList(getExpandedContiguousMap(map))
        --print(left, right)
    end

    return map
end

print(getChecksum(getCompactMap(getExpandedDiskMap(getData(inputFile)))))

print(getChecksum(getExpandedContiguousMap(getContiguousCompactedMap(getData(inputFile)))))
