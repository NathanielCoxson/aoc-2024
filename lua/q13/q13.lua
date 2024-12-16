local inputFile = "q13.in.txt"
local priceA = 3
local priceB = 1

local function getData(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local data = ""
    for line in io.lines(filename) do
        data = data .. line
    end
    return data
end

local function getTestCases(s)
    local testCases = {}
    local pattern = "(%d+)[^%d]+(%d+)[^%d]+(%d+)[^%d]+(%d+)[^%d]+(%d+)[^%d]+(%d+)"
    for x1, y1, x2, y2, x3, y3 in string.gmatch(s, pattern) do
        testCases[#testCases+1] = {
            tonumber(x1), tonumber(y1),
            tonumber(x2), tonumber(y2),
            tonumber(x3), tonumber(y3)
        }
    end
    return testCases
end

local function getPart2TestCases(cases)
    local shift = 10000000000000
    local result = {}
    for _, case in pairs(cases) do
        result[#result + 1] = {case[1], case[2], case[3], case[4], case[5] + shift, case[6] + shift}
    end
    return result
end

local function isInteger(n)
    return n % 1 == 0
end

local function calculatePrice(data)
    local x1, y1 = data[1], data[2]
    local x2, y2 = data[3], data[4]
    local x3, y3 = data[5], data[6]

    local b = ((x3 * y1) - (y3 * x1)) / ((x2 * y1) - (y2 * x1))
    local a = (x3 - (b * x2)) / x1

    if not isInteger(a) or not isInteger(b) then return 0 end
    return priceA * a + priceB * b
end

local function getSum(cases)
    local sum = 0
    for _, case in pairs(cases) do
        sum = sum + calculatePrice(case)
    end
    return math.floor(sum)
end

local testCases = getTestCases(getData(inputFile))
print(getSum(testCases))
local part2TestCases = getPart2TestCases(testCases)
print(getSum(part2TestCases))
