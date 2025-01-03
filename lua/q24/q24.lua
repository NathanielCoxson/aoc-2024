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
    local remap = {}
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

            local aFirstChar = string.sub(a, 1, 1)
            local bFirstChar = string.sub(b, 1, 1)
            local cFirstChar = string.sub(c, 1, 1)

            local x_y_inputs = (aFirstChar == "x" and bFirstChar == "y") or (aFirstChar == "y" and bFirstChar == "x")
            if x_y_inputs and op == "XOR" then
                local aIndex = string.sub(a, 2, #a)
                local bIndex = string.sub(b, 2, #b)
                remap[c] = "S" .. aIndex
                remap[a] = aFirstChar .. aIndex
                remap[b] = bFirstChar .. bIndex
            elseif x_y_inputs and op == "AND" then
                local aIndex = string.sub(a, 2, #a)
                local bIndex = string.sub(b, 2, #b)
                remap[c] = "c" .. aIndex
                remap[a] = aFirstChar .. aIndex
                remap[b] = bFirstChar .. bIndex
            elseif remap[a] ~= nil and remap[b] ~= nil then
                local raFirstChar = string.sub(remap[a], 1, 1)
                local rbFirstChar = string.sub(remap[b], 1, 1)
                local _, _, index1 = string.find(remap[a], "(%d+)")
                local _, _, index2 = string.find(remap[a], "(%d+)")
                index1 = tonumber(index1)
                index2 = tonumber(index2)
                if type(index1) ~= "number" or type(index2) ~= "number" then goto continue end
                local maxIndex = math.max(index1, index2)

                local carrySum = op == "AND"
                local outputCarry = op == "OR"
                local outputBit = op == "XOR"

                if carrySum then remap[c] = "s" .. maxIndex
                elseif outputCarry then remap[c] = "C" .. maxIndex
                elseif outputBit then remap[c] = "z" .. maxIndex end
            end
            --print(a, op, b, remap[c])

            table.remove(instructions, i)
            ::continue::
        end
    end
    return remap
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


local function expandGate(remap, instructions, name, enablePrint)
    local stack = {name}
    local _, _, index = string.find(name, "(%d+)")
    index = tonumber(index)


    if enablePrint then
        if remap[name] == nil then print(name)
        else print(remap[name])
        end
    end
    while #stack > 0 do
        local state = table.remove(stack, #stack)


        for _, inst in pairs(instructions) do
            if inst["c"] == state then
                local _, _, leftIndex = string.find(remap[inst["a"]], "(%d+)")
                local _, _, rightIndex = string.find(remap[inst["b"]], "(%d+)")
                leftIndex = tonumber(leftIndex)
                rightIndex = tonumber(rightIndex)

                if leftIndex == index then stack[#stack+1] = inst["a"] end
                if rightIndex == index then stack[#stack+1] = inst["b"] end

                if enablePrint then
                    if remap[inst["a"]] == nil then io.write(inst["a"], " ")
                    else io.write(remap[inst["a"]], " ") end

                    io.write(inst["op"], " ")

                    if remap[inst["b"]] == nil then io.write(inst["b"], " ")
                    else io.write(remap[inst["b"]], " ") end

                    if remap[inst["c"]] == nil then io.write(inst["c"], " ")
                    else io.write(remap[inst["c"]], " ") end

                    io.write(leftIndex, ", ", rightIndex)
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
print("expected: ", x + y)

print()
input = getInput(utils.getData(inputFile))
local renamed = renameSimulation(input["gates"], utils.copyTable(input["instructions"]))
local numGates = 0
local numRemaped = 0
for _, _ in pairs(input["gates"]) do numGates = numGates + 1 end
for _, _ in pairs(renamed) do numRemaped = numRemaped + 1 end
local C2 = ""
for k, v in pairs(renamed) do if string.sub(v, 1, 1) == "C" then print(k,v) end end
print(C2)
expandGate(utils.copyTable(renamed), utils.copyTable(input["instructions"]), "z08", true)

