local inputFile = "q19.in.txt"

local function getInput(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local testCases = {}
    local segments = {}
    local i = 1
    for line in io.lines(filename) do
        if i == 1 then
            for s in string.gmatch(line, "(%a+)") do
                segments[#segments+1] = s
            end
        end
        if i > 2 then
            testCases[#testCases+1] = line
        end
        i = i + 1
    end
    return {segments, testCases}
end

local function canMakeTowel(target, segments)
    local dp = {}
    for i = 1, #target do
        dp[i] = false
    end
    dp[0] = true

    for i = 1, #target do
        for _, s in pairs(segments) do
            if dp[i - 1] and string.sub(target, i, i + #s - 1) == s then
                dp[i + #s - 1] = true
            end
        end
    end

    return dp[#dp]
end

local data = getInput(inputFile)
local segments = data[1]
local testCases = data[2]

local count = 0
for i, case in pairs(testCases) do
    if canMakeTowel(case, segments) then count = count + 1 end
end
print("Part 1:", count)
