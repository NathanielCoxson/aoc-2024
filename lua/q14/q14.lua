local inputFile = "q14.in.txt"
local numRows, numCols = 103, 101

local function printTable2D(t)
    for i, _ in pairs(t) do
        for j, _ in pairs(t[i]) do
            if t[i][j] ~= 0 then io.write(t[i][j], "")
            else io.write(".") end
        end
        io.write("\n")
    end
end

local function getData(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local robots = {}
    local pattern = "p=(%d+),(%d+) v=([+-]?%d+),([+-]?%d+)"
    for line in io.lines(filename) do
        for x, y, dx, dy in string.gmatch(line, pattern) do
            robots[#robots+1] = {tonumber(x), tonumber(y), tonumber(dx), tonumber(dy)}
        end
    end
    return robots
end

local function getMap(ROWS, COLS, robots)
    local map = {}
    for i = 1, ROWS do
        map[i] = {}
        for j = 1, COLS do
            map[i][j] = 0
        end
    end
    for _, r in pairs(robots) do
        local x, y = r[1] + 1, r[2] + 1
        map[y][x] = map[y][x] + 1
    end
    return map
end

local function update(ROWS, COLS, robots)
    for _, r in pairs(robots) do
        local x, y, dx, dy = r[1], r[2], r[3], r[4]

        x = (x + dx) % COLS
        y = (y + dy) % ROWS

        r[1] = x
        r[2] = y
    end
end

local function getSafetyFactor(map)
    local rows, cols = #map, #map[1]
    local q1, q2, q3, q4 = 0, 0, 0, 0
    local br, bc = rows // 2 + 1, cols // 2 + 1
    for i = 1, rows do
        for j = 1, cols do
            if     (i < br and j < bc) then q1 = q1 + map[i][j]
            elseif (i < br and j > bc) then q2 = q2 + map[i][j]
            elseif (i > br and j < bc) then q3 = q3 + map[i][j]
            elseif (i > br and j > bc) then q4 = q4 + map[i][j]
            end
        end
    end
    print(q1, q2, q3, q4)
    return q1 * q2 * q3 * q4
end

local function unique(map)
    for i, _ in pairs(map) do
        for j, _ in pairs(map[i]) do
            if map[i][j] > 1 then return false end
        end
    end
    return true
end

local robots = getData(inputFile)
--for _ = 1, 100 do update(numRows, numCols, robots) end
--local map = getMap(numRows, numCols, robots)
--print(getSafetyFactor(map))

local second = 1
while true do
    update(numRows, numCols, robots)
    local map = getMap(numRows, numCols, robots)
    if unique(map) then
        printTable2D(map)
        print(second)
        break
    end
    print(second)
    second = second + 1
end
