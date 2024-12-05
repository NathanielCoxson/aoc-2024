local function getLines(filename)
    local f = assert(io.open(filename, "r"))
    local data = {}

    io.input(f)

    for line in io.lines() do
        local l = {}
        for char in string.gmatch(line, "%a") do
            table.insert(l, char)
        end
        table.insert(data, l)
    end

    f:close()

    return data
end

-- Part 1
local function dfs(t, r, c, word)
    assert(#t > 0, "Empty table")

    local ROWS = #t
    local COLS = #t[1]
    local result = 0
    local dirs = {
        { 1,  0},
        { 0,  1},
        {-1,  0},
        { 0, -1},
        { 1,  1},
        {-1, -1},
        {-1,  1},
        { 1, -1}
    }

    for _, d in pairs(dirs) do
        local dr, dc = d[1], d[2]
        local row, col = r, c
        local currWord = t[r][c]

        while #currWord < #word do
            if (1 <= row + dr and row + dr <= ROWS and
                1 <= col + dc and col + dc <= COLS)
            then
                currWord = currWord .. t[row + dr][col + dc]
                row = row + dr
                col = col + dc
            else break end
        end
        if currWord == word then
            result = result + 1
        end
    end
    return result
end

local lines = getLines("q4.in.txt")
local targetWord = "XMAS"
local output = 0
for row, line in pairs(lines) do
    for col, char in pairs(line) do
        if char == string.sub(targetWord, 1, 1) then
            output = output + dfs(lines, row, col, targetWord)
        end
    end
end
print(output)

-- Part 2
local function xMAS(t, r, c)
    local ROWS = #t
    local COLS = #t[1]
    if r < 2 or r > ROWS - 1 or c < 2 or c > COLS - 1 then return false end

    local left  = t[r-1][c-1] .. t[r][c] .. t[r+1][c+1]
    local right = t[r-1][c+1] .. t[r][c] .. t[r+1][c-1]
    if left  ~= "MAS" and string.reverse(left)  ~= "MAS" then return false end
    if right ~= "MAS" and string.reverse(right) ~= "MAS" then return false end
    return true
end

output = 0
for row, line in pairs(lines) do
    for col, char in pairs(line) do
        if char == "A" and xMAS(lines, row, col) then output = output + 1 end
    end
end
print(output)
