local inputFile = "q23.in.txt"

local function getInput(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local lines = {}
    for line in io.lines(filename) do
        local _, _, a,b = string.find(line, "(%a+)-(%a+)")
        lines[#lines+1] = {a, b}
    end

    local graph = {}
    for _, pair in pairs(lines) do
       local a, b = pair[1], pair[2]
       if graph[a] == nil then graph[a] = {} end
       if graph[b] == nil then graph[b] = {} end
       graph[a][b] = true
       graph[b][a] = true
    end

    return graph
end

local function copyList(l)
    local copy = {}
    for k, v in pairs(l) do copy[k] = v end
    return copy
end

local function getLength(l)
    local length = 0
    for _, _ in pairs(l) do length = length + 1 end
    return length
end

local function getLocalGroups(g, p)
    local pathLength = 3
    local groups = {}
    local stack = {{ p, {p}, {[p]=true} }}

    while #stack > 0 do
        local state = table.remove(stack, #stack)
        local node, path, seen = state[1], state[2], state[3]
        local first, last = path[1], path[#path]

        if getLength(path) == pathLength then
            if g[first][last] ~= nil then
                groups[#groups+1] = copyList(path)
            end
            goto continue
        end

        for neighbor, _ in pairs(g[node]) do
            if seen[neighbor] == nil then
                local newPath = copyList(path)
                local newSeen = copyList(seen)
                newPath[#newPath+1] = neighbor
                seen[neighbor] = true
                stack[#stack+1] = {neighbor, copyList(newPath), copyList(newSeen)}
            end
        end

        ::continue::
    end

    return groups
end

local function getGroups(g)
    local groups = {}
    local seen = {}
    for p, _ in pairs(g) do
        for _, group in pairs(getLocalGroups(g, p)) do
            table.sort(group)
            local key = ""
            for i, n in pairs(group) do
                key = key .. n
                if i ~= #n then key = key .. "," end
            end
            if seen[key] == nil then groups[#groups+1] = copyList(group) end
            seen[key] = true
        end
    end
    return groups
end

local graph = getInput(inputFile)
local groups = getGroups(graph)

local part1 = 0
for _, g in pairs(groups) do
    for _, v in pairs(g) do
        if string.sub(v, 1, 1) == "t" then
            part1 = part1 + 1
            break
        end
    end
end
print("Part 1:", part1)
