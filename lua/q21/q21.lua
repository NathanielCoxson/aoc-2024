local inputFile = "q21.in.txt"
local enablePrint = true

local function getInput(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local codes = {}
    for line in io.lines(filename) do
        codes[#codes+1] = line
    end
    return codes
end

local function getNumpadMoveSequence(startVal, endVal)
    --[[
    -- 7 8 9
    -- 4 5 6
    -- 1 2 3
    -- _ 0 A
    --]]
    local output = ""

    local val_pos_map = {}
    val_pos_map["A"] = {4, 3}
    val_pos_map["0"]   = {4, 2}
    val_pos_map["1"]   = {3, 1}
    val_pos_map["2"]   = {3, 2}
    val_pos_map["3"]   = {3, 3}
    val_pos_map["4"]   = {2, 1}
    val_pos_map["5"]   = {2, 2}
    val_pos_map["6"]   = {2, 3}
    val_pos_map["7"]   = {1, 1}
    val_pos_map["8"]   = {1, 2}
    val_pos_map["9"]   = {1, 3}

    local startPos, endPos = val_pos_map[startVal], val_pos_map[endVal]
    local dy, dx = endPos[1] - startPos[1], endPos[2] - startPos[2]
    local ud, lr = "", ""

    if dy < 0 then
        for _ = -1, dy, -1 do
            ud = ud .. "^"
        end
    elseif dy > 0 then
        for _ = 1, dy do
            ud = ud .. "v"
        end
    end
    if dx < 0 then
        for _ = -1, dx, -1 do
            lr = lr .. "<"
        end
    elseif dx > 0 then
        for _ = 1, dx do
            lr = lr .. ">"
        end
    end

    if (endPos[2] > startPos[2] and not (endPos[1] == 4 and startPos[2] == 1)) then
        return ud .. lr .. "A"
    end
    if (not (startPos[1] == 4 and endPos[2] == 1)) then
        return lr .. ud .. "A"
    end
    return ud .. lr .. "A"
end

local function getDpadMoveSequence(startVal, endVal)
    --[[
    --   ^ A
    -- < v >
    --]]
    local output = ""

    local val_pos_map = {}
    val_pos_map["^"] = {1, 2}
    val_pos_map["A"] = {1, 3}
    val_pos_map["<"] = {2, 1}
    val_pos_map["v"] = {2, 2}
    val_pos_map[">"] = {2, 3}

    local startPos, endPos = val_pos_map[startVal], val_pos_map[endVal]
    local dy, dx = endPos[1] - startPos[1], endPos[2] - startPos[2]
    local ud, lr = "", ""

    if dy < 0 then
        for _ = -1, dy, -1 do
            ud = ud .. "^"
        end
    elseif dy > 0 then
        for _ = 1, dy do
            ud = ud .. "v"
        end
    end
    if dx < 0 then
        for _ = -1, dx, -1 do
            lr = lr .. "<"
        end
    elseif dx > 0 then
        for _ = 1, dx do
            lr = lr .. ">"
        end
    end

    if (endPos[2] > startPos[2] and not (endPos[1] == 1 and startPos[2] == 1)) then
        return ud .. lr .. "A"
    end
    if (not (startPos[1] == 1 and endPos[2] == 1)) then
        return lr .. ud .. "A"
    end
    return ud .. lr .. "A"
end

local function getNumericPartOfCode(code)
    local pattern = "[0]*(%d+)"
    local _, _, n = string.find(code, pattern)
    return tonumber(n)
end

local function getFrequencies(seq)
    local freq = {}
    for inst in string.gmatch(seq, "[^A]*A") do
        if freq[inst] == nil then freq[inst] = 0 end
        freq[inst] = freq[inst] + 1
    end
    return freq
end

local function part2(codes, numDirRobots)
    local complexity = 0
    for _, code in pairs(codes) do
        local sequence = ""
        local prev = "A"
        local frequencies = {}
        for i = 1, #code do
            local current = string.sub(code, i, i)
            sequence = sequence .. getNumpadMoveSequence(prev, current)
            prev = current
            frequencies = getFrequencies(sequence)
        end

        for _ = 1, numDirRobots do
            local subTable = {}
            for inst, freq in pairs(frequencies) do
                local subInst = ""
                local p = "A"
                for i = 1, #inst do
                    local current = string.sub(inst, i, i)
                    subInst = subInst .. getDpadMoveSequence(p, current)
                    p = current
                end

                for k, f in pairs(getFrequencies(subInst)) do
                    if subTable[k] == nil then subTable[k] = 0 end
                    subTable[k] = subTable[k] + f * freq
                end
            end
            frequencies = subTable
        end

        local length = 0
        for k, f in pairs(frequencies) do
            length = length + (#k * f)
        end
        complexity = complexity + (length * getNumericPartOfCode(code))
    end
    return complexity
end

local codes = getInput(inputFile)

local complexitySum = 0
for _, code in pairs(codes) do
    local step1 = ""
    local prev = "A"
    for i = 1, #code do
        local current = string.sub(code, i, i)
        step1 = step1 .. getNumpadMoveSequence(prev, current)
        prev = current
    end

    local step2 = ""
    prev = "A"
    for i = 1, #step1 do
        local current = string.sub(step1, i, i)
        step2 = step2 .. getDpadMoveSequence(prev, current)
        prev = current
    end

    local step3 = ""
    prev = "A"
    for i = 1, #step2 do
        local current = string.sub(step2, i, i)
        step3 = step3 .. getDpadMoveSequence(prev, current)
        prev = current
    end

    local length = #step3
    local num = getNumericPartOfCode(code)
    local complexity = length * num
    complexitySum = complexitySum + complexity
    if enablePrint then io.write(code, ": ", num, ",\t", length, ",\t", complexity, ",\t", step3, "\n") end
end
print("Part 1:", complexitySum)

local complexity = part2(codes, 25)
print("Part 2:", complexity)
