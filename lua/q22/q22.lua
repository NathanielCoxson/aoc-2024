local inputFile = "q22.in.txt"

local function getInput(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local lines = {}
    for line in io.lines(filename) do
        lines[#lines+1] = tonumber(line)
    end
    return lines
end

local function mix(a, b)
    return math.floor(a) ~ math.floor(b)
end

local function prune(n)
    return n % 16777216
end

local function simulate(number, n)
    for i = 1, n do
        -- Step 1
        number = prune(mix(number, number * 64))

        -- Step 2
        number = prune(mix(number, number / 32))

        -- Step 3
        number = prune(mix(number, number * 2048))
    end
    return number
end

local secretNumbers = getInput(inputFile)
local sum = 0
for _, n in pairs(secretNumbers) do sum = sum + simulate(n, 2000) end
print("Part 1:", sum)
