local inputFile = "q9.in.txt"

local function printList(l)
    for _, v in pairs(l) do
        io.write(v)
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

print(getChecksum(getCompactMap(getExpandedDiskMap(getData(inputFile)))))
