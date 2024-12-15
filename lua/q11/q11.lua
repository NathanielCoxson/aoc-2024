local inputFile = "q11.in.txt"

local function printTable(t)
    for k, v in pairs(t) do
        if v > 0 then
            io.write("{", k, " ", v, "} ")
        end
    end
    io.write("\n")
end

local function getInput(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local lines = {}
    for line in io.lines(filename) do
        lines[#lines+1] = line
    end
    return lines
end

local function getNums(s)
    local nums = {}
    for n in string.gmatch(s, "%d+") do
        nums[#nums+1] = tonumber(n)
    end
    return nums
end

local function canSplit(n)
    return #tostring(n) % 2 == 0
end

local function split(n)
    local s = tostring(n)
    local left = tonumber(string.sub(s, 1, #s // 2))
    local right = tonumber(string.sub(s, #s // 2 + 1, #s))
    return {left, right}
end

local function doBlinks(n, t)
    local stones = {}
    local multi = 2024
    for _, v in pairs(t) do
        if stones[v] == nil then stones[v] = 1
        else stones[v] = stones[v] + 1 end
    end

    for _ = 1, n do
        local updates = {}
        for num, count in pairs(stones) do
            if num == 0 then
                if updates[1] ~= nil then updates[1] = updates[1] + count
                else updates[1] = count end
                stones[0] = 0
            elseif canSplit(num) then
                local halves = split(num)
                if updates[halves[1]] ~= nil then updates[halves[1]] = updates[halves[1]] + count
                else updates[halves[1]] = count end
                if updates[halves[2]] ~= nil then updates[halves[2]] = updates[halves[2]] + count
                else updates[halves[2]] = count end
                stones[num] = 0
            else
                if updates[num * multi] ~= nil then updates[num * multi] = updates[num * multi] + count
                else updates[num * multi] = count end
                stones[num] = 0
            end
        end
        for num, count in pairs(updates) do
            if stones[num] == nil then stones[num] = 0 end
            stones[num] = stones[num] + count
        end
    end

    local total = 0
    for _, c in pairs(stones) do total = total + c end
    return total
end

local data = getInput(inputFile)
local nums = getNums(data[1])
print(doBlinks(75, nums))
