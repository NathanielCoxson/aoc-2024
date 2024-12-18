local inputFile = "q15.in.txt"

local function printMap(m)
    for i, _ in pairs(m) do
        for j, _ in pairs(m[i]) do
            io.write(m[i][j])
        end
        io.write("\n")
    end
end

local function getData(filename)
    local file = assert(io.open(filename))
    file:close()

    local readingMap = true
    local map = {}
    local instructions = {}
    for line in io.lines(filename) do
        _, _, line = string.find(line, "([^s]+)")
        if line ~= nil then
            if readingMap then
                map[#map+1] = {}
                for i = 1, #line do
                    map[#map][i] = string.sub(line, i, i)
                end
            else
                for i = 1, #line do
                    instructions[#instructions+1] = string.sub(line, i, i)
                end
            end
        else readingMap = false end
    end
    return { map, instructions }
end

local function getRobotPosition(map)
    for i, _ in pairs(map) do
        for j, _ in pairs(map[i]) do
            if map[i][j] == "@" then return {i, j} end
        end
    end
    return {-1, -1}
end

local function runInstructions(map, instructions)
    local ROWS, COLS = #map, #map[1]
    local pos = getRobotPosition(map)
    for _, op in pairs(instructions) do
        local dir = {0, 0}
        if     op == ">" then dir = { 0,  1}
        elseif op == "<" then dir = { 0, -1}
        elseif op == "^" then dir = {-1,  0}
        elseif op == "v" then dir = { 1,  0}
        else goto continue end

        local i, j = pos[1], pos[2]
        while (1 <= i and i <= ROWS) and (1 <= j and j <= COLS) do
            if map[i][j] == "." then
                map[i][j] = "O"

                map[pos[1]][pos[2]] = "."
                pos[1] = pos[1] + dir[1]
                pos[2] = pos[2] + dir[2]
                map[pos[1]][pos[2]] = "@"

                break
            elseif map[i][j] == "#" then break end
            i = i + dir[1]
            j = j + dir[2]
        end

        ::continue::
    end
end

local function calculateGPSSum(map)
    local sum = 0
    for i, _ in pairs(map) do
        for j, _ in pairs(map[i]) do
            if map[i][j] == "O" then
                sum = sum + (100 * (i - 1) + (j - 1))
            end
        end
    end
    return sum
end

local function calculateGPSSum2(map)
    local sum = 0
    for i, _ in pairs(map) do
        for j, _ in pairs(map[i]) do
            if map[i][j] == "[" then
                sum = sum + (100 * (i - 1) + (j - 1))
            end
        end
    end
    return sum
end

local function getPart2Map(map)
    local newMap = {}
    for i, _ in pairs(map) do
        newMap[i] = {}
        for j, _ in pairs(map[i]) do
            if map[i][j] == "#" then
                newMap[i][#newMap[i]+1] = "#"
                newMap[i][#newMap[i]+1] = "#"
            elseif map[i][j] == "." then
                newMap[i][#newMap[i]+1] = "."
                newMap[i][#newMap[i]+1] = "."
            elseif map[i][j] == "O" then
                newMap[i][#newMap[i]+1] = "["
                newMap[i][#newMap[i]+1] = "]"
            elseif map[i][j] == "@" then
                newMap[i][#newMap[i]+1] = "@"
                newMap[i][#newMap[i]+1] = "."
            end
        end
    end
    return newMap
end

local function dfs(map, pos, dir)
    local ROWS, COLS = #map, #map[1]
    local row, col = pos[1], pos[2]
    if map[row+dir][col] == "#" then return map
    elseif map[row+dir][col] == "." then
        map[row+dir][col] = "@"
        map[row][col] = "."
        pos = {row+dir, col}
        return map
    end

    local visited = {}
    for i = 1, ROWS do
        visited[i] = {}
        for j = 1, COLS do
            visited[i][j] = false
        end
    end
    visited[row][col] = true

    local stack = {}
    if     map[row+dir][col] == "]" then
        stack[#stack+1] = {{row+dir, col - 1}, {row+dir, col}}
        visited[row+dir][col-1] = true
        visited[row+dir][col] = true
        if map[row+dir][col-1] == "#" or map[row+dir][col] == "#" then return map end
    elseif map[row+dir][col] == "[" then
        stack[#stack+1] = {{row+dir, col}, {row+dir, col + 1}}
        visited[row+dir][col] = true
        visited[row+dir][col+1] = true
        if map[row+dir][col+1] == "#" or map[row+dir][col] == "#" then return map end
    end
    while #stack > 0 do
        local state = table.remove(stack, #stack)
        local r1, c1, r2, c2 = state[1][1], state[1][2], state[2][1], state[2][2]
        local lhs, rhs = map[r1+dir][c1], map[r2+dir][c2]

        if lhs == "#" or rhs == "#" then return map end
        if lhs == "." and rhs == "." then goto continue end
        if lhs == "]" then
            stack[#stack+1] = {{r1+dir, c1-1}, {r1+dir, c1}}
            visited[r1+dir][c1-1] = true
            visited[r1+dir][c1] = true
        end
        if rhs == "[" then
            stack[#stack+1] = {{r2+dir, c2}, {r2+dir, c2+1}}
            visited[r2+dir][c2+1] = true
            visited[r2+dir][c2] = true
        end
        if lhs == "[" then
            stack[#stack+1] = {{r1+dir, c1}, {r2+dir, c2}}
            visited[r1+dir][c1] = true
            visited[r2+dir][c2] = true
        end
        ::continue::
    end
    if dir == -1 then
        for i, _ in pairs(visited) do
            for j, _ in pairs(visited[i]) do
                if visited[i][j] then
                    local temp = map[i][j]
                    map[i][j] = map[i+dir][j]
                    map[i+dir][j] = temp
                end
            end
        end
    else
        for i = #visited, 1, -1 do
            for j, _ in pairs(visited[i]) do
                if visited[i][j] then
                    local temp = map[i][j]
                    map[i][j] = map[i+dir][j]
                    map[i+dir][j] = temp
                end
            end
        end
    end
    return map
end

local function runInstructions2(map, instructions)
    local ROWS, COLS = #map, #map[1]
    local pos = getRobotPosition(map)
    for _, op in pairs(instructions) do
        if     op == ">" then
            if pos[2] < COLS and map[pos[1]][pos[2] + 1] == "." then
                map[pos[1]][pos[2]] = "."
                map[pos[1]][pos[2] + 1] = "@"
                pos = {pos[1], pos[2] + 1}
            else
                for col = pos[2], COLS do
                    if map[pos[1]][col] == "#" then break end
                    if map[pos[1]][col] == "." then
                        for i = col, pos[2] + 1, -1 do
                            local temp = map[pos[1]][i]
                            map[pos[1]][i] = map[pos[1]][i - 1]
                            map[pos[1]][i - 1] = temp
                        end
                        pos[2] = pos[2] + 1
                        break
                    end
                end
            end
        elseif op == "<" then
            if pos[2] > 1 and map[pos[1]][pos[2] - 1] == "." then
                map[pos[1]][pos[2]] = "."
                map[pos[1]][pos[2] - 1] = "@"
                pos = {pos[1], pos[2] - 1}
            else
                for col = pos[2], 1, -1 do
                    if map[pos[1]][col] == "#" then break end
                    if map[pos[1]][col] == "." then
                        for i = col, pos[2] - 1 do
                            local temp = map[pos[1]][i]
                            map[pos[1]][i] = map[pos[1]][i + 1]
                            map[pos[1]][i + 1] = temp
                        end
                        pos[2] = pos[2] - 1
                        break
                    end
                end
            end
        elseif op == "^" then
            if pos[1] > 1 and map[pos[1] - 1][pos[2]] == "." then
                map[pos[1]][pos[2]] = "."
                map[pos[1] - 1][pos[2]] = "@"
                pos = {pos[1] - 1, pos[2]}
            else
                dfs(map, pos, -1)
                pos = getRobotPosition(map)
            end
        elseif op == "v" then
            if pos[1] < ROWS and map[pos[1] + 1][pos[2]] == "." then
                map[pos[1]][pos[2]] = "."
                map[pos[1] + 1][pos[2]] = "@"
                pos = {pos[1] + 1, pos[2]}
            else
                dfs(map, pos, 1)
                pos = getRobotPosition(map)
            end
        end
    end
end

local data = getData(inputFile)
local map, instructions = data[1], data[2]
local map2 = getPart2Map(map)

-- Part 1
runInstructions(map, instructions)
--printMap(map)
print(calculateGPSSum(map))

-- Part 2
runInstructions2(map2, instructions)
--printMap(map2)
print(calculateGPSSum2(map2))
