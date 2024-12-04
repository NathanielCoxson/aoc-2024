local function get_numbers(filename)
    local file = io.open(filename, "r")
    local reports = {}
    if file ~= nil then
        io.input(file)
    else
        print("File does not exist")
        return reports
    end

    for line in io.lines() do
        local report = {}
        for num in string.gmatch(line, "[^%s]+") do
            table.insert(report, tonumber(num))
        end
        table.insert(reports, report)
    end

    return reports
end

local function removeAt(arr, index)
    local newArr = {}
    for k, v in pairs(arr) do
        if k ~= index then newArr[#newArr+1] = v end
    end
    return newArr
end
local function copyTable(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

local MAX_DIFF = 3
local function isSafe(report)
    local prev       = nil
    local decreasing = false

    for i, level in pairs(report) do
        if prev == nil then prev = level goto continue end

        if i == 2 and level < prev then decreasing = true end

        if prev == level then return false end

        if decreasing and level > prev then return false
        elseif not decreasing and level < prev then return false
        elseif math.abs(level - prev) > MAX_DIFF then return false
        end

        prev = level

        ::continue::
    end
    return true
end


local function countSafeReports(r)
    local safe_count = 0
    for _, report in pairs(r) do
        if isSafe(report) then safe_count = safe_count + 1
        else
            for i, _ in pairs(report) do
                local copy = copyTable(report)
                if isSafe(removeAt(copy, i)) then
                    safe_count = safe_count + 1
                    break
                end
            end
        end
    end
    return safe_count
end

local reports = get_numbers("q2.in.txt")
print(countSafeReports(reports))
