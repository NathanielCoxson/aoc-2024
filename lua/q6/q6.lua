local function getLines(filename)
    local file = assert(io.open(filename, "r"))
    if file then file:close()
    else return {} end

    local lines = {}
    for line in io.lines(filename) do
        lines[#lines + 1] = line
    end
    return lines
end

local function getMap(lines)
    local map = {}

    for i, line in pairs(lines) do
        map[i] = {}
        for j = 1, #line do
            map[i][j] = string.sub(line, j, j)
        end
    end

    return map
end

local function getStartingPoint(m)
    for i, r in pairs(m) do
        for j, c in pairs(r) do
            if     c == "^" then return {i, j, 0}
            elseif c == ">" then return {i, j, 1}
            elseif c == "v" then return {i, j, 2}
            elseif c == "<" then return {i, j, 3}
            end
        end
    end
end

local function dfs(m, r, c, d)
    local ROWS, COLS = #m, #m[1]
    local map = m
    local stack = {{r, c}}

    while #stack > 0 do
        local row, col = stack[#stack][1], stack[#stack][2]
        map[row][col] = "X"
        table.remove(stack, #stack)

        local dr, dc = row, col
        if     d == 0 then dr = dr - 1
        elseif d == 1 then dc = dc + 1
        elseif d == 2 then dr = dr + 1
        elseif d == 3 then dc = dc - 1 end

        if (1 <= dr and dr <= ROWS and
            1 <= dc and dc <= COLS and
            map[dr][dc] ~= "#")
        then
            stack[#stack + 1] = {dr, dc}
        elseif (1 <= dr and dr <= ROWS and
                1 <= dc and dc <= COLS and
                map[dr][dc] == "#")
        then
            d = (d + 1) % 4
            stack[#stack + 1] = {row, col}
        else return map end
    end
    return map
end

local function countVisited(m)
    local count = 0
    for _, r in pairs(m) do
        for _, c in pairs(r) do
            if c == "X" then count = count + 1 end
        end
    end
    return count
end

local lines = getLines("q6.in.txt")
local map = getMap(lines)
local startingPoint = getStartingPoint(map)
local row, col, dir = startingPoint[1], startingPoint[2], startingPoint[3]
local coverageMap = dfs(map, row, col, dir)
for _, r in pairs(coverageMap) do
    for _, c in pairs(r) do
        io.write(c)
    end
    io.write("\n")
end
print(countVisited(coverageMap))
