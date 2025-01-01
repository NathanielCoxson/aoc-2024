package.path = package.path .. ";../?.lua"
local utils = require("utils")

local inputFile = "q24.in.txt"

local function getInput(data)
    local readingGates = true
    local gates = {}
    local instructions = {}

    local gatePattern = "([%l%d][%l%d][%l%d])"
    local instPattern = "([%l%d][%l%d][%l%d]) (%a+) ([%l%d][%l%d][%l%d]).+([%l%d][%l%d][%l%d])"

    for _, line in pairs(data) do
        if line == "" then
            readingGates = false
            goto continue
        end

        if readingGates then
            local _, _, name = string.find(line, gatePattern)
            local _, _, value = string.find(line, ": ([01])")
            value = tonumber(value)

            gates[name] = value
        else
            local _, _, a, op, b, c = string.find(line, instPattern)
            instructions[#instructions+1] = {
                ["a"] = a,
                ["b"] = b,
                ["c"] = c,
                ["op"] = op
            }
        end

        ::continue::
    end

    return { ["gates"]=gates, ["instructions"]=instructions }
end

local function renameSimulation(gates, instructions)
    local renamed = {}
    local remap = {}
    while #instructions > 0 do
        for i = #instructions, 1, -1 do
            local inst = instructions[i]
            local a, b, c = inst["a"], inst["b"], inst["c"]
            local op = inst["op"]

            if gates[a] == nil or gates[b] == nil then
                goto continue
            end

            print(a,b, c,op)

            if op == "OR" then
                gates[c] = gates[a] | gates[b]
            elseif op == "AND" then
                gates[c] = gates[a] & gates[b]
            elseif op == "XOR" then
                gates[c] = gates[a] ~ gates[b]
            end

            renamed[i] = utils.copyTable(inst)
            table.remove(instructions, i)
            ::continue::
        end
    end
    return renamed
end

local function runSimulation(gates, instructions)
    while #instructions > 0 do
        for i = #instructions, 1, -1 do
            local inst = instructions[i]
            local a, b, c = inst["a"], inst["b"], inst["c"]
            local op = inst["op"]

            if gates[a] == nil or gates[b] == nil then
                goto continue
            end

            if op == "OR" then
                gates[c] = gates[a] | gates[b]
            elseif op == "AND" then
                gates[c] = gates[a] & gates[b]
            elseif op == "XOR" then
                gates[c] = gates[a] ~ gates[b]
            end


            table.remove(instructions, i)
            ::continue::
        end
    end
end

local function getSortedKeys(t)
    local keys = {}
    for key, _ in pairs(t) do
        keys[#keys+1] = key
    end
    table.sort(keys)
    return keys
end

local function getNumber(gates, pattern)
    local names = getSortedKeys(gates)
    local output = ""

    for _, name in pairs(names) do
        local _, _, found = string.find(name, pattern)
        if found ~= nil then
            output = gates[name] .. output
        end
    end

    return tonumber(output, 2)
end


local gateMap = {}
local function expandGate(instructions, name, enablePrint)
    local stack = {name}

    if enablePrint then
        if gateMap[name] == nil then print(name)
        else print(gateMap[name])
        end
    end
    while #stack > 0 do
        local state = table.remove(stack, #stack)

        for _, inst in pairs(instructions) do
            if inst["c"] == state then
                stack[#stack+1] = inst["a"]
                stack[#stack+1] = inst["b"]


                if enablePrint then
                    if gateMap[inst["a"]] == nil then io.write(inst["a"], " ")
                    else io.write(gateMap[inst["a"]], " ") end

                    io.write(inst["op"], " ")

                    if gateMap[inst["b"]] == nil then io.write(inst["b"], " ")
                    else io.write(gateMap[inst["b"]], " ") end

                    if gateMap[inst["c"]] == nil then io.write(inst["c"], " ")
                    else io.write(gateMap[inst["c"]], " ") end

                    io.write("\n")
                end
            end
        end
    end
end

local input = getInput(utils.getData(inputFile))
runSimulation(input["gates"], utils.copyTable(input["instructions"]))

local part1 = getNumber(input["gates"], "(z..)")
print("Part 1:", part1)

local x = getNumber(input["gates"], "(x..)")
print("x =", x)
local y = getNumber(input["gates"], "(y..)")
print("y =", y)
print("z =", part1)

print()
local renamed = renameSimulation(input["gates"], input["instructions"])
expandGate(utils.copyTable(renamed), "z01", true)
