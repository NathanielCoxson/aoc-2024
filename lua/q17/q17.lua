local inputFile = "q17.in2.txt"

local function getInput(filename)
    local file = assert(io.open(filename, "r"))
    file:close()

    local A, B, C = 0, 0, 0
    local program = {}
    local registerPattern = "Register ([ABC]): (%d+)"
    for line in io.lines(filename) do
        if line:sub(1,1) == "R" then
            local _, _, R, N = line:find(registerPattern)
            N = tonumber(N)
            if type(N) == "number" then
                if R == "A" then A = N
                elseif R == "B" then B = N
                elseif R == "C" then C = N
                end
            end
        elseif line:sub(1,1) == "P" then
            for opcode, operand in line:gmatch("(%d+)[^%d]+(%d+)") do
                program[#program+1] = {tonumber(opcode), tonumber(operand)}
            end
        end
    end
    return {A, B, C, program}
end

local function getComboOperand(A, B, C, operand)
    if (0 <= operand and operand <= 3) or operand == 7 then return operand
    elseif operand == 4 then return A
    elseif operand == 5 then return B
    elseif operand == 6 then return C
    end
end

local function runProgram(input)
    local A, B, C = input[1], input[2], input[3]
    local program = input[4]
    local output = {}
    local ptr = 1

    while 1 <= ptr and ptr <= #program do
        local instruction = program[ptr]
        local opcode, operand = instruction[1], instruction[2]
        local jumped = false

        if     opcode == 0 then
            local comboOperand = getComboOperand(A, B, C, operand)
            A = math.floor(A / (2^comboOperand))
        elseif opcode == 1 then
            B = B ~ operand
        elseif opcode == 2 then
            local comboOperand = getComboOperand(A, B, C, operand)
            B = comboOperand % 8
        elseif opcode == 3 then
            if A ~= 0 then
                ptr = operand + 1
                jumped = true
            end
        elseif opcode == 4 then
            B = B ~ C
        elseif opcode == 5 then
            local comboOperand = getComboOperand(A, B, C, operand)
            output[#output+1] = comboOperand % 8
        elseif opcode == 6 then
            local comboOperand = getComboOperand(A, B, C, operand)
            B = math.floor(A / (2^comboOperand))
        elseif opcode == 7 then
            local comboOperand = getComboOperand(A, B, C, operand)
            C = math.floor(A / (2^comboOperand))
        end

        if not jumped then ptr = ptr + 1 end
        --print(ptr, opcode, operand, A, B, C)
    end

    --print("Output:")
    --print("A: ", A, "B: ", B, "C: ", C)
    local result = ""
    for i, n in pairs(output) do
        result = result .. n
        --io.write(n)
        if i ~= #output then
            --result = result .. ","
            --io.write(",")
        end
    end

    return result
end

-- Take lowest 3 bits of A store them in B
-- XOR B with 2 and store in B
-- Right shift A by B and store in C
-- XOR B with C and store in B
-- XOR B with 3 and store in B
-- Output lowest 3 bits of B
-- Shift A by 3 and store in A
-- Jump to 0

local function findA(target, input)
    local ras = {}
    for i = 0, 7 do
        input[1] = i
        local output = runProgram(input)
        if output == string.sub(target, #target - #output + 1, #target) then
            ras[#ras+1] = i
        end
    end

    local octal_digit_count = 1
    while octal_digit_count < 16 do
        local new_ras = {}
        for _, a in pairs(ras) do
            a = a * 8
            for i = 0, 7 do
                input[1] = a + i
                local output = runProgram(input)
                if output == string.sub(target, #target - #output + 1, #target) then
                    new_ras[#new_ras+1] = a + i
                end
            end
        end
        ras = {}
        for _, d in pairs(new_ras) do ras[#ras+1] = d end
        octal_digit_count = octal_digit_count + 1
    end

    local min = math.huge
    for _, d in pairs(ras) do
        min = math.min(min, d)
    end
    return min
end

local input = getInput(inputFile)
local target = ""
for _, inst in pairs(input[4]) do
    target = target .. inst[1]
    target = target .. inst[2]
end

local output = runProgram(getInput("q17.in.txt"))
local result = ""
for i = 1, #output do
    result = result .. string.sub(output, i, i)
    if i ~= #output then result = result .. "," end
end
print("Part 1:", result)
print("Part 2:", findA(target, input))
