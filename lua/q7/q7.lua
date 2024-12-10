local enablePrint = false
local inputFile = "q7.in.txt"

local function getLines(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local lines = {}
    for line in io.lines(filename) do
        table.insert(lines, line)
    end

    return lines
end

-- Returns {testValue, {num1, num2, num3, ..., numk}}
local function parseLine(line)
    local numberCapture = "(%d+)"
    local targetCaptured = false
    local result = {nil, {}}

    for n in string.gmatch(line, numberCapture) do
        if not targetCaptured then
            result[1] = tonumber(n)
            targetCaptured = true
        else
            result[2][#result[2]+1] = tonumber(n)
        end
    end
    return result
end

local function getParsedLines(lines)
    local result = {}
    for _, line in pairs(lines) do
        local parsed = parseLine(line)
        result[#result+1] = parsed
    end
    return result
end

local function printStack(s)
    io.write("{")
    for _, state in pairs(s) do
        io.write("{", state[1], ", ", state[2], "} ")
    end
    io.write("}\n")
end

local function dfs(line, concatenation)
    local target = line[1]
    local nums   = line[2]
    local stack  = {{nums[1], 1}, {nums[1], 1}}

    while #stack > 0 do
        local state = table.remove(stack, #stack)
        local curr, idx = state[1], state[2]

        if curr == target and idx == #nums then return true
        elseif idx < #nums then
            stack[#stack+1] = {curr + nums[idx + 1], idx + 1}
            stack[#stack+1] = {curr * nums[idx + 1], idx + 1}
            if concatenation then stack[#stack+1] = {tonumber(curr .. nums[idx + 1]), idx + 1} end
        end
        if enablePrint then printStack(stack) end
    end

    return false
end

local function sumPossibleEquations(lines, concatenation)
    local total = 0
    for _, l in pairs(lines) do
        if dfs(l, concatenation) then total = total + l[1] end
    end
    return total
end

local lines = getParsedLines(getLines(inputFile))
if enablePrint then
    for _, l in pairs(lines) do
        io.write(l[1], ": ")
        for _, n in pairs(l[2]) do io.write(n, " ") end
        print(dfs(l))
    end
end

local partOneResult = sumPossibleEquations(lines, false)
local partTwoResult = sumPossibleEquations(lines, true)
io.write(partOneResult, "\n", partTwoResult, "\n")
