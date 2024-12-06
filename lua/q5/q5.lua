local enablePrint = false
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

local function orderRules(r)
    local after = {}
    for _, rule in pairs(r) do
        local x, y = rule[1], rule[2]
        if after[x] == nil then after[x] = {} end
        after[x][y] = true
    end
    for k, x in pairs(after) do
        io.write(k, ": ")
        for y, _ in pairs(x) do
            io.write(y, ",")
        end
        io.write("\n")
    end
end

local function fixUpdate(u, r)

end

local data = getInput("q5.test.txt")
local rules = getRules(data)
local updates = getUpdates(data)
orderRules(rules)

local invalidSum = 0
for _, update in pairs(updates) do
    if checkUpdate(update, rules) then
        invalidSum = invalidSum + update[#update // 2 + 1]
        if enablePrint then print(update[#update // 2 + 1]) end
    end
end
print(invalidSum)
