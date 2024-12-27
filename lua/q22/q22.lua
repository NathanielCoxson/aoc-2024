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
    for _ = 1, n do
        -- Step 1
        number = prune(mix(number, number * 64))

        -- Step 2
        number = prune(mix(number, number / 32))

        -- Step 3
        number = prune(mix(number, number * 2048))
    end
    return number
end

local function sequenceToString(seq)
    local s = ""
    for i, n in pairs(seq) do
        s = s .. n
        if i ~= #seq then s = s .. "," end
    end
    return s
end

local function getMaxBananas(nums, simulationLength)
    local sequences = {}
    for _, n in pairs(nums) do
        local secretNumbers = {}
        for _ = 1, simulationLength do
            secretNumbers[#secretNumbers+1] = n
            n = simulate(n, 1)
        end

        local prices = {}
        for i = 1, #secretNumbers do
            prices[#prices+1] = secretNumbers[i] % 10
        end

        local changes = {}
        changes[1] = 0
        for i = 2, #prices do
            changes[i] = prices[i] - prices[i - 1]
        end

        local seqs = {}
        for i = 2, simulationLength - 3 do
            local seq = {}
            for j = i, i + 3 do
                seq[#seq+1] = changes[j]
            end
            local k = sequenceToString(seq)
            if seqs[k] == nil then seqs[k] = prices[i + 3] end
        end

        for k, v in pairs(seqs) do
            if sequences[k] == nil then sequences[k] = 0 end
            sequences[k] = sequences[k] + v
        end
    end
    local max = 0
    for _, v in pairs(sequences) do
        if v > max then max = v end
    end
    return max
end


local secretNumbers = getInput(inputFile)
local sum = 0
for _, n in pairs(secretNumbers) do sum = sum + simulate(n, 2000) end
print("Part 1:", sum)

print("Part 2:", getMaxBananas(secretNumbers, 2000))
