local enablePrint = false
local function get_input(filename)
    local f = assert(io.open(filename, "r"))
    local data = f:read("*all")
    f:close()
    return data
end

local function findOccurences(input, pattern)
    local output = {}
    local start = 1
    while start < string.len(input) do
        local s, e, a = string.find(input, pattern, start)
        if e ~= nil then start = e else start = string.len(input) end
        if s ~= nil then table.insert(output, {start, a}) end
    end
    return output
end

local function get_commands(input)
    local mulPattern    = "(mul%(%d%d?%d?,%d%d?%d?%))"
    local doPattern     = "(do%(%))"
    local dontPattern   = "(don't%(%))"
    local output = {}

    local mults = findOccurences(input, mulPattern)
    local dos   = findOccurences(input, doPattern)
    local donts = findOccurences(input, dontPattern)

    for _, v in pairs(mults) do output[#output+1] = v end
    for _, v in pairs(dos)   do output[#output+1] = v end
    for _, v in pairs(donts) do output[#output+1] = v end

    table.sort(output, function(a, b) return a[1] < b[1] end)

    return output
end

local function get_total(commands)
    local enabled = true
    local numberPattern = "%((%d%d?%d?),(%d%d?%d?)%)"
    local total = 0
    for _, v in pairs(commands) do
        local command     = v[2]
        local commandType = command:match("^[^%(]*")

        if     commandType == "do"    then enabled = true
        elseif commandType == "don't" then enabled = false
        elseif commandType == "mul"   then
            local _, _, a, b = command:find(numberPattern)
            a = tonumber(a)
            b = tonumber(b)
            if enablePrint then print(a * b, enabled) end
            if enabled then total = total + a * b end
        end
    end
    return total
end

local data = get_input("q3.test.txt")
if enablePrint then print(data) end

local commands = get_commands(data)

local total = get_total(commands)
print(total)
