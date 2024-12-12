local filename = "q8.in.txt"

local function printMap(m)
    for _, row in pairs(m) do
        for _, v in pairs(row) do
            io.write(v)
        end
        io.write("\n")
    end
end

local function getInput(fname)
    local f = assert(io.open(fname), "r")
    f:close()

    local output = {}
    for line in io.lines(fname) do
        output[#output+1] = {}
        for i = 1, #line do
            table.insert(output[#output], string.sub(line, i, i))
        end
    end
    return output
end

local function getAntennas(m)
    local antennas = {}
    for i, l in pairs(m) do
        for j, v in pairs(l) do
            if v == "." then goto continue end

            if antennas[v] ~= nil then table.insert(antennas[v], {i, j})
            else antennas[v] = {{i, j}} end

            ::continue::
        end
    end
    return antennas
end

local function getPoint(m, x1, y1, x)
    return m * (x - x1) + y1
end

local function placeAntinodes(m, p1, p2)
    local antinodes = {}
    for i, row in pairs(m) do
        antinodes[i] = {}
        for j, v in pairs(row) do
            antinodes[i][j] = v
        end
    end
    local ROWS, COLS = #antinodes, #antinodes[1]
    local x1, y1 = p1[2], p1[1]
    local x2, y2 = p2[2], p2[1]

    for i = 1, COLS do
        local slope = ((y1 - y2) / (x1 - x2))
        local ax, ay = i, getPoint(slope, x1, y1, i)
        local ayIsWholeNum = ay == math.floor(ay)
        if (ayIsWholeNum and
            1 <= ax and ax <= COLS and
            1 <= ay and ay <= ROWS)
        then
            antinodes[ay][ax] = "#"
        end
    end

    return antinodes
end

local function getAntinodes(m, a)
    local ROWS, COLS = #m, #m[1]
    local antinodes = {}
    for i = 1, ROWS do
        antinodes[i] = {}
        for j = 1, COLS do
            antinodes[i][j] = m[i][j]
        end
    end

    for _, points in pairs(a) do
        for i = 1, #points do
            for j = i + 1, #points do
                antinodes = placeAntinodes(antinodes, points[i], points[j])
            end
        end
    end

    return antinodes
end

local function countUniqueAntinodes(m)
    local count = 0
    for _, row in pairs(m) do
        for _, v in pairs(row) do
            if v == "#" then count = count + 1 end
        end
    end
    return count
end

local map = getInput(filename)
local antennas = getAntennas(map)
local antinodes = getAntinodes(map, antennas)
printMap(antinodes)
print(countUniqueAntinodes(antinodes))
