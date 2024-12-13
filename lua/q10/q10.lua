local inputFile = "q10.in.txt"
local function print2DList(l)
    for _, row in pairs(l) do
        for _, v in pairs(row) do
            io.write(v)
        end
        io.write("\n")
    end
end

local function getMap(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local lines = {}
    for line in io.lines(filename) do
        lines[#lines+1] = {}
        for i = 1, #line do
            lines[#lines][i] = tonumber(string.sub(line, i, i))
        end
    end
    return lines
end

local function dfs(m, row, col)
    assert(m[row][col] == 0, "Starting position is not 0")
    local ROWS, COLS = #m, #m[1]
    local stack = {{row, col, 0}}
    local dirs = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}}
    local visited = {}
    for i, _ in pairs(m) do
        visited[i] = {}
        for j, _ in pairs(m[i]) do
            visited[i][j] = false
        end
    end
    local count = 0

    while #stack > 0 do
        local state = table.remove(stack, #stack)
        local r, c, h = state[1], state[2], state[3]

        if h == 9 then count = count + 1
        else
            for _, dir in pairs(dirs) do
                local dr, dc = r + dir[1], c + dir[2]
                if (1 <= dr and dr <= ROWS and
                    1 <= dc and dc <= COLS and
                    visited[dr][dc] == false and
                    m[dr][dc] == h + 1)
                then
                    stack[#stack+1] = {dr, dc, h + 1}
                    visited[dr][dc] = true
                end
            end
        end
        --for _, s in pairs(stack) do
        --    io.write("{", s[1], ",", s[2], ",", s[3], "} ")
        --end
        --io.write(count, "\n")
    end
    return count
end

local function scoreTrailheads(m)
    local sum = 0
    for i, _ in pairs(m) do
        for j, _ in pairs(m[i]) do
            if m[i][j] == 0 then sum = sum + dfs(m, i, j) end
        end
    end
    return sum
end

local map = getMap(inputFile)
print(scoreTrailheads(map))
