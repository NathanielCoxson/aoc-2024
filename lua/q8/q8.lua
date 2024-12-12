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
                local x1, y1 = points[i][2], points[i][1]
                local x2, y2 = points[j][2], points[j][1]
                local dx, dy = math.abs(x1 - x2), math.abs(y1 - y2)


                local ax1, ay1, ax2, ay2
                if x1 <= x2 then
                    ax1 = x1 - dx
                    ax2 = x2 + dx
                else
                    ax1 = x1 + dx
                    ax2 = x2 - dx
                end
                if y1 <= y2 then
                    ay1 = y1 - dy
                    ay2 = y2 + dy
                else
                    ay1 = y1 + dy
                    ay2 = y2 - dy
                end

                if (1 <= ax1 and ax1 <= COLS and
                    1 <= ay1 and ay1 <= ROWS)
                then
                    antinodes[ay1][ax1] = "#"
                end
                if (1 <= ax2 and ax2 <= COLS and
                    1 <= ay2 and ay2 <= ROWS)
                then
                    antinodes[ay2][ax2] = "#"
                end
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
print(countUniqueAntinodes(antinodes))
