local enablePrint = false

local function printList(l)
    for i, v in pairs(l) do
        io.write(v)
        if i < #l then io.write(" ") end
    end
    io.write("\n")
end

local function getTableLength(t)
    local length = 0
    for _, _ in pairs(t) do length = length + 1 end
    return length
end

local function getInput(filename)
    local f = assert(io.open(filename, "r"))
    local d = {}

    for line in f:lines() do
        table.insert(d, line)
    end

    return d
end

local function getRules(d)
    local output = {}
    local pattern = "(%d+)|(%d+)"
    for _, line in pairs(d) do
        if line == "" then break end
        for a, b in string.gmatch(line, pattern) do
            table.insert(output, {tonumber(a), tonumber(b)})
        end
    end
    return output
end

local function getUpdates(d)
    local output = {}
    local read = false
    local pattern = "(%d+),"
    for _, line in pairs(d) do
        if read then
            local update = {}
            line = line .. ","
            for num in string.gmatch(line, pattern) do
                table.insert(update, tonumber(num))
            end
            table.insert(output, update)
        end
        if line == "" then read = true end
    end
    return output
end

local function checkUpdate(u, r)
    local seen = {}

    for _, num in pairs(u) do
        for _, rule in pairs(r) do
            local x, y = rule[1], rule[2]
            if num == x and seen[y] ~= nil then return false end
        end
        seen[num] = true
    end
    return true
end

local function getRuleMap(r)
    local map = {}
    for _, rule in pairs(r) do
        local x, y = rule[1], rule[2]
        if map[x] == nil then map[x] = {} end
        table.insert(map[x], y)
    end
    return map
end

local function searchRule(r, x, y)
    for i, t in pairs(r) do
        for _, j in pairs(t) do
            if i == x and j == y then return true end
        end
    end
    return false
end

local function fixUpdate(u, r)
    for i = 1, getTableLength(u) do
        for j = i + 1, getTableLength(u) do
            if not searchRule(r, u[i], u[j]) then
                local temp = u[i]
                u[i] = u[j]
                u[j] = temp
            end
        end
    end
    return u
end

local data = getInput("q5.in.txt")
local rules = getRules(data)
local updates = getUpdates(data)
local ruleMap = getRuleMap(rules)

local invalidSum = 0
for _, update in pairs(updates) do
    if checkUpdate(update, rules) then
        invalidSum = invalidSum + update[#update // 2 + 1]
        if enablePrint then print(update[#update // 2 + 1]) end
    end
end
print(invalidSum)

local correctedSum = 0
for _, update in pairs(updates) do
    if not checkUpdate(update, rules) then
        update = fixUpdate(update, ruleMap)
        correctedSum = correctedSum + update[#update // 2 + 1]
    end
end
print(correctedSum)
