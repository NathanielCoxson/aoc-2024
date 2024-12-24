local inputFile = "q20.in.txt"

local function printMap(m)
    for i, _ in pairs(m) do
        for j, _ in pairs(m[i]) do
            io.write(m[i][j][1],":",m[i][j][2], "\t")
        end
        io.write("\n")
    end
end

local function getMap(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local map = {}
    for line in io.lines(filename) do
        map[#map+1] = {}
        for i = 1, #line do
            map[#map][i] = string.sub(line, i, i)
        end
    end
    return map
end

local function findChar(m, c)
    for i = 1, #m do
        for j = 1, #m[i] do
            if m[i][j] == c then return {i, j}
            end
        end
    end
    return {-1, -1}
end

local function getDistMap(m)
    local ROWS, COLS = #m, #m[1]
    local startPos = findChar(m, "S")
    local endPos   = findChar(m, "E")
    local distMap = {}
    for i = 1, ROWS do
        distMap[i] = {}
        for j = 1, COLS do
            distMap[i][j] = {m[i][j], 0}
        end
    end
    distMap[startPos[1]][startPos[2]] = {0, 0}

    local p = {startPos[1], startPos[2]}
    local dirs = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}}

    while p[1] ~= endPos[1] or p[2] ~= endPos[2] do
        for i, dir in pairs(dirs) do
            local dr, dc = p[1] + dir[1], p[2] + dir[2]

            if (1 <= dr and dr <= ROWS and
                1 <= dc and dc <= COLS and
                distMap[dr][dc][1] == "." or distMap[dr][dc][1] == "E")
            then
                distMap[p[1]][p[2]][2] = i
                distMap[dr][dc] = {distMap[p[1]][p[2]][1] + 1, distMap[p[1]][p[2]][2]}
                p = {dr, dc}
            end
        end
    end
    return distMap
end

local function findCheats(m)
    local ROWS, COLS = #m, #m[1]
    local distMap = getDistMap(m)
    local endPos = findChar(m, "E")
    local maxDist = distMap[endPos[1]][endPos[2]][1]
    local cheats = {}

    local dirs = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}}
    for i = 1, ROWS do
        for j = 1, COLS do
            if m[i][j] == "#" then
                for _, dir in pairs(dirs) do
                    local dr, dc   = i + dir[1], j + dir[2]
                    local idr, idc = i + (-1 * dir[1]), j + (-1 * dir[2])
                    if (1 <= dr and dr <= ROWS and
                        1 <= dc and dc <= COLS and
                        1 <= idr and idr <= ROWS and
                        1 <= idc and idc <= COLS and
                        m[dr][dc] ~= "#" and m[idr][idc] ~= "#")
                    then
                        local newDist = maxDist - math.abs(distMap[dr][dc][1] - distMap[idr][idc][1]) + 2
                        --io.write(newDist, " ", distMap[dr][dc][1], " ", distMap[idr][idc][1], " ", "(", dr, ",", dc, ")", "(", i, ",", j, ")", "(", idr, ",", idc, ")", "\n")

                        if cheats[maxDist - newDist] == nil then cheats[maxDist - newDist] = 0 end
                        cheats[maxDist - newDist] = cheats[maxDist - newDist] + 1
                    end
                end
            end
        end
    end
    for i, c in pairs(cheats) do cheats[i] = cheats[i] // 2 end
    return cheats
end

local map = getMap(inputFile)
local cheats = findCheats(map)
local minTimeSave = 100
local count = 0
for dt, c in pairs(cheats) do
    if dt >= minTimeSave then count = count + c end
end
print("Part 1:", count)
