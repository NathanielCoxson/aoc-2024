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
                local _, _, index2 = string.find(remap[b], "(%d+)")
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
                    io.write(remap[inst["a"]], " ", inst["a"], " | ")
                    io.write(inst["op"], " | ")
                    io.write(remap[inst["b"]], " ", inst["b"], " | ")
                    io.write(remap[inst["c"]], " ", inst["c"], " | ")

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
print("actual: ", part1)
print("expected: ", x + y)

-- For part two, look at bitwise difference between actual and expected outputs
-- and expand on the gate with the name "z" + bit index to debug the wiring.
-- Use a diagram of a full adder to diagnose the errors
print()
input = getInput(utils.getData(inputFile))
local renamed = renameSimulation(input["gates"], utils.copyTable(input["instructions"]))
expandGate(utils.copyTable(renamed), utils.copyTable(input["instructions"]), "z35", true)

--[[
-- Gates to swap:
-- On z8: gvw qjb
-- On z15: z15 jgc
-- On z22: z22 drg 
-- On z35: z35 jbp
--]]

local part2 = {
    "gvw", "qjb",
    "z15", "jgc",
    "z22", "drg",
    "z35", "jbp"
}
table.sort(part2)
for i, name in pairs(part2) do
    io.write(name)
    if i ~= #part2 then io.write(",") end
end
io.write("\n")
