local inputFile = "q12.in.txt"

local function getLines(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local lines = {}
    for line in io.lines(filename) do
        lines[#lines+1] = line
    end
    return lines
end

local function getMap(l)
    local map = {}
    for i, line in pairs(l) do
        map[i] = {}
        for j = 1, #line do
            map[i][j] = string.sub(line, j, j)
        end
    end
    return map
end

local function printMap(m)
    for _, row in pairs(m) do
        for _, v in pairs(row) do
            io.write(v)
        end
        io.write("\n")
    end
end

local function createVisitedMap(r, c)
    local map = {}
    for i = 1, r do
        map[i] = {}
        for j = 1, c do
            map[i][j] = false
        end
    end
    return map
end

local function dfs(m)
    local ROWS, COLS = #m, #m[1]
    local visited = createVisitedMap(ROWS, COLS)

    local price = 0
    for i, _ in pairs(m) do
        for j, _ in pairs(m[i]) do
            if not visited[i][j] then
                local seen = createVisitedMap(ROWS, COLS)
                seen[i][j] = true
                local dirs = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}}
                local stack = {{i, j}}
                local area = 0
                local perimeter = 0

                while #stack > 0 do
                    local state = table.remove(stack, #stack)
                    local row, col = state[1], state[2]
                    area = area + 1

                    for _, dir in pairs(dirs) do
                        local dr, dc = row + dir[1], col + dir[2]
                        local inBounds = (1 <= dr and dr <= ROWS and
                                          1 <= dc and dc <= COLS)
                        if (inBounds and
                            m[dr][dc] == m[row][col] and
                            not seen[dr][dc])
                        then
                            stack[#stack+1] = {dr, dc}
                            visited[dr][dc] = true
                            seen[dr][dc] = true
                        elseif (inBounds and not seen[dr][dc]) or not inBounds then
                            perimeter = perimeter + 1
                        end
                    end
                end

                price = price + (area * perimeter)
                --print(price, area, perimeter, i, j)
            end
        end
    end
    return price
end

local function countSides(m, seen)
    local ROWS, COLS = #m, #m[1]
    local sides = 0

    -- Left to right vertical
    local side = false
    for col = 0, COLS - 1 do
        for row = 1, ROWS do
            local s = false
            if col == 0 then s = false
            elseif seen[row][col] then s = true end

            local isSide = not s and seen[row][col + 1]
            if not isSide then
                if side then sides = sides + 1 end
                side = false
            else side = true end
        end
    end
    if side then sides = sides + 1 end

    -- Right to left vertical
    side = false
    for col = COLS + 1, 2, -1 do
        for row = 1, ROWS do
            local s = false
            if col == COLS + 1 then s = false
            elseif seen[row][col] then s = true end

            local isSide = not s and seen[row][col - 1]
            if not isSide then
                if side then sides = sides + 1 end
                side = false
            else side = true end
        end
    end
    if side then sides = sides + 1 end

    -- Left to right horizontal
    side = false
    for row = 0, ROWS - 1 do
        for col = 1, COLS do
            local s = false
            if row == 0 then s = false
            elseif seen[row][col] then s = true end

            local isSide = not s and seen[row + 1][col]
            if not isSide then
                if side then sides = sides + 1 end
                side = false
            else side = true end
        end
    end
    if side then sides = sides + 1 end

    -- Right to left horizontal
    side = false
    for row = ROWS + 1, 2, -1 do
        for col = 1, COLS do
            local s = false
            if row == ROWS + 1 then s = false
            elseif seen[row][col] then s = true end

            local isSide = not s and seen[row - 1][col]
            if not isSide then
                if side then sides = sides + 1 end
                side = false
            else side = true end
        end
    end
    if side then sides = sides + 1 end
    return sides
end

local function dfs2(m)
    local ROWS, COLS = #m, #m[1]
    local visited = createVisitedMap(ROWS, COLS)

    local price = 0
    for i, _ in pairs(m) do
        for j, _ in pairs(m[i]) do
            if not visited[i][j] then
                local seen = createVisitedMap(ROWS, COLS)
                seen[i][j] = true
                local dirs = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}}
                local stack = {{i, j}}
                local area = 0
                local perimeter = 0

                while #stack > 0 do
                    local state = table.remove(stack, #stack)
                    local row, col = state[1], state[2]
                    area = area + 1

                    for _, dir in pairs(dirs) do
                        local dr, dc = row + dir[1], col + dir[2]
                        local inBounds = (1 <= dr and dr <= ROWS and
                                          1 <= dc and dc <= COLS)
                        if (inBounds and
                            m[dr][dc] == m[row][col] and
                            not seen[dr][dc])
                        then
                            stack[#stack+1] = {dr, dc}
                            visited[dr][dc] = true
                            seen[dr][dc] = true
                        elseif (inBounds and not seen[dr][dc]) or not inBounds then
                            perimeter = perimeter + 1
                        end
                    end
                end

                local sides = countSides(m, seen)
                price = price + (area * sides)
                --print(price, area, perimeter, i, j)
            end
        end
    end
    return price
end

local map = getMap(getLines(inputFile))
local price1 = dfs(map)
local price2 = dfs2(map)
print(price1, price2)
