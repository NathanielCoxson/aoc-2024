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
                newSeen[neighbor] = true
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

local function union(a, b)
    local result = {}
    for n, _ in pairs(a) do
        result[n] = true
    end
    for n, _ in pairs(b) do
        result[n] = true
    end
    return result
end

local function intersection(a, b)
    local result = {}
    for n, _ in pairs(a) do
        if b[n] ~= nil then result[n] = true end
    end
    for n, _ in pairs(b) do
        if a[n] ~= nil then result[n] = true end
    end
    return result
end

local function complement(a, b)
    local result = {}
    for n, _ in pairs(a) do
        if b[n] == nil then result[n] = true end
    end
    return result
end

local max = {}
local maxLength = 0
local graph = getInput(inputFile)
local groups = getGroups(graph)
local vertices = {}
for v, _ in pairs(graph) do vertices[v] = true end

-- Algorithm used s Bron-Kerbosch algorithm
-- to find maximally connected subsets of an undirected graph
-- found here:
-- https://en.wikipedia.org/wiki/Bron%E2%80%93Kerbosch_algorithm
local function getLargestGroup(R, P, X)
    if getLength(P) == 0 and getLength(X) == 0 then
        if getLength(R) > maxLength then
            maxLength = getLength(R)
            max = copyList(R)
        end
    end

    for v, _ in pairs(P) do
        getLargestGroup(union(R, {[v]=true}), intersection(P, graph[v]), intersection(X, graph[v]))
        P = complement(P, {[v]=true})
        X = union(X, {[v]=true})
    end
end


-- Part 1
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

-- Part 2
getLargestGroup({}, vertices, {})
local part2 = {}
for v, _ in pairs(max) do
    part2[#part2+1] = v
end
table.sort(part2)

io.write("Part 2: ")
for i, v in pairs(part2) do
    io.write(v)
    if i ~= #part2 then io.write(",") end
end
io.write("\n")
