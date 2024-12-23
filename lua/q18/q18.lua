local inputFile = "q18.in.txt"

local function printMap(m)
    for i, _ in pairs(m) do
        for j, _ in pairs(m[i]) do
            io.write(m[i][j], "\t")
        end
        io.write("\n")
    end
end

local function getBytes(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local pattern = "(%d+),(%d+)"
    local result = {}
    for line in io.lines(filename) do
        for x, y in string.gmatch(line, pattern) do
            result[#result+1] = {tonumber(y), tonumber(x)}
        end
    end
    return result
end

local function copyList(l)
    local copy = {}
    for i, _ in pairs(l) do
        copy[i] = {l[i][1], l[i][2]}
    end
    return copy
end

local function bfs(map)
    local rows, cols = #map, #map[1]
    local visited = {}
    for i = 1, rows do
        visited[i] = {}
        for j = 1, cols do
            visited[i][j] = false
        end
    end

    local dirs = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}}
    local q = { {1, 1, 0} }
    visited[1][1] = true

    while #q > 0 do
        local state = table.remove(q, 1)
        local row, col = state[1], state[2]
        local length = state[3]

        if row == rows and col == cols then return length end

        for _, dir in pairs(dirs) do
            local dr, dc = row + dir[1], col + dir[2]

            if (1 <= dr and dr <= rows and
                1 <= dc and dc <= cols and
                not visited[dr][dc] and
                map[dr][dc] ~= "#")
            then
                q[#q+1] = {dr, dc, length + 1}
                visited[dr][dc] = true
            end
        end
    end
    return -1
end

local bytes = getBytes(inputFile)

local rows, cols = 71, 71
local map = {}
for i = 1, rows do
    map[i] = {}
    for j = 1, cols do
        map[i][j] = "."
    end
end

for i, byte in pairs(bytes) do
    map[byte[1]+1][byte[2]+1] = "#"
    local pathLength = bfs(map)

    if i == 1024 then print("Part 1:", pathLength)
    elseif pathLength == -1 then
        print("Part 2:", byte[2]..","..byte[1])
        break
    end
end
